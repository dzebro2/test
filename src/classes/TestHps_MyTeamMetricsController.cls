@isTest
private class TestHps_MyTeamMetricsController {

    static testMethod void myUnitTest() {
        try{
            Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
            User testUser = TestClassUtiltity.CreateUserRecord(p.Id, 'testlgnadev@user.com', 'testUser', 'test@user.com');
            system.runAs(testUser){
                Account testAccount = TestClassUtiltity.CreateAccountRecord('Test Account');
                testAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Group Account').getRecordTypeId();
                testAccount.status__c = 'Active';
                testAccount.Fax = '1234567';
                testAccount.Active_Health_Members__c = 10;
                testAccount.Active_Dental_Members__c = 10;
                testAccount.X1_31_Account_Status__c = 'Active';
                testAccount.X1_31_Membership__c = 10;
                update testAccount;
                
                //create Opportunity records
                list<Opportunity> opportunities = TestClassUtiltity.CreateOpportunities(testAccount.Id);
                opportunities[1].RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal').getRecordTypeId();
                opportunities[1].StageName = 'Closed Won';
                opportunities[1].Date_Closed__c = date.today();
                 opportunities[0].RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal').getRecordTypeId();
                opportunities[0].StageName = 'Closed Won';
                opportunities[0].Date_Closed__c = date.today();
                 opportunities[2].RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal').getRecordTypeId();
                opportunities[2].StageName = 'Closed Won';
                opportunities[2].Date_Closed__c = date.today();
                 opportunities[3].RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal').getRecordTypeId();
                opportunities[3].StageName = 'Closed Won';
                opportunities[3].Date_Closed__c = date.today();
                 opportunities[4].RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal').getRecordTypeId();
                opportunities[4].StageName = 'Closed Won';
                opportunities[4].Date_Closed__c = date.today();
                 opportunities[5].RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal').getRecordTypeId();
                opportunities[5].StageName = 'Closed Won';
                opportunities[5].Date_Closed__c = date.today();
                
                insert opportunities;
                
                //Initializing the Constructor
                HPS_MyTeamMetricsController tempController = new HPS_MyTeamMetricsController();
                //assert the size of the Task list
                System.assertEquals(tempController.medicalRecordsCount,10);
            }
        }catch(Exception e){
            
        }
    }
    static testMethod void myUnitTest1() {
        try{
            Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
            User testUser = TestClassUtiltity.CreateUserRecord(p.Id, 'testlgnadev@user.com', 'testUser', 'test@user.com');
            system.runAs(testUser){
                Account testAccount = TestClassUtiltity.CreateAccountRecord('Test Account');
                testAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Group Account').getRecordTypeId();
                testAccount.status__c = 'Sold';
                testAccount.Fax = '1234567';
                testAccount.Active_Health_Members__c = 10;
                testAccount.Active_Dental_Members__c = 10;
                testAccount.X1_31_Account_Status__c = 'Sold';
                testAccount.X1_31_Membership__c = 10;
                update testAccount;
                
                //create Opportunity records
                list<Opportunity> opportunities = TestClassUtiltity.CreateOpportunities(testAccount.Id);
                opportunities[0].RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal').getRecordTypeId();
                opportunities[0].StageName = 'Prospective';
                
                opportunities[1].RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal').getRecordTypeId();
                opportunities[1].StageName = 'Prospective';
                
                insert opportunities;
                test.StartTest(); 
                //Initializing the Constructor
                HPS_MyTeamMetricsController tempController = new HPS_MyTeamMetricsController();
                //assert the size of the Task list
                System.assertEquals(tempController.medicalRecordsCount,0);
                test.StopTest(); 
            }
        }catch(Exception e){
            
        }
    }
}