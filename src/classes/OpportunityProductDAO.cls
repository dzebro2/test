public with sharing class OpportunityProductDAO implements IOpportunityProductDAO {
  public interface IOpportunityProductDAO {
    List<Opportunity_Product__c> getLostProducts(List<String> lostProductIds);
    List<Opportunity_Product__c> getSelectedProducts(List<String> selectedProductIds);
    void updateOpportunityProducts(List<Opportunity_Product__c> opProducts);
    Opportunity_Product__c getOpportunityProductById(Id opportunityProductId);
    void deleteOpportunityProduct(Opportunity_Product__c opportunityProduct);
    void upsertOpportunityProducts(List<Opportunity_Product__c> opportunityProducts);
    List<Opportunity_Product__c> getExistingOpProducts(List<Schema.FieldSetMember> fields);
    List<Opportunity_Product__c> getLostProductsForAddOpProds(List<Opportunity_Product__c> lostProductIds);

  }

  public List<Opportunity_Product__c> getLostProducts(List<String> lostProductIds) {
    return [SELECT Id, Name, Product__r.Non_Medical_Compensation__c, Product__r.Name, Product_Type__c, Funding_Type__c,
            Premium_Type__c, Projected_Contracts__c, Projected_Members__c, Win_Probability__c, Status__c,
            Product_Stage__c FROM Opportunity_Product__c WHERE Id IN :lostProductIds AND Product__r.Non_Medical_Compensation__c = True];
  }

  public List<Opportunity_Product__c> getLostProductsForAddOpProds(List<Opportunity_Product__c> lostProductIds) {
    return [SELECT Id, Name, Status__c, Product__r.Non_Medical_Compensation__c FROM Opportunity_Product__c WHERE Id IN :lostProductIds AND Product__r.Non_Medical_Compensation__c = True and Status__c = 'Lost' and (Product_Type__c = 'New Sale' or Product_Type__c = 'Upsell')];
  }

  public List<Opportunity_Product__c> getSelectedProducts(List<String> selectedProductIds) {
    return [SELECT Id, Opportunity_Name__c, Projected_Members__c, Projected_Contracts__c,
            Category__c, Status__c, Product_Type__c FROM Opportunity_Product__c WHERE Id IN :selectedProductIds];
  }

  public void updateOpportunityProducts(List<Opportunity_Product__c> opProducts) {
    update opProducts;
  }

  public Opportunity_Product__c getOpportunityProductById(Id opportunityProductId) {
    return [Select Id from Opportunity_Product__c where Id = :opportunityProductId limit 1];
  }

  public void deleteOpportunityProduct(Opportunity_Product__c opportunityProduct) {
    delete opportunityProduct;
  }

  public void upsertOpportunityProducts(List<Opportunity_Product__c> opportunityProducts) {
    upsert opportunityProducts;
  }

  public List<Opportunity_Product__c> getExistingOpProducts(List<Schema.FieldSetMember> fields) {
    String query = 'SELECT ';
    for (Schema.FieldSetMember f : fields) {
      query += f.getFieldPath() + ', ';
    }
    query += 'Id, Opportunity_Name__c, Product__r.Simplified_Product__c, Category__c, Name, Benefit_Agreement__c FROM Opportunity_Product__c WHERE Opportunity_Name__c =:opportunityId';
    return Database.query(query);
  }
}