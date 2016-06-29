@isTest
public with sharing class ScheduledBatchCreateCurrentProductsTest {

	public static String CRON_EXP = '0 0 0 15 3 ? 2022';

	@isTest
	static void testScheduledBatchCreateCurrentProducts() {
		Test.startTest();

		String jobId = System.schedule('ScheduleApexClassTest',
		                               CRON_EXP,
		                               new ScheduledBatchCreateCurrentProducts());

		CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered,
		                  NextFireTime
		                  FROM CronTrigger WHERE id = :jobId];

		System.assertEquals(CRON_EXP,
		                    ct.CronExpression);

		System.assertEquals(0, ct.TimesTriggered);

		System.assertEquals('2022-03-15 00:00:00',
		                    String.valueOf(ct.NextFireTime));

		Test.stopTest();

	}
}