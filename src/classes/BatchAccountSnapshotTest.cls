/**************************************************************************************
  Apex Class Name     : BatchAccountSnapshotTest
  Version             : 1.0
  Function            : Test class for the Batch Account Snapshot Result class 
  Modification Log    :
* Developer                  Date                  Description
* ----------------------------------------------------------------------------
  Nick Serafin       :   March 5 2016           Original Version
*************************************************************************************/
@isTest
private class BatchAccountSnapshotTest {

	public static testMethod void batchSnapshotTest() {

		Test.StartTest();
		
		Account a = new Account();
		a.Name = 'testAccount';

		insert a;

		Account f = new Account();
		f.Name = 'testAccount2';

		insert f;

		Account s = new Account();
		s.Name = 'testAccount3';

		insert s;
		
		Complete_Account_Snapshot__c b = new Complete_Account_Snapshot__c();
		b.Name = 'March';
		b.Account__c = a.Id;
		b.Sliced__c = true;
		b.Carrier_Count__c = 1;
		b.Exchange__c = false;
		b.Status__c = 'Active';
		b.Snapshot_Number__c = 1;
			
		insert b;

		Complete_Account_Snapshot__c c = new Complete_Account_Snapshot__c();
		c.Name = 'March';
		c.Account__c = f.Id;
		c.Sliced__c = false;
		c.Carrier_Count__c = 1;
		c.Exchange__c = true;
		c.Status__c = 'Active';
		c.Snapshot_Number__c = 2;
			
		insert c;

		Complete_Account_Snapshot__c cr = new Complete_Account_Snapshot__c();
		cr.Name = 'March';
		cr.Account__c = s.Id;
		cr.Sliced__c = true;
		cr.Carrier_Count__c = 1;
		cr.Exchange__c = true;
		cr.Status__c = 'Active';
		cr.Snapshot_Number__c = 3;
			
		insert cr;

		Complete_Account_Snapshot__c ac = new Complete_Account_Snapshot__c();
		ac.Name = 'April';
		ac.Account__c = s.Id;
		ac.Sliced__c = true;
		ac.Carrier_Count__c = 2;
		ac.Exchange__c = false;
		ac.Status__c = 'Active';
		ac.Snapshot_Number__c = 4;
			
		insert ac;
	
		Complete_Account_Snapshot__c d = new Complete_Account_Snapshot__c();
		d.Name = 'April';
		d.Account__c = a.Id;
		d.Sliced__c = false;
		d.Carrier_Count__c = 1;
		d.Exchange__c = false;
		d.Status__c = 'cancelled';
		d.Snapshot_Number__c = 5;
			
		insert d;

		Complete_Account_Snapshot__c e = new Complete_Account_Snapshot__c();
		e.Name = 'April';
		e.Account__c = f.Id;
		e.Sliced__c = false;
		e.Carrier_Count__c = 2;
		e.Exchange__c = true;
		e.Status__c = 'Cancelled';
		e.Snapshot_Number__c = 6;
			
		insert e;

		String firstMonth = 'March';
		String secondMonth = 'April';
		Double startBound = 1.0;
		Double endBound = 5000.0;

		BatchAccountSnapshotResult accountSnapshotResult = new BatchAccountSnapshotResult(firstMonth, secondMonth, startBound, endBound);
		accountSnapshotResult.query = 'SELECT Id, Name, Account__c, Account__r.Id, Carrier_Count__c, Sliced__c, Exchange__c, Status__c FROM Complete_Account_Snapshot__c WHERE Name = \'March\' OR Name = \'April\'';


		ID batchprocessid = Database.executeBatch(accountSnapshotResult);

		System.AssertEquals(
		    database.countquery('SELECT COUNT()' + ' FROM Complete_Account_Snapshot__c'), 6);


		Test.StopTest();
		
	}
}