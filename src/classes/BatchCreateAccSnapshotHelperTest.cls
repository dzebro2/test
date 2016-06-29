/**************************************************************************************
  Apex Class Name     : BatchCreateAccSnapshotHelperTest
  Version             : 1.0
  Function            : Test class for the BatchCreateAccSnapshotResultHelper class 
  Modification Log    :
* Developer                  Date                  Description
* ----------------------------------------------------------------------------
  Nick Serafin       :   March 9 2016           Original Version
*************************************************************************************/
@isTest
private class BatchCreateAccSnapshotHelperTest {

	public static testMethod void batchSnapshotHelperTest(){

		Test.StartTest();

		Map<Id, Complete_Account_Snapshot__c> firstMonthMap = new Map<Id, Complete_Account_Snapshot__c>();
		Set<Id> idList = new Set<Id>();

		Account a = new Account();
		a.Name = 'testAccount';

		insert a;
		idList.add(a.Id);

		Account f = new Account();
		f.Name = 'testAccount2';

		insert f;
		idList.add(f.Id);

		Account s = new Account();
		s.Name = 'testAccount3';

		insert s;
		idList.add(s.Id);

		Complete_Account_Snapshot__c b = new Complete_Account_Snapshot__c();
		b.Name = 'March';
		b.Account__c = a.Id;
		b.Sliced__c = true;
		b.Carrier_Count__c = 1;
		b.Exchange__c = false;
		b.Status__c = 'Active';
		b.Snapshot_Number__c = 1;
			
		insert b;
		firstMonthMap.put(a.Id, b);

		Complete_Account_Snapshot__c c = new Complete_Account_Snapshot__c();
		c.Name = 'March';
		c.Account__c = f.Id;
		c.Sliced__c = false;
		c.Carrier_Count__c = 1;
		c.Exchange__c = true;
		c.Status__c = 'Active';
		c.Snapshot_Number__c = 2;
			
		insert c;
		firstMonthMap.put(f.Id, c);

		Complete_Account_Snapshot__c cr = new Complete_Account_Snapshot__c();
		cr.Name = 'March';
		cr.Account__c = s.Id;
		cr.Sliced__c = true;
		cr.Carrier_Count__c = 1;
		cr.Exchange__c = true;
		cr.Status__c = 'Active';
		cr.Snapshot_Number__c = 3;
			
		insert cr;
		firstMonthMap.put(s.Id, cr);

		Complete_Account_Snapshot__c ac = new Complete_Account_Snapshot__c();
		ac.Name = 'April';
		ac.Account__c = s.Id;
		ac.Sliced__c = true;
		ac.Carrier_Count__c = 2;
		ac.Exchange__c = false;
		ac.Status__c = 'Active';
		ac.Snapshot_Number__c = 4;
			
		insert ac;
		firstMonthMap.put(s.Id, ac);

		Complete_Account_Snapshot__c d = new Complete_Account_Snapshot__c();
		d.Name = 'April';
		d.Account__c = a.Id;
		d.Sliced__c = false;
		d.Carrier_Count__c = 1;
		d.Exchange__c = false;
		d.Status__c = 'cancelled';
		d.Snapshot_Number__c = 5;
			
		insert d;
		firstMonthMap.put(a.Id, d);

		Complete_Account_Snapshot__c e = new Complete_Account_Snapshot__c();
		e.Name = 'April';
		e.Account__c = f.Id;
		e.Sliced__c = false;
		e.Carrier_Count__c = 2;
		e.Exchange__c = true;
		e.Status__c = 'Cancelled';
		e.Snapshot_Number__c = 6;
			
		insert e;
		firstMonthMap.put(f.Id, e);

		String firstMonth = 'March';
		String secondMonth = 'April';
		Double startBound = 1.0;
		Double endBound = 5000.0;


		BatchCreateAccSnapshotResultHelper accountSnapshotResult = new BatchCreateAccSnapshotResultHelper(firstMonth, secondMonth, firstMonthMap, idList, startBound, endBound);
		accountSnapshotResult.query = 'SELECT Id, Name, Account__c, Account__r.Id, Carrier_Count__c, Sliced__c, Exchange__c, Status__c FROM Complete_Account_Snapshot__c WHERE Name = \'March\' OR Name = \'April\'';


		ID batchprocessid = Database.executeBatch(accountSnapshotResult);

		System.AssertEquals(
		    database.countquery('SELECT COUNT()' + ' FROM Complete_Account_Snapshot__c'), 6);


		Test.StopTest();
		
	}
}