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
| Participation ID from National (Text 18) | 1 |
| Layout section ("Participation Rollups") | 1 |

All 12 rollup fields provide core vs. optional breakdowns for:
- 1:1 touchpoints (offered/attended)
- Communication touchpoints (offered/attended)
- Programming days (offered/attended)

### 2. btspdev — National Participation Fields

**Org:** btspdev | **Object:** `Participation__c`

| Item | Count |
|---|---|
| Fields renamed (label + API name) | 4 |
| New rollup fields created | 8 |
| Permission set created ("BTSP Participation") | 1 |
| FLS grants (12 fields × 2 targets) | 24 |
| Layout reorganized ("Program Participation") | 1 |

### 3. btspdev — Platform Event

**Object:** `Affiliate_Participation_Sync__e`

| Item | Count |
|---|---|
| Rollup fields (Number 18,0) | 12 |
| Matching/key fields (Text) | 5 |
| Total PE fields | 17 |

Key fields: `Source_Contact_ID__c`, `Source_Org_ID__c`, `Term__c`, `BTSP_Participation_ID__c`, `Participation_ID__c`

### 4. btspdev — Affiliate Term Schema Updates

| Change | Object | Detail |
|---|---|---|
| Picklist value "Manual Review" | `Affiliate_Term__c.Term_Type__c` | Local picklist |
| Picklist value "Manual Review" | `Affiliate_Term__c.Term__c` | Term global value set |
| Picklist value "0000" | `Affiliate_Term__c.Year__c` | Program_Year global value set |

### 5. btspdev — Participation Schema Updates

| Change | Object | Detail |
|---|---|---|
| New field `Invalid_Reason__c` | `Participation__c` | Text(255), describes why term validation failed |

### 6. btspdev — Apex & Flow

| Component | Type | Purpose |
|---|---|---|
| `TermValidator` | Apex Class | Validates/normalizes affiliate term text |
| `ParticipationSyncHandler` | Apex Class (@InvocableMethod) | Processes PE events, upserts Participation records |
| `TestDataFactory` | Apex Test Utility | Shared test data factory |
| `TermValidatorTest` | Apex Test Class | 13 tests, 98% coverage |
| `ParticipationSyncHandlerTest` | Apex Test Class | 8 tests, 97% coverage |
| `Affiliate_Participation_Sync_Handler` | PE-Triggered Flow | Subscribes to PE, calls handler |

### Manual Review Holding Pattern

When an affiliate's term text fails validation:
1. Participation is parented to a "Manual Review" `Affiliate_Term__c` (Term Type = Manual Review, Year = 0000)
2. `Invalid_Reason__c` on the `Participation__c` describes the validation failure
3. Users review, fix the term, and re-parent to the correct Affiliate Term

---

## Test Coverage

| Class | Tests | Coverage |
|---|---|---|
| TermValidator | 13 | 98% |
| ParticipationSyncHandler | 8 | 97% |

Test scenarios include: valid School Year, valid Summer, invalid term (Manual Review), existing Participation update, missing Integration Key (skip), bulk processing, empty/null inputs.

---

## FLS Summary

| Field(s) | Targets |
|---|---|
| 12 rollup fields on `Participation__c` | BTSP Participation perm set + System Administrator |
| `Invalid_Reason__c` on `Participation__c` | BTSP Participation perm set + System Administrator |
| PE fields on `Affiliate_Participation_Sync__e` | Accessible by default (no FLS needed) |

---

## Open Item

**Update vs. Create:** The handler supports both. If a Participation exists for the same Contact + Affiliate Term, rollup values are updated. Otherwise a new record is created. Typically one Participation per Contact per Term.

---

## Project Structure

```
btsppackage/
├── docs/
│   ├── Build_Plan.md                    # Consolidated build plan (this project)
│   ├── Build_Summary.md                 # This file
│   ├── Field_Mapping_btsppackage_to_btspdev.csv
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
│       ├── Affiliate_Participation_Sync__e/fields/ # 17 fields (platform event)
│       └── Participation__c/fields/               # Invalid_Reason__c
├── manifest/package.xml
└── sfdx-project.json
```

---

## Related

- [Build Plan](Build_Plan.md) — Detailed field specs, architecture, and implementation details.
- [Field Mapping CSV](Field_Mapping_btsppackage_to_btspdev.csv) — Excel-friendly field mapping across all three objects.
