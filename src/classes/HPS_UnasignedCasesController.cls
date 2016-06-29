/**************************************************************************************
  Apex Class Name     : HPS_MyActivitiesController
  Version             : 1.0
  Function            : This is a controller class for HPS_MyActivities Page for showing the information of current logged in user tasks and events.
  Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------    
  Dinesh           :       March                    Original Version
  mayuri                   June                     Updated Code comments
*************************************************************************************/
public with sharing class HPS_UnasignedCasesController {
    //list stores case records
    public List<Case> UnassignedCasesList {get; set;}
    Set<string>  statusClosed ;
    /*************************************************
     * Method name  : HPS_UnasignedCasesController
     * Description  : Constructor of the Controller class HPS_UnasignedCasesController
     * Return Type  : Void
     * Parameter    : StandardController
     *************************************************/
    public HPS_UnasignedCasesController(){
       statusClosed = new Set<String>{ 'Closed - No Response','Closed'};
       populateUnassignedCases();
    }
  
  
  /*************************************************************
     * Method name  : populateUnassignedCases
     * Description  : Method to Collect Unassigned cases in list to populate on Page.
     * Return Type  : void
     * Parameter    : None
  ************************************************************ */
  
   private void populateUnassignedCases(){
        
        UnassignedCasesList = new List<Case>();
        Set<Id> QueueIds    = new Set<Id>();        
        
       // Id lgnaCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('LGNA - General Case').getRecordTypeId();       
       try{
            //logic to add queue Ids in set. Added for loop in case if we need Multiple queue Ids in future. 
            /*for( Group queue :[   select  Id 
                                from    Group 
                                where   Name = 'Proposal Delivery Unit' 
                                    and Type = 'Queue' 
                                limit   :Limits.getLimitQueryRows() - Limits.getQueryRows() ] ) {
                QueueIds.add( queue.Id );
            }*/
            for(GroupMember gm : [Select UserOrGroupId, Group.Type, GroupId From GroupMember where UserOrGroupId = :UserInfo.getUserId() and Group.Type = 'Queue']){
                QueueIds.add( gm.GroupId );
            }
        
            // for loop collects cases whos Owner is "Proposal Delivery Unit" queue
            if( QueueIds.size() > 0 ) { 
                for( Case caseObj :[    SELECT  Id, AccountId, Subject, Status, Type, Account.Name, CreatedDate, Days_Open__c,CaseNumber,Opportunity_Name__c,
                                                RecordTypeid,Mail_Date_Due_Date__c 
                                        FROM    Case 
                                        WHERE   OwnerId IN :QueueIds 
                                            AND Status NOT IN :statusClosed 
                                        limit :Limits.getLimitQueryRows() - Limits.getQueryRows() ] ) {
                    if(UnassignedCasesList.size()<10000)
                    	UnassignedCasesList.add(caseObj);
                }
            }  
       }catch(Exception e){
        System.debug( 'Exception : ' +e.getMessage() );
       } 
   }
   
}