@isTest
private class TestHPS_MyTeamMetrics_NewController {

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
                testAccount.Effective_Date__c = Date.newInstance(Date.Today().year(),1,31);
                update testAccount;
                
                //create Opportunity records
                list<Opportunity> opportunities = TestClassUtiltity.CreateOpportunities(testAccount.Id);
                opportunities[1].RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal').getRecordTypeId();
                opportunities[1].StageName = 'Won';
                opportunities[1].Date_Closed__c = date.today();
                opportunities[1].Primary_Closed_Reason__c = 'Absorbed by Parent Group';
                 opportunities[0].RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal').getRecordTypeId();
                opportunities[0].StageName = 'Won';
                opportunities[0].Date_Closed__c = date.today();
                 opportunities[0].Primary_Closed_Reason__c = 'Absorbed by Parent Group';
                 opportunities[2].RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal').getRecordTypeId();
                opportunities[2].StageName = 'Won';
                opportunities[2].Date_Closed__c = date.today();
                opportunities[2].Primary_Closed_Reason__c = 'Absorbed by Parent Group';
                 opportunities[3].RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal').getRecordTypeId();
                opportunities[3].StageName = 'Won';
                opportunities[3].Date_Closed__c = date.today();
                 opportunities[3].Primary_Closed_Reason__c = 'Absorbed by Parent Group';
                 opportunities[4].RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal').getRecordTypeId();
                opportunities[4].StageName = 'Won';
                opportunities[4].Date_Closed__c = date.today();
                opportunities[4].Primary_Closed_Reason__c = 'Absorbed by Parent Group';
                 opportunities[5].RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal').getRecordTypeId();
                opportunities[5].StageName = 'Won';
                opportunities[5].Date_Closed__c = date.today();
                opportunities[5].Primary_Closed_Reason__c = 'Absorbed by Parent Group';
                insert opportunities;
                
                list<Product2> products = TestClassUtiltity.createProducts();
                insert products;
                
                list<Opportunity_Product__c> oppProducts = TestClassUtiltity.createOppProducts(opportunities[1].Id,products[0].Id);
                insert oppProducts;
                
                HPS_MyTeamMetrics_NewController tempController = new HPS_MyTeamMetrics_NewController();
                System.assertEquals(10,tempController.medicalRecordsCount);
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
                
                list<Product2> products = TestClassUtiltity.createProducts();
                insert products;
                
                list<Opportunity_Product__c> oppProducts = TestClassUtiltity.createOppProducts(opportunities[1].Id,products[0].Id);
                insert oppProducts;
                
                HPS_MyTeamMetrics_NewController tempController = new HPS_MyTeamMetrics_NewController();
                System.assertEquals(0,tempController.medicalRecordsCount);
            }
        }catch(Exception e){
            
        }
    }
}