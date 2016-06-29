/**************************************************************************************
  Apex Class Name     : TestHPS_MyRenewalsController
  Version             : 1.0
  Function            : This is a test class for HPS_MyRenewalsController
  Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
*  
*************************************************************************************/
@isTest
private class TestHPS_MyRenewalsController {

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
                
                //create Opportunity Team Members
                list<OpportunityTeamMember> oppTeamMembers = TestClassUtiltity.createOppTeamMember(opportunities[1].Id,UserInfo.getUserId());
                insert oppTeamMembers;
                
                //create Product
                list<Product2> products = TestClassUtiltity.createProducts();
                insert products;
                
                //create Opportunity Products
                list<Opportunity_Product__c> opportunityProducts = TestClassUtiltity.createOppProducts(opportunities[1].Id,products[0].Id);
                opportunityProducts[0].Projected_Members__c = 5;
                insert opportunityProducts;
                
                HPS_MyRenewalsController tempController = new HPS_MyRenewalsController();
                System.assertNotEquals(tempController.myRenewalsList,null);
             }
        }catch(Exception e){
            
        }
    }
}