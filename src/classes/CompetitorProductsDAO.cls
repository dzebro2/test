public class CompetitorProductsDAO implements ICompetitorProductsDAO {
	public interface ICompetitorProductsDAO {
		List<Competitor_Products__c> getBatchCompetitorProducts(Set<Id> accountIds);
	}

	public List<Competitor_Products__c> getBatchCompetitorProducts(Set<Id> accountIds) {
		return [select Id, Product__r.Product_Category__c, Product__r.Simplified_Product__c, Product__c, Product__r.Name, Business_Type__c, Renewal_Date__c, Members__c, Carrier__r.Status__c, Carrier__r.Group_Account__c, Carrier__r.Group_Account__r.Name, Carrier__r.Competitor_Account__c, Carrier__r.Competitor_Account__r.Name, Carrier__r.Opportunity__c, Product__r.Family from Competitor_Products__c where Carrier__r.Group_Account__c in :accountIds and Effective_Date__c < :System.today() and Status__c != 'Cancelled' and Status__c != null];
	}
}