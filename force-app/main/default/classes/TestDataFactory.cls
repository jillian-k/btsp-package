/**
 * TestDataFactory
 * Shared test data factory for all test classes.
 * Creates test records for the Participation Sync feature.
 */
@IsTest
public class TestDataFactory {

    /**
     * Create a test Account.
     * @param name Account name
     * @return Inserted Account
     */
    public static Account createAccount(String name) {
        Account a = new Account(Name = name);
        insert a;
        return a;
    }

    /**
     * Create a test Contact linked to an Account.
     * @param firstName First name
     * @param lastName Last name
     * @param accountId Account to link to
     * @return Inserted Contact
     */
    public static Contact createContact(String firstName, String lastName, Id accountId) {
        Contact c = new Contact(
            FirstName = firstName,
            LastName = lastName,
            AccountId = accountId
        );
        insert c;
        return c;
    }

    /**
     * Create a test Integration Key with Affiliate_Org record type.
     * @param contactId Contact lookup
     * @param sourceContactId Source Contact ID from affiliate
     * @param sourceOrgId Source Org ID from affiliate
     * @param typeValue Type__c value (e.g. 'BTSP')
     * @param writebackStatus Writeback_Status__c value (e.g. 'Complete')
     * @return Inserted Integration_Key__c
     */
    public static Integration_Key__c createIntegrationKey(
        Id contactId,
        String sourceContactId,
        String sourceOrgId,
        String typeValue,
        String writebackStatus
    ) {
        Id rtId = Schema.SObjectType.Integration_Key__c
            .getRecordTypeInfosByDeveloperName()
            .get('Affiliate_Org')
            .getRecordTypeId();

        Integration_Key__c ik = new Integration_Key__c(
            Contact__c = contactId,
            Source_Contact_ID__c = sourceContactId,
            Source_Org_ID__c = sourceOrgId,
            Type__c = typeValue,
            Writeback_Status__c = writebackStatus,
            RecordTypeId = rtId
        );
        insert ik;
        return ik;
    }

    /**
     * Create a test Affiliate Term.
     * @param accountId Affiliate Account (master-detail parent)
     * @param term Term picklist value
     * @param termType Term Type picklist value
     * @param year Year picklist value
     * @return Inserted Affiliate_Term__c
     */
    public static Affiliate_Term__c createAffiliateTerm(
        Id accountId,
        String term,
        String termType,
        String year
    ) {
        Affiliate_Term__c at = new Affiliate_Term__c(
            Affiliate_Account__c = accountId,
            Term__c = term,
            Term_Type__c = termType,
            Year__c = year
        );
        insert at;
        return at;
    }

    /**
     * Create a test Participation record.
     * @param contactId Participant
     * @param affiliateTermId Affiliate Term (master-detail parent)
     * @param affiliateSiteId Affiliate Site (Account)
     * @return Inserted Participation__c
     */
    public static Participation__c createParticipation(
        Id contactId,
        Id affiliateTermId,
        Id affiliateSiteId
    ) {
        Participation__c p = new Participation__c(
            Participant__c = contactId,
            Affiliate_Term__c = affiliateTermId,
            Affiliate_Site__c = affiliateSiteId,
            Type__c = 'Student'
        );
        insert p;
        return p;
    }

    /**
     * Build a platform event record (not published -- for use in direct handler testing).
     * @param sourceContactId Source Contact ID
     * @param sourceOrgId Source Org ID
     * @param term Term text
     * @param btspParticipationId Source BTSP Participation ID
     * @return Affiliate_Participation_Sync__e (not published)
     */
    public static Affiliate_Participation_Sync__e buildSyncEvent(
        String sourceContactId,
        String sourceOrgId,
        String term,
        String btspParticipationId
    ) {
        return new Affiliate_Participation_Sync__e(
            Source_Contact_ID__c = sourceContactId,
            Source_Org_ID__c = sourceOrgId,
            Term__c = term,
            BTSP_Participation_ID__c = btspParticipationId,
            X1_1_Core_Offered__c = 10,
            X1_1_Core_Attended__c = 8,
            X1_1_Optional_Offered__c = 5,
            X1_1_Optional_Attended__c = 4,
            Communication_Core_Offered__c = 12,
            Communication_Core_Attended__c = 11,
            Communication_Optional_Offered__c = 6,
            Communication_Optional_Attended__c = 5,
            Core_Programming_Days_Offered__c = 20,
            Core_Programming_Days_Attended__c = 18,
            Non_Core_Programming_Days_Offered__c = 15,
            Non_Core_Programming_Days_Attended__c = 13
        );
    }
}
