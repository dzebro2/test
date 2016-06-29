@isTest
private class QueueLookupControllerTest {

	String userNoSearchPageRefPath = '/apex/QueueLookupPage?&lkfm=page%3ACaseForm&lknm=page%3ACaseForm%3APageBlock%3Aj_id6%3AqueueLookup&lktp=StandardUserLookup&rctp=Cede&lksrch=';
	String userSearchPageRefPath = '/apex/QueueLookupPage?&lkfm=page%3ACaseForm&lknm=page%3ACaseForm%3APageBlock%3Aj_id6%3AqueueLookup&lktp=StandardUserLookup&rctp=Cede&lksrch=test';
	String groupPageRefPath = '/apex/QueueLookupPage?&lkfm=page%3ACaseForm&lknm=page%3ACaseForm%3APageBlock%3Aj_id6%3AqueueLookup&lktp=case_queue&rctp=Cede&lksrch=';

	PageReference userNoSearchPageRef = new PageReference(userNoSearchPageRefPath);
	PageReference userSearchPageRef = new PageReference(userSearchPageRefPath);
	PageReference groupPageRef = new PageReference(groupPageRefPath);


	// Tests on getRecentlyViewedUsers and getGroupsByRecordType
	@isTest static void test_method_one() {
		try {
			test.StartTest();
			Integer pageSize = 20;
			String userSearchPageRefPath = '/apex/QueueLookupPage?&lkfm=page%3ACaseForm&lknm=page%3ACaseForm%3APageBlock%3Aj_id6%3AqueueLookup&lktp=StandardUserLookup&rctp=Cede&lksrch=';
			PageReference userSearchPageRef = new PageReference(userSearchPageRefPath);
			Test.setCurrentPage(userSearchPageRef);
			QueueLookupController qlController = new QueueLookupController();

			List<User> users = qlController.getRecentlyViewedUsers();
			List<User> users2 = [SELECT Name, Title, Phone, Email, Id FROM User
			                     WHERE LastViewedDate != NULL
			                     ORDER BY LastViewedDate DESC LIMIT :pageSize];

			System.assertEquals(users, users2);

			List<Group> group1 = qlController.getGroupsByRecordType('Proposal');
			List<CaseQueues__c> group2 = [SELECT Id FROM CaseQueues__c where RecordTypeName__c =  'Proposal'];

			System.assertEquals(group1.size(), group2.size());
			test.StopTest();
		} catch (Exception e) {

		}
	}



	//This method is to test performsearch, next and previous methods.
	@isTest static void test_method_two() {
		Test.startTest();
		List<User> users = new List<User>() ;
		Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User'];




		Integer i;
		for (i = 0 ; i < 30 ; i++) {

			users.add(TestClassUtiltity.createUserRecord(p.id , 'alecK' + i + '@slalom.com', 'Klein' , 'AlecK@slalom.com'));


		}


		String userSearchPageRefPath = '/apex/QueueLookupPage?&lkfm=page%3ACaseForm&lknm=page%3ACaseForm%3APageBlock%3Aj_id6%3AqueueLookup&lktp=StandardUserLookup&rctp=Cede&lksrch=Klein';
		PageReference userSearchPageRef = new PageReference(userSearchPageRefPath);

		String userNoSearchPageRefPath = '/apex/QueueLookupPage?&lkfm=page%3ACaseForm&lknm=page%3ACaseForm%3APageBlock%3Aj_id6%3AqueueLookup&lktp=StandardUserLookup&rctp=Cede&lksrch=';
		PageReference userNoSearchPageRef = new PageReference(userNoSearchPageRefPath);



		Test.setCurrentPage(userSearchPageRef);
		QueueLookupController qlController = new QueueLookupController();

		qlController.search();


		System.assertNotEquals(qlController.userResults, users);

		qlController.next();
		System.assertEquals(qlController.pageNumber, 1);


		qlController.previous();
		System.assertEquals(qlController.pageNumber, 0);



		Test.stopTest();
	}
}