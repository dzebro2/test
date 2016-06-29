/**************************************************************************************
  Apex Class Name     : TestHPS_MyTeamsOpportunitiesController
  Version             : 1.0
  Function            : This is a test class for HPS_MyTeamsOpportunitiesController
  Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
*  
*************************************************************************************/
@isTest
private class TestHPS_MyTeamsOpportunitiesController {

    static testMethod void myUnitTest() {
        try{
             Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
             User testUser = TestClassUtiltity.CreateUserRecord(p.Id, 'testlgnadev@user.com', 'testUser', 'test@user.com');
             User testUser2 = TestClassUtiltity.CreateUserRecord(p.Id, 'testlgnadev1@user.com', 'testUser1', 'test1@user.com');
             testUser2.ManagerId = testUser.Id;
             update testUser2;
             system.runAs(testUser){
                Account testAccount = TestClassUtiltity.CreateAccountRecord('Test Account');
                testAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Group Account').getRecordTypeId();
                testAccount.status__c = 'Sold';
                testAccount.Fax = '1234567';
                update testAccount;
                
                //create Opportunity records
                list<Opportunity> opportunities = TestClassUtiltity.CreateOpportunities(testAccount.Id);
                opportunities[0].RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('New Sale').getRecordTypeId();
                opportunities[0].StageName = 'Prospective';
                
                opportunities[1].RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('New Sale').getRecordTypeId();
                opportunities[1].StageName = 'Closed Won';
                insert opportunities;
                system.debug('===Id=='+Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('New Sale').getRecordTypeId());
                for(Opportunity opp:opportunities){
                	system.debug('opp====='+opp);
                }
                
                //create Opportunity Team Members
                list<OpportunityTeamMember> oppTeamMembers = TestClassUtiltity.createOppTeamMember(opportunities[0].Id,testUser.Id);
                oppTeamMembers[0].TeamMemberRole = 'Sales Executive';
                insert oppTeamMembers;
                
                //create Product
                list<Product2> products = TestClassUtiltity.createProducts();
                insert products;
                
                //create Opportunity Products
                list<Opportunity_Product__c> opportunityProducts = TestClassUtiltity.createOppProducts(opportunities[0].Id,products[0].Id);
                opportunityProducts[0].Projected_Members__c = 5;
                insert opportunityProducts;
                test.StartTest(); 
                HPS_MyTeamsOpportunitiesController tempController = new HPS_MyTeamsOpportunitiesController();
                system.assertNotEquals(null,tempController.myTeamsOpportunitiesList);
                test.StopTest(); 
             }
        }catch(Exception e){
            throw e;
        }
    }
}