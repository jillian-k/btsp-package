# Consolidated Build Plan — BT-188 Participation Sync

**Ticket:** BT-188
**Date:** February 11–12, 2026

---

## Part 1: btsppackage — BTSP Participation Rollup Fields

**Object:** `btsp1__BTSP_Participation__c`
**Org:** btsppackage (managed package, namespace `btsp1`)

### Overview

Create 13 new fields on `btsp1__BTSP_Participation__c` for participation rollup tracking (core/optional breakdowns for 1:1 touchpoints, communication touchpoints, and programming days) plus a Participation ID from National field used for sync writeback. Add a new "Participation Rollups" layout section.

### New Fields (13 total)

#### 1:1 Touchpoint Fields (4)

| API Name | Label | Type |
|---|---|---|
| `X1_1_Core_Offered__c` | 1:1 Core Offered | Number(18,0) |
| `X1_1_Core_Attended__c` | 1:1 Core Attended | Number(18,0) |
| `X1_1_Optional_Offered__c` | 1:1 Optional Offered | Number(18,0) |
| `X1_1_Optional_Attended__c` | 1:1 Optional Attended | Number(18,0) |

#### Communication Touchpoint Fields (4)

| API Name | Label | Type |
|---|---|---|
| `Communication_Core_Offered__c` | Communication Core Offered | Number(18,0) |
| `Communication_Core_Attended__c` | Communication Core Attended | Number(18,0) |
| `Communication_Optional_Offered__c` | Communication Optional Offered | Number(18,0) |
| `Communication_Optional_Attended__c` | Communication Optional Attended | Number(18,0) |

#### Programming Days Fields (4)

| API Name | Label | Type |
|---|---|---|
| `Core_Programming_Days_Offered__c` | Core Programming Days Offered | Number(18,0) |
| `Core_Programming_Days_Attended__c` | Core Programming Days Attended | Number(18,0) |
| `Non_Core_Programming_Days_Offered__c` | Non-Core Programming Days Offered | Number(18,0) |
| `Non_Core_Programming_Days_Attended__c` | Non-Core Programming Days Attended | Number(18,0) |

#### Participation ID from National (1)

| API Name | Label | Type |
|---|---|---|
| `Participation_ID_from_National__c` | Participation ID from National | Text(18) |

Used for writeback operations during participation sync.

### Layout Changes

**Layout:** `BTSP Participation Layout`

- `Participation_ID_from_National__c` added to the **Information** section.
- New **"Participation Rollups"** section with two-column Offered/Attended layout.

### Notes

- All fields use `Edit` behavior on layout. Consider `Readonly` once automation is validated.
- Source files omit namespace prefix — Salesforce applies `btsp1__` automatically upon deploy.

---

## Part 2: btspdev — National Participation Fields

**Object:** `Participation__c`
**Org:** btspdev

### Overview

Align the `Participation__c` object in btspdev with the `BTSP_Participation__c` fields in the btsp1 managed package. 4 field renames + 8 new fields + layout reorganization + permission set + FLS.

### Existing Fields Renamed (4)

| Previous API Name | Previous Label | New API Name | New Label |
|---|---|---|---|
| `X1_1_Offered__c` | 1:1 Offered | `X1_1_Core_Offered__c` | 1:1 Core Offered |
| `X1_1_Attended__c` | 1:1 Attended | `X1_1_Core_Attended__c` | 1:1 Core Attended |
| `Communication_Offered__c` | Communication Offered | `Communication_Core_Offered__c` | Communication Core Offered |
| `Communication_Attended__c` | Communication Attended | `Communication_Core_Attended__c` | Communication Core Attended |

All four were already `Number(18,0)` and contained no data.

### New Fields (8)

| API Name | Label | Type |
|---|---|---|
| `X1_1_Optional_Offered__c` | 1:1 Optional Offered | Number(18,0) |
| `X1_1_Optional_Attended__c` | 1:1 Optional Attended | Number(18,0) |
| `Communication_Optional_Offered__c` | Communication Optional Offered | Number(18,0) |
| `Communication_Optional_Attended__c` | Communication Optional Attended | Number(18,0) |
| `Core_Programming_Days_Offered__c` | Core Programming Days Offered | Number(18,0) |
| `Core_Programming_Days_Attended__c` | Core Programming Days Attended | Number(18,0) |
| `Non_Core_Programming_Days_Offered__c` | Non-Core Programming Days Offered | Number(18,0) |
| `Non_Core_Programming_Days_Attended__c` | Non-Core Programming Days Attended | Number(18,0) |

