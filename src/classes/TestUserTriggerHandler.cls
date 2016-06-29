/*
    @Description : This is an test class for UserTriggerHandler
    @author      : Deloitte
    @date        : 10/16/2015
*/
@isTest
public with sharing class TestUserTriggerHandler {
	static testMethod void unittest1(){
		Account acc = TestClassUtiltity.CreateAccountRecord('test');
		RecordType rt = [select Id from RecordType where SobjectType = 'Contact' and DeveloperName=:ConstantsController.ContactRecordType][0];
		Contact con = new Contact();
		con.LastName = 'Test';
		con.AccountId = acc.Id;
		con.External_ID__c = '124';
		con.RecordTypeId = rt.Id;
		insert con;
		Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
	    User testUser = TestClassUtiltity.CreateUserRecord(p.Id, 'testlgnadev@user.com', 'testUser', 'test@user.com');
	    testUser = [select EmployeeNumber,Is_Super_User__c from User where Id =:testUser.Id][0];
	    testUser.Is_Super_User__c = true;
	    testUser.EmployeeNumber = '124';
	    update testUser;
	    list<PermissionSet> superUserpermisionset= [SELECT id ,Name, PermissionsModifyAllData FROM PermissionSet WHERE Name = :system.label.Super_User_Permissions limit 1];
	    system.assertEquals(superUserpermisionset.size(),1);
	    testUser.Is_Super_User__c = false;
	    testUser.EmployeeNumber = '125';
	    update testUser;
	    
	    testUser.EmployeeNumber = '124';
	    update testUser;
	    
	}
}