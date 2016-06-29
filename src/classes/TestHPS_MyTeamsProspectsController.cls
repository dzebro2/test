/**************************************************************************************
  Apex Class Name     : TestHPS_MyTeamsProspectsController
  Version             : 1.0
  Function            : This is a test class for HPS_MyTeamsProspectsController
  Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
*  
*************************************************************************************/
@isTest
private class TestHPS_MyTeamsProspectsController {

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
                
                //create AccountTeam Members
                list<AccountTeamMember> accountTeamMembers = TestClassUtiltity.createAccountTeamMembersRecords(testAccount.Id,testUser.Id);
                accountTeamMembers[0].TeamMemberRole = 'Sales Executive';
                insert accountTeamMembers; 
                
                //create Strategic plans
                list<Strategic_Plan__c> strategicPlans = TestClassUtiltity.createStrategicPlans(testAccount.Id);
                strategicPlans[0].active__c = true;
                insert strategicPlans;
                test.StartTest(); 
                HPS_MyTeamsProspectsController tempController = new HPS_MyTeamsProspectsController();
                system.assertEquals(1,tempController.myTeamsProspectsList.size());
                test.StopTest(); 
             }
        }catch(Exception e){
            throw e;
        }
    }
}