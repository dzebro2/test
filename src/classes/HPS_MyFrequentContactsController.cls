/**************************************************************************************
  Apex Class Name     : HPS_MyFrequentContactsController
  Version             : 1.0
  Function            : This is a controller class for HPS_MyFrequentContacts Page for showing the information of current logged in user frequest contacts.
Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------    
  Dinesh           :       March                    Original Version
  mayuri                   June                     Updated Code comments
*************************************************************************************/
public without sharing class HPS_MyFrequentContactsController {
    public List<MyFrequentContactsWrapper> myFrequentContactsList {get; set;}  // Wrapper list stores contact and no of interactions and Activity History
    public Map<Id, Contact> mapOfContactIdAndContact = new Map<Id, Contact>();
    public Map<String, Integer> mapOfContactIdAndTaskCount = new Map<String, Integer>(); // Map of Contacts and no of interactions
    public Map<String, Integer> mapOfContactIdAndEventCount = new Map<String, Integer>(); // not in use
    public Map<Id, ActivityHistory> mapOfContactIdAndLastInteraction = new Map<Id, ActivityHistory>();  // Map of contact and latest interaction
   
    /*************************************************
     * Method name  : HPS_MyFrequentContactsController
     * Description  : Constructor of the Controller class HPS_MyFrequentContactsController
     * Return Type  : Void
     * Parameter    : StandardController
   *************************************************/ 
    public HPS_MyFrequentContactsController(){
        try{            
         
            populateMyFrequentContacts();
        }catch(Exception e){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage());
            ApexPages.addMessage(myMsg);
        }
    }
   
  /*************************************************************
     * Method name  : PopulateMyFrequentContacts
     * Description  : Method to Collect frequesnt contacts of logged in user.
     * Return Type  : void
     * Parameter    : None
  ************************************************************ */ 
    private void PopulateMyFrequentContacts(){
        try{
            MyFrequentContactsWrapper myFrequentContactsObj;
            myFrequentContactsList = new List<MyFrequentContactsWrapper>();
            Set<Id> contactIds = new Set<Id>();
            Set<Id> eventIds = new Set<Id>();
            Set<Id> contactRelatedEventIds = new Set<Id>();
            Schema.DescribeSObjectResult contactDescribeResult = Contact.sObjectType.getDescribe();
            String contactPrefix = contactDescribeResult.getKeyPrefix();
            
            // Queryy All tasks of logged in user and collect contact ids of those tasks
            for(Task taskObj : [    SELECT  Id, WhoId 
                                    FROM    Task 
                                    WHERE   OwnerId =:UserInfo.getUserId() 
                                        and WhoId != null
                                    limit   :Limits.getLimitQueryRows() - Limits.getQueryRows()])
            {
               // if Who id has prefix '003' then collect id in set
                if(String.valueOf(taskObj.WhoId).subString(0,3) == contactPrefix){ 
                    contactIds.add(taskObj.WhoId);
                }
            }
            // Query all event of Logged in user and collect contact ids from thos events
            for(Event eventObj : [  SELECT  Id, WhoId ,
                                    (   select  Id,RelationId,EventId 
                                        from    EventRelations
                                        where   RelationId != null
                                        limit   :Limits.getLimitQueryRows() - Limits.getQueryRows()) 
                                    FROM    Event 
                                    WHERE   OwnerId =:UserInfo.getUserId() 
                                    limit   :Limits.getLimitQueryRows() - Limits.getQueryRows()])
            {
                if(eventObj.WhoId !=null)
                {
                      // if Who id has prefix '003' then collect id in set
                    if(String.valueOf(eventObj.WhoId).subString(0,3) == contactPrefix)
                    {
                        contactIds.add(eventObj.WhoId);
                    }
                }
                // collect contcts from Event Relation child object
                for(EventRelation eventRelationObj : eventObj.EventRelations)
                {                    
                    if(String.valueOf(eventRelationObj.RelationId).subString(0,3) == contactPrefix)
                    {
                        contactIds.add(eventRelationObj.RelationId);
                        contactRelatedEventIds.add(eventRelationObj.EventId);
                    }                
                }
                eventIds.add(eventObj.Id);
            }
            /*for(EventRelation eventRelationObj : [  SELECT  Id, RelationId, EventId 
                                                    FROM    EventRelation 
                                                    WHERE   EventId IN: eventIds 
                                                    limit   :Limits.getLimitQueryRows() - Limits.getQueryRows()]){
                if(eventRelationObj.RelationId !=null){
                    if(String.valueOf(eventRelationObj.RelationId).subString(0,3) == contactPrefix){
                        contactIds.add(eventRelationObj.RelationId);
                        contactRelatedEventIds.add(eventRelationObj.EventId);
                    }
                }
            }*/
            
            // Query all contact details and contact history of collected contact Ids and create Map of Contact id and Contact
            for(Contact contactObj : [  SELECT  Id, AccountId, Name, Email, Phone,
                                            (   SELECT  Id, Subject 
                                                        FROM    ActivityHistories 
                                                        ORDER BY ActivityDate DESC NULLS LAST, LastModifiedDate DESC
                                                        LIMIT   1) 
                                        FROM    Contact 
                                        WHERE   Id IN: contactIds 
                                        limit   :Limits.getLimitQueryRows() - Limits.getQueryRows()])
            {
                if(!mapOfContactIdAndContact.containsKey(contactObj.Id))
                {
                    mapOfContactIdAndContact.put(contactObj.Id, contactObj);
                }
              // Create map of contact id and latest activity history reocrd   
                if(!contactObj.ActivityHistories.isEmpty())
                {
                    mapOfContactIdAndLastInteraction.put(contactObj.Id, contactObj.ActivityHistories[0]);
                }
            }
           // Query count of task for each contact of logged in user 
            List<AggregateResult> taskAggregateList = [ SELECT  Count(Id) noOfTaskInteractions, WhoId contactRelatedTasks 
                                                        FROM    Task 
                                                        WHERE   OwnerId =:UserInfo.getUserId() 
                                                        GROUP BY WhoId 
                                                        limit   :Limits.getLimitQueryRows() - Limits.getQueryRows()];
            
           
            // create map of contact and its no of interaction with logged in user
            if(!taskAggregateList.isEmpty())
            {
                for(AggregateResult aggregateResultObj : taskAggregateList)
                {
                    mapOfContactIdAndTaskCount.put(String.valueOf(aggregateResultObj.get('contactRelatedTasks')), Integer.valueOf(aggregateResultObj.get('noOfTaskInteractions')));
                }
            }
           
             // Query count of Events for each contact of logged in user 
            List<AggregateResult> eventAggregateList = [    SELECT  Count(Id) noOfEventInteractions, WhoId contactRelatedEvents 
                                                            FROM    Event 
                                                            WHERE   OwnerId =:UserInfo.getUserId() 
                                                                AND Id IN: contactRelatedEventIds 
                                                            GROUP BY WhoId 
                                                            limit   :Limits.getLimitQueryRows() - Limits.getQueryRows()];
            if(!eventAggregateList.isEmpty())
            {
                for(AggregateResult aggregateResultObj : eventAggregateList)
                {
                    mapOfContactIdAndEventCount.put(String.valueOf(aggregateResultObj.get('contactRelatedEvents')), Integer.valueOf(aggregateResultObj.get('noOfEventInteractions')));
                }
            }
            
           /* for(Contact contactObj : [  SELECT  Id, (   SELECT  Id, Subject 
                                                        FROM    ActivityHistories 
                                                        ORDER BY ActivityDate DESC NULLS LAST, LastModifiedDate DESC
                                                        LIMIT   500) 
                                        FROM    Contact 
                                        WHERE   Id IN:contactIds 
                                        limit   :Limits.getLimitQueryRows() - Limits.getQueryRows()])
             {
                
                if(!contactObj.ActivityHistories.isEmpty())
                {
                    mapOfContactIdAndLastInteraction.put(contactObj.Id, contactObj.ActivityHistories[0]);
                }
            }*/
            
           //calculate the frequesnt contacts using created map mapOfContactIdAndLastInteraction
            for(Id ContactId : contactIds)
            {
                myFrequentContactsObj = new MyFrequentContactsWrapper();
                if(mapOfContactIdAndContact.containsKey(contactId))
                {
                    myFrequentContactsObj.contactObj = mapOfContactIdAndContact.get(contactId);
                }
                if(mapOfContactIdAndTaskCount.containsKey(contactId) && mapOfContactIdAndEventCount.containsKey(contactId))
                {
                    myFrequentContactsObj.numberOfInteractions = mapOfContactIdAndTaskCount.get(contactId)+mapOfContactIdAndTaskCount.get(contactId);
                }
                if(mapOfContactIdAndTaskCount.containsKey(contactId) && !mapOfContactIdAndEventCount.containsKey(contactId))
                {
                    myFrequentContactsObj.numberOfInteractions = mapOfContactIdAndTaskCount.get(contactId);
                }
                if(!mapOfContactIdAndTaskCount.containsKey(contactId) && mapOfContactIdAndEventCount.containsKey(contactId))
                {
                    myFrequentContactsObj.numberOfInteractions = mapOfContactIdAndEventCount.get(contactId);
                }
                if(mapOfContactIdAndLastInteraction.containsKey(contactId))
                {
                    myFrequentContactsObj.activityHistoryObj = mapOfContactIdAndLastInteraction.get(contactId);
                }
                myFrequentContactsList.add(myFrequentContactsObj);
            }
        }catch(Exception e)
        {
            System.debug( 'Exception : ' +e.getMessage() );
            throw e;
        }
    }
    
    // Wrapper class to store contact no of interactions and history of interctions
    public class MyFrequentContactsWrapper {

        public Contact contactObj {get; set;}
        public Integer numberOfInteractions {get; set;}
        public ActivityHistory activityHistoryObj {get; set;}
    
        public MyFrequentContactsWrapper() {
        
        }
    }
}