@isTest
private class BatchCreateAccountSnapshotTest {


    public static testMethod void testBatchError() {


        Test.StartTest();


        List <Account> accns = new List<Account>();
        for (integer i = 0; i < 10; i++) {
            Account a = new Account(Name = 'testAccount' + 'i');
            accns.add(a);
        }

        insert accns;


        BatchCreateAccountSnapshot accountSnapshot = new BatchCreateAccountSnapshot();
        accountSnapshot.currentMonth = 0;
        accountSnapshot.currentYear = 2010;
        accountSnapshot.query = 'SELECT Id, Name, RecordType.Name, Active_Health_Members__c, Sliced__c, Exchange_Account__c, Status__c, AccountNumber FROM Account';

        ID batchprocessid = Database.executeBatch(accountSnapshot);

        System.AssertEquals(
            database.countquery('SELECT COUNT()' + ' FROM Account'), 10);


        Test.StopTest();

    }

    public static testMethod void testBatchJan() {


        Test.StartTest();


        List <Account> accns = new List<Account>();
        for (integer i = 0; i < 10; i++) {
            Account a = new Account(Name = 'testAccount' + 'i');
            accns.add(a);
        }

        insert accns;


        BatchCreateAccountSnapshot accountSnapshot = new BatchCreateAccountSnapshot();
        accountSnapshot.currentMonth = 1;
        accountSnapshot.currentYear = 2010;
        accountSnapshot.query = 'SELECT Id, Name, RecordType.Name, Active_Health_Members__c, Sliced__c, Exchange_Account__c, Status__c, AccountNumber FROM Account';

        ID batchprocessid = Database.executeBatch(accountSnapshot);

        System.AssertEquals(
            database.countquery('SELECT COUNT()' + ' FROM Account'), 10);



        Test.StopTest();
        Account_Snapshot__c testAccount = [SELECT Name FROM Account_Snapshot__c LIMIT 1];
        System.assertEquals('January 2010', testAccount.Name);
    }

    public static testMethod void testBatchFeb() {


        Test.StartTest();


        List <Account> accns = new List<Account>();
        for (integer i = 0; i < 10; i++) {
            Account a = new Account(Name = 'testAccount' + 'i');
            accns.add(a);
        }

        insert accns;


        BatchCreateAccountSnapshot accountSnapshot = new BatchCreateAccountSnapshot();
        accountSnapshot.currentMonth = 10;
        accountSnapshot.currentYear = 2010;
        accountSnapshot.query = 'SELECT Id, Name, RecordType.Name, Active_Health_Members__c, Sliced__c, Exchange_Account__c, Status__c, AccountNumber FROM Account';

        ID batchprocessid = Database.executeBatch(accountSnapshot);

        System.AssertEquals(
            database.countquery('SELECT COUNT()' + ' FROM Account'), 10);


        Test.StopTest();
        Account_Snapshot__c testAccount = [SELECT Name FROM Account_Snapshot__c LIMIT 1];
        System.assertEquals('October 2010', testAccount.Name);

    }

    
}