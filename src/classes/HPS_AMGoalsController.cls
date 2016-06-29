/**************************************************************************************
  Apex Class Name     : HPS_AMGoalsController
  Version             : 1.0
  Function            : This is a controller class for HPS_AMGoals Page for showing the information of renwal opportunity win rate.
  Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------    
  Dinesh           :       March                    Original Version
*************************************************************************************/
public with sharing class HPS_AMGoalsController 
{
    public Decimal renewalWinRate 
    {
        get; 
        set;
    }
    public Integer renewalWonOpportunities;
    public Integer renewalTotalOpportunities;
    public String colChartData 
    {
        get;
        set;
    }
    public Report openCasesByPriorityReportObj 
    {
        get; 
        set;
    }
    
     /******************************************************************** 
    * Method Name    : HPS_AMGoalsController
    *   @description :   controller of class.
    *   @parameters  :   none
    *   @return type :   none                     
    ***************************************************************/  
    public HPS_AMGoalsController() 
    {
        colChartData = '';
        calculateAMGoals();
    }
    //
 
  
  /******************************************************************** 
    * Method Name    : CalculateAMGoals
    *   @description :   Method to perform all the calculations and SOQL for getting the data to show on the page.
    *   @parameters  :   none
    *   @return type :   none                     
    ***************************************************************/  
 
 
    private void CalculateAMGoals() 
    {
        try
        {
            if(!Test.isRunningTest())
            {
               // Query Report Case By Priority Report 
                list<Report> reports = [SELECT Id FROM Report WHERE DeveloperName = :ConstantsController.hpsAMGoalsReportNameCaseByPriority];
                if(reports.size()>0)
                    openCasesByPriorityReportObj = reports[0];
                else
                    openCasesByPriorityReportObj = new Report();
            
            }
            Id renewalRecordTypeId,lgnaCaseRecordTypeId;
            
            //Query Renewal Record type id of opportunity.
            for(RecordType rt : [select Id from RecordType where SobjectType = 'Opportunity' and DeveloperName =: ConstantsController.RenewalOppRecordTypeName])
            {
                renewalRecordTypeId = rt.Id;
            }
            
             //Query LGNA General Case Record type id of case.
            for(RecordType rt : [select Id from RecordType where SobjectType = 'Case' and DeveloperName = :ConstantsController.LGNAGeneralCaseRecordTypeName])
            {
                lgnaCaseRecordTypeId = rt.Id;
            }
            
            //Query count of number won renewal opportunity 
            for(AggregateResult aggregateResultObj : [SELECT Count(Id) renewalWonOpportunities FROM Opportunity WHERE IsWon = true AND RecordTypeId =: renewalRecordTypeId ])
            {
                renewalWonOpportunities = Integer.valueOf(aggregateResultObj.get('renewalWonOpportunities'));
            }
           
             //Query count of total renewal opportunity 
            for(AggregateResult aggregateResultObj : [SELECT Count(Id) renewalTotalOpportunities FROM Opportunity WHERE RecordTypeId =: renewalRecordTypeId ])
            {
                renewalTotalOpportunities = Integer.valueOf(aggregateResultObj.get('renewalTotalOpportunities'));
            }
            
            //calculate renewal win rate
            if(renewalTotalOpportunities != 0){
                renewalWinRate = renewalWonOpportunities/renewalTotalOpportunities;
            }
            Map<String, Integer> caseCountByPriority = new Map<String, Integer>();
            colChartData='';
            Schema.DescribeFieldResult fieldResult  = Case.Priority.getDescribe();
            List<Schema.PicklistEntry> ple          = fieldResult.getPicklistValues();
                
            for( Schema.PicklistEntry f : ple)
            {
                caseCountByPriority.put(f.getLabel(), 0);
            }       
            // query open LGNA  genarl cases by priority group.
            AggregateResult[] groupedResults = [select Priority, count(Id) from Case Where IsClosed = false AND RecordTypeId =:lgnaCaseRecordTypeId GROUP BY Priority limit   :Limits.getLimitQueryRows() - Limits.getQueryRows()];
            for (AggregateResult ar : groupedResults)  
            {
                caseCountByPriority.put( String.valueOf( ar.get( 'Priority' ) ), Integer.valueOf(ar.get( 'expr0' )));
            } 
            map<Integer, String> orderAndPriority = new Map<Integer, String>();
            orderAndPriority.put(1,'Low');
            orderAndPriority.put(2,'Medium');
            orderAndPriority.put(3,'High');
            orderAndPriority.put(4,'Critical');
           // define Colour chart with color for each catagory to display on UI 
            for(String casePriority :orderAndPriority.values()) 
            {
                if(casePriority != ''){
                if(casePriority == 'Low')
                    colChartData += '["'+ casePriority +'",'+ caseCountByPriority.get(casePriority) +',\'color:blue\'],';
                if(casePriority == 'Medium')
                    colChartData += '["'+ casePriority +'",'+ caseCountByPriority.get(casePriority) +',\'color:gold\'],';
                if(casePriority == 'High')
                    colChartData += '["'+ casePriority +'",'+ caseCountByPriority.get(casePriority) +',\'color:#FF4040\'],';
                if(casePriority == 'Critical')
                    colChartData += '["'+ casePriority +'",'+ caseCountByPriority.get(casePriority) +',\'color:#8B0000\'],';
                }
            }
            colChartData = colChartData.removeEnd(',');
         }
         catch(Exception e)
         {
             System.debug( 'Exception : ' +e.getMessage() );
             ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage())); 
         }
    }
}