/**************************************************************************************
  Apex Class Name     : BatchAccountSnapshotResult
  Version             : 1.0
  Function            : Used to compare two snapshot records from a large set of data in batches in order
  						to report on the movement of accounts
* Developer                  Date                  Description
* ----------------------------------------------------------------------------
  Alec Klein       :   March 5 2016           Original Version
*************************************************************************************/
global class BatchAccountSnapshotResult implements Database.Batchable<sObject>, Database.Stateful {
	public String query;
	public String firstMonth;
	public String secondMonth;
	public Double startBound;
	public Double endBound;
	public Map<Id, Complete_Account_Snapshot__c> firstMonthMap = new Map<Id, Complete_Account_Snapshot__c>();
	public Set<Id> idList = new Set<Id>();
	/*************************************************************
	 * Method name  : BatchAccountSnapshotResult
	 * Description  : Constructor that grabs the variables that are used in the query to filter the results to two months
	************************************************************ */
	public BatchAccountSnapshotResult(String firstMonth, String secondMonth, Double startBound, Double endBound) {
		this.firstMonth = firstMonth;
		this.secondMonth = secondMonth;
		this.startBound = startBound;
		this.endBound = endBound;
	}
	/*************************************************************
	 * Method name  : start
	 * Description  : Method that initiates the batch process. It calls the query that was set in the Schedule method
	 * Returns      : Complete Account Snapshot Records
	************************************************************ */
	global Database.querylocator start(Database.BatchableContext batchContext) {
		return Database.getQueryLocator(query);
	}
	/*************************************************************
	 * Method name  : execute
	 * Description  : Method that iterates through the query in order to group the returned records by month into maps for comparison
	 * Returns      : None
	************************************************************ */
	global void execute(Database.BatchableContext batchContext, List<sObject> scope) {
		for (Complete_Account_Snapshot__c accSnapshot : (List<Complete_Account_Snapshot__c>) scope) {
			firstMonthMap.put(accSnapshot.Account__r.Id, accSnapshot);
			idList.add(accSnapshot.Account__r.Id);
		}
	}
	/*************************************************************
	 * Method name  : finish
	 * Description  : Calls the BatchCreateAccSnapshotResultHelper class in order to compare the two snapshot records
	 * Returns      : None
	************************************************************ */
	global void finish(Database.BatchableContext batchContext) {
		System.debug('endBound: ' + endBound);

		if (firstMonthMap.size() > 0) {
			BatchCreateAccSnapshotResultHelper myBatch = new BatchCreateAccSnapshotResultHelper(firstMonth, secondMonth, firstMonthMap, idList, startBound, endBound);
			String myQuery = 'SELECT Id, Name, Account__c, Account__r.Id, Carrier_Count__c, Sliced__c, Exchange__c, Status__c, Snapshot_Number__c FROM Complete_Account_Snapshot__c';
			myQuery = myQuery + ' WHERE (Name =\'' + myBatch.secondMonth + '\'';
			myQuery = myQuery + ' AND Account__r.Id IN :idList)';
			System.debug('Query: ' + myQuery);
			myBatch.query = myQuery;
			Id myBatchProcessId = Database.executeBatch(myBatch, 2000);
		}
	}
}