global with sharing class ScheduledBatchCreateAccountSnapshot implements Schedulable {

	//This Apex class schedules a BatchCreateAccountSnapshot to be run.
	global void execute(SchedulableContext sc) {

		String theQuery = 'SELECT Id, Name, RecordType.Name, Active_Health_Members__c FROM Account WHERE Status__c != \'Cancelled\' AND RecordType.Name = \'Group Account\'';
		BatchCreateAccountSnapshot Batch = new BatchCreateAccountSnapshot();
		Batch.query = theQuery;
		ID batchprocessid = Database.executeBatch(Batch, 2000);
	}
}