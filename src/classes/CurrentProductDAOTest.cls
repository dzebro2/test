@isTest
public with sharing class CurrentProductDAOTest {

	@isTest
	static void CurrentProductDAOTest() {

		CurrentProductDAO.ICurrentProductDAO currentProductDAOInstance = new CurrentProductDAO();
		Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
		User testUser = new User(Alias = 'standt1', Email = 'john.testing@testorg.com', EmailEncodingKey = 'UTF-8', LastName = 'Testing', FirstName = 'John', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = p.Id, TimeZoneSidKey = 'America/Los_Angeles', UserName = 'john.testing@testorg.com', isActive = TRUE);
		insert testUser;

		List<Product2> testProducts = TestClassUtiltity.createProducts();
		insert testProducts;

		Account testAcnt = TestClassUtiltity.CreateAccountRecord('TestAccount');

		Current_Product__c currentProduct = new Current_Product__c(Account__c = testAcnt.Id, Product__c = testProducts[0].Id);
		List<Current_Product__c> listProds = new List<Current_Product__c>();
		listProds.add(currentProduct);

		List<Current_Product__c> testProds = currentProductDAOInstance.insertCurrentProducts(listProds);
		System.assertEquals(testProds.size(), 1);

		currentProductDAOInstance.deleteAllCurrentProducts(testProds);
		List<Current_Product__c> afterDeleteProds = [SELECT Id FROM Current_Product__c];
		System.assertEquals(afterDeleteProds.size(), 0);
	}
}