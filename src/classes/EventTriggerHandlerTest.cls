@isTest
public class EventTriggerHandlerTest {
	
	static testMethod void testUpdateUserLastOppActivity() {
		
		
		Profile p = [SELECT Id FROM Profile WHERE Name='LGNA - Account Management']; 
		User testUser = TestClassUtiltity.CreateUserRecord(p.Id, 'testlgnadev@user.com', 'testUser', 'test@user.com');
		Account testAccount = TestClassUtiltity.CreateAccountRecord('Test Account');
		testAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Group Account').getRecordTypeId();
		
		update testAccount;
		System.runAs(testUser){
			
			List<Opportunity> opps = TestClassUtiltity.CreateOpportunities(testAccount.Id);
			opps[0].RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal').getRecordTypeId();
			opps[0].StageName = 'Closed Won';
			opps[0].Rate_End_Date__c = System.today()+1;
			opps[0].Exchange_Offering_Type__c = 'No Private Exchange';
           
			insert opps[0];
			
			System.assertEquals(testUser.Last_Opp_Activity_Date__c, null);
			
			opps[0].Description = 'its changed';
			update opps[0];

			Task t = new Task(WhatID = opps[0].Id,ActivityDate = system.today().addDays(-1),Subject='Donni',Status='In Progress',Priority='Normal');
			insert t;
			Event e = new Event(WhatId = opps[0].Id,Subject = 'Test Event 1',StartDateTime = system.now().addMonths(1),EndDateTime = system.now().addMonths(1).addHours(1));
			insert e;
			System.assertEquals(t.WhatId, opps[0].Id);
			System.assertEquals(e.WhatId, opps[0].Id);
			
		}
	}
}