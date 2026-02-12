/**
 * ParticipationSyncHandlerTest
 * Tests the ParticipationSyncHandler invocable method with various scenarios.
 * Uses TestDataFactory for all test data creation.
 */
@IsTest
private class ParticipationSyncHandlerTest {

    private static final String SOURCE_CONTACT_ID = '003000000000001';
    private static final String SOURCE_ORG_ID = '00D000000000001';
    private static final String BTSP_PARTICIPATION_ID = 'a0B000000000001';

    /**
     * Test: Valid School Year term -> Participation created with correct rollup values
     */
    @IsTest
    static void testValidSchoolYear_CreatesParticipation() {
        Account acct = TestDataFactory.createAccount('Test Affiliate');
        Contact con = TestDataFactory.createContact('Test', 'Student', acct.Id);
        TestDataFactory.createIntegrationKey(
            con.Id, SOURCE_CONTACT_ID, SOURCE_ORG_ID, 'BTSP', 'Complete'
        );

        // Create the Affiliate Term that the handler should find
        TestDataFactory.createAffiliateTerm(acct.Id, '2024/2025 SY', 'School Year', '2024');

        Affiliate_Participation_Sync__e evt = TestDataFactory.buildSyncEvent(
            SOURCE_CONTACT_ID, SOURCE_ORG_ID, '2024/2025 SY', BTSP_PARTICIPATION_ID
        );

        Test.startTest();
        ParticipationSyncHandler.handleEvents(new List<Affiliate_Participation_Sync__e>{ evt });
        Test.stopTest();

        List<Participation__c> parts = [
            SELECT Participant__c, Affiliate_Site__c, Type__c, Invalid_Reason__c,
                   Writeback_Status__c, BTSP_Provided_Term__c,
                   X1_1_Core_Offered__c, X1_1_Core_Attended__c,
                   Core_Programming_Days_Offered__c, Core_Programming_Days_Attended__c
            FROM Participation__c
            WHERE Participant__c = :con.Id
        ];

        System.assertEquals(1, parts.size(), 'Should create one Participation');
        Participation__c p = parts[0];
        System.assertEquals(acct.Id, p.Affiliate_Site__c, 'Affiliate Site should match Account');
        System.assertEquals('Student', p.Type__c, 'Type should be Student');
        System.assertEquals(null, p.Invalid_Reason__c, 'No invalid reason for valid term');
        System.assertEquals('Pending Writeback', p.Writeback_Status__c, 'Valid term should be Pending Writeback');
        System.assertEquals('2024/2025 SY', p.BTSP_Provided_Term__c, 'Should store raw term text');
        System.assertEquals(10, p.X1_1_Core_Offered__c, 'Rollup value should match');
        System.assertEquals(8, p.X1_1_Core_Attended__c, 'Rollup value should match');
        System.assertEquals(20, p.Core_Programming_Days_Offered__c, 'Rollup value should match');
        System.assertEquals(18, p.Core_Programming_Days_Attended__c, 'Rollup value should match');
    }

    /**
     * Test: Valid Summer term -> Participation created
     */
    @IsTest
    static void testValidSummer_CreatesParticipation() {
        Account acct = TestDataFactory.createAccount('Test Affiliate');
        Contact con = TestDataFactory.createContact('Test', 'Student', acct.Id);
        TestDataFactory.createIntegrationKey(
            con.Id, SOURCE_CONTACT_ID, SOURCE_ORG_ID, 'BTSP', 'Complete'
        );

        TestDataFactory.createAffiliateTerm(acct.Id, '2024 Summer', 'Summer', '2024');

        Affiliate_Participation_Sync__e evt = TestDataFactory.buildSyncEvent(
            SOURCE_CONTACT_ID, SOURCE_ORG_ID, '2024 Summer', BTSP_PARTICIPATION_ID
        );

        Test.startTest();
        ParticipationSyncHandler.handleEvents(new List<Affiliate_Participation_Sync__e>{ evt });
        Test.stopTest();

        List<Participation__c> parts = [
            SELECT Participant__c, Type__c, Writeback_Status__c, BTSP_Provided_Term__c
            FROM Participation__c
            WHERE Participant__c = :con.Id
        ];
        System.assertEquals(1, parts.size(), 'Should create one Participation');
        System.assertEquals('Student', parts[0].Type__c);
        System.assertEquals('Pending Writeback', parts[0].Writeback_Status__c, 'Valid term should be Pending Writeback');
        System.assertEquals('2024 Summer', parts[0].BTSP_Provided_Term__c, 'Should store raw term text');
    }

    /**
     * Test: Invalid term -> Affiliate Term created with Manual Review, Participation has Invalid Reason
     */
    @IsTest
    static void testInvalidTerm_ManualReview() {
        Account acct = TestDataFactory.createAccount('Test Affiliate');
        Contact con = TestDataFactory.createContact('Test', 'Student', acct.Id);
        TestDataFactory.createIntegrationKey(
            con.Id, SOURCE_CONTACT_ID, SOURCE_ORG_ID, 'BTSP', 'Complete'
        );

        Affiliate_Participation_Sync__e evt = TestDataFactory.buildSyncEvent(
            SOURCE_CONTACT_ID, SOURCE_ORG_ID, '2020-2021 SY', BTSP_PARTICIPATION_ID
        );

        Test.startTest();
        ParticipationSyncHandler.handleEvents(new List<Affiliate_Participation_Sync__e>{ evt });
        Test.stopTest();

        // Verify the Manual Review Affiliate Term was created
        List<Affiliate_Term__c> terms = [
            SELECT Term__c, Term_Type__c, Year__c
            FROM Affiliate_Term__c
            WHERE Affiliate_Account__c = :acct.Id AND Term_Type__c = 'Manual Review'
        ];
        System.assertEquals(1, terms.size(), 'Should create Manual Review term');
        System.assertEquals('Manual Review', terms[0].Term__c);
        System.assertEquals('0000', terms[0].Year__c);

        // Verify Participation has invalid reason and mismatched term status
        List<Participation__c> parts = [
            SELECT Invalid_Reason__c, Writeback_Status__c, BTSP_Provided_Term__c
            FROM Participation__c
            WHERE Participant__c = :con.Id
        ];
        System.assertEquals(1, parts.size(), 'Should create Participation');
        System.assertEquals('Uses hyphen instead of slash', parts[0].Invalid_Reason__c,
            'Invalid reason should describe the issue');
        System.assertEquals('Mismatched Term', parts[0].Writeback_Status__c,
            'Invalid term should have Mismatched Term status');
        System.assertEquals('2020-2021 SY', parts[0].BTSP_Provided_Term__c,
            'Should store the raw term text from affiliate');
    }

