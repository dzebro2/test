/**************************************************************************************
  Apex Class Name     : TestHPS_UnasignedCasesController
  Version             : 1.0
  Function            : This is a test class for HPS_UnasignedCasesController
  Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
*  
*************************************************************************************/
@isTest
private class TestHPS_UnasignedCasesController {

    static testMethod void myUnitTest() {
        try{
             Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
             User testUser = TestClassUtiltity.CreateUserRecord(p.Id, 'testlgnadev@user.com', 'testUser', 'test@user.com');
             User testUser2 = TestClassUtiltity.CreateUserRecord(p.Id, 'testlgnadev1@user.com', 'testUser1', 'test1@user.com');
             testUser2.ManagerId = testUser.Id;
             update testUser2;
             User testUser3 = TestClassUtiltity.CreateUserRecord(p.Id, 'testlgnadev2@user.com', 'testUser2', 'test2@user.com');
             testUser3.ManagerId = testUser2.Id;
             update testUser3;
             Group tempGroup;
             Account testAccount;
             system.runAs(testUser){
                //crate Account
                testAccount = TestClassUtiltity.CreateAccountRecord('Test Account');
                testAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
                testAccount.status__c = 'Sold';
                testAccount.Fax = '1234567';
                update testAccount;
                
                tempGroup = new Group(Name = 'Proposal Delivery Unit',Type = 'Queue');
                insert tempGroup;
                
                GroupMember gm = new GroupMember(UserOrGroupId = UserInfo.getUserId(),GroupId=tempGroup.Id );
                insert gm;
                list<Case> cases = TestClassUtiltity.createCaseRecords(testAccount.Id);
                cases[0].OwnerId = tempGroup.Id;
		    	insert cases;
                test.StartTest(); 
                HPS_UnasignedCasesController tempController = new HPS_UnasignedCasesController();
                system.assertEquals(1,tempController.UnassignedCasesList.size());
                test.StopTest(); 
            }
                
            
           
            // 
        }catch(Exception e){
            throw e;
        }
    }
    

    
}