/**
* @author dan.zebrowski@slalom.com
* @description This class creates and inserts Account_Snapshot__c records for each Group Account 
*			   to facilitate reporting on monthly Active Health Members for each account
*/
global class BatchCreateAccountSnapshot implements Database.Batchable<sObject> {

    public String query;
    public Integer currentMonth;
    public Integer currentYear;


    global BatchCreateAccountSnapshot() {
    }

	/**
	* @description First method run of the batch to grab all records in query
	* @param BC Internal Apex object for running batch jobs
	* @return Database.querylocator Object that contains the query results
	*/
    global Database.querylocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

	/**
	* @description This method runs for each batch of records in the job. Creates a new Account_Snapshot__c record
	*			   for each Non-cancelled Group Accounts to store the Active_Health_Members__c
	* @param BC	   Internal Apex object for running batch jobs
	* @param scope List<sObject> containg the records to be processed in this batch
	*/
    global void execute(Database.BatchableContext BC, List<sObject> scope) {

        List<Account_Snapshot__c> accountSnapshots = new List<Account_Snapshot__c>();
        List<String> months = new List<String> {'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December', 'Error Getting Date'};

        for (sObject s : scope) {
            Account a = (Account)s;
            Account_Snapshot__c newAccountSnapshot = new Account_Snapshot__c();


            if (!Test.isRunningTest()) {
                currentMonth = System.now().month();
                currentYear = System.now().year();
            }

            try {
                if (currentMonth != null)
                    newAccountSnapshot.Name = months[currentMonth - 1] + ' ' + currentYear;
                else
                    newAccountSnapshot.Name = 'Error Getting Date';
            } catch (Exception e) {
                newAccountSnapshot.Name = 'Error Getting Date';
                System.debug('Bad index given to month list');
            }


            newAccountSnapshot.Account__c = a.Id;
            newAccountSnapshot.Active_Health_Members__c = a.Active_Health_Members__c;
            accountSnapshots.add(newAccountSnapshot);
        }

        insert accountSnapshots;

    }

    global void finish(Database.BatchableContext BC) {

    }
}