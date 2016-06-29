/*
    @Description : This is an test class for BatchAccountRenewalNotification
    @author      : Deloitte
    @date        : 10/29/2015
*/
@isTest
public with sharing class TestBatchAccountRenewalNotification {
	/*
        @Description : This is a testMethod for testing the accountRenewalBatch
        @author      : Deloitte
        @date        : 10/29/2015
    */
    static testMethod void myUnitTest1() {
    	Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
	    User testUser = TestClassUtiltity.CreateUserRecord(p.Id, 'testlgnadev@user.com', 'testUser', 'test@user.com');
	    system.runAs(testUser){
	    	Account TestAcnt = TestClassUtiltity.CreateAccountRecord('TestAccount');
	    	TestAcnt.Renewal_Notification_in_days__c = 2;
	    	TestAcnt.Renewal_Date__c = date.today().addDays(2);
	    	TestAcnt.Ceded__c = true;
	    	TestAcnt.Status__c = 'Active';
	    	update TestAcnt;
	    	Custom_Notification_Enabled_Profiles__c ce = new Custom_Notification_Enabled_Profiles__c();
	    	ce.Name='Standard User';
	    	ce.Account_Renewal_Tasks__c = true;
	    	insert ce;
	    	test.startTest();
		    	BatchAccountRenewalNotification bt = new BatchAccountRenewalNotification();
	        	Id batchId=database.executeBatch(bt);
        		System.assertNOTEquals(batchId,null);
        	test.stopTest();
	    }
    }
}