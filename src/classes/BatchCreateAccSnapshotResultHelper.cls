/**************************************************************************************
  Apex Class Name     : BatchCreateAccSnapshotResultHelper
  Version             : 1.0
  Function            : Grabs the two snapshot records and preforms the comparison on them and fills a field based on the result
  Modification Log    :
* Developer                  Date                  Description
* ----------------------------------------------------------------------------
  Nick Serafin       :   March 9 2016           Original Version
*************************************************************************************/
global class BatchCreateAccSnapshotResultHelper implements Database.Batchable<sObject>, Database.Stateful {
	public String query;
	public String firstMonth;
	public String secondMonth;
	public Double startBound;
	public Double endBound;
	public Map<Id, Complete_Account_Snapshot__c> firstMonthMap = new Map<Id, Complete_Account_Snapshot__c>();
	public Set<Id> idList = new Set<Id>();
	/*************************************************************
	 * Method name  : BatchCreateAccSnapshotResultHelper
	 * Description  : Constructor that grabs the variables that are used for the comparison
	************************************************************ */
	public BatchCreateAccSnapshotResultHelper(String firstMonth, String secondMonth, Map<Id, Complete_Account_Snapshot__c> firstMonthMap, Set<Id> idList, Double startBound, Double endBound) {
		this.firstMonth = firstMonth;
		this.secondMonth = secondMonth;
		this.startBound = startBound;
		this.endBound = endBound;
		this.firstMonthMap = firstMonthMap;
		this.idList = idList;
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
	 * Description  : Method that iterates through the query and compares the two snpashot records and then inserts them for the report
	 * Returns      : None
	************************************************************ */
	global void execute(Database.BatchableContext batchContext, List<sObject> scope) {
		List<Snapshot_Comparison_Result__c> newSnapshots = new List<Snapshot_Comparison_Result__c>();

		for (Complete_Account_Snapshot__c secondSnapshot : (List<Complete_Account_Snapshot__c>) scope) {
			Complete_Account_Snapshot__c firstSnapshot = firstMonthMap.remove(secondSnapshot.Account__r.Id);
			if (firstSnapshot != NULL) {
				Snapshot_Comparison_Result__c newAccountSnapshot = new Snapshot_Comparison_Result__c();
				newAccountSnapshot.Account__c = firstSnapshot.Account__r.Id;
				newAccountSnapshot.Date_Created__c = system.today();
				if (firstSnapshot.Sliced__c == True) {
					if (secondSnapshot.Status__c == 'Cancelled')
						newAccountSnapshot.Sole_Source__c = 'Split to Cancelled';
					else {
						if (secondSnapshot.Sliced__c == False)
							newAccountSnapshot.Sole_Source__c = 'Split to Sole Source';
						else
							newAccountSnapshot.Sole_Source__c = 'Split to Split';

						if (secondSnapshot.Carrier_Count__c > firstSnapshot.Carrier_Count__c)
							newAccountSnapshot.Sole_Source__c = 'Split to Lost to Competitor';
					}
				} else if (firstSnapshot.Sliced__c == False) {
					if (secondSnapshot.Status__c == 'Cancelled')
						newAccountSnapshot.Sole_Source__c = 'Sole Source to Cancelled';
                    else{
                    	if (secondSnapshot.Sliced__c == false){
                        	if (firstSnapshot.Exchange__c == false && secondSnapshot.Exchange__c == true){
                            	newAccountSnapshot.Sole_Source__c = 'Sole Source to Split Exchange';
                        	} else {
                            	newAccountSnapshot.Sole_Source__c = 'Sole Source to Sole Source';
                        	}
                    	}           
					if (secondSnapshot.Carrier_Count__c > firstSnapshot.Carrier_Count__c || secondSnapshot.Sliced__c == true)
						newAccountSnapshot.Sole_Source__c = 'Sole Source to Split';
                    }
				} else {
					System.debug('No Change');
				}

				newSnapshots.add(newAccountSnapshot);
			}
		}

		insert newSnapshots;
	}

	/*************************************************************
	 * Method name  : finish
	 * Description  : Calls the BatchAccountSnapshotResult class in order to grab more records to be used later for comparison
	 * Returns      : None
	************************************************************ */
	global void finish(Database.BatchableContext batchContext) {
		startBound = endBound + 1;
		endBound = endBound + 5000.0;
		//String stringBound = String.valueOf(newBound);

		BatchAccountSnapshotResult myBatch = new BatchAccountSnapshotResult(firstMonth, secondMonth, startBound, endBound);
		String myQuery = 'SELECT Id, Name, Account__c, Account__r.Id, Carrier_Count__c, Sliced__c, Exchange__c, Status__c, Snapshot_Number__c FROM Complete_Account_Snapshot__c';
		myQuery = myQuery + ' WHERE (Name =\'' + myBatch.firstMonth + '\'';
		myQuery = myQuery + ' AND Snapshot_Number__c <= :endBound AND Snapshot_Number__c >= :startBound)';
		System.debug('Query: ' + myQuery);
		myBatch.query = myQuery;
		Id myBatchProcessId = Database.executeBatch(myBatch, 2000);
	}
}