    /**
     * Test: Existing Participation -> rollup values updated (not duplicated)
     */
    @IsTest
    static void testExistingParticipation_Updated() {
        Account acct = TestDataFactory.createAccount('Test Affiliate');
        Contact con = TestDataFactory.createContact('Test', 'Student', acct.Id);
        TestDataFactory.createIntegrationKey(
            con.Id, SOURCE_CONTACT_ID, SOURCE_ORG_ID, 'BTSP', 'Complete'
        );

        Affiliate_Term__c term = TestDataFactory.createAffiliateTerm(
            acct.Id, '2024/2025 SY', 'School Year', '2024'
        );
        Participation__c existing = TestDataFactory.createParticipation(
            con.Id, term.Id, acct.Id
        );
        existing.X1_1_Core_Offered__c = 5;
        update existing;

        Affiliate_Participation_Sync__e evt = TestDataFactory.buildSyncEvent(
            SOURCE_CONTACT_ID, SOURCE_ORG_ID, '2024/2025 SY', BTSP_PARTICIPATION_ID
        );

        Test.startTest();
        ParticipationSyncHandler.handleEvents(new List<Affiliate_Participation_Sync__e>{ evt });
        Test.stopTest();

        List<Participation__c> parts = [
            SELECT X1_1_Core_Offered__c, Writeback_Status__c, BTSP_Provided_Term__c
            FROM Participation__c
            WHERE Participant__c = :con.Id
        ];
        System.assertEquals(1, parts.size(), 'Should NOT create a duplicate');
        System.assertEquals(10, parts[0].X1_1_Core_Offered__c, 'Should update to new value');
        System.assertEquals('Pending Writeback', parts[0].Writeback_Status__c,
            'Updated record should be Pending Writeback');
        System.assertEquals('2024/2025 SY', parts[0].BTSP_Provided_Term__c,
            'Should store raw term text');
    }

    /**
     * Test: Missing Integration Key -> event skipped gracefully
     */
    @IsTest
    static void testMissingIntegrationKey_Skipped() {
        Affiliate_Participation_Sync__e evt = TestDataFactory.buildSyncEvent(
            'NONEXISTENT001', 'NONEXISTENT002', '2024/2025 SY', BTSP_PARTICIPATION_ID
        );

        Test.startTest();
        ParticipationSyncHandler.handleEvents(new List<Affiliate_Participation_Sync__e>{ evt });
        Test.stopTest();

        List<Participation__c> parts = [SELECT Id FROM Participation__c];
        System.assertEquals(0, parts.size(), 'No Participation should be created');
    }

    /**
     * Test: Bulk -- multiple events processed in one transaction
     */
    @IsTest
    static void testBulk_MultipleEvents() {
        Account acct = TestDataFactory.createAccount('Test Affiliate');
        Contact con1 = TestDataFactory.createContact('Test', 'Student1', acct.Id);
        Contact con2 = TestDataFactory.createContact('Test', 'Student2', acct.Id);

        String srcContact1 = '003000000000011';
        String srcContact2 = '003000000000012';

        TestDataFactory.createIntegrationKey(
            con1.Id, srcContact1, SOURCE_ORG_ID, 'BTSP', 'Complete'
        );
        TestDataFactory.createIntegrationKey(
            con2.Id, srcContact2, SOURCE_ORG_ID, 'BTSP', 'Complete'
        );

        TestDataFactory.createAffiliateTerm(acct.Id, '2024/2025 SY', 'School Year', '2024');

        List<Affiliate_Participation_Sync__e> events = new List<Affiliate_Participation_Sync__e>{
            TestDataFactory.buildSyncEvent(srcContact1, SOURCE_ORG_ID, '2024/2025 SY', 'a0B000000000011'),
            TestDataFactory.buildSyncEvent(srcContact2, SOURCE_ORG_ID, '2024/2025 SY', 'a0B000000000012')
        };

        Test.startTest();
        ParticipationSyncHandler.handleEvents(events);
        Test.stopTest();

        List<Participation__c> parts = [SELECT Id FROM Participation__c];
        System.assertEquals(2, parts.size(), 'Should create two Participations');
    }

    /**
     * Test: Empty list -> no errors
     */
    @IsTest
    static void testEmptyList_NoError() {
        Test.startTest();
        ParticipationSyncHandler.handleEvents(new List<Affiliate_Participation_Sync__e>());
        Test.stopTest();
        // No assertion needed -- just verifying no exception
    }

    /**
     * Test: Null list -> no errors
     */
    @IsTest
    static void testNullList_NoError() {
        Test.startTest();
        ParticipationSyncHandler.handleEvents(null);
        Test.stopTest();
        // No assertion needed -- just verifying no exception
    }
}
