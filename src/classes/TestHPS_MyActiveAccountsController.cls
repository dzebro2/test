/**************************************************************************************
  Apex Class Name     : TestHPS_MyActiveAccountsController
  Version             : 1.0
  Function            : This is a test class for HPS_MyActiveAccountsController .
  Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
*  
*************************************************************************************/
@isTest
public class TestHPS_MyActiveAccountsController {

    static testMethod void myUnitTest() {
    	Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
	     User testUser = TestClassUtiltity.CreateUserRecord(p.Id, 'testlgnadev@user.com', 'testUser', 'test@user.com');
        system.runAs(testUser){
	        Account testAccount = TestClassUtiltity.CreateAccountRecord('Test Account');
	        testAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Group Account').getRecordTypeId();
	    	testAccount.status__c = 'Sold';
	    	testAccount.Fax = '1234567';
	    	update testAccount;
    		 list<AccountTeamMember> accountTeamMembers = TestClassUtiltity.createAccountTeamMembersRecords(testAccount.Id,testUser.Id);
		     insert accountTeamMembers; 
		     
		     //create Strategic plans
	         list<Strategic_Plan__c> strategicPlans = TestClassUtiltity.createStrategicPlans(testAccount.Id);
	         insert strategicPlans;
	        
	         test.startTest();
	            HPS_MyActiveAccountsController tempController = new HPS_MyActiveAccountsController();
	    		System.assertEquals(tempController.myActiveAccountsList.size(),1);
	    	 test.stopTest();
	     }
    }
}