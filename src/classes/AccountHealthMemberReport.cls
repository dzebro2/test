global class AccountHealthMemberReport implements Database.Batchable<sObject> {
	String query;


	global AccountHealthMemberReport(String theQuery) {

		this.query = theQuery;
	}

	global Database.querylocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		List<Account_Member_Snapshot__c> accns = new List<Account_Member_Snapshot__c>();

		for (sObject s : scope) {
			Account a = (Account)s;
			Account_Member_Snapshot__c ams = new Account_Member_Snapshot__c();
			ams.Name = System.now().format();
			ams.Account_Name__c = a.Name;
			ams.Account__c = a.Id;
			ams.Active_Health_Members__c = a.Active_Health_Members__c;

			accns.add(ams);
		}

		insert accns;

	}
	global void finish(Database.BatchableContext BC) {

	}
}