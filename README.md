# BTSP Packaging Org

Source repository for the **btsp1** managed package, targeting the `btsppackage` Salesforce packaging org.

**Org alias:** `btsppackage`
**Namespace:** `btsp1`
**API Version:** 62.0

---

## What Was Built

### BT-188: Participation Rollup Fields

13 new custom fields were added to the `btsp1__BTSP_Participation__c` object to support the Participation Sync feature. These fields provide core vs. optional breakdowns for 1:1 touchpoints, communication touchpoints, and programming days -- data that the existing general-purpose fields (`X1_1_Offered__c`, `Communication_Attended__c`, etc.) do not distinguish.

#### New Fields

| API Name | Label | Type | Purpose |
|---|---|---|---|
| `X1_1_Core_Offered__c` | 1:1 Core Offered | Number(18,0) | Core 1:1 touchpoints offered (video call/in person) |
| `X1_1_Core_Attended__c` | 1:1 Core Attended | Number(18,0) | Core 1:1 touchpoints attended |
| `X1_1_Optional_Offered__c` | 1:1 Optional Offered | Number(18,0) | Optional 1:1 touchpoints offered (video call/in person) |
| `X1_1_Optional_Attended__c` | 1:1 Optional Attended | Number(18,0) | Optional 1:1 touchpoints attended |
| `Communication_Core_Offered__c` | Communication Core Offered | Number(18,0) | Core communication touchpoints offered (phone/text/email/other) |
| `Communication_Core_Attended__c` | Communication Core Attended | Number(18,0) | Core communication touchpoints attended |
| `Communication_Optional_Offered__c` | Communication Optional Offered | Number(18,0) | Optional communication touchpoints offered (phone/text/email/other) |
| `Communication_Optional_Attended__c` | Communication Optional Attended | Number(18,0) | Optional communication touchpoints attended |
| `Core_Programming_Days_Offered__c` | Core Programming Days Offered | Number(18,0) | Core programming days offered from Service Schedules |
| `Core_Programming_Days_Attended__c` | Core Programming Days Attended | Number(18,0) | Core programming days attended |
| `Non_Core_Programming_Days_Offered__c` | Non-Core Programming Days Offered | Number(18,0) | Non-core programming days offered from Service Schedules |
| `Non_Core_Programming_Days_Attended__c` | Non-Core Programming Days Attended | Number(18,0) | Non-core programming days attended |
| `Participation_ID_from_National__c` | Participation ID from National | Text(18) | Record ID of matching Participation in the National org for sync writeback |

All number fields include description and help text for admin clarity.

### Layout Changes

The **BTSP Participation Layout** was updated with:

- `Participation_ID_from_National__c` added to the **Information** section (after BTSP Key).
- A new **"Participation Rollups"** section added between Information and System Information, with a two-column layout:
  - Left column: all "Offered" fields
  - Right column: all "Attended" fields
  - Grouped by category: 1:1 Core, 1:1 Optional, Communication Core, Communication Optional, Core Programming, Non-Core Programming

No existing fields were removed or relocated.

---

## What Was Not Changed

- Existing general-purpose rollup fields (`X1_1_Offered__c`, `X1_1_Attended__c`, `Communication_Offered__c`, `Communication_Attended__c`, `Programming_Days_Attended__c`, `Programming_Days_Required__c`) remain untouched.
- No Apex code, LWC, or automation was added -- these fields are intended to be populated by future automation.

---

## Manual Steps

### Deploy to the Packaging Org

After cloning this repo, deploy the new metadata to the packaging org:

```bash
sf project deploy start --target-org btsppackage
```

To deploy only the new fields and layout (without touching other metadata):

```bash
sf project deploy start \
  --target-org btsppackage \
  --source-dir force-app/main/default/objects/BTSP_Participation__c \
  --source-dir force-app/main/default/layouts
```

### Post-Deploy Verification

1. Navigate to **Setup > Object Manager > BTSP Participation > Fields & Relationships** and confirm all 13 new fields are present with the `btsp1__` namespace prefix.
2. Open the **BTSP Participation Layout** and verify the "Participation Rollups" section appears with the correct field arrangement.
3. Confirm `Participation ID from National` appears in the Information section.

---

## Notes

- **Field behavior on layout:** All new fields use `Edit` behavior to match existing fields and allow flexibility during initial testing. Once automation is in place and validated, consider changing these to `Readonly` to prevent accidental manual edits.
- **Namespace:** This is a packaging org with namespace `btsp1`. The `sfdx-project.json` has an empty namespace string, which is expected -- the org applies the namespace automatically. Source files use bare API names (e.g. `X1_1_Core_Offered__c`, not `btsp1__X1_1_Core_Offered__c`).

---

## Project Structure

```
btsppackage/
├── docs/
│   └── BTSP_Participation_Build_Plan.md    # Detailed build plan for BT-188
├── force-app/main/default/
│   ├── layouts/
│   │   └── BTSP_Participation__c-BTSP Participation Layout.layout-meta.xml
│   └── objects/BTSP_Participation__c/
│       ├── BTSP_Participation__c.object-meta.xml
│       └── fields/
│           ├── X1_1_Core_Offered__c.field-meta.xml      (new)
│           ├── X1_1_Core_Attended__c.field-meta.xml     (new)
│           ├── X1_1_Optional_Offered__c.field-meta.xml  (new)
│           ├── X1_1_Optional_Attended__c.field-meta.xml (new)
│           ├── Communication_Core_Offered__c.field-meta.xml      (new)
│           ├── Communication_Core_Attended__c.field-meta.xml     (new)
│           ├── Communication_Optional_Offered__c.field-meta.xml  (new)
│           ├── Communication_Optional_Attended__c.field-meta.xml (new)
│           ├── Core_Programming_Days_Offered__c.field-meta.xml      (new)
│           ├── Core_Programming_Days_Attended__c.field-meta.xml     (new)
│           ├── Non_Core_Programming_Days_Offered__c.field-meta.xml  (new)
│           ├── Non_Core_Programming_Days_Attended__c.field-meta.xml (new)
│           ├── Participation_ID_from_National__c.field-meta.xml     (new)
│           └── ... (existing fields)
├── manifest/package.xml
└── sfdx-project.json
```

---

## Related Documentation

- [Build Plan (BT-188)](docs/BTSP_Participation_Build_Plan.md) -- Full field specifications, descriptions, help text, and layout details.
