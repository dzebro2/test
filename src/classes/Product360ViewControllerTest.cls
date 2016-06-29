@isTest
private class Product360ViewControllerTest {
	
    @testSetup
    static void setupTests(){
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
    }
    @isTest
    static void testAddRow(){
        
        Test.startTest();
		

		PageReference initialPage = new PageReference('/apex/Product360View');
        Test.setCurrentPage(initialPage);
        System.assertNotEquals(null, InitialPage);
        User testUser = [Select Id, Email from User where Email = 'john.testing@testorg.com' limit 1];
        System.runAs(testUser){ 

			Product360ViewController sc = new Product360ViewController();             
			List<Opportunity> testOpp = [select Id, Name from Opportunity];
            sc.currentOpportunity = testOpp[0].Id;
            System.assertEquals(2, sc.accountWrappers[0].opps[0].opportunityProducts.size()); 
            sc.addNewOpportunityProduct();
            System.assertEquals(3, sc.accountWrappers[0].opps[0].opportunityProducts.size()); 
			sc.save();
		}
        Test.stopTest();
    }
    
    @isTest
    static void testRemoveRow(){
        
        Test.startTest();
		

		PageReference initialPage = new PageReference('/apex/Product360View');
        Test.setCurrentPage(initialPage);
        System.assertNotEquals(null, InitialPage);
        User testUser = [Select Id, Email from User where Email = 'john.testing@testorg.com' limit 1];
        System.runAs(testUser){ 

			Product360ViewController sc = new Product360ViewController();             
			List<Opportunity> testOpp = [select Id, Name from Opportunity];
            List<Opportunity_Product__c> testOppProducts = [Select Id from Opportunity_Product__c];
            sc.currentOpportunity = testOpp[0].Id;
            sc.recordToDelete = testOppProducts[0].Id;
            System.assertEquals(2, sc.accountWrappers[0].opps[0].opportunityProducts.size()); 
            sc.removeRow();
            System.assertEquals(1, sc.accountWrappers[0].opps[0].opportunityProducts.size()); 
			sc.save();
		}
        Test.stopTest();
    }
}