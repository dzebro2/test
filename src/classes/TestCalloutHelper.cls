/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class TestCalloutHelper {

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
		    	CalloutHelperclass.SubmitAccountCallout(cases[0].Id);
		    	case cs = [select Integration_Action__c from case where Id =:cases[0].Id][0];
		    	system.assertEquals(cs.Integration_Action__c,'Account Submit');
   				CalloutHelperclass.SendCalloutsToCBSR('test','test@test.com','1234','test');
		     }
    	}catch(Exception e){
    		
    	}
    }
}