# National Participation Build Plan

**Ticket:** BT-188
**Object:** `Participation__c` (National / btspdev)
**Target Org:** btspdev only (no changes to btspprod)
**Date:** February 11, 2026

---

## Overview

Align the `Participation__c` object in btspdev with the `BTSP_Participation__c` fields in the btsp1 managed package. This involves renaming 4 existing fields (label + API name), creating 8 new fields, reorganizing the page layout, creating a permission set, and granting field-level security.

**Note:** `Core_Attended__c` and `Core_Offered__c` exist in btspprod but do **not** exist in btspdev. Therefore, the core programming days fields must be created new in btspdev rather than renamed.

---

## Existing Fields to Rename (4 fields)

These fields exist on `Participation__c` in btspdev, are **empty** (no data), and will be renamed to align with the BTSP packaging org naming convention.

| Current Label | Current API Name | Current Type | New Label | New API Name | New Type |
|---|---|---|---|---|---|
| 1:1 Offered | `X1_1_Offered__c` | Number(18,0) | 1:1 Core Offered | `X1_1_Core_Offered__c` | Number(18,0) |
| 1:1 Attended | `X1_1_Attended__c` | Number(18,0) | 1:1 Core Attended | `X1_1_Core_Attended__c` | Number(18,0) |
| Communication Offered | `Communication_Offered__c` | Number(18,0) | Communication Core Offered | `Communication_Core_Offered__c` | Number(18,0) |
| Communication Attended | `Communication_Attended__c` | Number(18,0) | Communication Core Attended | `Communication_Core_Attended__c` | Number(18,0) |

### Descriptions for Renamed Fields

Each renamed field includes a description noting what it was previously named.

**X1_1_Core_Offered__c** (was `X1_1_Offered__c` "1:1 Offered")
- **Description:** Number of core 1:1 touchpoints offered. Counts touchpoints where Count as Dosage = true, Avenue = Video Call or In Person, Core = true, and Status = Completed or Attempted. Previously "1:1 Offered" (X1_1_Offered__c) -- renamed to align BTSP with National.
- **Help Text:** Total core 1:1 touchpoints (video call or in person) offered to this participant.

**X1_1_Core_Attended__c** (was `X1_1_Attended__c` "1:1 Attended")
- **Description:** Number of core 1:1 touchpoints attended. Counts touchpoints where Count as Dosage = true, Avenue = Video Call or In Person, Core = true, and Status = Completed. Previously "1:1 Attended" (X1_1_Attended__c) -- renamed to align BTSP with National.
- **Help Text:** Total core 1:1 touchpoints (video call or in person) this participant attended.

**Communication_Core_Offered__c** (was `Communication_Offered__c` "Communication Offered")
- **Description:** Number of core communication touchpoints offered. Counts touchpoints where Count as Dosage = true, Avenue = Phone/Text/Email/Other, Core = true, and Status = Completed or Attempted. Previously "Communication Offered" (Communication_Offered__c) -- renamed to align BTSP with National.
- **Help Text:** Total core communication touchpoints (phone, text, email, other) offered to this participant.

**Communication_Core_Attended__c** (was `Communication_Attended__c` "Communication Attended")
- **Description:** Number of core communication touchpoints attended. Counts touchpoints where Count as Dosage = true, Avenue = Phone/Text/Email/Other, Core = true, and Status = Completed. Previously "Communication Attended" (Communication_Attended__c) -- renamed to align BTSP with National.
- **Help Text:** Total core communication touchpoints (phone, text, email, other) this participant attended.

---

## New Fields to Create (8 fields)

All new fields are Number(18,0).

| API Name | Label | Type | Precision | Scale |
|---|---|---|---|---|
| `X1_1_Optional_Offered__c` | 1:1 Optional Offered | Number | 18 | 0 |
| `X1_1_Optional_Attended__c` | 1:1 Optional Attended | Number | 18 | 0 |
| `Communication_Optional_Offered__c` | Communication Optional Offered | Number | 18 | 0 |
| `Communication_Optional_Attended__c` | Communication Optional Attended | Number | 18 | 0 |
| `Core_Programming_Days_Offered__c` | Core Programming Days Offered | Number | 18 | 0 |
| `Core_Programming_Days_Attended__c` | Core Programming Days Attended | Number | 18 | 0 |
| `Non_Core_Programming_Days_Offered__c` | Non-Core Programming Days Offered | Number | 18 | 0 |
| `Non_Core_Programming_Days_Attended__c` | Non-Core Programming Days Attended | Number | 18 | 0 |

**X1_1_Optional_Offered__c**
- **Description:** Number of optional 1:1 touchpoints offered. Counts touchpoints where Count as Dosage = true, Avenue = Video Call or In Person, Core = false, and Status = Completed or Attempted.
- **Help Text:** Total optional 1:1 touchpoints (video call or in person) offered to this participant.

**X1_1_Optional_Attended__c**
- **Description:** Number of optional 1:1 touchpoints attended. Counts touchpoints where Count as Dosage = true, Avenue = Video Call or In Person, Core = false, and Status = Completed.
- **Help Text:** Total optional 1:1 touchpoints (video call or in person) this participant attended.

**Communication_Optional_Offered__c**
- **Description:** Number of optional communication touchpoints offered. Counts touchpoints where Count as Dosage = true, Avenue = Phone/Text/Email/Other, Core = false, and Status = Completed or Attempted.
- **Help Text:** Total optional communication touchpoints (phone, text, email, other) offered to this participant.

