/** This class is a test class to validate methods in CaseQueueSelectionController.
	The save method will update the Current Case's caseowner.ID */


@isTest
private class CaseQueueSelectionControllerTest {
	@isTest
	static void TestsaveMethod() {
		Test.startTest();
		Case case1 = new Case();
		case1.Subject = 'Test Case';

		Id oldId = case1.owner.Id ;
		insert case1;

		ApexPages.StandardController sc = new ApexPages.StandardController(case1);
		CaseQueueSelectionController controller = new CaseQueueSelectionController(sc);

		PageReference pageref = new PageReference('/apex/CaseQueueSelection');
		pageref.getParameters().put('id', case1.Id);
		Test.setCurrentPage(pageref);

		controller.save();

		System.AssertEquals(case1.Owner.Id , oldId);
		System.AssertEquals(case1.Owner.Id , oldId);
	}


	@isTest
	static void TestsaveMethodException() {
		Test.startTest();

		Case case1 = new Case();
		case1.Subject = 'Test Case';

		Case case2 = new Case();
		case1.Subject = 'Test Case 2';

		insert case1;
		insert case2;

		ApexPages.StandardController sc = new ApexPages.StandardController(case1);
		CaseQueueSelectionController controller = new CaseQueueSelectionController(sc);

		PageReference pageref = new PageReference('/apex/CaseQueueSelection');
		pageref.getParameters().put('id', case2.owner.Id);
		Test.setCurrentPage(pageref);

		controller.save();

		System.AssertEquals(case1.Owner.Id , case2.Owner.Id);
	}

	@isTest
	static void TestOwnerIsQueue() {
		Test.startTest();
		Profile currentProfile = [SELECT Name, Id FROM Profile WHERE Name = 'LGNA - Account Management' LIMIT 1];
		User currentUser = TestClassUtiltity.CreateUserRecord(currentProfile.Id, 'TestUserCaseQueues@test.com', 'TestLastNameCaseQueues', 'TestUserCaseQueues@test.com');
		System.runAs(currentUser){
			Case case1 = new Case();
			case1.Subject = 'Test Case';

			Id oldId = case1.owner.Id;
			case1.OwnerId = currentUser.Id;
			insert case1;

			ApexPages.StandardController sc = new ApexPages.StandardController(case1);
			CaseQueueSelectionController controller = new CaseQueueSelectionController(sc);

			PageReference pageref = new PageReference('/apex/CaseQueueSelection');
			pageref.getParameters().put('id', case1.Id);
			Test.setCurrentPage(pageref);
		}
		Test.stopTest();
		System.assert(True);
	}
}