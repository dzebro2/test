global with sharing class ScheduledAccountHealthMemberReport implements Schedulable {

	public static String schedule = '59 59 23 L * ?';  //Every Day at Midnight

	//global static String scheduleThisJob() {
	//	AccountHealthMemberReport SBJ = new ScheduAccountHealthMemberReport();
	//	return System.schedule('Your Job Name', schedule, SBJ);
	//}

	global void execute(SchedulableContext sc) {
		String query = 'SELECT Id, Name, RecordType.Name, Active_Health_Members__c FROM Account WHERE Status__c != \'\' AND Status__c != \'Cancelled\' AND Status__c != \'Terminated\' AND RecordType.Name = \'Group Account\'';
		AccountHealthMemberReport Batch = new AccountHealthMemberReport(query);
		ID batchprocessid = Database.executeBatch(Batch, 2000);
	}

}