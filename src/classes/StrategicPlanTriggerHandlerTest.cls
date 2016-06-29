@isTest
private class StrategicPlanTriggerHandlerTest {

	@isTest
	static void validateRecordChangeTest() {

		
		//Grab the recordtypes
		Id recTypeGroupAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Group Account').getRecordTypeId();
		Id recTypeProspectAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
		Id recTypeSPlanProspect = Schema.SObjectType.Strategic_Plan__c.getRecordTypeInfosByName().get('Prospect Account Plan').getRecordTypeId();
		Id recTypeSPlanGroup = Schema.SObjectType.Strategic_Plan__c.getRecordTypeInfosByName().get('Group Account Plan').getRecordTypeId();
		//Create the user
		Profile p = [SELECT Id FROM Profile WHERE Name = 'LGNA - Account Management'];
		User u = TestClassUtiltity.CreateStratgicPlanUser(p.id, 'lgna@testorg.com', 'Last Name', 'Test@test.com');
		
		List<Strategic_Plan_Super_Users__c> cs = TestClassUtiltity.createStrategicHelperCustomSetting();
		
		Strategic_Plan__c sPlan1;
		Strategic_Plan__c sPlan2;
		Date futureDate = Date.today() + 30;	
		
		Test.startTest();	
		
		System.runAs(u) {
			
			try {	
			Account groupAcnt = TestClassUtiltity.createAccountWithRecType('Strategic Plan Account 1', recTypeGroupAccount);			

				sPlan1 = new Strategic_Plan__c(Account_Name__c = GroupAcnt.Id);
				sPlan1.RecordTypeId = recTypeSPlanGroup;
				sPlan1.Active__c = True;
				splan1.Name = 'Test Strategic Plan';
				sPlan1.Effective_Date__c = futureDate;
				insert sPlan1;

				try {
					splan1.Effective_Date__c = (futureDate + 1);
					update sPlan1;
				} catch(Exception ex) {
					Boolean expectedExceptionThrown = (ex.getMessage().contains(Label.Strategic_Plan_Update_Not_Allowed) ? true : false);
					System.AssertEquals(expectedExceptionThrown, false);
				}

				try {
					sPlan1.Effective_Date__c = Date.today() - 1;
					update sPlan1;
					sPlan1.Effective_Date__c = futureDate + 45;
					update sPlan1;
				} catch(Exception ex) {
					Boolean expectedExceptionThrown = (ex.getMessage().contains(Label.Strategic_Plan_Update_Not_Allowed) ? true : false);
					System.AssertEquals(expectedExceptionThrown, true);
				}
			} catch(Exception ex) {
				sPlan1.Active__c = false;
				update sPlan1;
			}


			/*Test Prospect Account and Strategic Plan - We can also test Prospect Account Name Updates*/
			
			try {
			Account ProspectAcnt = TestClassUtiltity.createAccountWithRecType('Strategic Plan Test 2', recTypeProspectAccount);
				

				sPlan2 = new Strategic_Plan__c(Account_Name__c = ProspectAcnt.Id);
				sPlan2.RecordTypeId = recTypeSPlanProspect;
				sPlan2.Active__c = True;
				splan2.Name = 'Test Strategic Plan 2';
				sPlan2.Effective_Date__c = futureDate;
				insert sPlan2;

				try {
					splan2.Name = 'Updated Attempt 1';
					update sPlan2;
				} catch(Exception ex) {
					Boolean expectedExceptionThrown = (ex.getMessage().contains(Label.Strategic_Plan_Update_Not_Allowed) ? true : false);
					System.AssertEquals(expectedExceptionThrown, false);
				}

				try {
					splan2.Effective_Date__c = Date.today() - 1;
					update sPlan2;
					splan2.Name = 'Post Effective Date Attempt';
					update sPlan2;
				} catch(Exception ex) {
					Boolean expectedExceptionThrown = (ex.getMessage().contains(Label.Strategic_Plan_Update_Not_Allowed) ? true : false);
					System.AssertEquals(expectedExceptionThrown, true);
				}
			} catch(Exception ex) {
				CreateExceptionLog.insertErrorLog(ex, null, null, null, 'Apex Class', 'Strategic Plan', 'StrategicPlanTrigger', 'StrategicPlanTriggerHandler.validateRecordChange()', 'High');
			}

			/* Testing the update of efftective date after it has passed. -Should not be allowed */
			try {
				splan2.Effective_Date__c = Date.today() + 225;
				update sPlan2;
				System.assert(false, 'Exception expected');
			} catch(Exception ex) {
				Boolean expectedExceptionThrown = (ex.getMessage().contains(Label.Strategic_Plan_Update_Not_Allowed) ? true : false);
				System.AssertEquals(expectedExceptionThrown, true);
				CreateExceptionLog.insertErrorLog(ex, null, null, null, 'Apex Class', 'Strategic Plan', 'StrategicPlanTrigger', 'StrategicPlanTriggerHandler.validateRecordChange()', 'High');
			}
		}
        Test.stopTest();
	}
    
    @isTest
	static void resetFieldsForClonedSPTest() {

		//Grab the recordtypes
		Id recTypeGroupAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Group Account').getRecordTypeId();
		Id recTypeSPlanGroup = Schema.SObjectType.Strategic_Plan__c.getRecordTypeInfosByName().get('Group Account Plan').getRecordTypeId();
		//Create the user
		Profile p = [SELECT Id FROM Profile WHERE Name = 'LGNA - Account Management'];
		User u = TestClassUtiltity.CreateStratgicPlanUser(p.id, 'lgna@testorg.com', 'Last Name', 'Test@test.com');

		List<Strategic_Plan_Super_Users__c> cs = TestClassUtiltity.createStrategicHelperCustomSetting();

		Strategic_Plan__c sPlan1;
		Date futureDate = Date.today() + 30;

		Test.startTest();

		System.runAs(u) {
			try {
				Account groupAcnt = TestClassUtiltity.createAccountWithRecType('Strategic Plan Account 1', recTypeGroupAccount);
				sPlan1 = new Strategic_Plan__c(Account_Name__c = GroupAcnt.Id);
				sPlan1.RecordTypeId = recTypeSPlanGroup;
				sPlan1.Active__c = True;
				splan1.Name = 'Test Strategic Plan';
				sPlan1.Effective_Date__c = futureDate;
				sPlan1.Manager_Approval__c = TRUE;
				insert sPlan1;
                Strategic_Plan__c sPlan2 = sPlan1.clone();
                insert sPlan2;
			} catch (Exception ex) {
				CreateExceptionLog.insertErrorLog(ex, null, null, null, 'Apex Class', 'Strategic Plan', 'StrategicPlanTrigger', 'StrategicPlanTriggerHandler.resetFieldsForClonedSPTest', 'High');
			}
		}
        Test.stopTest();
	}

	@isTest
	static void throwException() {
		try
		{
			StrategicPlanTriggerHandler.validateRecordChange(null, null);
            StrategicPlanTriggerHandler.resetFieldsForClonedSP(null);
		}
		catch(NullPointerException e)
		{
            
		}
	}
}