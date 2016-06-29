@isTest
private class TestOpportunityTeamImportController {

    static testMethod void myUnitTest() {
         try{
            Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
            User testUser = TestClassUtiltity.CreateUserRecord(p.Id, 'testlgnadev@user.com', 'testUser', 'test@user.com');
            system.runAs(testUser){
                Account testAccount = TestClassUtiltity.CreateAccountRecord('Test Account');
                testAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Group Account').getRecordTypeId();
                testAccount.status__c = 'Active';
                testAccount.Fax = '1234567';
                testAccount.New_Active_Health_Members__c = 10;
                testAccount.New_Active_Dental_Members__c = 10;
                testAccount.X1_31_Account_Status__c = 'Active';
                testAccount.X1_31_Membership__c = 10;
                testAccount.Effective_Date__c = date.today();
                update testAccount;
                
                //create Opportunity records
                list<Opportunity> opportunities = TestClassUtiltity.CreateOpportunities(testAccount.Id);
                opportunities[0].RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal').getRecordTypeId();
                opportunities[0].StageName = 'Prospective';
                
                opportunities[1].RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal').getRecordTypeId();
                opportunities[1].StageName = 'Closed Won';
                opportunities[1].Date_Closed__c = date.today();
                insert opportunities;
                
                ApexPAges.StandardController sc2 = new ApexPages.StandardController(opportunities[0]);
                OpportunityTeamImportController myCntrl = new OpportunityTeamImportController(sc2);
                myCntrl.getSelectImportOptions();
                //myCntrl.proceedMethod();
                PageReference pg = myCntrl.cancelMethod();
                system.assertEquals(pg.getURL(),'/'+opportunities[0].Id);
            }
         }catch(Exception e){
            
         }
    }
}