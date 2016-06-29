/*
    @Description : This is a test class for ContactRelationshipTriggerHandle
    @author      : Deloitte
    @date        : 11/02/2015
*/
@isTest
public with sharing class TestContactRelationshipTriggerHandler {
	
	static testMethod void myUnitTest() {
		Account acc = TestClassUtiltity.CreateAccountRecord('Test Account');
		Contact con = TestClassUtiltity.CreateContactRecord(acc.Id,'Test','Last',null);
		Contact conRelate = TestClassUtiltity.CreateContactRecord(acc.Id,'TestRelate','LastRelate',null);
		Map<Id, RecordType> recordTypes = LGNAUtilityClass.createRecordTypeIdToRecordTypeMap( 'Contact_Relationship__c' );
        list<Contact_Relationship__c> contactRelationshipRecords = new list<Contact_Relationship__c>();
        for(RecordType rt : recordTypes.values()){
        	contactRelationshipRecords.add(new Contact_Relationship__c(Contact__c = con.Id, Related_Contact__c = conRelate.Id, Related_User__c = userInfo.getUserId(),RecordTypeId = rt.Id));
        }
        test.startTest();
        	insert contactRelationshipRecords;
        	list<Contact_Relationship__c> cr = [select Id from Contact_Relationship__c where Related_Contact__c =:conRelate.Id];
        	system.assertEquals(cr.size(),4);
		test.stopTest();
	}
	
	static testMethod void myUnitTestUpdate() {
		Account acc = TestClassUtiltity.CreateAccountRecord('Test Account');
		Contact con = TestClassUtiltity.CreateContactRecord(acc.Id,'Test','Last',null);
		Contact conRelate = TestClassUtiltity.CreateContactRecord(acc.Id,'TestRelate','LastRelate',null);
		Map<Id, RecordType> recordTypes = LGNAUtilityClass.createRecordTypeIdToRecordTypeMap( 'Contact_Relationship__c' );
        list<Contact_Relationship__c> contactRelationshipRecords = new list<Contact_Relationship__c>();
        for(RecordType rt : recordTypes.values()){
        	contactRelationshipRecords.add(new Contact_Relationship__c(Status__c = 'Active',Relationship_Info__c = 'test',Contact__c = con.Id, Related_Contact__c = conRelate.Id, Related_User__c = userInfo.getUserId(),RecordTypeId = rt.Id));
        }
        test.startTest();
	        insert contactRelationshipRecords;
	        list<Contact_Relationship__c> tempList = [select Id from Contact_Relationship__c where Related_Contact__c =:conRelate.Id];
        	system.assertEquals(tempList.size(),4);
	        for(Contact_Relationship__c cr : contactRelationshipRecords){
	        	cr.Status__c = 'Inactive';
	        }
	        update contactRelationshipRecords;
        test.stopTest();
	}
	static testMethod void myUnitTestDelete() {
		Account acc = TestClassUtiltity.CreateAccountRecord('Test Account');
		Contact con = TestClassUtiltity.CreateContactRecord(acc.Id,'Test','Last',null);
		Contact conRelate = TestClassUtiltity.CreateContactRecord(acc.Id,'TestRelate','LastRelate',null);
		Map<Id, RecordType> recordTypes = LGNAUtilityClass.createRecordTypeIdToRecordTypeMap( 'Contact_Relationship__c' );
        list<Contact_Relationship__c> contactRelationshipRecords = new list<Contact_Relationship__c>();
        for(RecordType rt : recordTypes.values()){
        	contactRelationshipRecords.add(new Contact_Relationship__c(Status__c = 'Active',Relationship_Info__c = 'test',Contact__c = con.Id, Related_Contact__c = conRelate.Id, Related_User__c = userInfo.getUserId(),RecordTypeId = rt.Id));
        }
        test.startTest();
	        insert contactRelationshipRecords;
	        list<Contact_Relationship__c> tempList = [select Id from Contact_Relationship__c where Related_Contact__c =:conRelate.Id];
        	system.assertEquals(tempList.size(),4);
	        for(Contact_Relationship__c cr : contactRelationshipRecords){
	        	cr.Status__c = 'Inactive';
	        	cr.Relationship_Info__c = 'test1';
	        }
	        delete contactRelationshipRecords;
		test.stopTest();
	}
}