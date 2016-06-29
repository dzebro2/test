/**************************************************************************************
  Apex Class Name     : ScheduledAccountSnapshotTest
  Version             : 1.0
  Function            : Test class for the Scheduled Account Snapshot Result class
  Modification Log    :
* Developer                  Date                  Description
* ----------------------------------------------------------------------------
  Nick Serafin       :   March 9 2016           Original Version
*************************************************************************************/
@isTest
private class ScheduledAccountSnapshotTest {

    // CRON expression: midnight on March 15.
    // Because this is a test, job executes
    // immediately after Test.stopTest().
    public static String CRON_EXP = '0 0 0 15 3 ? 2022';


    static testmethod void scheduledSnapshotTest() {
        List<SVSReport__c> years = new List<SVSReport__c>();
        years.add(new SVSReport__c(Name = 'Year1', Month__c = 'Jun-16'));
        years.add(new SVSReport__c(Name = 'Year2', Month__c = 'Jun-17'));
        insert years;
    
        Test.startTest();

        // Schedule the test job
        String jobId = System.schedule('ScheduleApexClassTest',
                                       CRON_EXP,
                                       new ScheduledAccountSnapshotResult());

        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered,
                          NextFireTime
                          FROM CronTrigger WHERE id = :jobId];

        // Verify the expressions are the same
        System.assertEquals(CRON_EXP,
                            ct.CronExpression);

        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);

        // Verify the next time the job will run
        System.assertEquals('2022-03-15 00:00:00',
                            String.valueOf(ct.NextFireTime));

        Test.stopTest();

    }
}