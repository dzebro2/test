/**************************************************************************************
  Apex Class Name     : TestHPS_MyGoalsController
  Version             : 1.0
  Function            : This is a test class for HPS_MyGoalsController
  Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
*  
*************************************************************************************/
@isTest
public with sharing class TestHPS_MyGoalsController {
    static testMethod void myUnitTest() {
        try{
             Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
             User testUser = TestClassUtiltity.CreateUserRecord(p.Id, 'testlgnadev@user.com', 'testUser', 'test@user.com');
             system.runAs(testUser){
                //crate Account
                Account testAccount = TestClassUtiltity.CreateAccountRecord('Test Account');
                testAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Group Account').getRecordTypeId();
                testAccount.status__c = 'Sold';
                testAccount.Fax = '1234567';
                update testAccount;
                
                //create Opportunity records
                list<Opportunity> opportunities = TestClassUtiltity.CreateOpportunities(testAccount.Id);
                opportunities[0].RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal').getRecordTypeId();
                opportunities[0].StageName = 'Closed Won';
                
               
                opportunities[1].RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal').getRecordTypeId();
                opportunities[1].StageName = 'Prospective';
                insert opportunities;
                test.StartTest(); 
                HPS_MyGoalsController tempController = new HPS_MyGoalsController();
                tempController.salesPipelineReportObj = new List<Report>();
                system.assertEquals(tempController.wonOpportunities !=null , true);
                test.StopTest(); 
             }
         }catch(Exception e){
            throw e;
         }    
    }
}