@isTest
public with sharing class BatchCreateCurrentProductsTest {

	@isTest
	public static void testCreateCurrentProducts() {


		Test.StartTest();

		Account competitor = new Account(Name = 'competitor', Status__c = 'Active');
		competitor.Type = 'Competitor Account';
		competitor.RecordTypeid = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Competitor').getRecordTypeId();
		Account testAccount = new Account(Name = 'test', Status__c = 'Active');
		insert competitor;
		insert testAccount;
		List<Product2> testProducts = TestClassUtiltity.createProducts();
		insert testProducts;

		Competitor_Relationship__c compRelation = new Competitor_Relationship__c(Competitor_Account__c = competitor.Id, Group_Account__c = testAccount.Id, Status__c = 'Active');
		compRelation.RecordTypeid = Schema.SObjectType.Competitor_Relationship__c.getRecordTypeInfosByName().get('Competitor').getRecordTypeId();
		insert compRelation;
		Competitor_Products__c compProd = new Competitor_Products__c(Carrier__c = compRelation.Id, Product__c = testProducts[0].Id, Status__c = 'Active', Effective_Date__c = (System.today() - 1));
		insert compProd;

		Benefit_Agreement__c testBA1 = new Benefit_Agreement__c(Group_Account__c = testAccount.Id, Effective_Date__c = (System.today() - 1), Status__c = 'Active', Product__c = testProducts[0].Id, Funding_Type__c = 'ASO');
		Benefit_Agreement__c testBA2 = new Benefit_Agreement__c(Group_Account__c = testAccount.Id, Effective_Date__c = (System.today() - 1), Status__c = 'Active', Product__c = testProducts[1].Id, Funding_Type__c = 'ASO');
		Benefit_Agreement__c testBA3 = new Benefit_Agreement__c(Group_Account__c = testAccount.Id, Effective_Date__c = (System.today() - 1), Status__c = 'Active', Product__c = testProducts[1].Id, Funding_Type__c = 'ACAP');
		Benefit_Agreement__c testBA4 = new Benefit_Agreement__c(Group_Account__c = testAccount.Id, Effective_Date__c = (System.today() + 1), Status__c = 'Active', Product__c = testProducts[1].Id, Funding_Type__c = 'ACAP');
		List<Benefit_Agreement__c> bas = new List<Benefit_Agreement__c>();
		bas.add(testBA3);
		bas.add(testBA2);
		bas.add(testBA1);
		bas.add(testBA4);
		insert bas;


		BatchCreateCurrentProducts batchCreateProducts = new BatchCreateCurrentProducts('SELECT Id, Name FROM Account WHERE Status__c = \'Active\'');

		ID batchprocessid = Database.executeBatch(batchCreateProducts);

		Test.StopTest();

		List<Current_Product__c> currProd  = [SELECT Name, Number_Of_BAs__c, Funding_Type__c FROM Current_Product__c Where Number_Of_BAs__c > 1];
		System.assertEquals(1, currProd.size());
		System.assertEquals('ASO', currProd[0].Funding_Type__c);
	}

}