**Communication_Optional_Attended__c**
- **Description:** Number of optional communication touchpoints attended. Counts touchpoints where Count as Dosage = true, Avenue = Phone/Text/Email/Other, Core = false, and Status = Completed.
- **Help Text:** Total optional communication touchpoints (phone, text, email, other) this participant attended.

**Core_Programming_Days_Offered__c**
- **Description:** Number of core programming days offered. Sum of Service Sessions or Service Delivery records from core programming Service Schedules.
- **Help Text:** Total number of core programming days offered to this participant from core Service Schedules.

**Core_Programming_Days_Attended__c**
- **Description:** Number of core programming days attended by this participant.
- **Help Text:** Total number of core programming days this participant actually attended.

**Non_Core_Programming_Days_Offered__c**
- **Description:** Number of non-core programming days offered. Sum of Service Sessions or Service Delivery records from non-core programming Service Schedules.
- **Help Text:** Total number of non-core programming days offered to this participant from non-core Service Schedules.

**Non_Core_Programming_Days_Attended__c**
- **Description:** Number of non-core programming days attended by this participant.
- **Help Text:** Total number of non-core programming days this participant actually attended.

---

## Formula Field Dependency

The existing formula field `Core_Attendance__c` ("Core Attendance", Formula Percent) has this formula:

```
Programming_Days_Attended__c / Programming_Days_Required__c
```

This references `Programming_Days_Attended__c` and `Programming_Days_Required__c` -- the **general** programming days fields which are NOT being renamed or changed. No formula update is needed.

Note: `Core_Attended__c` and `Core_Offered__c` do not exist in btspdev, so there are no dependencies on them here.

---

## Existing Fields NOT Being Changed

These fields remain as-is on `Participation__c`:

| API Name | Label | Type | Notes |
|---|---|---|---|
| `Programming_Days_Attended__c` | Programming Days Attended | Number(2,0) | General field, has data in prod (1,821 records) |
| `Programming_Days_Required__c` | Programming Days Required | Number(2,0) | General field, has data in prod (1,827 records) |
| `Core_Attendance__c` | Core Attendance | Formula (Percent) | References Programming_Days fields above |

---

## Layout Changes

**Layout:** `Participation Layout`

The current layout has these sections:
1. **Information** -- core record fields (Name, Participant, Affiliate Term, Type, etc.)
2. **Program Participation** -- rollup fields (currently holds the old field names)
3. **Not Yet in Use** -- deprecated/unused fields
4. **System Information** -- Created/Modified By
5. **Custom Links**

### Reorganize "Program Participation" Section

Rather than adding a new section, reorganize the existing **"Program Participation"** section to hold all 12 rollup fields in an intuitive two-column layout, with Offered on the left and Attended on the right, grouped by category:

| Left Column (Offered) | Right Column (Attended) |
|---|---|
| 1:1 Core Offered | 1:1 Core Attended |
| 1:1 Optional Offered | 1:1 Optional Attended |
| Communication Core Offered | Communication Core Attended |
| Communication Optional Offered | Communication Optional Attended |
| Core Programming Days Offered | Core Programming Days Attended |
| Non-Core Programming Days Offered | Non-Core Programming Days Attended |

The general fields `Programming_Days_Required__c`, `Programming_Days_Attended__c`, and formula `Core_Attendance__c` should remain on the layout in this section as well, placed after the new rollup fields.

---

## Permission Set and Field-Level Security

### Create Permission Set

Create a new permission set named **"BTSP Participation"** (API name: `BTSP_Participation`). No existing permission set with this name was found in btspdev.

### Grant FLS

Grant Read and Edit field-level security on all 12 rollup fields (4 renamed + 8 new) to:

1. **BTSP Participation** permission set (new)
2. **System Administrator** profile
3. **Terranox Devs** user (via the above)

Fields to grant FLS for:

- `X1_1_Core_Offered__c`
- `X1_1_Core_Attended__c`
- `X1_1_Optional_Offered__c`
- `X1_1_Optional_Attended__c`
- `Communication_Core_Offered__c`
- `Communication_Core_Attended__c`
- `Communication_Optional_Offered__c`
- `Communication_Optional_Attended__c`
- `Core_Programming_Days_Offered__c`
- `Core_Programming_Days_Attended__c`
- `Non_Core_Programming_Days_Offered__c`
- `Non_Core_Programming_Days_Attended__c`

---

## Notes

- **btspdev only.** No changes to btspprod.
- **No Participation ID from National.** That field is only needed on the packaging org (`btsp1__BTSP_Participation__c`).
- **`Core_Attended__c` / `Core_Offered__c` do not exist in btspdev.** They only exist in btspprod. The core programming days fields are created new in btspdev.
- **Field behavior on layout:** All fields use Edit behavior for flexibility during testing. Consider changing to Readonly once automation is in place.
- **Old field names in descriptions.** Each renamed field's description notes what the field was previously named, for audit trail.

---

## Summary

| Action | Count | Target |
|---|---|---|
| Rename existing fields (label + API name) | 4 | `Participation__c` in btspdev |
| Create new fields | 8 | `Participation__c` in btspdev |
| Reorganize layout | 1 | `Participation Layout` in btspdev |
| Create permission set | 1 | "BTSP Participation" in btspdev |
| Grant FLS | 12 fields | Sys Admin profile + BTSP Participation perm set |
