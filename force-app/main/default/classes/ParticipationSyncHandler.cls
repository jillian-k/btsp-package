/**
 * ParticipationSyncHandler
 * Invocable Apex called by a Platform Event-Triggered Flow that subscribes to
 * Affiliate_Participation_Sync__e. Processes incoming participation rollup data
 * from affiliate orgs and upserts Participation__c records in National.
 *
 * Flow passes a list of platform event records. This handler:
 *   1. Validates terms via TermValidator
 *   2. Looks up Integration Keys to find the National Contact
 *   3. Finds existing Affiliate Term records (user-created)
 *   4. Falls back to Manual Review holding term if no match found (auto-creates if needed)
 *   5. Creates or updates Participation records with rollup values
 */
public with sharing class ParticipationSyncHandler {

    /**
     * Invocable method called by the Platform Event-Triggered Flow.
     * @param events List of Affiliate_Participation_Sync__e records
     */
    @InvocableMethod(
        label='Process Participation Sync Events'
        description='Processes Affiliate Participation Sync platform events to create or update Participation records.'
    )
    public static void handleEvents(List<Affiliate_Participation_Sync__e> events) {
        if (events == null || events.isEmpty()) {
            return;
        }

        // Get the Affiliate_Org record type ID for Integration_Key__c
        Id affiliateOrgRtId = Schema.SObjectType.Integration_Key__c
            .getRecordTypeInfosByDeveloperName()
            .get('Affiliate_Org')
            .getRecordTypeId();

        // Step 1: Validate terms
        Map<Integer, TermValidator.TermResult> termResults = new Map<Integer, TermValidator.TermResult>();
        for (Integer i = 0; i < events.size(); i++) {
            termResults.put(i, TermValidator.validate(events[i].Term__c));
        }

        // Step 2: Query Integration Keys -- bulk lookup by Source Contact + Source Org
        Set<String> contactIds = new Set<String>();
        Set<String> orgIds = new Set<String>();
        for (Affiliate_Participation_Sync__e evt : events) {
            contactIds.add(evt.Source_Contact_ID__c);
            orgIds.add(evt.Source_Org_ID__c);
        }

        // Get all matching Integration Keys, ordered by LastModifiedDate DESC
        // so the first match per Source Contact + Org combo is the most recent
        List<Integration_Key__c> ikList = [
            SELECT Id, Source_Contact_ID__c, Source_Org_ID__c,
                   Contact__c, Contact__r.AccountId
            FROM Integration_Key__c
            WHERE RecordTypeId = :affiliateOrgRtId
              AND Type__c = 'BTSP'
              AND Writeback_Status__c = 'Complete'
              AND Source_Contact_ID__c IN :contactIds
              AND Source_Org_ID__c IN :orgIds
            ORDER BY LastModifiedDate DESC
        ];

        // Build a map keyed by Source_Contact_ID + '|' + Source_Org_ID -> most recent IK
        Map<String, Integration_Key__c> ikMap = new Map<String, Integration_Key__c>();
        for (Integration_Key__c ik : ikList) {
            String compositeKey = ik.Source_Contact_ID__c + '|' + ik.Source_Org_ID__c;
            if (!ikMap.containsKey(compositeKey)) {
                ikMap.put(compositeKey, ik);
            }
        }

        // Step 3: Determine Affiliate Accounts from Integration Keys
        // Collect unique Account IDs for Affiliate Term lookups
        Set<Id> accountIds = new Set<Id>();
        Set<String> normalizedTerms = new Set<String>();

        // Build per-event context
        List<EventContext> contexts = new List<EventContext>();
        for (Integer i = 0; i < events.size(); i++) {
            Affiliate_Participation_Sync__e evt = events[i];
            TermValidator.TermResult tr = termResults.get(i);

            String compositeKey = evt.Source_Contact_ID__c + '|' + evt.Source_Org_ID__c;
            Integration_Key__c ik = ikMap.get(compositeKey);

            if (ik == null) {
                System.debug(LoggingLevel.WARN,
                    'No Integration Key found for Source Contact: ' + evt.Source_Contact_ID__c +
                    ', Source Org: ' + evt.Source_Org_ID__c + '. Skipping event.');
                continue;
            }

            if (ik.Contact__c == null) {
                System.debug(LoggingLevel.WARN,
                    'Integration Key ' + ik.Id + ' has no Contact. Skipping event.');
                continue;
            }

            Id affiliateAccountId = ik.Contact__r.AccountId;
            if (affiliateAccountId == null) {
                System.debug(LoggingLevel.WARN,
                    'Contact on Integration Key ' + ik.Id + ' has no Account. Skipping event.');
                continue;
            }

            accountIds.add(affiliateAccountId);
            normalizedTerms.add(tr.normalizedTerm);

            EventContext ctx = new EventContext();
            ctx.evt = evt;
            ctx.termResult = tr;
            ctx.integrationKey = ik;
            ctx.contactId = ik.Contact__c;
            ctx.accountId = affiliateAccountId;
            contexts.add(ctx);
        }

        if (contexts.isEmpty()) {
            return;
        }

        // Step 4: Find existing Affiliate Terms by Account + Term (user-created terms)
        // Also include "Manual Review" in the query for the holding term lookup
        normalizedTerms.add('Manual Review');
        
        Map<String, Affiliate_Term__c> existingTerms = new Map<String, Affiliate_Term__c>();
        for (Affiliate_Term__c at : [
            SELECT Id, Affiliate_Account__c, Term__c, Term_Type__c, Year__c
            FROM Affiliate_Term__c
            WHERE Affiliate_Account__c IN :accountIds
              AND Term__c IN :normalizedTerms
        ]) {
            String termKey = at.Affiliate_Account__c + '|' + at.Term__c;
            existingTerms.put(termKey, at);
        }

        // Step 4b: Create Manual Review holding terms for accounts that don't have one
        // This is the ONLY type of Affiliate Term this handler creates
        List<Affiliate_Term__c> newManualReviewTerms = new List<Affiliate_Term__c>();
        Map<Id, Affiliate_Term__c> newManualReviewByAccount = new Map<Id, Affiliate_Term__c>();

        for (EventContext ctx : contexts) {
            String manualReviewKey = ctx.accountId + '|' + 'Manual Review';
            // Check if Manual Review term exists or is already queued for creation
            if (!existingTerms.containsKey(manualReviewKey) && !newManualReviewByAccount.containsKey(ctx.accountId)) {
                Affiliate_Term__c manualReviewTerm = new Affiliate_Term__c(
                    Affiliate_Account__c = ctx.accountId,
                    Term__c = 'Manual Review',
                    Term_Type__c = 'Manual Review',
                    Year__c = '0000'
                );
                newManualReviewTerms.add(manualReviewTerm);
                newManualReviewByAccount.put(ctx.accountId, manualReviewTerm);
            }
        }

        if (!newManualReviewTerms.isEmpty()) {
            insert newManualReviewTerms;
            // Add newly created Manual Review terms to the map
            for (Affiliate_Term__c mrTerm : newManualReviewTerms) {
                String termKey = mrTerm.Affiliate_Account__c + '|' + mrTerm.Term__c;
                existingTerms.put(termKey, mrTerm);
            }
        }

        // Step 5: Resolve which Affiliate Term to use for each event
        // If the term is valid AND a matching Affiliate Term exists, use it.
        // Otherwise, fall back to Manual Review.
        for (EventContext ctx : contexts) {
            // If term validation failed, go straight to Manual Review
            if (!ctx.termResult.isValid) {
                String manualReviewKey = ctx.accountId + '|' + 'Manual Review';
                Affiliate_Term__c manualReviewTerm = existingTerms.get(manualReviewKey);
                ctx.resolvedTermId = manualReviewTerm.Id;
                ctx.useManualReview = true;
                // Invalid reason already set by TermValidator
                continue;
            }
            
            // Term format is valid - look for matching Affiliate Term
            String termKey = ctx.accountId + '|' + ctx.termResult.normalizedTerm;
            Affiliate_Term__c matchedTerm = existingTerms.get(termKey);
            
            if (matchedTerm != null) {
                // Found a matching Affiliate Term
                ctx.resolvedTermId = matchedTerm.Id;
                ctx.useManualReview = false;
            } else {
                // No matching term found - fall back to Manual Review
                String manualReviewKey = ctx.accountId + '|' + 'Manual Review';
                Affiliate_Term__c manualReviewTerm = existingTerms.get(manualReviewKey);
                ctx.resolvedTermId = manualReviewTerm.Id;
                ctx.useManualReview = true;
                
                // Term format was valid but no matching Affiliate Term exists
                ctx.missingTermReason = 'No matching Affiliate Term found for: ' + ctx.termResult.normalizedTerm;
            }
        }

        // Step 6: Find existing Participations by Contact + Affiliate Term
        Set<Id> contactIdsForQuery = new Set<Id>();
        Set<Id> termIdsForQuery = new Set<Id>();
        for (EventContext ctx : contexts) {
            contactIdsForQuery.add(ctx.contactId);
            if (ctx.resolvedTermId != null) {
                termIdsForQuery.add(ctx.resolvedTermId);
            }
        }

        Map<String, Participation__c> existingParticipations = new Map<String, Participation__c>();
        for (Participation__c p : [
            SELECT Id, Participant__c, Affiliate_Term__c
            FROM Participation__c
            WHERE Participant__c IN :contactIdsForQuery
              AND Affiliate_Term__c IN :termIdsForQuery
        ]) {
            String pKey = p.Participant__c + '|' + p.Affiliate_Term__c;
            existingParticipations.put(pKey, p);
        }

        // Step 7: Build Participation records to upsert
        List<Participation__c> toUpsert = new List<Participation__c>();

        for (EventContext ctx : contexts) {
            if (ctx.resolvedTermId == null) {
                System.debug(LoggingLevel.ERROR,
                    'Could not resolve Affiliate Term for account ' + ctx.accountId +
                    ' and term ' + ctx.termResult.normalizedTerm);
                continue;
            }

            String pKey = ctx.contactId + '|' + ctx.resolvedTermId;
            Participation__c p = existingParticipations.get(pKey);

            if (p == null) {
                p = new Participation__c(
                    Participant__c = ctx.contactId,
                    Affiliate_Term__c = ctx.resolvedTermId,
                    Affiliate_Site__c = ctx.accountId,
                    Type__c = 'Student'
                );
            }

            // Set rollup values
            p.X1_1_Core_Offered__c = ctx.evt.X1_1_Core_Offered__c;
            p.X1_1_Core_Attended__c = ctx.evt.X1_1_Core_Attended__c;
            p.X1_1_Optional_Offered__c = ctx.evt.X1_1_Optional_Offered__c;
            p.X1_1_Optional_Attended__c = ctx.evt.X1_1_Optional_Attended__c;
            p.Communication_Core_Offered__c = ctx.evt.Communication_Core_Offered__c;
            p.Communication_Core_Attended__c = ctx.evt.Communication_Core_Attended__c;
            p.Communication_Optional_Offered__c = ctx.evt.Communication_Optional_Offered__c;
            p.Communication_Optional_Attended__c = ctx.evt.Communication_Optional_Attended__c;
            p.Core_Programming_Days_Offered__c = ctx.evt.Core_Programming_Days_Offered__c;
            p.Core_Programming_Days_Attended__c = ctx.evt.Core_Programming_Days_Attended__c;
            p.Non_Core_Programming_Days_Offered__c = ctx.evt.Non_Core_Programming_Days_Offered__c;
            p.Non_Core_Programming_Days_Attended__c = ctx.evt.Non_Core_Programming_Days_Attended__c;

            // Set Invalid Reason - either from term validation or from missing Affiliate Term
            if (ctx.missingTermReason != null) {
                p.Invalid_Reason__c = ctx.missingTermReason;
            } else {
                p.Invalid_Reason__c = ctx.termResult.invalidReason;
            }

            // Set writeback status - Mismatched Term if using Manual Review, otherwise Pending Writeback
            p.Writeback_Status__c = ctx.useManualReview ? 'Mismatched Term' : 'Pending Writeback';

            // Store the raw term text from the affiliate for reference
            p.BTSP_Provided_Term__c = ctx.evt.Term__c;

            // Store source IDs for traceability and writeback
            p.Source_Contact_ID__c = ctx.evt.Source_Contact_ID__c;
            p.Source_Org_ID__c = ctx.evt.Source_Org_ID__c;
            p.BTSP_Participation_ID__c = ctx.evt.Participation_ID__c;

            toUpsert.add(p);
        }

        if (!toUpsert.isEmpty()) {
            upsert toUpsert;
        }
    }

    /**
     * Internal context object to hold per-event processing data.
     */
    private class EventContext {
        public Affiliate_Participation_Sync__e evt;
        public TermValidator.TermResult termResult;
        public Integration_Key__c integrationKey;
        public Id contactId;
        public Id accountId;
        public Id resolvedTermId;
        public Boolean useManualReview = false;
        public String missingTermReason;
    }
}
