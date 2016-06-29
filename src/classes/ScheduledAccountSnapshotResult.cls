/**************************************************************************************
  Apex Class Name     : ScheduledAccountSnapshotResult
  Version             : 1.0
  Function            : Schedules a Batch process for Complete Account Snapshot Records to be compared
* Developer                  Date                  Description
* ----------------------------------------------------------------------------
  Alec Klein       :   March 5 2016           Original Version
*************************************************************************************/
global with sharing class ScheduledAccountSnapshotResult implements Schedulable {
	/*************************************************************
	 * Method name  : execute
	 * Description  : This method sets the query that will be used by the BatchAccountSnapshotResult class and
	 				executes the batch class
	 * Returns      : None
	************************************************************ */
	global void execute(SchedulableContext sc) {
		Double startBound = 1.0;
		Double endBound = 5000.0;
        SVSReport__c a = SVSReport__c.getValues('Year1');
        SVSReport__c b = SVSReport__c.getValues('Year2');
		BatchAccountSnapshotResult myBatch = new BatchAccountSnapshotResult(a.Month__c, b.Month__c, startBound, endBound);
		String myQuery = 'SELECT Id, Name, Account__c, Account__r.Id, Carrier_Count__c, Sliced__c, Exchange__c, Status__c, Snapshot_Number__c FROM Complete_Account_Snapshot__c';
		myQuery = myQuery + ' WHERE (Name =\'' + myBatch.firstMonth + '\'';
		myQuery = myQuery + ' AND Snapshot_Number__c <= 5000.0 AND Snapshot_Number__c >= 1.0)';
		System.debug('Query: ' + myQuery);
		myBatch.query = myQuery;
		Id myBatchProcessId = Database.executeBatch(myBatch, 2000);
	}
}