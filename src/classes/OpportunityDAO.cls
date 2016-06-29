public with sharing class OpportunityDAO implements IOpportunityDAO {
	public interface IOpportunityDAO {
		List<Opportunity> getOpportunitiesForProduct360(Set<Id> accountIds);
		void updateOpportunities(List<Opportunity> opportunities);
		Opportunity getOpportunityById(Id opportunityId);
		void updateOpportunity(Opportunity opportunityObj);
	}

	public void updateOpportunity(Opportunity opportunityObj) {
		update opportunityObj;
	}

	public List<Opportunity> getOpportunitiesForProduct360(Set<Id> oppIds) {

		return [Select Id, Name, Expected_Health_Members__c, Expected_Health_Contracts__c, Expected_Dental_Members__c, Expected_Dental_Contracts__c, (Select Id, Product__r.Non_Medical_Compensation__c, Name, Product_Stage__c, Category__c, Projected_Members__c, Projected_Contracts__c, Product__r.Name, Status__c, Product_Type__c, Win_Probability__c, Funding_Type__c, Premium_Type__c from Opportunity_Products__r) From Opportunity Where Id in :oppIds];
	}

	public void updateOpportunities(List<Opportunity> opportunities) {
		update opportunities;
	}

	public Opportunity getOpportunityById(Id opportunityId) {
		return [SELECT Id, Name, CloseDate, AccountId, StageName, RecordTypeId, Probability, HCSC_Division__c, Expected_Health_Members__c, Expected_Health_Contracts__c, Expected_Dental_Members__c, Expected_Dental_Contracts__c
		        FROM Opportunity WHERE Id = :opportunityId LIMIT 1];
	}
}