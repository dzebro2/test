/**************************************************************************************
  Apex Class Name     : TestHPS_MyCasesController
  Version             : 1.0
  Function            : This is a test class for HPS_MyCasesController
  Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
*  
*************************************************************************************/
@isTest
public class TestHPS_MyCasesController {

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
		    	
		    	//create Case
		    	list<Case> cases = TestClassUtiltity.createCaseRecords(testAccount.Id);
		    	insert cases;
		    	
		    	CaseTeamRole role = [select Id from CaseTeamRole limit 1];
		    	
		    	//create Case Team member
		    	list<CaseTeamMember> caseTeamMembers = TestClassUtiltity.createCaseTeamMembersRecords(cases[0].id,testUser.Id);
		    	caseTeamMembers[0].TeamRoleId = role.Id;
		    	insert caseTeamMembers;
		    	
		    	//create the instance of constructor
		    	HPS_MyCasesController tempController = new HPS_MyCasesController();
		    	//assert the size of the case records queried
		    	system.assertEquals(1,tempController.myCasesList.size());
		     }
	     }
	     catch(Exception e){
	     	throw e;
	     } 
    }
}