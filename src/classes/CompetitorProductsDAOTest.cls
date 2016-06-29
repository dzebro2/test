@isTest(SeeAllData = false)
private class CompetitorProductsDAOTest {

	@isTest
	static void competitorProductsDAOTest() {

		CompetitorProductsDAO.ICompetitorProductsDAO competitorProductsDAOInstance = new CompetitorProductsDAO();
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

		Set<Id> compAccs = new Set<Id>();
		compAccs.add(testAccount.Id);
		List<Competitor_Products__c> compProds = competitorProductsDAOInstance.getBatchCompetitorProducts(compAccs);
		System.assertEquals(compProds.size(), 1);
	}
}