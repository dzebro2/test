public with sharing class HPS_MyRenewalsController {
    
    public List<MyRenewalsWrapper> myRenewalsList {get; set;}
    public Map<Id, Opportunity> mapOfOpportunityIdAndOpportunity = new Map<Id, Opportunity>();
    public Map<String, Integer> mapOfOpportunityIdAndProjectedMembers = new Map<String, Integer>();
    
    public HPS_MyRenewalsController(){
        try{
            populateMyRenewals();
        }catch(Exception e){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage());
            ApexPages.addMessage(myMsg);
        }
    }
    private void populateMyRenewals(){
        try{
            MyRenewalsWrapper myRenewalsObj;
            myRenewalsList = new List<MyRenewalsWrapper>();
            Set<Id> opportunityIds = new Set<Id>();
            
            Id renewalRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal').getRecordTypeId();
            
            for(OpportunityTeamMember opportunityTeamMemberObj : [  SELECT  OpportunityId 
                                                                    FROM    OpportunityTeamMember 
                                                                    WHERE   Opportunity.RecordTypeId =: renewalRecordTypeId 
                                                                        AND UserId =: UserInfo.getUserId() and Opportunity.IsClosed = false
                                                                    limit   :Limits.getLimitQueryRows() - Limits.getQueryRows()]){
                opportunityIds.add(opportunityTeamMemberObj.OpportunityId);
            }
            
            for(Opportunity opportunityObj : [  SELECT  Id, Name, AccountId, Account.Name, CloseDate, StageName, Account.Current_Risk_Level__c,  Expected_Health_Members__c  
                                                FROM    Opportunity 
                                                WHERE   RecordTypeId =: renewalRecordTypeId 
                                                    AND OwnerId =: UserInfo.getUserId() and IsClosed = false
                                                limit   :Limits.getLimitQueryRows() - Limits.getQueryRows() ]){
                opportunityIds.add(opportunityObj.Id);
            }
            for(Opportunity opportunityObj : [  SELECT  Id, Name, AccountId, Account.Name, CloseDate, StageName, Account.Current_Risk_Level__c,  Expected_Health_Members__c  
                                                FROM    Opportunity 
                                                WHERE   Id IN: opportunityIds and IsClosed = false
                                                limit   :Limits.getLimitQueryRows() - Limits.getQueryRows()]){
                if(!mapOfOpportunityIdAndOpportunity.containsKey(opportunityObj.Id)){
                    mapOfOpportunityIdAndOpportunity.put(opportunityObj.Id, opportunityObj);
                }
            }
            for(AggregateResult aggregateResultObj : [  SELECT  SUM(Projected_Members__c) noOfProjectedMembers, Opportunity_Name__c opportunityName 
                                                        FROM    Opportunity_Product__c 
                                                        WHERE   Product__c != null 
                                                        GROUP BY Opportunity_Name__c
                                                        limit   :Limits.getLimitQueryRows() - Limits.getQueryRows()]){
                if(!mapOfOpportunityIdAndProjectedMembers.containsKey(String.valueOf(aggregateResultObj.get('opportunityName')))){
                    mapOfOpportunityIdAndProjectedMembers.put(String.valueOf(aggregateResultObj.get('opportunityName')), Integer.valueOf(aggregateResultObj.get('noOfProjectedMembers')));
                }
            }
            for(Id opportunityId : opportunityIds){
                myRenewalsObj = new MyRenewalsWrapper();
                if(mapOfOpportunityIdAndOpportunity.containsKey(opportunityId)){
                    myRenewalsObj.opportunityObj = mapOfOpportunityIdAndOpportunity.get(opportunityId);
                }
                if(mapOfOpportunityIdAndProjectedMembers.containsKey(opportunityId)){
                    myRenewalsObj.projectedMembers = mapOfOpportunityIdAndProjectedMembers.get(opportunityId);
                }
                if(myRenewalsList.size()<10000)
                	myRenewalsList.add(myRenewalsObj);
            }
        }catch(Exception e){
           System.debug( 'Exception : ' +e.getMessage() );
            throw e;
        }
    }
    public class MyRenewalsWrapper {
        public Opportunity opportunityObj {get; set;}
        public Integer projectedMembers {get; set;}
        
        public MyRenewalsWrapper() {
        
        }
    }
}