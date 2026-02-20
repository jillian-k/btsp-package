# Build Summary — BT-188 Participation Sync

**Ticket:** BT-188
**Date:** February 11–12, 2026

---

## Overview

This project enables participation rollup data to flow from BTSP affiliate Salesforce orgs to the National Salesforce org via a Make integration and platform event subscriber.

```
Affiliate Org (btsppackage)  →  Make Integration  →  National Org (btspdev)
BTSP_Participation__c           Publishes PE          Affiliate_Participation_Sync__e
                                                       ↓
                                                      Flow → Apex Handler
                                                       ↓
                                                      Participation__c (upsert)
```

---

## What Was Built

### 1. btsppackage — Participation Rollup Fields

**Org:** btsppackage | **Object:** `btsp1__BTSP_Participation__c`

| Item | Count |
|---|---|
| New rollup fields (Number 18,0) | 12 |
| New date field (`Last_Participation_Sync__c`) | 1 |
| Layout section ("Participation Rollups") | 1 |
| FLS grants (13 fields × 2 targets) | 26 |

All 12 rollup fields provide core vs. optional breakdowns for:
- 1:1 touchpoints (offered/attended)
- Communication touchpoints (offered/attended)
- Programming days (offered/attended)

`Last_Participation_Sync__c` tracks the date of the most recent sync with the National Org.

FLS granted to BTSP Participation permission set and System Administrator profile for all 13 fields (12 rollup + Last Participation Sync).

### 2. btspdev — National Participation Fields

**Org:** btspdev | **Object:** `Participation__c`

| Item | Count |
|---|---|
| Fields renamed (label + API name) | 4 |
| New rollup fields created | 8 |
| New date field (`Last_Participation_Sync__c`) | 1 |
| Permission set created ("BTSP Participation") | 1 |
| FLS grants (13 fields × 2 targets) | 26 |
| Layout reorganized ("Program Participation") | 1 |

### 3. btspdev — Platform Event

**Object:** `Affiliate_Participation_Sync__e`

| Item | Count |
|---|---|
| Rollup fields (Number 18,0) | 12 |
| Matching/key fields (Text) | 4 |
| Total PE fields | 16 |

Key fields: `Source_Contact_ID__c`, `Source_Org_ID__c`, `Term__c`, `Participation_ID__c`

### 4. btspdev — Affiliate Term Schema Updates

| Change | Object | Detail |
|---|---|---|
| Picklist value "Manual Review" | `Affiliate_Term__c.Term_Type__c` | Local picklist |
| Picklist value "Manual Review" | `Affiliate_Term__c.Term__c` | Term global value set |
| Picklist value "0000" | `Affiliate_Term__c.Year__c` | Program_Year global value set |

### 5. btspdev — Participation Schema Updates

| Change | Object | Detail |
|---|---|---|
| New field `Last_Participation_Sync__c` | `Participation__c` | Date, date of most recent sync from the BTSP Affiliate Org |
| New field `Source_Contact_ID__c` | `Participation__c` | Text(18), affiliate Contact ID for traceability and writeback |
| New field `Source_Org_ID__c` | `Participation__c` | Text(18), affiliate Org ID for traceability and writeback |
| New field `BTSP_Participation_ID__c` | `Participation__c` | Text(18), source record ID for Make writeback |
| New field `Invalid_Reason__c` | `Participation__c` | Text(255), describes why term validation failed |
| New field `Writeback_Status__c` | `Participation__c` | Picklist (Not Synced, Pending Writeback, Complete, Error, Mismatched Term) |
| New field `BTSP_Provided_Term__c` | `Participation__c` | Text(80), stores raw term text from affiliate |

### 6. btspdev — Apex & Flow

| Component | Type | Purpose |
|---|---|---|
| `TermValidator` | Apex Class | Validates/normalizes affiliate term text |
| `ParticipationSyncHandler` | Apex Class (@InvocableMethod) | Processes PE events, upserts Participation records with status tracking |
| `TestDataFactory` | Apex Test Utility | Shared test data factory |
| `TermValidatorTest` | Apex Test Class | 13 tests, 98% coverage |
| `ParticipationSyncHandlerTest` | Apex Test Class | 8 tests, 97% coverage |
| `Affiliate_Participation_Sync_Handler` | PE-Triggered Flow | Subscribes to PE, calls handler |

