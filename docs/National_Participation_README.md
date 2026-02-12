# National Org (btspdev) — Participation Field Build

**Ticket:** BT-188
**Object:** `Participation__c`
**Target Org:** btspdev
**Date:** February 11, 2026

---

## What Was Built

### Field Renames (4 fields)

Four existing fields on `Participation__c` were renamed (label, API name, description, and help text) to align with the BTSP managed package naming convention. All four were already `Number(18,0)` and contained no data.

| Previous API Name | Previous Label | New API Name | New Label |
|---|---|---|---|
| `X1_1_Offered__c` | 1:1 Offered | `X1_1_Core_Offered__c` | 1:1 Core Offered |
| `X1_1_Attended__c` | 1:1 Attended | `X1_1_Core_Attended__c` | 1:1 Core Attended |
| `Communication_Offered__c` | Communication Offered | `Communication_Core_Offered__c` | Communication Core Offered |
| `Communication_Attended__c` | Communication Attended | `Communication_Core_Attended__c` | Communication Core Attended |

Each renamed field's description notes its previous name for audit trail purposes.

### New Fields (8 fields)

Eight new `Number(18,0)` fields were created on `Participation__c`. All include description and help text.

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

### Permission Set

A new permission set **"BTSP Participation"** (API name: `BTSP_Participation`) was created with Read and Edit FLS on all 12 rollup fields.

### Field-Level Security

Read and Edit FLS was granted on all 12 rollup fields to:
- **BTSP Participation** permission set (new)
- **System Administrator** profile

### Layout Changes

The **Participation Layout** was reorganized. The existing **"Program Participation"** section now contains all 12 rollup fields in a two-column Offered/Attended layout, grouped by category. A new **"Attendance Summary"** section was added below it to hold the existing `Core_Attendance__c` formula field.

| Left Column (Offered) | Right Column (Attended) |
|---|---|
| 1:1 Core Offered | 1:1 Core Attended |
| 1:1 Optional Offered | 1:1 Optional Attended |
| Communication Core Offered | Communication Core Attended |
| Communication Optional Offered | Communication Optional Attended |
| Core Programming Days Offered | Core Programming Days Attended |
| Non-Core Programming Days Offered | Non-Core Programming Days Attended |
| Programming Days Required | Programming Days Attended |

The **Attendance Summary** section contains:
- Core Attendance (formula: `Programming_Days_Attended__c / Programming_Days_Required__c`)

---

## Field Cross-Reference: btsppackage vs. btspdev

The table below maps each rollup field from the BTSP managed package (`btsp1__BTSP_Participation__c`) to the corresponding field on the National org (`Participation__c` in btspdev).

| btsppackage (BTSP_Participation__c) | btspdev (Participation__c) | Action in btspdev |
|---|---|---|
| `btsp1__X1_1_Core_Offered__c` | `X1_1_Core_Offered__c` | Renamed from `X1_1_Offered__c` |
| `btsp1__X1_1_Core_Attended__c` | `X1_1_Core_Attended__c` | Renamed from `X1_1_Attended__c` |
| `btsp1__X1_1_Optional_Offered__c` | `X1_1_Optional_Offered__c` | Created new |
| `btsp1__X1_1_Optional_Attended__c` | `X1_1_Optional_Attended__c` | Created new |
| `btsp1__Communication_Core_Offered__c` | `Communication_Core_Offered__c` | Renamed from `Communication_Offered__c` |
| `btsp1__Communication_Core_Attended__c` | `Communication_Core_Attended__c` | Renamed from `Communication_Attended__c` |
| `btsp1__Communication_Optional_Offered__c` | `Communication_Optional_Offered__c` | Created new |
| `btsp1__Communication_Optional_Attended__c` | `Communication_Optional_Attended__c` | Created new |
| `btsp1__Core_Programming_Days_Offered__c` | `Core_Programming_Days_Offered__c` | Created new |
| `btsp1__Core_Programming_Days_Attended__c` | `Core_Programming_Days_Attended__c` | Created new |
| `btsp1__Non_Core_Programming_Days_Offered__c` | `Non_Core_Programming_Days_Offered__c` | Created new |
| `btsp1__Non_Core_Programming_Days_Attended__c` | `Non_Core_Programming_Days_Attended__c` | Created new |
| `btsp1__Participation_ID_from_National__c` | *(not applicable)* | Not created — only needed on the package side for sync writeback |

All 12 rollup fields share the same API name (sans namespace), the same field type (`Number(18,0)`), and the same description/help text across both orgs.

---

## Existing Fields Not Changed

These fields were already on `Participation__c` and remain unchanged:

| API Name | Label | Type | Notes |
|---|---|---|---|
| `Programming_Days_Attended__c` | Programming Days Attended | Number(2,0) | General field, has data in prod (1,821 records) |
| `Programming_Days_Required__c` | Programming Days Required | Number(2,0) | General field, has data in prod (1,827 records) |
| `Core_Attendance__c` | Core Attendance | Formula (Percent) | `Programming_Days_Attended__c / Programming_Days_Required__c` |

---

## Differences Between btsppackage and btspdev

| Aspect | btsppackage | btspdev |
|---|---|---|
| Object | `btsp1__BTSP_Participation__c` | `Participation__c` |
| Namespace | `btsp1` (managed package) | None (unmanaged) |
| Participation ID from National | Yes (`btsp1__Participation_ID_from_National__c`) | No — not needed |
| Layout section name | "Participation Rollups" (new section) | "Program Participation" (existing, reorganized) |
| `Core_Attended__c` / `Core_Offered__c` | N/A (do not exist) | N/A (do not exist in btspdev; exist in btspprod only) |

---

## Notes

- **btspdev only.** No changes were made to btspprod.
- **No Apex code or automation.** These fields will be populated by future automation. Currently they are empty.
- **Field behavior on layout:** All fields use `Edit` behavior for flexibility during testing. Consider tightening to `Readonly` once automation is in place and validated.
- **Old field names in descriptions.** Each renamed field's description notes what it was previously named, for audit purposes.
- **`Core_Attended__c` / `Core_Offered__c` do not exist in btspdev.** They only exist in btspprod. The core programming days fields were created new in btspdev rather than renamed.

---

## Related Documentation

- [BTSP Participation Build Plan (btsppackage)](BTSP_Participation_Build_Plan.md) — Field specs for the packaging org.
- [National Participation Build Plan (btspdev)](National_Participation_Build_Plan.md) — Detailed build plan for the btspdev implementation.
- [btsppackage README](BTSP_Participation_README.md) — Overview of all work done in the packaging org.
