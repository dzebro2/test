/**************************************************************************************
  Apex Class Name     : TestHPS_MyTeamsActiveAccountsController
  Version             : 1.0
  Function            : This is a test class for HPS_MyTeamsActiveAccountsController
  Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
*  
*************************************************************************************/
@isTest
private class TestHPS_MyTeamsActiveAccountsController {

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
                
                //create AccountTeam Members
                list<AccountTeamMember> accountTeamMembers = TestClassUtiltity.createAccountTeamMembersRecords(testAccount.Id,testUser.Id);
                accountTeamMembers[0].TeamMemberRole = 'Account Executive';
                insert accountTeamMembers; 
                
                //create Strategic plans
                list<Strategic_Plan__c> strategicPlans = TestClassUtiltity.createStrategicPlans(testAccount.Id);
                strategicPlans[0].active__c = true;
                insert strategicPlans;
                test.StartTest(); 
                HPS_MyTeamsActiveAccountsController tempController = new HPS_MyTeamsActiveAccountsController();
                system.assertEquals(1,tempController.myTeamsActiveAccountsList.size());
                test.StopTest(); 
             }
         }catch(Exception e){
            throw e;
         }
    }
}