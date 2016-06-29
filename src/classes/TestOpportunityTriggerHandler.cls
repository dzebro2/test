/**************************************************************************************
  Apex Class Name     : TestOpportunityTriggerHandler
  Version             : 1.0
  Function            : This is a test class for OpportunityTriggerHandler
  Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
*  
*************************************************************************************/
@isTest
private class TestOpportunityTriggerHandler {
    
    static testMethod void myUnitTest() {
    Test.startTest();
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
         User testUser = TestClassUtiltity.CreateUserRecord(p.Id, 'testlgnadev@user.com', 'testUser', 'test@user.com');
         system.runAs(testUser){
            //crate Account
            Account testAccount = TestClassUtiltity.CreateAccountRecord('Test Account');
            testAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Group Account').getRecordTypeId();
            // Id renewalRecordTypeId = opportunityRecordTypeInfo.get('Renewal').getRecordTypeId();
            testAccount.status__c = 'Sold';
            testAccount.Fax = '1234567';
            update testAccount;
            
            TestClassUtiltity.createPlaybookSettingsFields();
            
            list<Playbook__c> playBooks = TestClassUtiltity.createPlayBookRecords();
            insert playBooks;
            
            list<Stage__c> stages = TestClassUtiltity.createStageRecords(playBooks[0].Id);
            insert stages;
            
            list<Substage__c> substages = TestClassUtiltity.createSubStageRecords(stages[0].Id);
            insert substages;
            
            list<Task__c> tasks = TestClassUtiltity.createTaskSubStageRecords(substages[0].Id);
            insert tasks;
           
           
            //create Opportunity records
            list<Opportunity> opportunities = TestClassUtiltity.CreateOpportunities(testAccount.Id);
            opportunities[0].RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal').getRecordTypeId();
            opportunities[0].StageName = 'Closed Won';
            opportunities[0].Rate_End_Date__c = System.today()+1;
            
            opportunities[1].RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('New Sale').getRecordTypeId();
            opportunities[1].StageName = 'Prospective';
            insert opportunities;
            
            list<Opportunity> updatedOpps = [select Id,Playbook__c from Opportunity where Id  =:opportunities[1].Id];
            //system.assertEquals(updatedOpps[0].Playbook__c,playBooks[0].Id);
            
            
            opportunities[1].Playbook__c = null;
            update opportunities[1];
            system.assertEquals(opportunities[1].Playbook__c,null);
            Id BANonBluStarRecordTypeId ;
            for(RecordType rt : [select Id from RecordType where SobjectType = 'Product2' and DeveloperName = :ConstantsController.HCSCNonBlueStarRecordType]){
                BANonBluStarRecordTypeId = rt.Id;
            }
            //create Product
            list<Product2> products = TestClassUtiltity.createProducts();
            products[0].RecordTypeId = BANonBluStarRecordTypeId;
            insert products;
            
            //create Opportunity Products
            list<Opportunity_Product__c> opportunityProducts = TestClassUtiltity.createOppProducts(opportunities[0].Id,products[0].Id);
            opportunityProducts[0].Projected_Members__c = 5;            
            opportunityProducts[0].Excluded__c = false ;
            insert opportunityProducts;
            
            list<Opportunity> opportunities1 = TestClassUtiltity.CreateOpportunities(testAccount.Id);
            opportunities1[0].RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal').getRecordTypeId();
            opportunities1[0].StageName = 'Closed Won';
            opportunities1[0].Playbook__c = playBooks[1].Id;
            insert opportunities1;
            
            OpportunityTriggerHandler.insertOpportunityProducts(opportunities);
            Test.StopTest();
         }
    }
     
    static testMethod void myUnitTest2() {
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
         User testUser = TestClassUtiltity.CreateUserRecord(p.Id, 'testlgnadev@user.com', 'testUser', 'test@user.com');
         system.runAs(testUser){
            //crate Account
            Account testAccount = TestClassUtiltity.CreateAccountRecord('Test Account');
            testAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
            // Id renewalRecordTypeId = opportunityRecordTypeInfo.get('Renewal').getRecordTypeId();
            testAccount.status__c = 'Sold';
            testAccount.Fax = '1234567';
            testAccount.Ceded__c = true;
            update testAccount;
            
            //create Opportunity records
            list<Opportunity> opportunities = TestClassUtiltity.CreateOpportunities(testAccount.Id);
            opportunities[0].RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('New Sale').getRecordTypeId();
            opportunities[0].StageName = 'Prospective';
            opportunities[0].Rate_End_Date__c = System.today()+1;
                       
            insert opportunities[0];
            system.assertEquals(opportunities[0].Playbook__c,null);
            list<Case> cases = TestClassUtiltity.createCaseRecords(testAccount.Id);
            cases[0].RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Cede').getRecordTypeId();
            cases[0].Opportunity_Name__c = opportunities[0].Id;
            
            insert cases[0];
            test.startTest();
                opportunities[0].StageName = 'Won';
                opportunities[0].Primary_Closed_Reason__c = 'Won';               
                update opportunities[0];
            test.stopTest();
         }
    }
}