### Layout Changes

**Layout:** `Participation Layout`

Reorganized existing **"Program Participation"** section with two-column Offered/Attended layout. Existing general fields (`Programming_Days_Required__c`, `Programming_Days_Attended__c`, `Core_Attendance__c`) remain in the section.

### Permission Set & FLS

- Created **"BTSP Participation"** permission set (API: `BTSP_Participation`).
- Granted Read/Edit FLS on all 12 rollup fields to BTSP Participation perm set and System Administrator profile.

---

## Part 3: btspdev — Platform Event & Sync Handler

### Platform Event: Affiliate_Participation_Sync__e

**Org:** btspdev
**Publish Behavior:** Publish After Commit

Receives participation rollup data from BTSP affiliate orgs via an external Make integration.

#### Platform Event Fields (17 total)

| API Name | Label | Type | Required | Purpose |
|---|---|---|---|---|
| `Source_Contact_ID__c` | Source Contact ID | Text(18) | Yes | Affiliate Contact ID for Integration Key lookup |
| `Source_Org_ID__c` | Source Org ID | Text(18) | Yes | Affiliate Org ID for Integration Key lookup |
| `Term__c` | Term | Text(80) | Yes | Term text from affiliate, validated by sync handler |
| `BTSP_Participation_ID__c` | BTSP Participation ID | Text(18) | Yes | Source record ID for writeback |
| `Participation_ID__c` | Participation ID | Text(18) | Yes | Target Participation record ID (populated on subsequent syncs) |
| `X1_1_Core_Offered__c` | 1:1 Core Offered | Number(18,0) | No | Rollup value |
| `X1_1_Core_Attended__c` | 1:1 Core Attended | Number(18,0) | No | Rollup value |
| `X1_1_Optional_Offered__c` | 1:1 Optional Offered | Number(18,0) | No | Rollup value |
| `X1_1_Optional_Attended__c` | 1:1 Optional Attended | Number(18,0) | No | Rollup value |
| `Communication_Core_Offered__c` | Communication Core Offered | Number(18,0) | No | Rollup value |
| `Communication_Core_Attended__c` | Communication Core Attended | Number(18,0) | No | Rollup value |
| `Communication_Optional_Offered__c` | Communication Optional Offered | Number(18,0) | No | Rollup value |
| `Communication_Optional_Attended__c` | Communication Optional Attended | Number(18,0) | No | Rollup value |
| `Core_Programming_Days_Offered__c` | Core Programming Days Offered | Number(18,0) | No | Rollup value |
| `Core_Programming_Days_Attended__c` | Core Programming Days Attended | Number(18,0) | No | Rollup value |
| `Non_Core_Programming_Days_Offered__c` | Non-Core Programming Days Offered | Number(18,0) | No | Rollup value |
| `Non_Core_Programming_Days_Attended__c` | Non-Core Programming Days Attended | Number(18,0) | No | Rollup value |

### Affiliate_Term__c Schema Updates

- **Term_Type__c**: Added "Manual Review" picklist value
- **Term__c**: Added "Manual Review" to the Term global value set
- **Year__c**: Added "0000" to the Program_Year global value set

### Participation__c Schema Updates

| API Name | Label | Type | Purpose |
|---|---|---|---|
| `Source_Contact_ID__c` | Source Contact ID | Text(18) | Affiliate Contact ID — stored for traceability and writeback |
| `Source_Org_ID__c` | Source Org ID | Text(18) | Affiliate Org ID — stored for traceability and writeback |
| `BTSP_Participation_ID__c` | BTSP Participation ID | Text(18) | Source record ID from affiliate — required for Make writeback |
| `Invalid_Reason__c` | Invalid Reason | Text(255) | Describes why term validation failed so users can resolve and re-parent |
| `Writeback_Status__c` | Writeback Status | Picklist | Tracks sync status: Not Synced, Pending Writeback, Complete, Error, Mismatched Term |
| `BTSP_Provided_Term__c` | BTSP Provided Term | Text(80) | Raw term text from affiliate exactly as submitted (from PE Term__c) |

### Architecture

```
Affiliate Org (btsppackage)
  └── BTSP_Participation__c
        │
        ▼  (Make Integration)
National Org (btspdev)
  └── Affiliate_Participation_Sync__e  (Platform Event)
        │
        ▼  (PE-Triggered Flow)
  └── ParticipationSyncHandler  (@InvocableMethod)
        ├── TermValidator.validate()
        ├── Integration_Key__c lookup
        ├── Affiliate_Term__c find/create
        └── Participation__c upsert
```

