# Enable Reparenting on Master-Detail Fields

**Date:** February 12, 2026  
**Orgs Assessed:** btspprod, btspdev  
**Issue:** `Affiliate_Term__c` on `Participation__c` and `Affiliate_Account__c` on `Affiliate_Term__c` are master-detail fields with reparenting disabled. Users cannot edit these fields after record creation, which blocks the ability to correct a Participation's Affiliate Term.

---

## Problem

Both of these fields are master-detail relationships with "Allow Reparenting" turned off (the default):

- `Participation__c.Affiliate_Term__c` — cannot change which Affiliate Term a Participation belongs to
- `Affiliate_Term__c.Affiliate_Account__c` — cannot change which Account an Affiliate Term belongs to

This blocks a core workflow: when the sync handler parks a Participation under a "Manual Review" term, users cannot re-parent it to the correct Affiliate Term.

---

## Solution: Enable "Allow Reparenting"

Salesforce master-detail fields support an **"Allow Reparenting"** checkbox. Enabling this allows users to change the parent record on existing child records — without converting the field type to lookup.

This is the recommended approach because it:

- Preserves all 5 existing rollup summary fields on `Affiliate_Term__c`
- Preserves ControlledByParent sharing on both objects
- Preserves cascade delete behavior
- Requires zero code changes
- Requires zero data migration
- Has no impact on existing records
- Can be toggled on/off at any time with no adverse effects

---

## Data Context (queried February 12, 2026)

### btspprod

| Item | Value |
|------|-------|
| Participation__c records | 106,647 |
| Affiliate_Term__c records | 787 |
| Participations with Term_Type = null | 105,931 |
| Participations with Term_Type = "School Year" | 716 |
| Participations with Term_Type = "Manual Review" | 0 (sync handler not yet deployed to prod) |
| Participation__c sharing model | ControlledByParent |
| Affiliate_Term__c sharing model | ControlledByParent |

### btspdev

| Item | Value |
|------|-------|
| Participation__c records | 1 (test data) |

### Rollup Summary Fields on Affiliate_Term__c (from Participation__c)

These exist in both orgs and are **unaffected** by enabling reparenting:

| # | API Name | Type |
|---|----------|------|
| 1 | Count_Did_Not_Participate__c | Roll-Up Summary (COUNT Participation) |
| 2 | Count_Enrolled__c | Roll-Up Summary (COUNT Participation) |
| 3 | Count_Participated__c | Roll-Up Summary (COUNT Participation) |
| 4 | Count_Total__c | Roll-Up Summary (COUNT Participation) |
| 5 | Count_of_Students__c | Roll-Up Summary (COUNT Participation) |

---

## Steps

### 1. Enable reparenting in btspdev (test first)

- **Setup > Object Manager > Participation > Fields & Relationships > Affiliate_Term__c > Edit**
  - Check **"Allow Reparenting"** > Save
- **Setup > Object Manager > Affiliate Term > Fields & Relationships > Affiliate_Account__c > Edit**
  - Check **"Allow Reparenting"** > Save

### 2. Validate in btspdev

- Open an existing Participation record and confirm the Affiliate Term field is editable
- Change the Affiliate Term to a different value and save — confirm it works
- Verify rollup summary counts on Affiliate_Term__c still calculate correctly after the re-parent
- Test the Manual Review re-parenting workflow end-to-end

### 3. Enable reparenting in btspprod

Repeat the same two field changes in production.

### 4. Validate in btspprod

- Spot-check that Affiliate Term is editable on a Participation record
- Confirm rollup summaries are correct

---

## Risk Summary

| Risk | Severity | Notes |
|------|----------|-------|
| Impact on existing data | None | Toggling "Allow Reparenting" is metadata-only; no records are modified |
| Rollup summary fields affected | None | Rollup summaries continue to function normally on master-detail with reparenting enabled |
| Sharing model affected | None | ControlledByParent is preserved; child records inherit sharing from whichever parent they are moved to |
| Cascade delete affected | None | Master-detail cascade delete behavior is preserved |
| Code changes required | None | All existing Apex, Flows, and integrations continue to work without modification |
| Reversibility | Full | The checkbox can be unchecked at any time to disable reparenting again |
