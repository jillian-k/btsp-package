# BTSP Participation Build Plan

**Ticket:** BT-188
**Object:** `btsp1__BTSP_Participation__c`
**Date:** February 11, 2026

---

## Overview

Create 13 new fields on `btsp1__BTSP_Participation__c` for participation rollup tracking (core/optional breakdowns for 1:1 touchpoints, communication touchpoints, and programming days) plus a Participation ID from National field used for sync writeback. Add a new "Participation Rollups" layout section to house the rollup fields. No existing fields are modified or moved.

## Context

The object already has general-purpose rollup fields (e.g. `X1_1_Offered__c`, `Communication_Attended__c`, `Programming_Days_Attended__c`) that do not distinguish between core and optional. Those existing fields remain untouched. The new fields provide the core vs. optional breakdown required by the Participation Sync feature.

All field source files go under:

```
force-app/main/default/objects/BTSP_Participation__c/fields/
```

Since this is a packaging org (namespace `btsp1`), field source files omit the namespace prefix -- Salesforce applies it automatically upon deploy. Field conventions follow the existing fields (Number, precision 18, scale 0). Every field includes a `description` and `inlineHelpText` so any admin can understand its purpose.

---

## New Fields (13 total)

### 1:1 Touchpoint Fields (4 fields)

| API Name | Label | Type | Precision | Scale |
|---|---|---|---|---|
| `X1_1_Core_Offered__c` | 1:1 Core Offered | Number | 18 | 0 |
| `X1_1_Core_Attended__c` | 1:1 Core Attended | Number | 18 | 0 |
| `X1_1_Optional_Offered__c` | 1:1 Optional Offered | Number | 18 | 0 |
| `X1_1_Optional_Attended__c` | 1:1 Optional Attended | Number | 18 | 0 |

**X1_1_Core_Offered__c**
- **Description:** Number of core 1:1 touchpoints offered. Counts touchpoints where Count as Dosage = true, Avenue = Video Call or In Person, Core = true, and Status = Completed or Attempted.
- **Help Text:** Total core 1:1 touchpoints (video call or in person) offered to this participant.

**X1_1_Core_Attended__c**
- **Description:** Number of core 1:1 touchpoints attended. Counts touchpoints where Count as Dosage = true, Avenue = Video Call or In Person, Core = true, and Status = Completed.
- **Help Text:** Total core 1:1 touchpoints (video call or in person) this participant attended.

**X1_1_Optional_Offered__c**
- **Description:** Number of optional 1:1 touchpoints offered. Counts touchpoints where Count as Dosage = true, Avenue = Video Call or In Person, Core = false, and Status = Completed or Attempted.
- **Help Text:** Total optional 1:1 touchpoints (video call or in person) offered to this participant.

**X1_1_Optional_Attended__c**
- **Description:** Number of optional 1:1 touchpoints attended. Counts touchpoints where Count as Dosage = true, Avenue = Video Call or In Person, Core = false, and Status = Completed.
- **Help Text:** Total optional 1:1 touchpoints (video call or in person) this participant attended.

---

### Communication Touchpoint Fields (4 fields)

| API Name | Label | Type | Precision | Scale |
|---|---|---|---|---|
| `Communication_Core_Offered__c` | Communication Core Offered | Number | 18 | 0 |
| `Communication_Core_Attended__c` | Communication Core Attended | Number | 18 | 0 |
| `Communication_Optional_Offered__c` | Communication Optional Offered | Number | 18 | 0 |
| `Communication_Optional_Attended__c` | Communication Optional Attended | Number | 18 | 0 |

**Communication_Core_Offered__c**
- **Description:** Number of core communication touchpoints offered. Counts touchpoints where Count as Dosage = true, Avenue = Phone/Text/Email/Other, Core = true, and Status = Completed or Attempted.
- **Help Text:** Total core communication touchpoints (phone, text, email, other) offered to this participant.

**Communication_Core_Attended__c**
- **Description:** Number of core communication touchpoints attended. Counts touchpoints where Count as Dosage = true, Avenue = Phone/Text/Email/Other, Core = true, and Status = Completed.
- **Help Text:** Total core communication touchpoints (phone, text, email, other) this participant attended.

**Communication_Optional_Offered__c**
- **Description:** Number of optional communication touchpoints offered. Counts touchpoints where Count as Dosage = true, Avenue = Phone/Text/Email/Other, Core = false, and Status = Completed or Attempted.
- **Help Text:** Total optional communication touchpoints (phone, text, email, other) offered to this participant.

**Communication_Optional_Attended__c**
- **Description:** Number of optional communication touchpoints attended. Counts touchpoints where Count as Dosage = true, Avenue = Phone/Text/Email/Other, Core = false, and Status = Completed.
- **Help Text:** Total optional communication touchpoints (phone, text, email, other) this participant attended.

---

### Programming Days Fields (4 fields)

| API Name | Label | Type | Precision | Scale |
|---|---|---|---|---|
| `Core_Programming_Days_Offered__c` | Core Programming Days Offered | Number | 18 | 0 |
| `Core_Programming_Days_Attended__c` | Core Programming Days Attended | Number | 18 | 0 |
| `Non_Core_Programming_Days_Offered__c` | Non-Core Programming Days Offered | Number | 18 | 0 |
| `Non_Core_Programming_Days_Attended__c` | Non-Core Programming Days Attended | Number | 18 | 0 |

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

### Participation ID from National (1 field)

| API Name | Label | Type | Length |
|---|---|---|---|
| `Participation_ID_from_National__c` | Participation ID from National | Text | 18 |

**Participation_ID_from_National__c**
- **Description:** The Salesforce Record ID of the matching Participation record in the National org. Used for writeback operations during participation sync.
- **Help Text:** Record ID of the corresponding Participation record in the National Salesforce org, used for sync writeback.

---

## Layout Changes

**Layout:** `BTSP Participation Layout`

No existing fields are removed or moved. Two changes are made:

### 1. Add Participation ID to Information Section

Add `Participation_ID_from_National__c` to the existing "Information" section (left column, after `BTSP_Key__c`).

### 2. Add "Participation Rollups" Section

Add a new section named **"Participation Rollups"** between "Information" and "System Information" with a two-column layout.

| Left Column (Offered) | Right Column (Attended) |
|---|---|
| 1:1 Core Offered | 1:1 Core Attended |
| 1:1 Optional Offered | 1:1 Optional Attended |
| Communication Core Offered | Communication Core Attended |
| Communication Optional Offered | Communication Optional Attended |
| Core Programming Days Offered | Core Programming Days Attended |
| Non-Core Programming Days Offered | Non-Core Programming Days Attended |

---

## Notes

- **Field behavior on layout:** All new fields use `Edit` behavior on the layout to match existing fields and allow flexibility during testing. Once automation is in place and validated, consider tightening these to `Readonly` to prevent accidental manual edits.
- **package.xml:** The manifest does not currently include `CustomObject`, `CustomField`, or `Layout` types. This does not affect source-based deployment but should be updated if manifest-based retrieval/deployment is needed.

---

## File Summary

| Action | Count | Location |
|---|---|---|
| New field XML files | 13 | `force-app/main/default/objects/BTSP_Participation__c/fields/` |
| Layout XML update | 1 | `force-app/main/default/layouts/BTSP_Participation__c-BTSP Participation Layout.layout-meta.xml` |