### Apex Classes

#### TermValidator.cls

Validates free-text term values from affiliates. Returns `TermResult` with:
- `isValid`, `termType`, `year`, `normalizedTerm`, `invalidReason`

Valid formats:
- **School Year:** `2024/2025 SY` or `2024 / 2025 SY` (spaces both sides or neither)
- **Summer:** `2024 Summer`

Invalid terms get descriptive reasons:
| Input | Invalid Reason |
|---|---|
| `2020/ 2021 SY` | Space only after slash |
| `2020 /2021 SY` | Space only before slash |
| `2020-2021 SY` | Uses hyphen instead of slash |
| `2020` | Missing term type |
| `Summer 2020` | Year not at start |
| `School Year 2020` | Wrong format entirely |
| *(empty)* | Empty string |
| `TBD` | No valid pattern |

#### ParticipationSyncHandler.cls

`@InvocableMethod` that processes platform events:

1. **Validate terms** via `TermValidator`
2. **Query Integration Keys** — `RecordType = Affiliate_Org`, `Type__c = BTSP`, `Writeback_Status__c = Complete`, matched by `Source_Contact_ID__c` + `Source_Org_ID__c`, most recent by `LastModifiedDate`
3. **Get Affiliate Account** from `Integration_Key__c.Contact__r.AccountId`
4. **Find/Create Affiliate Terms** — query by Account + normalized Term. Create new with Manual Review holding pattern for invalid terms
5. **Upsert Participation records** — match by `Participant__c` + `Affiliate_Term__c`. Set 12 rollup values, `Affiliate_Site__c`, `Type__c = Student`, `Source_Contact_ID__c`, `Source_Org_ID__c`, `BTSP_Participation_ID__c`, `Invalid_Reason__c` for invalid terms, `Writeback_Status__c` (Pending Writeback or Mismatched Term), and `BTSP_Provided_Term__c` (raw term text)
6. **Skip events** where no Integration Key found (logged via `System.debug`)

#### TestDataFactory.cls

Shared test data factory with methods for Account, Contact, Integration_Key__c, Affiliate_Term__c, Participation__c, and platform event construction.

### Flow

**Affiliate Participation Sync Handler** — Platform Event-Triggered Flow
- Subscribes to `Affiliate_Participation_Sync__e`
- Calls `ParticipationSyncHandler` invocable method

### Manual Review Holding Pattern

When a term fails validation:
1. A single `Affiliate_Term__c` record is created per Account with `Term = Manual Review`, `Term_Type = Manual Review`, `Year = 0000`
2. The `Participation__c` record is parented to this holding term
3. `Writeback_Status__c` is set to "Mismatched Term"
4. `Invalid_Reason__c` describes what was wrong with the original term text
5. `BTSP_Provided_Term__c` stores the exact text the affiliate sent
6. Users review, correct the term, re-parent to the correct `Affiliate_Term__c`, and set `Writeback_Status__c` to "Pending Writeback" so Make can complete the sync

### FLS

FLS granted on `Participation__c` to BTSP Participation permission set and System Administrator profile:
- `Source_Contact_ID__c`
- `Source_Org_ID__c`
- `BTSP_Participation_ID__c`
- `Invalid_Reason__c`
- `Writeback_Status__c`
- `BTSP_Provided_Term__c`

Platform event fields are accessible by default (no FLS required).

### Test Coverage

| Class | Tests | Coverage |
|---|---|---|
| TermValidator | 13 (TermValidatorTest) | 98% |
| ParticipationSyncHandler | 8 (ParticipationSyncHandlerTest) | 97% |
| TestDataFactory | Covered by above tests | N/A |

---

## Clarification Needed (non-blocking)

**Update vs. Create:** The current implementation handles both. If a `Participation__c` already exists for the same Contact + Affiliate Term, it updates the rollup values. If not, it creates a new one. This is safe since there's typically one Participation per Contact per Term.

---

## Differences Between btsppackage and btspdev

| Aspect | btsppackage | btspdev |
|---|---|---|
| Object | `btsp1__BTSP_Participation__c` | `Participation__c` |
| Namespace | `btsp1` (managed package) | None (unmanaged) |
| Participation ID from National | Yes | No — not needed |
| Layout section | "Participation Rollups" (new) | "Program Participation" (reorganized) |
| Platform Event | N/A | `Affiliate_Participation_Sync__e` |
| Apex/Flow | N/A | TermValidator, ParticipationSyncHandler, PE-Triggered Flow |
