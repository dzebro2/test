/**************************************************************************************
  Apex Class Name     : ScheduledBatchCompleteAccountSnapshot
  Version             : 1.0
  Function            : Schedules the Complete Account Snapshot batch process for Account records
* Developer                  Date                  Description
* ----------------------------------------------------------------------------
  Ralph Tariga      :   March 5 2016           Original Version
*************************************************************************************/
global with sharing class ScheduledBatchCompleteAccountSnapshot implements Schedulable {

	
	global void execute(SchedulableContext sc) {

		String theQuery = 'SELECT Id, Name, RecordType.Name, Sliced__c, Exchange_Account__c, Status__c, AccountNumber, (SELECT Id FROM Competitor_Relationships1__r  WHERE Group_Account__c != NULL) FROM Account WHERE RecordType.Name = \'Group Account\'';
		BatchCreateCompleteAccountSnapshot Batch = new BatchCreateCompleteAccountSnapshot();
		Batch.query = theQuery;
		ID batchprocessid = Database.executeBatch(Batch, 2000);
	}
}