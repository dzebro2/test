/**************************************************************************************
  Apex Class Name     : TestHPS_MyTeamsCasesController
  Version             : 1.0
  Function            : This is a test class for HPS_MyTeamsCasesController
  Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
*  
*************************************************************************************/
@isTest
private class TestHPS_MyTeamsCasesController {

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
                testAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Group Account').getRecordTypeId();
                testAccount.status__c = 'Sold';
                testAccount.Fax = '1234567';
                update testAccount;
                
                //create Case
                list<Case> cases = TestClassUtiltity.createCaseRecords(testAccount.Id);
                insert cases;
                test.StartTest(); 
                HPS_MyTeamsCasesController tempController = new HPS_MyTeamsCasesController();
                system.assertEquals(1,tempController.myTeamsCasesList.size());
                test.StopTest(); 
             }  
        }catch(Exception e){
            throw e;
        }        
    }
}