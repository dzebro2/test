public class OpportunityTriggerHandler {

    public static void insertOpportunityProducts(List<Opportunity> listOfOpportunities){
    
        try{
            Map<Id,Set<Id>> accountIdAndOpportunityMap = new Map<Id,Set<Id>>();
            Map<Id, List<Opportunity_Product__c>> opportunityIdAndOpportunityProductsMap = new Map<Id, List<Opportunity_Product__c>>();
            
            Map<Id, List<Opportunity_Product__c>> accountIdAndOpportunityProductMap = new Map<Id, List<Opportunity_Product__c>>();
            List<Opportunity_Product__c>insertListOfOpportunityProducts = new List<Opportunity_Product__c>();
            
            Schema.DescribeSObjectResult objectSchema = Opportunity.SobjectType.getDescribe(); 
            Map<String,Schema.RecordTypeInfo> opportunityRecordTypeInfo = objectSchema.getRecordTypeInfosByName();
     
            Id renewalRecordTypeId = opportunityRecordTypeInfo.get('Renewal').getRecordTypeId();
            
            for(Opportunity oppObj : listOfOpportunities){
                if(oppObj.RecordTypeId == renewalRecordTypeId){
                    if(!accountIdAndOpportunityMap.containsKey(oppObj.AccountId)){
                        Set<Id> opportunityIds = new Set<Id>();
                        opportunityIds.add(oppObj.id);
                        accountIdAndOpportunityMap.put(oppObj.AccountId, opportunityIds);
                    }
                    else{
                        accountIdAndOpportunityMap.get(oppObj.AccountId).add(oppObj.Id);
                    }
                }       
            }
            
            if(!accountIdAndOpportunityMap.isEmpty()){
                for(Opportunity_Product__c oppProductIteratorObj : [SELECT Id, Opportunity_Name__c, Product__c, Excluded__c, Opportunity_Name__r.AccountId, Opportunity_Name__r.StageName, Opportunity_Name__r.Rate_End_Date__c FROM Opportunity_Product__c WHERE Opportunity_Name__r.AccountId IN:accountIdAndOpportunityMap.keySet() AND Opportunity_Name__r.StageName = 'Closed Won' AND Opportunity_Name__r.Rate_End_Date__c >=: System.today() AND Excluded__c = false]){
                    if(!accountIdAndOpportunityProductMap.containsKey(oppProductIteratorObj.Opportunity_Name__r.AccountId)){
                    
                        List<Opportunity_Product__c> tempOpportunityProductList = new List<Opportunity_Product__c>();
                        tempOpportunityProductList.add(oppProductIteratorObj);
                        accountIdAndOpportunityProductMap.put(oppProductIteratorObj.Opportunity_Name__r.AccountId, tempOpportunityProductList);
                    }
                    else{
                        accountIdAndOpportunityProductMap.get(oppProductIteratorObj.Opportunity_Name__r.AccountId).add(oppProductIteratorObj);
                    }
                }
            }
            if(!accountIdAndOpportunityMap.isEmpty() && !accountIdAndOpportunityProductMap.isEmpty()){
                Opportunity_Product__c oppProductObj;
                for(Id accountId : accountIdAndOpportunityMap.keySet()){
                    for(Id opportunityId : accountIdAndOpportunityMap.get(accountId)){
                        for(Opportunity_Product__c oppProductIteratorObj : accountIdAndOpportunityProductMap.get(accountId)){
                            oppProductObj = new Opportunity_Product__c();
                            oppProductObj.Opportunity_Name__c = opportunityId;
                            oppProductObj.Product__c = oppProductIteratorObj.Product__c;
                            oppProductObj.Excluded__c = oppProductIteratorObj.Excluded__c;
                            insertListOfOpportunityProducts.add(oppProductObj);
                        }
                    }
                }
            }
            if(!insertListOfOpportunityProducts.isEmpty()){
                insert insertListOfOpportunityProducts;
            }
        }
        catch(Exception e){
           CreateExceptionLog.insertErrorLog(e, null, null, null, 'Apex Class', 'Opportunity', null, 'OpportunityTriggerHandler','High'); 
            System.debug('Exception Error Message--'+e.getMessage());
        }   
    }
}