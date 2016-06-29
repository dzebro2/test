/**************************************************************************************
  Apex Class Name     : BatchCreateCompleteAccountSnapshotTest
  Version             : 1.0
  Function            : Test class for BatchCreateCompleteAccountSnapshot 
* Developer                  Date                  Description
* ----------------------------------------------------------------------------
  Ralph Tariga       :   March 9 2016           Original Version
*************************************************************************************/
@isTest
private class BatchCreateCompleteAccountSnapshotTest {


	public static testMethod void testBatchError() {


		Test.StartTest();


		List <Account> accns = new List<Account>();
		for (integer i = 0; i < 10; i++) {
			Account a = new Account(Name = 'testAccount' + 'i');
			accns.add(a);
		}

		insert accns;


		BatchCreateCompleteAccountSnapshot accountSnapshot = new BatchCreateCompleteAccountSnapshot();
		accountSnapshot.currentMonth = 0;
		accountSnapshot.currentYear = 2010;
		accountSnapshot.query = 'SELECT Id, Name, RecordType.Name, Sliced__c, Exchange_Account__c, Status__c FROM Account';

		ID batchprocessid = Database.executeBatch(accountSnapshot);

		System.AssertEquals(
		    database.countquery('SELECT COUNT()' + ' FROM Account'), 10);


		Test.StopTest();

	}

	public static testMethod void testBatchJan() {


		Test.StartTest();


		List <Account> accns = new List<Account>();
		for (integer i = 0; i < 10; i++) {
			Account a = new Account(Name = 'testAccount' + 'i');
			accns.add(a);
		}

		insert accns;


		BatchCreateCompleteAccountSnapshot accountSnapshot = new BatchCreateCompleteAccountSnapshot();
		accountSnapshot.currentMonth = 1;
		accountSnapshot.currentYear = 2010;
		accountSnapshot.query = 'SELECT Id, Name, RecordType.Name, Sliced__c, Exchange_Account__c, Status__c FROM Account';

		ID batchprocessid = Database.executeBatch(accountSnapshot);

		System.AssertEquals(
		    database.countquery('SELECT COUNT()' + ' FROM Account'), 10);



		Test.StopTest();
		Complete_Account_Snapshot__c testAccount = [SELECT Name FROM Complete_Account_Snapshot__c LIMIT 1];
		System.assertEquals('January 2010', testAccount.Name);
	}

	public static testMethod void testBatchFeb() {


		Test.StartTest();


		List <Account> accns = new List<Account>();
		for (integer i = 0; i < 10; i++) {
			Account a = new Account(Name = 'testAccount' + 'i');
			accns.add(a);
		}

		insert accns;


		BatchCreateCompleteAccountSnapshot accountSnapshot = new BatchCreateCompleteAccountSnapshot();
		accountSnapshot.currentMonth = 10;
		accountSnapshot.currentYear = 2010;
		accountSnapshot.query = 'SELECT Id, Name, RecordType.Name, Sliced__c, Exchange_Account__c, Status__c FROM Account';

		ID batchprocessid = Database.executeBatch(accountSnapshot);

		System.AssertEquals(
		    database.countquery('SELECT COUNT()' + ' FROM Account'), 10);


		Test.StopTest();
		Complete_Account_Snapshot__c testAccount = [SELECT Name FROM Complete_Account_Snapshot__c LIMIT 1];
		System.assertEquals('October 2010', testAccount.Name);

	}
}