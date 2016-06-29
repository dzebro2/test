/**************************************************************************************
  Apex Class Name     : BatchSendOpportunityDueDateNotification
  Version             : 1.0
  Function            : 
  Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------               
* Deloitte           10/14/2015                Original Version
*************************************************************************************/
global  class BatchSendOpportunityDueDateNotification implements Database.Batchable<sObject>{
    Integer numberOfDueDays;
    Date taskActivityDate ; 
    String query;
    
    /*************************************************
     * Method name  : start
     * Description  : Start method queries all the records matching criteria and returns a Database.QueryLocator for it.
     * Return Type  : Database.QueryLocator
    *************************************************/
    global Database.QueryLocator start( Database.BatchableContext BC ){
                    
        
        
        query = 'select Id,Name,CloseDate, OwnerId ,Due_Date_Notification_in_Days__c,Opportunity_Due_Date_Notification_Date__c'
                        + ' from Opportunity  '
                        + ' where Opportunity_Due_Date_Notification_Date__c = TODAY and ISCLOSED = false and CloseDate != null and Due_Date_Notification_in_Days__c!= null';     
        
        return Database.getQueryLocator( query );
    }
    /*************************************************
     * Method name  : execute
     * Description  :  
     * Return Type  : void
    *************************************************/
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        list<FeedItem> feedItems  = new list<FeedItem>();
        
        for(Opportunity opp : (List<Opportunity>)scope){
            String chatterMessage = Label.Opportunity_Due_Date_Chatter.replace('[Opportunity Name]',opp.Name).replace('[Due Date Notification (in days)]',string.valueOf(integer.valueOf(opp.Due_Date_Notification_in_Days__c))).replace('[Due Date]',string.valueOf(opp.CloseDate));
            String chatterTitle   = Opp.Name;
            String OppLink        = URL.getSalesforceBaseUrl().toExternalForm()+ '/' + opp.Id;
            set<String> userIds   = new set<String>();
            userIds.add(opp.OwnerId);
            feedItems.addAll(ConstantsController.sendChattertoTeams(userIds,chatterMessage,OppLink,chatterTitle));
        }
        try {    
                if(feedItems.size()>0)
                    insert feedItems;
            } catch( Exception e ) {
                System.debug( 'Exception in Account Renewal Batch: ' + e.getMessage() );
            }
        
    }
    /*************************************************
     * Method name  : finish
     * Description  : No finish method behaviour is identified yet. 
     * Return Type  : void
    *************************************************/  
    global void finish(Database.BatchableContext BC){
    
    }
}