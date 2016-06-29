/*
    @Description : This is an extension class for Sharing the Financial records with the Opportunity Team Member
    @author      : Deloitte
    @date        : 10/29/2015
*/
@isTest
public with sharing class TestBatchSendOppDueDateNotification {
	 /*
        @Description : This is a testMethod
        @author      : Deloitte
        @date        : 10/29/2015
    */
    static testMethod void myUnitTest1() {
    	Account TestAcnt = TestClassUtiltity.CreateAccountRecord('TestAccount');
        
        List<Opportunity> TestOppLst = TestClassUtiltity.CreateOpportunities(TestAcnt.id);
        TestOppLst[0].RecordTypeId =Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal').getRecordTypeId();
        TestOppLst[0].closeDate = date.today().addDays(2);
        TestOppLst[0].Due_Date_Notification_in_Days__c = 2;
        insert TestOppLst;
        test.startTest();
        	BatchSendOpportunityDueDateNotification bt = new BatchSendOpportunityDueDateNotification();
        	Id batchId=database.executeBatch(bt);
        	System.assertNOTEquals(batchId,null);
        test.stopTest();
    }
}