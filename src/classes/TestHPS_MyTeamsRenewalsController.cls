/**************************************************************************************
  Apex Class Name     : TestHPS_MyTeamsRenewalsController
  Version             : 1.0
  Function            : This is a test class for HPS_MyTeamsRenewalsController
  Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
*  
*************************************************************************************/
@isTest
private class TestHPS_MyTeamsRenewalsController {

    static testMethod void myUnitTest() {
        try{
             Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
             User testUser = TestClassUtiltity.CreateUserRecord(p.Id, 'testlgnadev@user.com', 'testUser', 'test@user.com');
             User testUser2 = TestClassUtiltity.CreateUserRecord(p.Id, 'testlgnadev1@user.com', 'testUser1', 'test1@user.com');
             testUser2.ManagerId = testUser.Id;
             update testUser2;
             system.runAs(testUser){
                //crate Account
                Account testAccount = TestClassUtiltity.CreateAccountRecord('Test Account');
                testAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
                testAccount.status__c = 'Sold';
                testAccount.Fax = '1234567';
                update testAccount;
                
                //create Opportunity records
                list<Opportunity> opportunities = TestClassUtiltity.CreateOpportunities(testAccount.Id);
                opportunities[0].RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal').getRecordTypeId();
                opportunities[0].StageName = 'Prospective';
                
                opportunities[1].RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal').getRecordTypeId();
                opportunities[1].StageName = 'Closed Won';
                insert opportunities;
                
                //create Opportunity Team Members
                list<OpportunityTeamMember> oppTeamMembers = TestClassUtiltity.createOppTeamMember(opportunities[0].Id,testUser.Id);
                oppTeamMembers[0].TeamMemberRole = 'Account Executive';
                insert oppTeamMembers;
                
                //create Product
                list<Product2> products = TestClassUtiltity.createProducts();
                insert products;
                
                //create Opportunity Products
                list<Opportunity_Product__c> opportunityProducts = TestClassUtiltity.createOppProducts(opportunities[0].Id,products[0].Id);
                opportunityProducts[0].Projected_Members__c = 5;
                insert opportunityProducts;
                test.StartTest(); 
                HPS_MyTeamsRenewalsController tempController = new HPS_MyTeamsRenewalsController();
                System.assertNotEquals(null,tempController.myTeamsRenewalsList.size());
                test.StopTest(); 
             }
             
        }catch(Exception e){
            throw e;
        }    
    }
}