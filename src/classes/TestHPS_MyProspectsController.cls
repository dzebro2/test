/**************************************************************************************
  Apex Class Name     : TestHPS_MyProspectsController
  Version             : 1.0
  Function            : This is a test class for HPS_MyProspectsController
  Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
*  
*************************************************************************************/
@isTest
private class TestHPS_MyProspectsController {

    static testMethod void myUnitTest() {
        try{
             Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
             User testUser = TestClassUtiltity.CreateUserRecord(p.Id, 'testlgnadev@user.com', 'testUser', 'test@user.com');
             system.runAs(testUser){
                Account testAccount = TestClassUtiltity.CreateAccountRecord('Test Account');
                testAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
                testAccount.status__c = 'Sold';
                testAccount.Fax = '1234567';
                update testAccount;
                
                list<AccountTeamMember> accountTeamMembers = TestClassUtiltity.createAccountTeamMembersRecords(testAccount.Id,testUser.Id);
                insert accountTeamMembers; 
                 
                 //create Strategic plans
                list<Strategic_Plan__c> strategicPlans = TestClassUtiltity.createStrategicPlans(testAccount.Id);
                insert strategicPlans;
                
                //create Activities
                list<Event> events = TestClassUtiltity.createEvents(testAccount.Id);
                insert events;
                
                HPS_MyProspectsController tempController = new HPS_MyProspectsController();
                system.assertEquals(tempController.myProspectsList.size(),1);
             }
        }catch(Exception e){
            throw e;
        }
    }
}