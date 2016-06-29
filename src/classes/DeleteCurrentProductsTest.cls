@isTest
public with sharing class DeleteCurrentProductsTest {

	@isTest
	public static void testDeleteCurrentProducts() {


		Test.StartTest();
		Account testAccount = new Account(Name = 'test', Status__c = 'Active');
		insert testAccount;
		Current_Product__c currProduct = new Current_Product__c(Account__c = testAccount.Id);

		insert currProduct;

		DeleteCurrentProducts batchDeleteProducts = new DeleteCurrentProducts('Select Id from Current_Product__c');

		ID batchprocessid = Database.executeBatch(batchDeleteProducts);

		Test.StopTest();

		List<Current_Product__c> currProd  = [SELECT Name, Number_Of_BAs__c, Funding_Type__c FROM Current_Product__c Where Number_Of_BAs__c > 1];
		System.assertEquals(0, currProd.size());

	}

}