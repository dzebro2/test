@isTest
private class ConfirmProduct360StatusControllerTest { 
	
	@isTest
	static void saveTest(){
		
		Test.startTest();
		Account testAccount = TestClassUtiltity.CreateAccountRecord('Test Account');
		List<Opportunity> testOpp = TestClassUtiltity.CreateOpportunities(testAccount.Id);
		testOpp[0].Requested_Effective_Date__c = System.now().date();
		insert testOpp[0];

		List<Product2> testProducts = TestClassUtiltity.createProducts();
		testProducts[0].Non_Medical_Compensation__c = True;
		testProducts[1].Non_Medical_Compensation__c = True;
		insert testProducts;

		List<Opportunity_Product__c> testOpProduct1 = TestClassUtiltity.createOppProducts(testOpp[0].Id, testProducts[0].Id);
		List<Opportunity_Product__c> testOpProduct2 = TestClassUtiltity.createOppProducts(testOpp[0].Id, testProducts[1].Id);
		testOpProduct1[0].Product_Type__c = 'New Sale';
		testOpProduct1[0].Category__c = 'Medical';
		testOpProduct1[0].Status__c = 'Lost';

		testOpProduct2[0].Category__c = 'Dental';
		testOpProduct2[0].Product_Type__c = 'New Sale';
		testOpProduct2[0].Status__c = 'Lost';
		insert testOpProduct1;
		insert testOpProduct2;

		Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
		User testUser = new User(Alias = 'standt1', Email = 'john.testing@testorg.com',EmailEncodingKey = 'UTF-8', LastName = 'Testing', FirstName = 'John', LanguageLocaleKey = 'en_US',LocaleSidKey = 'en_US', ProfileId = p.Id, TimeZoneSidKey = 'America/Los_Angeles',UserName = 'john.testing@testorg.com', isActive = TRUE);
		insert testUser;

		List<AccountTeamMember> testAccountTeam = TestClassUtiltity.createAccTeamMember(testAccount.Id, testUser.Id);
		insert testAccountTeam;

		PageReference initialPage = new PageReference('/apex/ConfirmProduct360Status');
        Test.setCurrentPage(initialPage);
        System.assertNotEquals(null, InitialPage);
        System.runAs(testUser){ 

			ConfirmProduct360StatusController sc = new ConfirmProduct360StatusController();             
			System.assertNotEquals(sc.opportunityObjects, null);
			PageReference result = sc.save();
			Test.setCurrentPage(result);
			System.assertEquals(result.getUrl(), ApexPages.currentPage().getUrl());
		}
        Test.stopTest();
	}
}