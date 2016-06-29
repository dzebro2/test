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
public with sharing class HPS_MyActivitiesController {

    public List<Task> myTaskList {get;set;}
    public List<Event> myEventList {get; set;}
   
    /******************************************************************** 
    * Method Name    : HPS_MyActivitiesController
    *   @description :   controller of class.
    *   @parameters  :   none
    *   @return type :   none                     
    ***************************************************************/  
    public HPS_MyActivitiesController() {
        try{
            populateMyActivities();
        }catch(Exception e){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage());
            ApexPages.addMessage(myMsg);
        }
    }
  
   
      /******************************************************************** 
    * Method Name    : PopulateMyActivities
    *   @description :   Method to populate active Activities on home page slider.
    *   @parameters  :   none
    *   @return type :   none                     
    ***************************************************************/  
    private void PopulateMyActivities() {
        try{
            myTaskList = new List<Task>();
            myEventList = new List<Event>();
           
           // Query All open tasks of logged in user
            for(Task taskObj : [SELECT Id, Subject, WhatId, ActivityDate, Status, Priority FROM Task WHERE OwnerId =:UserInfo.getUserId() and Status != :ConstantsController.TaskStageToExclude limit 1000]){
                myTaskList.add(taskObj);
            }
           // Query All open Eventsof logged in user
            for(Event eventObj : [SELECT Id, Subject, WhatId, ActivityDate FROM Event WHERE OwnerId =:UserInfo.getUserId() and ActivityDate >= :date.Today() limit 1000]){
                myEventList.add(eventObj);
            }
        }catch(Exception e){
            System.debug( 'Exception : ' +e.getMessage() );
            throw e;
        }
    }
}