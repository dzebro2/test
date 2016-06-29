/**************************************************************************************
  Apex Class Name     : ScheduledBatchCompleteAccSnapshotTest
  Version             : 1.0
  Function            : Test class for ScheduledBatchCompleteAccountSnapshot
* Developer                  Date                  Description
* ----------------------------------------------------------------------------
  Ralph Tariga       :   March 5 2016           Original Version
*************************************************************************************/
@isTest
private class ScheduledBatchCompleteAccSnapshotTest {

	// CRON expression: midnight on March 15.
	// Because this is a test, job executes
	// immediately after Test.stopTest().
	public static String CRON_EXP = '0 0 0 15 3 ? 2022';


	static testmethod void testScheduledBatchCompleteAccSnapshot() {
		Test.startTest();

		// Schedule the test job
		String jobId = System.schedule('ScheduleApexClassTest',
		                               CRON_EXP,
		                               new ScheduledBatchCompleteAccountSnapshot());

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