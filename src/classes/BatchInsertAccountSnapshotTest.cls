/**************************************************************************************
  Apex Class Name     : BatchInsertAccountSnapshotTest
  Version             : 1.0
  Function            : Test class for the Batch Insert Account Snapshot Result Class 
  Modification Log    :
* Developer                  Date                  Description
* ----------------------------------------------------------------------------
  Nick Serafin       :   March 5 2016           Original Version
*************************************************************************************/
@isTest
private class BatchInsertAccountSnapshotTest {

	public static testMethod void BatchInsertAccountTest() {

		Test.StartTest();

		Account a = new Account();
		a.Name = 'testAccount';

		insert a;
		
		Complete_Account_Snapshot__c b = new Complete_Account_Snapshot__c();
		b.Name = 'March';
		b.Account__c = a.Id;
		b.Sliced__c = true;
		b.Carrier_Count__c = 1;
		b.Exchange__c = false;
		b.Status__c = 'Active';
			
		insert b;

		Complete_Account_Snapshot__c c = new Complete_Account_Snapshot__c();
		c.Name = 'March';
		c.Account__c = a.Id;
		c.Sliced__c = false;
		c.Carrier_Count__c = 1;
		c.Exchange__c = true;
		c.Status__c = 'Active';
			
		insert c;

		List<Snapshot_Comparison_Result__c> snaps = new List<Snapshot_Comparison_Result__c>();

		Snapshot_Comparison_Result__c snap = new Snapshot_Comparison_Result__c();
		snap.Name = 'a1qf0000000Uqag';
		snap.Account__c = a.Id;
		snap.Sole_Source__c = 'Split to Sole Source';

		snaps.add(snap);
		Integer startIdx = 0;
	    Integer endIdx = 1;

		BatchInsertAccountSnapshotResult accountSnapshotResult = new BatchInsertAccountSnapshotResult(snaps, startIdx, endIdx);
		accountSnapshotResult.newSnapshots = snaps;


		ID batchprocessid = Database.executeBatch(accountSnapshotResult);

		System.AssertEquals(accountSnapshotResult.newSnapshots.size(), 1);

		Test.StopTest();
	}
}