### Affiliate Term Creation

The handler **does not** create regular Affiliate Terms (School Year or Summer). These must be user-created in btspdev before syncing participation data.

The handler **only** auto-creates the "Manual Review" holding term if one doesn't exist for the Account. There is one Manual Review term per Account, used for all error scenarios.

| Term Type | Created By | Count Per Account |
|-----------|------------|-------------------|
| School Year (e.g., 2024/2025 SY) | User | Many (one per year) |
| Summer (e.g., 2024 Summer) | User | Many (one per year) |
| Manual Review | Handler (auto) | One (holding record) |

### Mismatched Term Handling

When a term fails validation **OR** no matching Affiliate Term exists:

1. The Participation is parented to a "Manual Review" `Affiliate_Term__c` (Term Type = Manual Review, Year = 0000)
2. `Writeback_Status__c` is set to "Mismatched Term"
3. `Invalid_Reason__c` describes what was wrong:
   - For invalid term format: e.g., "Uses hyphen instead of slash", "Empty string"
   - For valid format but missing Affiliate Term: "No matching Affiliate Term found for: 2024/2025 SY"
4. `BTSP_Provided_Term__c` stores the exact text the affiliate sent

**To resolve:** Re-parent the Participation to the correct Affiliate Term and set `Writeback_Status__c` to "Pending Writeback" so Make can complete the sync.

### Scenario Matrix

| # | Scenario | Integration Key | Term Format | Affiliate Term Exists? | Outcome | Writeback Status | Invalid Reason |
|---|----------|-----------------|-------------|------------------------|---------|------------------|----------------|
| 1 | Happy path - School Year | ✅ Found | ✅ Valid (`2024/2025 SY`) | ✅ Yes | Participation created/updated | Pending Writeback | (null) |
| 2 | Happy path - Summer | ✅ Found | ✅ Valid (`2024 Summer`) | ✅ Yes | Participation created/updated | Pending Writeback | (null) |
| 3 | Happy path - Spaces normalized | ✅ Found | ✅ Valid (`2024 / 2025 SY`) | ✅ Yes (as `2024/2025 SY`) | Participation created/updated | Pending Writeback | (null) |
| 4 | Missing Affiliate Term | ✅ Found | ✅ Valid (`2024/2025 SY`) | ❌ No | Participation → Manual Review | Mismatched Term | "No matching Affiliate Term found for: 2024/2025 SY" |
| 5 | Invalid - Hyphen | ✅ Found | ❌ Invalid (`2020-2021 SY`) | N/A | Participation → Manual Review | Mismatched Term | "Uses hyphen instead of slash" |
| 6 | Invalid - Space after slash only | ✅ Found | ❌ Invalid (`2020/ 2021 SY`) | N/A | Participation → Manual Review | Mismatched Term | "Space only after slash" |
| 7 | Invalid - Space before slash only | ✅ Found | ❌ Invalid (`2020 /2021 SY`) | N/A | Participation → Manual Review | Mismatched Term | "Space only before slash" |
| 8 | Invalid - Year only | ✅ Found | ❌ Invalid (`2020`) | N/A | Participation → Manual Review | Mismatched Term | "Missing term type" |
| 9 | Invalid - Wrong order | ✅ Found | ❌ Invalid (`Summer 2020`) | N/A | Participation → Manual Review | Mismatched Term | "Year not at start" |
| 10 | Invalid - Wordy format | ✅ Found | ❌ Invalid (`School Year 2020`) | N/A | Participation → Manual Review | Mismatched Term | "Wrong format entirely" |
| 11 | Invalid - Empty/null | ✅ Found | ❌ Invalid (empty) | N/A | Participation → Manual Review | Mismatched Term | "Empty string" |
| 12 | Invalid - Gibberish | ✅ Found | ❌ Invalid (`TBD`) | N/A | Participation → Manual Review | Mismatched Term | "No valid pattern" |
| 13 | No Integration Key | ❌ Not found | Any | Any | **Skipped** - no record created | N/A (stays Pending Sync in btsppackage) | N/A |
| 14 | IK - Wrong Type | ❌ Type ≠ BTSP | Any | Any | **Skipped** | N/A | N/A |
| 15 | IK - Wrong Status | ❌ Status ≠ Complete | Any | Any | **Skipped** | N/A | N/A |
| 16 | IK - No Contact | ❌ Contact is null | Any | Any | **Skipped** | N/A | N/A |
| 17 | IK - Contact has no Account | ❌ Account is null | Any | Any | **Skipped** | N/A | N/A |

