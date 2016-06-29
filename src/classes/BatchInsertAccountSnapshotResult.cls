/**************************************************************************************
  Apex Class Name     : BatchInsertAccountSnapshotResult
  Version             : 1.0
  Function            : Used to insert large amounts (10000+) of Snapshot Comparison Result Records by batching them
  Modification Log    :
* Developer                  Date                  Description
* ----------------------------------------------------------------------------
  Rallph Tariga       :   March 5 2016           Original Version
*************************************************************************************/
global class BatchInsertAccountSnapshotResult implements Database.Batchable<sObject>, Database.Stateful {
	public List<Snapshot_Comparison_Result__c> newSnapshots = new List<Snapshot_Comparison_Result__c>();
	public List<Snapshot_Comparison_Result__c> snapshotList = new List<Snapshot_Comparison_Result__c>();
	Integer startIdx;
	Integer endIdx;

	/*************************************************************
	 * Method name  : BatchInsertAccountSnapshotResult
	 * Description  : Constructor that fills the contents of the local list with the records that need to be inserted
	************************************************************ */
	public BatchInsertAccountSnapshotResult(List<Snapshot_Comparison_Result__c> snapshotList, Integer startIdx, Integer endIdx) {
		this.startIdx = startIdx;
		this.endIdx = endIdx;
		this.snapshotList = snapshotList;
		for (Integer idx = this.startIdx; idx < this.endIdx; idx++) {
			this.newSnapshots.add(snapshotList[idx]);
		}
	}

	/*************************************************************
	 * Method name  : start
	 * Description  : Method that initiates the batch process. It feeds the contents of the list to be inserted
	 * Returns      : Snapshot Comparison Result Records
	************************************************************ */
	global List<Snapshot_Comparison_Result__c> start(Database.BatchableContext info) {
		return newSnapshots;
	}

	/*************************************************************
	 * Method name  : execute
	 * Description  : Method that inserts chunks of records
	 * Returns      : None
	************************************************************ */
	global void execute(Database.BatchableContext batchContext, List<sObject> scope) {
		List<Snapshot_Comparison_Result__c> curSnapshotList = new List<Snapshot_Comparison_Result__c>();
		for (Snapshot_Comparison_Result__c curSnapshot : (List<Snapshot_Comparison_Result__c>)scope) {
			curSnapshotList.add(curSnapshot);
		}

		insert curSnapshotList;
	}

	/*************************************************************
	 * Method name  : finish
	 * Description  : Method that does additional work (if needed) after all records have been processed
	 				  No addtional work required in this case
	 * Returns      : None
	************************************************************ */
	global void finish(Database.BatchableContext batchContext) {
		
	}
}