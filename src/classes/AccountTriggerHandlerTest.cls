@isTest
private class AccountTriggerHandlerTest {


	@isTest
	static void addAE2AndUnderwritertoAccountTeamTest() {

		Test.startTest();
		List<User> testUsers = new List<User>();
		Account testAccount = new Account( Name = 'Test Account' );
		Profile p = [SELECT Id FROM Profile WHERE Name = 'LGNA - Account Management'];
		testUsers.add(new User(Alias = 'standt1', Email = 'john.testing@testorg.com',EmailEncodingKey = 'UTF-8', LastName = 'Testing', FirstName = 'John', LanguageLocaleKey = 'en_US',LocaleSidKey = 'en_US', ProfileId = p.Id, TimeZoneSidKey = 'America/Los_Angeles',UserName = 'john.testing@testorg.com', isActive = TRUE));
		testUSers.add(new User(Alias = 'standt2', Email = 'jane.testing@testorg.com',EmailEncodingKey = 'UTF-8', LastName = 'Testing', FirstName = 'Jane', LanguageLocaleKey = 'en_US',LocaleSidKey = 'en_US', ProfileId = p.Id, TimeZoneSidKey = 'America/Los_Angeles',UserName = 'jane.testing@testorg.com', isActive = TRUE));		
		testUsers.add(new User(Alias = 'standt3', Email = 'jim.testing@testorg.com',EmailEncodingKey = 'UTF-8', LastName = 'Testing', FirstName = 'Jim', LanguageLocaleKey = 'en_US',LocaleSidKey = 'en_US', ProfileId = p.Id, TimeZoneSidKey = 'America/Los_Angeles',UserName = 'jim.testing@testorg.com', isActive = TRUE, Lan_Id__c = 'UU456'));		
		testUsers.add(new User(Alias = 'standt4', Email = 'bob.testing@testorg.com',EmailEncodingKey = 'UTF-8', LastName = 'Testing', FirstName = 'Bob', LanguageLocaleKey = 'en_US',LocaleSidKey = 'en_US', ProfileId = p.Id, TimeZoneSidKey = 'America/Los_Angeles',UserName = 'bob.testing@testorg.com', isActive = TRUE, Lan_Id__c = 'UU4567'));		
		testUsers.add(new User(Alias = 'standt5', Email = 'dan.testing@testorg.com',EmailEncodingKey = 'UTF-8', LastName = 'Testing', FirstName = 'Dan', LanguageLocaleKey = 'en_US',LocaleSidKey = 'en_US', ProfileId = p.Id, TimeZoneSidKey = 'America/Los_Angeles',UserName = 'dan.testing@testorg.com', isActive = TRUE, Lan_Id__c = 'UU4568'));		
		testUsers.add(new User(Alias = 'standt6', Email = 'sana.testing@testorg.com',EmailEncodingKey = 'UTF-8', LastName = 'Testing', FirstName = 'Sana', LanguageLocaleKey = 'en_US',LocaleSidKey = 'en_US', ProfileId = p.Id, TimeZoneSidKey = 'America/Los_Angeles',UserName = 'sana.testing@testorg.com', isActive = TRUE, Lan_Id__c = 'UU4569'));
		insert testUsers;

		testAccount.Account_Cluster_Name__c = 'John Testing';
		testAccount.Account_Executive_2__c = 'Jane Testing';
		testAccount.Underwriter_User_ID__c = 'UU456';
		List<AccountTeamMember> acctTeamMember = new List<AccountTeamMember>();
		List<String> memberName = new List<String>();
		List<String> memberNamequery = new List<String>();
		insert testAccount;

		acctTeamMember = [select User.Name, Account.Name, AccountAccessLevel, CreatedDate, CreatedBy.Name from AccountTeamMember where Account.Name = 'Test Account'];

		System.assertEquals(3, acctTeamMember.size());

		testAccount.Account_Cluster_Name__c = 'Dan Testing';
		testAccount.Account_Executive_2__c = 'Sana Testing';
		testAccount.Underwriter_User_ID__c = 'UU4567';

		update testAccount;

		acctTeamMember = [select User.Name, Account.Name, AccountAccessLevel, CreatedDate, CreatedBy.Name from AccountTeamMember where Account.Name = 'Test Account'];

		System.assertEquals(6, acctTeamMember.size());

		Test.stopTest();

	}


	@isTest
	static void updateRegionTest() {

		Test.startTest();
		List<Account> accs = new List<Account>();

		for (Integer i = 0; i < 5; i ++) {
			accs.add(new Account(name = 'Test' + i, RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get( 'Group Account' ).getRecordTypeId()));
		}


		accs[0].HCSC_Division__c = 'TX';
		accs[1].HCSC_Division__c = 'NM';
		accs[2].HCSC_Division__c = 'MT';
		accs[3].HCSC_Division__c = 'OK';
		accs[4].HCSC_Division__c = 'IL';

		insert accs;

		List<Account> accAfterInsert = [Select Name, Id, Region__c from Account];

		System.assertEquals('TX', accAfterInsert[0].Region__c);
		System.assertEquals('NM', accAfterInsert[1].Region__c);
		System.assertEquals('MT', accAfterInsert[2].Region__c);
		System.assertEquals('OK', accAfterInsert[3].Region__c);
		System.assertEquals('IL', accAfterInsert[4].Region__c);
		Test.stopTest();
	}



}