---

## Test Coverage

| Class | Tests | Coverage |
|---|---|---|
| TermValidator | 13 | 98% |
| ParticipationSyncHandler | 9 | 97% |

Test scenarios include: valid School Year, valid Summer, invalid term (Manual Review), valid term with missing Affiliate Term (Manual Review), existing Participation update, missing Integration Key (skip), bulk processing, empty/null inputs.

---

## FLS Summary

### btsppackage

| Field(s) | Targets |
|---|---|
| 12 rollup fields on `btsp1__BTSP_Participation__c` | BTSP Participation perm set + System Administrator |
| `Last_Participation_Sync__c` on `btsp1__BTSP_Participation__c` | BTSP Participation perm set + System Administrator |

### btspdev

| Field(s) | Targets |
|---|---|
| 12 rollup fields on `Participation__c` | BTSP Participation perm set + System Administrator |
| `Last_Participation_Sync__c` on `Participation__c` | BTSP Participation perm set + System Administrator |
| `Last_Participation_Sync__c` on `Participation__c` | BTSP Participation perm set + System Administrator |
| `Source_Contact_ID__c` on `Participation__c` | BTSP Participation perm set + System Administrator |
| `Source_Org_ID__c` on `Participation__c` | BTSP Participation perm set + System Administrator |
| `BTSP_Participation_ID__c` on `Participation__c` | BTSP Participation perm set + System Administrator |
| `Invalid_Reason__c` on `Participation__c` | BTSP Participation perm set + System Administrator |
| `Writeback_Status__c` on `Participation__c` | BTSP Participation perm set + System Administrator |
| `BTSP_Provided_Term__c` on `Participation__c` | BTSP Participation perm set + System Administrator |
| PE fields on `Affiliate_Participation_Sync__e` | Accessible by default (no FLS needed) |

---

## Open Item

**Update vs. Create:** The handler supports both. If a Participation exists for the same Contact + Affiliate Term, rollup values are updated. Otherwise a new record is created. Typically one Participation per Contact per Term.

---

## Project Structure

```
btsppackage/
├── docs/
│   ├── participation-sync-Build_Plan.md                    # Consolidated build plan (this project)
│   ├── participation-sync-Build_Summary.md                 # This file
│   ├── participation-sync-Field_Mapping_btsppackage_to_btspdev.csv
│   └── agentrules.md
├── force-app/main/default/
│   ├── classes/
│   │   ├── TermValidator.cls
│   │   ├── ParticipationSyncHandler.cls
│   │   ├── TestDataFactory.cls
│   │   ├── TermValidatorTest.cls
│   │   └── ParticipationSyncHandlerTest.cls
│   ├── flows/
│   │   └── Affiliate_Participation_Sync_Handler.flow-meta.xml
│   ├── layouts/
│   │   └── BTSP_Participation__c-BTSP Participation Layout.layout-meta.xml
│   └── objects/
│       ├── BTSP_Participation__c/fields/          # 13 fields (btsppackage)
│       ├── Affiliate_Participation_Sync__e/fields/ # 16 fields (platform event)
│       └── Participation__c/fields/               # Source IDs, Invalid_Reason, Writeback_Status, BTSP_Provided_Term
├── manifest/package.xml
└── sfdx-project.json
```

---

## Related

- [Build Plan](participation-sync-Build_Plan.md) — Detailed field specs, architecture, and implementation details.
- [Field Mapping CSV](participation-sync-Field_Mapping_btsppackage_to_btspdev.csv) — Excel-friendly field mapping across all three objects.
