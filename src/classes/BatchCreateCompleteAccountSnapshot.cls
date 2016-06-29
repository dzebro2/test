/**************************************************************************************
  Apex Class Name     : BatchCreateCompleteAccountSnapshot
  Version             : 1.0
  Function            : Creates Complete Account Snapshot records in batches for
  						a certain period in time to be used for comparison
* Developer                  Date                  Description
* ----------------------------------------------------------------------------
  Ralph Tariga       :   March 5 2016           Original Version
*************************************************************************************/
global class BatchCreateCompleteAccountSnapshot implements Database.Batchable<sObject>, Database.Stateful {


	// This class creates and inserts Complete_Account_Snapshot__c records for each Group Account including Cancelled Accounts
	// for reporting changes in Accounts

	public String query;
	public Integer currentMonth;
	public Integer currentYear;
	public Integer recordNum = 1;


	global BatchCreateCompleteAccountSnapshot() {
	}

	/*************************************************************
	 * Method name  : start
	 * Description  : Method that initiates the batch process. It calls the query that was set in the Schedule method
	 * Returns      : Account records
	************************************************************ */
	global Database.querylocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

	/*************************************************************
	 * Method name  : execute
	 * Description  : Method that iterates through the query in order to map account fields to the Complete Account Snapshot records and insert them
	 * Returns      : None
	************************************************************ */
	global void execute(Database.BatchableContext BC, List<sObject> scope) {

		List<Complete_Account_Snapshot__c> accountSnapshots = new List<Complete_Account_Snapshot__c>();
		List<String> months = new List<String> {'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December', 'Error Getting Date'};

		for (sObject s : scope) {
			Account a = (Account)s;
			Complete_Account_Snapshot__c newAccountSnapshot = new Complete_Account_Snapshot__c();


			if (!Test.isRunningTest()) {
				currentMonth = System.now().month();
				currentYear = System.now().year();
			}

			try {
				if (currentMonth != null)
					newAccountSnapshot.Name = months[currentMonth - 1] + ' ' + currentYear;
				else
					newAccountSnapshot.Name = 'Not Expected';
			} catch (Exception e) {
				newAccountSnapshot.Name = 'Error Getting Date';
				System.debug('Bad index given to month list');
			}


			newAccountSnapshot.Account__c = a.Id;
			newAccountSnapshot.Account_Id__c = a.Id;
			newAccountSnapshot.Sliced__c = a.Sliced__c;
			newAccountSnapshot.Exchange__c = a.Exchange_Account__c;
			newAccountSnapshot.Carrier_Count__c = a.Competitor_Relationships1__r.size();
			newAccountSnapshot.Status__c = a.Status__c;
			newAccountSnapshot.Snapshot_Date__c = system.today();
			newAccountSnapshot.Snapshot_Number__c = recordNum;
			accountSnapshots.add(newAccountSnapshot);

			recordNum++;
		}

		insert accountSnapshots;

	}

	/*************************************************************
	 * Method name  : finish
	 * Description  : Place to do post batch logic. None needed for this class.
	 * Returns      : None
	************************************************************ */
	global void finish(Database.BatchableContext BC) {

	}
}