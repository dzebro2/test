global with sharing class ScheduledBatchCreateCurrentProducts implements Schedulable {

	//This Apex class schedules a BatchCreateAccountSnapshot to be run.
	global void execute(SchedulableContext sc) {

		BatchCreateCurrentProducts batch = new BatchCreateCurrentProducts('SELECT Id, Name, Status__c FROM Account WHERE Status__c = \'Active\'');

		ID batchprocessid = Database.executeBatch(batch, 2000);
	}
}