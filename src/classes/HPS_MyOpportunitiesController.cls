/**************************************************************************************
  Apex Class Name     : HPS_MyOpportunitiesController
  Version             : 1.0
  Function            : This is a controller class for HPS_MyOpportunities Page for showing the information of current logged in user opportunities.
  Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
**/
public with sharing class HPS_MyOpportunitiesController 
{
    
    public List<MyOpportunitiesWrapper> myOpportunitiesList {get; set;}
    public Map<Id, Opportunity> mapOfOpportunityIdAndOpportunity;
    public Map<String, Integer> mapOfOpportunityIdAndProjectedMembers;
    public list<Opportunity> testOpps{get;set;}
    public map<String,Integer> testOppsCountProjectedMember{get;set;}
    
    public HPS_MyOpportunitiesController()
    {
        mapOfOpportunityIdAndOpportunity        = new Map<Id, Opportunity>();
        mapOfOpportunityIdAndProjectedMembers   = new Map<String, Integer>();
        
        populateMyOpportuities();
    }
    
    
    private void PopulateMyOpportuities()
    {
        MyOpportunitiesWrapper myOpportunitiesObj;
        try
        {
	        myOpportunitiesList             = new List<MyOpportunitiesWrapper>();
	        Set<Id> opportunityIds          = new Set<Id>();
	        list<Id> sortedOppIds           = new list<Id>();
	        testOppsCountProjectedMember    = new map<String,Integer>();
	        testOpps                        = new list<Opportunity>();
	        RecordType rt = [select Id from RecordType  where SobjectType = 'Opportunity' and DeveloperName = :ConstantsController.NewSaleOpportunityRecordTypeName];
	        for( OpportunityTeamMember opportunityTeamMemberObj :[  SELECT  OpportunityId 
	                                                                FROM    OpportunityTeamMember 
	                                                                WHERE   UserId =: UserInfo.getUserId() and Opportunity.IsClosed = false and Opportunity.RecordTypeId =:rt.Id
	                                                                limit   :Limits.getLimitQueryRows() - Limits.getQueryRows() ] )
	        { 
	            opportunityIds.add( opportunityTeamMemberObj.OpportunityId );
	        }
	        
	        for( Opportunity opportunityObj :[  SELECT  Id, Name, AccountId, Account.Name, CloseDate, StageName, Expected_Health_Members__c 
	                                            FROM    Opportunity 
	                                            WHERE   OwnerId = :UserInfo.getUserId() and IsClosed = false and RecordTypeId =:rt.Id
	                                            limit   :Limits.getLimitQueryRows() - Limits.getQueryRows() ] ) 
	        {
	            opportunityIds.add( opportunityObj.Id );
	        }
	        
	        for( Opportunity opportunityObj :[  SELECT  Id, Name, AccountId, Account.Name, CloseDate, StageName, Expected_Health_Members__c  
	                                            FROM    Opportunity 
	                                            WHERE   Id IN: opportunityIds and IsClosed = false and RecordTypeId =:rt.Id
	                                            order by CloseDate ASC 
	                                            limit   :Limits.getLimitQueryRows() - Limits.getQueryRows() ] ) 
	        {
	            
	            if( !mapOfOpportunityIdAndOpportunity.containsKey( opportunityObj.Id ) ) 
	            {
	                mapOfOpportunityIdAndOpportunity.put( opportunityObj.Id, opportunityObj );
	                sortedOppIds.add( opportunityObj.Id );
	                
	                testOpps.add( opportunityObj );
	            }
	        }
	        
	        for( AggregateResult aggregateResultObj : [ SELECT  SUM(Projected_Members__c) noOfProjectedMembers, Opportunity_Name__c opportunityName 
	                                                    FROM    Opportunity_Product__c 
	                                                    WHERE   Product__c != null 
	                                                    GROUP BY Opportunity_Name__c 
	                                                    limit   :Limits.getLimitQueryRows() - Limits.getQueryRows() ] ) 
	        {
	            
	            if( !mapOfOpportunityIdAndProjectedMembers.containsKey( String.valueOf( aggregateResultObj.get( 'opportunityName' ) ) ) ) 
	            {
	                mapOfOpportunityIdAndProjectedMembers.put( String.valueOf( aggregateResultObj.get( 'opportunityName' ) ), Integer.valueOf( aggregateResultObj.get( 'noOfProjectedMembers' ) ) );
	            }
	        }
	     
	        
	        for( Opportunity opp : testOpps ) 
	        {
	            
	            myOpportunitiesObj = new MyOpportunitiesWrapper();
	            if( mapOfOpportunityIdAndOpportunity.containsKey( opp.Id ) ) 
	            {
	                myOpportunitiesObj.opportunityObj = mapOfOpportunityIdAndOpportunity.get( opp.Id );
	            }
	            
	            if( mapOfOpportunityIdAndProjectedMembers.containsKey( opp.Id ) ) 
	            {
	                myOpportunitiesObj.projectedMembers = mapOfOpportunityIdAndProjectedMembers.get( opp.Id );
	                testOppsCountProjectedMember.put( opp.Id, myOpportunitiesObj.projectedMembers );
	            } 
	            else 
	            {
	                testOppsCountProjectedMember.put( opp.Id, 0 );
	            }
	            if(myOpportunitiesList.size()<10000)
	            	myOpportunitiesList.add( myOpportunitiesObj );
	        }
	      }catch(Exception e){
	       System.debug( 'Exception : ' +e.getMessage() );
	       ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage());
           ApexPages.addMessage(myMsg);
	      }
    }
    
    public class MyOpportunitiesWrapper {
        public Opportunity opportunityObj {get; set;}
        public Integer projectedMembers {get; set;}
    }
}