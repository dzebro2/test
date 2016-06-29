/**************************************************************************************
  Apex Class Name     : TakeACasePinnedListController
  Version             : 1.0
  Function            : This class is used to get case queues information to show as a pinned list. 
  Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
*   Suyog Dongaonkar       26/09/2014                Original Version
*   Mei Chen               03/16/2015                Add logic to look thru the Ok queue for Role in the public group
*************************************************************************************/

global with sharing class TakeACasePinnedListController {
        
    public List<Queue_Names__c> queuesNamesList {get;set;}
    public Queue_Names__c defaultQueueConfig {get;set;}
    public Map<String, Integer> queueCounts {get;set;}
    public Map<String, String> QueueMinTimeAndName{get;set;}

    public  Integer MyCasesCount {get; set;}
    public  Integer AssignedCasesCount {get; set;}
    public  Integer UnreadEmailCount {get; set;}    
    public  String CaseNumber {get;set;}
    public  String CaseId {get;set;}
    public  String AssignStatus {get;set;}
    public  Map<String, Id> QueueNameAndIdMap{get;set;}
    
    Map<Id, String> QueueIdAndNameMap{get;set;}
    public Decimal RefereshInterval {get; set;}
    public String ReportId {get; set;}
    
    
    /*  TakeACasePinnedListController constructor
    *   Initialize data in constructor
    */
    public TakeACasePinnedListController() 
    {
        
        try 
        {
            List<Service_Console_Settings__c> serviceConsoleSettings = Service_Console_Settings__c.getall().values();
            List<Report> reports = [    select  Id 
                                        from    Report
                                        where   DeveloperName = :serviceConsoleSettings[0].Unread_Email_Report_Name__c
                                        limit   1];
            if( reports.size() > 0 ) {                                       
                ReportId = reports[0].Id;
            }
            RefereshInterval = serviceConsoleSettings[0].Unread_Email_Refresh_Interval__c;
        } catch( Exception e ) {
            ReportId = '';
            RefereshInterval = 300;
        }
        try 
        {    
            defaultQueueConfig = Queue_Names__c.getInstance( 'Default' );
            
            PopulateQueueCaseCounts();
            
        } catch( Exception e ) 
        {
            AssignStatus = 'error';
        }
        
        UnreadEmailCount = PopulateUnReadEmails();
    }
    
    /*  PopulateQueueCaseCounts
    *   @description:   This method gets the queue names applicable for the logged in user.
                        This method also gets the counts for each queues.
    *   @parameters     N/A
    *   @return type    N/A                     
    */
    public  void PopulateQueueCaseCounts() 
    {
        
        QueueNameAndIdMap   = new Map<String, Id>();
        QueueIdAndNameMap   = new Map<Id, String>();
        QueueCounts         = new Map<String, Integer>();
        QueueMinTimeAndName = new Map<String, String>();
           
        List<Id> GroupIds   = new List<Id>();
        
        //check if role in the Public group
        List<Id> roleList = new List<Id>();
        
        //Logic in order to check if Role of User is present in Public Group and the Public Group is present in any Queue - D-00612
        for(Group g:[select Id from Group where RelatedId=:UserInfo.getUserRoleId()]){
            roleList.add(g.Id);
        }
        system.debug('populate case count');
        //Get the GroupMember records
        for( GroupMember groupMemberObj : [ SELECT  GroupId 
                                            FROM    GroupMember 
                                            WHERE   UserOrGroupId = :UserInfo.getUserId() or UserOrGroupId IN:roleList
                                            limit   :Limits.getLimitQueryRows() - Limits.getQueryRows() ] )
        {
            GroupIds.add( groupMemberObj.GroupId );
        }
    
        if( !GroupIds.isEmpty() ) 
        {
            //To Store Queue Names and Salesforce Queue Id
            for( Group groupObj : [ SELECT  Id, Name
                                    FROM    Group
                                    WHERE   Id IN :GroupIds
                                    limit   :Limits.getLimitQueryRows() - Limits.getQueryRows() ] )
            {
                QueueNameAndIdMap.put(groupObj.Name, groupObj.Id);
                QueueIdAndNameMap.put(groupObj.Id, groupObj.Name);
                QueueCounts.put( groupObj.Name, 0 );
                QueueMinTimeAndName.put(groupObj.Name,'');
            }
        }
        
        //Get queue names from custom setting
        QueuesNamesList = [ select  Id, Name, Active__c, Sort_Order__c, Title__c, Count_Range_1_Color__c, Count_Range_1_End__c, 
                                    Count_Range_1_Start__c, Count_Range_2_Color__c, Count_Range_2_End__c, Count_Range_3_Color__c, Zero_Count_Color__c
                            from    Queue_Names__c
                            where   Active__c = true
                                and Title__c IN :QueueIdAndNameMap.values()
                                and Active__c = true
                            order by Sort_Order__c
                            limit   :Limits.getLimitQueryRows() - Limits.getQueryRows() ];

        AggregateResult[] groupedResults = [SELECT  count(Id), Min(Createddate), OwnerId
                                            FROM Case 
                                            WHERE ownerId IN :QueueIdAndNameMap.keySet() AND isClosed = false 
                                            Group by OwnerId];

    
        for(AggregateResult ar :groupedResults)
        {
            system.debug(' queue name: '+ar.get('OwnerId'));
            
            Integer ct=Integer.valueOf(ar.get('expr0')); 
            
            QueueCounts.put( QueueIdAndNameMap.get( String.valueOf( ar.get('OwnerId') ) ),ct);
          
           //  DateTime myDatetime=DateTime.valueOf(ar.get('expr1'));
             
            //system.debug(ar.get('OwnerId')+'  min created date: '+myDatetime.format('yyyy-mm-dd HH:mm:ss'));//2015-10-14 21:04:15
            
            String  minTimeInStr='';//convertMinTimeToStr(DateTime.valueOf(ar.get('expr1')));  
        
           if(ct>0){
           	  minTimeInStr=convertMinTimeToStr(DateTime.valueOf(ar.get('expr1')));
           }
           system.debug(ar.get('OwnerId')+ '  min time: '+minTimeInStr);
          QueueMinTimeAndName.put(QueueIdAndNameMap.get(String.valueOf(ar.get('OwnerId'))), minTimeInStr);
           
        }
        
        MyCasesCount = PopulateMyCasesCount();      
        AssignedCasesCount = PopulateAssignedCasesCount();
    }
    
    /*  AssignCase
    *   @description:   This method gets a case from the selected queue and assigns it to the requesting user.
    *   @parameters     N/A
    *   @return type    N/A                     
    */
    global  void AssignCase()
    {
        try 
        {
            CaseTriggerHandler.isUpdateFromCode = true;
            AssignStatus = 'success';
            String queueId = ApexPages.currentPage().getParameters().get('queueId');
            //check for Blue Leader cases 
            List<Case> Cases = [    select  Id, CaseNumber, ownerId
                                    from    Case
                                    where   IsClosed = false
                                        and ownerId = :queueId
                                        and Producer_Account__r.Blue_Leader__c = true
                                    order by CreatedDate ASC
                                    limit   1];
            //If Blue Leader cases exist, assign it in priority                                    
            if( Cases.size() > 0 ) {
                Cases   = [    select  Id, CaseNumber, ownerId
                                from    Case
                                where   IsClosed = false
                                    and Id = :Cases[0].Id
                                    and ownerId = :queueId
                                limit   1
                                FOR UPDATE];
            }                                    
            
            //if no Blue Leader cases exist, check for other cases                                      
            if( Cases.size() == 0 ) 
            {
                Cases = [   select  Id, CaseNumber, ownerId
                            from    Case
                            where   IsClosed = false
                                and ownerId = :queueId
                            order by CreatedDate ASC
                            limit   1];
                
                if( Cases.size() > 0 ) {
                    Cases   = [    select  Id, CaseNumber, ownerId
                                    from    Case
                                    where   IsClosed = false
                                        and Id = :Cases[0].Id
                                        and ownerId = :queueId
                                    limit   1
                                    FOR UPDATE];
                }                            
            }
            Case caseRec = Cases[0];
            caseRec.ownerId = UserInfo.getUserId();
            update caseRec; 
            PopulateQueueCaseCounts();
            CaseNumber  = caseRec.CaseNumber;
            CaseId      = caseRec.Id;
        }
        catch( Exception e ) {
            AssignStatus = 'error';
        }
    }
    
    /*  CreatePushTopic
    *   @description:   This method creates a PushTopic record for Case if it does not already exist. 
    *   @parameters     N/A
    *   @return type    N/A                     
    */
    public  void CreatePushTopic() 
    {
        List<PushTopic> PushTopics = [  select  Id
                                        from    PushTopic
                                        where   Name = :StaticVariablesUtility.casePushTopicName
                                        limit   :Limits.getLimitQueryRows() - Limits.getQueryRows()];
        if( PushTopics.size() == 0 ) 
        {                              
            PushTopic pushTopic     = new PushTopic();
            pushTopic.ApiVersion    = StaticVariablesUtility.casePushTopicAPIVersion;
            if(!Test.isRunningTest())
                pushTopic.Name = StaticVariablesUtility.casePushTopicName;
            else
                pushTopic.Name = StaticVariablesUtility.testCasePushTopicName;
                
            pushTopic.Description       = StaticVariablesUtility.casePushTopicDescription;
            pushTopic.NotifyForFields   = StaticVariablesUtility.casePushTopicNotifyForFields;
            pushTopic.Query             = StaticVariablesUtility.casePushTopicQuery;
            insert pushTopic;   
        }
    }
    
    
    /*  PopulateCaseCountByType
    *   @description:   This method gets the count of Cases by its type. 
    *   @parameters     N/A
    *   @return type    N/A                     
    */
    private  Integer PopulateCaseCountByType(Id QueueId ) 
    {
        return [SELECT  count() 
                FROM    Case 
                WHERE   ownerId = :QueueId 
                    AND isClosed = false 
                LIMIT :Limits.getLimitQueryRows() - Limits.getQueryRows() ];  
    }
    
    /*  PopulateMyCasesCount
    *   @description:   This method gets count of my Cases. 
    *   @parameters     N/A
    *   @return type    Integer                 
    */  
    private  Integer PopulateMyCasesCount() 
    {
        return [SELECT  count() 
                FROM    Case 
                WHERE   OwnerId = :UserInfo.getUserId() 
                    AND isClosed = false 
                LIMIT :Limits.getLimitQueryRows() - Limits.getQueryRows() ];  
    }
    
    /*
    *  PopulateMyoldestCaseTime
    *  @description This method retrieve the oldest time from the owner's qeueu
    */
    private String convertMinTimeToStr(dateTime minTime){
    	
    	String minTimeInStr='00:00:00';
    	
    	try{
  
    	if(minTime !=null){
    	 // Datetime myDatetime=Datetime.parse(minTime);
    	  system.debug('original time: '+minTime);
    	  minTimeInStr=minTime.format();//String.valueOfGMT(minTime);//minTime.format('yyyy-mm-dd h:mm a', 'GMT');  
    	  system.debug('oldest time: '+minTimeInStr);	
    	 }
    	 
    	}catch(Exception e){
    	  system.debug('error from convertMinTimToStr: '+e +' date time from parameter: '+minTime);	
    	}
    	return minTimeInStr;
    	
    }
    /*  PopulateAssignedCasesCount
    *   @description:   This method creates a PushTopic record for Case if it does not already exist. 
    *   @parameters     N/A
    *   @return type    Integer                     
    */
    private  Integer PopulateAssignedCasesCount() {
        return [SELECT  count() 
                FROM    Case 
                WHERE   OwnerId != :UserInfo.getUserId() 
                    AND Assigned_To__c = :UserInfo.getUserId()  
                    AND isClosed = false 
                LIMIT :Limits.getLimitQueryRows() - Limits.getQueryRows() ];  
    }  
    
    
    public void callUnReadEmails() {
        UnreadEmailCount = PopulateUnReadEmails();
    }
    
    public Integer PopulateUnReadEmails() {
        List<Case> ListOfCases = [  SELECT  Id, OwnerId 
                                    FROM    Case 
                                    WHERE   OwnerId = :UserInfo.getUserId() 
                                            OR Assigned_To__c  =:UserInfo.getUserId()  
                                    LIMIT :Limits.getLimitQueryRows() - Limits.getQueryRows()];
        Set<Id> ParentIds = new Set<Id>();
        
        if(!ListOfCases.isEmpty()){
            for(Case caseObj : ListOfCases){
                ParentIds.add(caseObj.Id);
            }
        }
        if(!ParentIds.isEmpty()){
            return [SELECT  count() 
                    FROM    EmailMessage 
                    WHERE   Status = '0' 
                        AND ParentId IN: ParentIds 
                    LIMIT :Limits.getLimitQueryRows() - Limits.getQueryRows() ];
        }
        else{
            return 0;
        }
    }
}