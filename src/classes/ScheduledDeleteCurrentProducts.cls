global with sharing class ScheduledDeleteCurrentProducts implements Schedulable {

	global void execute(SchedulableContext sc) {

		DeleteCurrentProducts Batch = new DeleteCurrentProducts('SELECT Id FROM Current_Product__c');
		ID batchprocessid = Database.executeBatch(Batch, 2000);
	}

}