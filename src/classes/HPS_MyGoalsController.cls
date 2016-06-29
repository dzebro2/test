/**************************************************************************************
  Apex Class Name     : HPS_MyGoalsController
  Version             : 1.0
  Function            : This is a controller class for HPS_MyGoals Page for showing the information of current logged in user goals.
  Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------    
  Dinesh           :       March                    Original Version
  mayuri                   June                     Updated Code comments
*************************************************************************************/
public with sharing class HPS_MyGoalsController {
    public Decimal opportunityCloseRatio {get; set;} // stores opp close ratio 
    public Integer openOpportunities {get; set;} // stores all open opp
    public Integer potentialMembers {get; set;} // stores potential member of open opp
    public Integer wonOpportunities; // no of won opp
    public Integer totalOpportunities; // no of total opp
    public String colChartData {get; set;}
    public List<Report> salesPipelineReportObj {get; set;} // stores my goal report record
    
     /******************************************************************** 
    * Method Name    : HPS_MyGoalsController
    *   @description :   controller of class.
    *   @parameters  :   none
    *   @return type :   none                     
    ***************************************************************/  
    public HPS_MyGoalsController() {
        colChartData = '';
       // Method call to calculate goals
        calculateMyGoals();
    }
    
   /******************************************************************** 
    * Method Name    : CalculateMyGoals
    *   @description :   Method to populate calculated goals on home page slider.
    *   @parameters  :   none
    *   @return type :   none                     
    ***************************************************************/  
    private void CalculateMyGoals() 
    {
      try
      {
        // Query My goals report 
        if(!Test.isRunningTest())
        {
           salesPipelineReportObj  = [SELECT Id FROM Report WHERE DeveloperName = :ConstantsController.MyGoalsReportName LIMIT 1];
        }
        // query count of won opportunities
        for(AggregateResult aggregateResultObj : [SELECT Count(Id) noOfWonOpportunities FROM Opportunity WHERE IsWon = true ])
        {
            wonOpportunities = Integer.valueOf(aggregateResultObj.get('noOfWonOpportunities'));
        }
        // Query count of total opportunties
        for(AggregateResult aggregateResultObj : [SELECT Count(Id) noOfTotalOpportunities FROM Opportunity where Id != null])
        {
            totalOpportunities = Integer.valueOf(aggregateResultObj.get('noOfTotalOpportunities'));
        }
        // query count of opportunties and sum of Expected health member for open oppoertunities
        for(AggregateResult aggregateResultObj : [SELECT Count(Id) noOfOpenOpportunities, SUM(Expected_Health_Members__c) potentialMembers FROM Opportunity WHERE IsWon = false AND IsClosed = false ])
        {
            openOpportunities = Integer.valueOf(aggregateResultObj.get('noOfOpenOpportunities'));
            potentialMembers = Integer.valueOf(aggregateResultObj.get('potentialMembers'));
        }
       //Caclate opportunity close ratio
        if(potentialMembers == null)
            potentialMembers = 0;
        opportunityCloseRatio = wonOpportunities/totalOpportunities;
        
        Map<String, Integer> opportunityCountByStageName = new Map<String, Integer>();
        
        // query count of all open opportunity by priority (stage)
        List<AggregateResult> opportunitiesByPrioriry = [SELECT StageName, Count(Id) noOfOpportunities FROM Opportunity WHERE IsClosed = false AND IsWon = false GROUP BY StageName limit   :Limits.getLimitQueryRows() - Limits.getQueryRows()];
        // create map of priority and count of open opp
        for (AggregateResult aggregateResultObj : opportunitiesByPrioriry)  
        {
            opportunityCountByStageName.put(String.valueOf(aggregateResultObj.get('StageName')), Integer.valueOf(aggregateResultObj.get('noOfOpportunities')));
        }
        
        //create a color chart to populate priority and no of opp with diferent color
        for(String stageName :opportunityCountByStageName.keySet())
         {
            colChartData += '["'+ stageName +'",'+ opportunityCountByStageName.get(stageName) +'],';
        
        }
        colChartData = colChartData.removeEnd(',');
     }catch(Exception e){
         System.debug( 'Exception : ' +e.getMessage() );
         ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage());
            ApexPages.addMessage(myMsg);
     }
    }
}