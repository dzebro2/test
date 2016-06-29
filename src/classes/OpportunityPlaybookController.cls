/**************************************************************************************
  Apex Class Name     : OpportunityPlaybookController
  Version             : 1.0
  Function            : This is a controller class for the OpportunityPlaybook page
  Modification Log    :

*************************************************************************************/
public with sharing class OpportunityPlaybookController 
{
   
 
    public List<CommonStageWrapper>             lstPlaybook         {set; get;} // list of CommonStageWrapper wrapper
    public Map<String, List<Task_Mapping__c>>   mapTasksBySubstage  {get; private set;} // map to hold Record ID of Substage_Mapping1__c as Key and list of related Task Mapping records as Value
    public Boolean                              closedLostOpp       {get;set;}
    public Boolean                              showEdit            {get;set;}
    public Boolean                              isEditAllowed       {get;set;} 
    public Opportunity                          opp                 {get;set;} // Opportunity sObject record
    public List<Playbook__c>                    playbooks           {get;set;} 
    public String                               selectedPlaybook    {get;set;}
    
    public boolean hasError{get;set;}
    private Map<String, Case> casesRelatedToOpportunity; //Map of case record type and case record
    private Id                                  pniOwnerId;
    private Id                                  oppId;
    private Map<String, List<OpportunityTeamMember>> oppTeamMembers;
    private Map<String, List<Opportunity_Team_Non_SF__c>> oppTeamMembersNonSF;
    //constructor
    public OpportunityPlaybookController(ApexPages.StandardController sc) 
    { 
        oppId               = sc.getId();
        closedLostOpp       = false;
        showEdit            = false;
        isEditAllowed       = true;
        mapTasksBySubstage  = new Map<String, List<Task_Mapping__c>>();
        lstPlaybook         = new List<CommonStageWrapper>();      
        
        try
        {  
            opp                         = getOpportunityRecord();
            selectedPlaybook            = opp.Playbook__c;
            oppTeamMembers              = populateOpportunityTeamMembers();
            oppTeamMembersNonSF         = populateOpportunityTeamMembersNonSF();
            hasError = false;
        }
        catch(exception e)
        {
            ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.Info, System.Label.UnexpectedError);
            ApexPages.addMessage(errMsg);
        }
       
    }  
   
    
 
    
    private Opportunity getOpportunityRecord() 
    {
        try
        {
        Opportunity oppRec =  [ SELECT  Id,StageName, Playbook__c,Expected_Health_Members__c, createdDate, LastModifiedDate, AccountId,Account.RecordType.DeveloperName, Account.of_BCBS_Enrolled_Subscribers__c,
                                        Name, Requested_Effective_Date__c,Rate_End_Date__c, HCSC_Division__c,closeDate, FSU_Location__c, Other_FSU_Location__c,District__c,
                                        Account.External_ID__c,Account.Funding_Type__c, Account.Group_Anniversary_Date__c,ownerID, createdbyid, Expected_Health_Contracts__c, Expected_Dental_Contracts__c,
                                        (Select Id, OpportunityId, ContactId,Contact.Name ,Role, IsPrimary From OpportunityContactRoles),
                                        (Select Opportunity__c,Producer_Consultant__c,Account_Record_Type__c from Producer_Association_For_Opportunity__r)
                                FROM    Opportunity  
                                WHERE   Id = :oppId
                                limit   1 ];
    
        if( oppRec.StageName == 'Lost' || oppRec.StageName == 'Declined' || oppRec.StageName == 'Cancelled' ) 
        {
            closedLostOpp = true;
        } 
        return oppRec;
        }catch(Exception e)
        {
            throw e;
            return new Opportunity();
        }                  
    } 
    
    private Map<String, Case> getCasesRelatedToOpportunity() 
    {
        Map<String, Case> casesMap = new Map<String, Case>();
        try
        {
            for( Case caseRec :[    select  Id, Related_Case__c, RecordTypeId, RecordType.Name
                                    from    Case
                                    where   Opportunity_Name__c = :opp.Id
                                    limit   :Limits.getLimitQueryRows() - Limits.getQueryRows() ] )
            {
                casesMap.put( caseRec.RecordType.Name, caseRec );
            }                               
        }catch(Exception e)
        {
            throw e;
        }        
            return casesMap;
    }
    
    private Map<String, List<OpportunityTeamMember>> populateOpportunityTeamMembers() 
    {
       
        Map<String, List<OpportunityTeamMember>> oppTeamMembersMap = new Map<String, List<OpportunityTeamMember>>();
        try
        {
            for( OpportunityTeamMember otm :[   select  Id, TeamMemberRole, UserId, OpportunityId
                                                from    OpportunityTeamMember
                                                where   OpportunityId = :opp.Id
                                                limit   :Limits.getLimitQueryRows() - Limits.getQueryRows() ] ) 
            {
                
                if( !oppTeamMembersMap.containsKey( otm.TeamMemberRole ) ) 
                {
                    oppTeamMembersMap.put( otm.TeamMemberRole, new List<OpportunityTeamMember>() );
                }
                oppTeamMembersMap.get( otm.TeamMemberRole ).add( otm );
            }
        }catch(exception e)
        {
            System.debug( 'Exception : ' +e.getMessage() );
            throw e;
        }
        return oppTeamMembersMap;
    }
    
    private Map<String, List<Opportunity_Team_Non_SF__c>> populateOpportunityTeamMembersNonSF() 
    {
        Map<String, List<Opportunity_Team_Non_SF__c>> oppTeamMembersNonSFMap = new Map<String, List<Opportunity_Team_Non_SF__c>>();
        try
        {
            for(Opportunity_Team_Non_SF__c oppTeamNonSF :[SELECT Id, Member_Role__c, Opportunity_Team_Member__c, Opportunity_Team_Member__r.Name, Opportunity_Team_Member__r.Email FROM Opportunity_Team_Non_SF__c WHERE Opportunity_Name__c = :opp.Id LIMIT :Limits.getLimitQueryRows() - Limits.getQueryRows() ] ) 
            {
                
                if(!oppTeamMembersNonSFMap.containsKey(oppTeamNonSF.Member_Role__c))
                {
                    List<Opportunity_Team_Non_SF__c> tempOppTeamNonSFList = new List<Opportunity_Team_Non_SF__c>();
                    tempOppTeamNonSFList.add(oppTeamNonSF);
                    oppTeamMembersNonSFMap.put(oppTeamNonSF.Member_Role__c, tempOppTeamNonSFList);
                }
                else
                {
                    oppTeamMembersNonSFMap.get(oppTeamNonSF.Member_Role__c).add(oppTeamNonSF);
                }
            }
       }catch(Exception e)
       {
           System.debug( 'Exception : ' +e.getMessage() );
           throw e;
       } 
        return oppTeamMembersNonSFMap;
    }
    /**    
    * @Description: Adding stages to playbook
    * @Param: none
    * @Return: none
    */  
    public void initPlaybook()
    {
        try 
        {
            Set<Id> setStageIds = new Set<Id>(); 
            lstPlaybook.clear();
            mapTasksBySubstage.clear();
    
            // for each stage mapping record and its related sub stage mapping records..
            List<Stage_Mapping__c> stageMappings = [    SELECT  Id, Name, Playbook__c, Stage_Name__c, Stage_Background_Color__c, No_of_Completed_Substage__c,  
                                                                Number_of_Substage__c, Playbook__r.Stage_Progression__c,
                                                            (   SELECT  Id, Name,Completed__c, Task_Type__c, Substage_Background_Color__c, Verifiable_Outcome__c, Total_Tasks__c, 
                                                                        Completed_Tasks__c, SubStage_Name__c, Substage__r.Image_URL__c, LastModifiedDate, Started__c, Substage__r.Closed_Lost_Substage__c,
                                                                        Completed_Date_Time__c, Start_DateTime__c
                                                                FROM    Substage_Mappings__r 
                                                                ORDER BY Substage_Sort_Order__c
                                                                limit   :Limits.getLimitQueryRows() - Limits.getQueryRows() ) 
                                                        FROM    Stage_Mapping__c 
                                                        WHERE   Playbook__c =: opp.Playbook__c 
                                                            and Opportunity__c=:opp.Id
                                                            and Stage__r.Closed_Lost_Stage__c = false  
                                                        ORDER BY Stage_Sort_Order__c 
                                                        limit   :Limits.getLimitQueryRows() - Limits.getQueryRows()];
         
            List<Stage_Mapping__c> closedStageMappings = new List<Stage_Mapping__c>();
            
            closedStageMappings = [ SELECT  Id, Name, Playbook__c, Stage_Name__c, Stage_Background_Color__c, No_of_Completed_Substage__c,  
                                            Number_of_Substage__c, Playbook__r.Stage_Progression__c,
                                        (   SELECT  Id, Name,Completed__c, Task_Type__c, Substage_Background_Color__c, Verifiable_Outcome__c, Total_Tasks__c, 
                                                    Completed_Tasks__c, SubStage_Name__c, Substage__r.Image_URL__c, LastModifiedDate, Started__c, Substage__r.Closed_Lost_Substage__c,
                                                    Completed_Date_Time__c, Start_DateTime__c
                                            FROM    Substage_Mappings__r 
                                            WHERE   Substage__r.Closed_Lost_Substage__c = :closedLostOpp
                                            ORDER BY Substage_Sort_Order__c
                                            limit   :Limits.getLimitQueryRows() - Limits.getQueryRows() ) 
                                    FROM    Stage_Mapping__c 
                                    WHERE   Playbook__c =: opp.Playbook__c 
                                        and Opportunity__c=:opp.Id
                                        and Stage__r.Closed_Lost_Stage__c = true  
                                    ORDER BY Stage_Sort_Order__c 
                                    limit   :Limits.getLimitQueryRows() - Limits.getQueryRows()];
                                        
            stageMappings.addAll( closedStageMappings );
            
            for(Stage_Mapping__c stageMapping :stageMappings) 
            {
                setStageIds.add( stageMapping.Id );
                if( stageMapping.No_of_Completed_Substage__c > 0 ) 
                {
                    isEditAllowed = false;
                }
                for( Substage_Mapping1__c substageMapping :stageMapping.Substage_Mappings__r ) 
                {
                    if( substageMapping.Completed_Tasks__c > 0 ) 
                    {
                        isEditAllowed = false;
                    }
                }
            } 
        
        
            // for each stage mapping record and its related task mapping records..
            if(setStageIds <> NULL && !setStageIds.isEmpty())
            {
                for(Substage_Mapping1__c ss : [ SELECT  Id, Substage__c, Substage__r.Image_URL__c,
                                                        (   SELECT  Id, Name, Task_Name__c,Task_Sort_Order__c,Completed__c,Task_Type__c,Task_URL__c, Due_Date__c, Date_Time_Completed__c,
                                                                    Task__r.Owner_Role__c, Task__r.Trigger_After_Completion__c, Task__r.Case_Record_Type__c, Task__r.Action__c
                                                            FROM    Task_Mappings__r 
                                                            ORDER BY Task_Sort_Order__c
                                                            limit   :Limits.getLimitQueryRows() - Limits.getQueryRows() ) 
                                                FROM    Substage_Mapping1__c 
                                                WHERE   Stage_Mapping__c IN: setStageIds
                                                limit   :Limits.getLimitQueryRows() - Limits.getQueryRows()] ) 
                {
                    mapTasksBySubstage.put( ss.Id, ss.Task_Mappings__r );
                }
            }
        
        
            for(Stage_Mapping__c s :stageMappings) 
            {
                    initCommonStages( s );
            }
    
            
            //Start closed lost substages
            if( closedLostOpp ) 
            {
                List<Id> closedSubStageIds = new List<Id>();
                for( Stage_Mapping__c closedStageMapping :closedStageMappings ) {
                    for( Substage_Mapping1__c subStageMapping :closedStageMapping.Substage_Mappings__r ) 
                    {
                        closedSubStageIds.add( subStageMapping.Id );
                    }
                }
                startMultipleSubStages( closedSubStageIds );
            }
       } catch( Exception e ) 
       {
           System.debug( 'Exception : ' +e.getMessage() );
           throw e;
       }
    }

    /**    
    * @Description: Populating data in CommonStageWrapper wrapper
    * @Param: Stage_Mapping__c record
    * @Return: none
    */  
    private void initCommonStages(Stage_Mapping__c s)
    {
        try
        {
            CommonStageWrapper newStage = new CommonStageWrapper();
            
            newStage.stageMappingRec    = s;
            newStage.lOBStages          = getLOBStages(s);
             
            lstPlaybook.add(newStage);
        }catch(Exception e)
        {
            throw e;
        }
    }
    
    /**    
    * @Description: To fetch LOB stages
    * @Param: Stage_Mapping__c record
    * @Return: List of LOBStageWrapper wrapper
    */  
    private List<LOBStageWrapper> getLOBStages(Stage_Mapping__c s)
    {
        List<LOBStageWrapper> lOBStages = new List<LOBStageWrapper>();
        try
        {
            for(Substage_Mapping1__c ss : s.Substage_Mappings__r) 
            {
                
                LOBStageWrapper newLOBStage     = new LOBStageWrapper();
                newLOBStage.subStageMappingRec  = ss;
                newLOBStage.lastModified        = ss.LastModifiedDate.date().format(); 
                newLOBStage.Tasks               = getTasksForLobStage(ss.Id);
                lOBStages.add(newLOBStage);
            }
        }catch(Exception e)
        {
            throw e;
        }
        return lOBStages;  
    }
  

    /**    
    * @Description: Method to return list of TaskWrapper
    * @Param: LOB Stage ID
    * @Return: list of TaskWrapper
    */  
    private List<TaskWrapper> getTasksForLobStage(Id lobStageId)
    {
        List<TaskWrapper> lstTasks = new List<TaskWrapper>();
        try
        {
            if(mapTasksBySubstage != NULL && mapTasksBySubstage.get(lobStageId) != NULL)
            {
             
                for(Task_Mapping__c tsk : mapTasksBySubstage.get(lobStageId)) 
                {
                    TaskWrapper newTask     = new TaskWrapper();
                    newTask.taskMappingRec  = tsk;
                    if( oppTeamMembers.containsKey( tsk.Task__r.Owner_Role__c ) && oppTeamMembers.get( tsk.Task__r.Owner_Role__c ).size() > 0 ) 
                    {
                        newTask.taskOwners      = oppTeamMembers.get( tsk.Task__r.Owner_Role__c );
                    } 
                    lstTasks.add(newTask);
                }
            
            }
        }catch(Exception e)
        {
            throw e;
        }
        return lstTasks;  
    }
    
    public PageReference startSubStage() 
    {
        try 
        {
            String subStageId   = ApexPages.currentPage().getParameters().get( 'subStageId' );
            startMultipleSubStages( new List<Id> { subStageId } );
            initPlaybook();
        } catch( Exception e ) 
        {
            throw e;
        }
        return null;
    }
    
    
    private void startMultipleSubStages( List<Id> subStageIds ) 
    {
       try
       {
            List<Substage_Mapping1__c> newSubStageMappings = [  select  Started__c, Start_DateTime__c
                                                                from    Substage_Mapping1__c
                                                                where   Id IN :subStageIds
                                                                    and Started__c = false
                                                                limit   :Limits.getLimitQueryRows() - Limits.getQueryRows()];
                                                                
            
            for( Substage_Mapping1__c  newSubStageMapping :newSubStageMappings ) 
            {
                newSubStageMapping.Started__c           = true;
                newSubStageMapping.Start_DateTime__c    = DateTime.now();
            }
            update newSubStageMappings;
      }catch(Exception e)
      {
          System.debug( 'Exception : ' +e.getMessage() );
          throw e;
      }  
    }
    
    public PageReference updateSubStageStatus() 
    {
        Savepoint sp = Database.setSavepoint();

        try 
        {
            
            String subStageId   = ApexPages.currentPage().getParameters().get( 'subStageId' );
            String status       = ApexPages.currentPage().getParameters().get( 'status' );
            
            Substage_Mapping1__c subStageMapping = [    select  Id, Completed__c, SubStage_Name__c, Substage_Sort_Order__c, Stage_Mapping__r.Stage_Sort_Order__c, Stage_Mapping__c,
                                                                Stage_Mapping__r.Playbook__c
                                                        from    Substage_Mapping1__c
                                                        where   Id = :subStageId 
                                                            and Started__c = true
                                                        limit   1 ];
            
            if( status == 'done' ) {                                                    
                subStageMapping.Completed__c            = true;
                subStageMapping.Completed_Date_Time__c  = DateTime.now();
                opp.StageName                           = subStageMapping.SubStage_Name__c;
            } else if( status == 'undone' ) {
                subStageMapping.Completed__c = false;
            }
            update subStageMapping;
            update opp;
            
            opp = getOpportunityRecord();
            
            startNextStage( subStageMapping );
            
            initPlaybook();
            hasError = false;
        } 
        catch (System.DmlException e) {
            hasError = true;
            Database.rollback(sp);
            
            ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.Info, e.getDmlMessage(0));
            ApexPages.addMessage(errMsg);
        }
        catch( Exception e)
        {
            Database.rollback(sp);
            
            System.debug( 'Exception : ' +e.getMessage() );
            ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.Info, e.getMessage());
            ApexPages.addMessage(errMsg);
        }     
        return null;
    }
    
    private void startNextStage( Substage_Mapping1__c subStageMapping ) 
    {
        
        //1. Activate the next substage in the same stage which has not yet been started
        try
        {
        List<Substage_Mapping1__c> newSubStageMappings = [  select  Started__c, Start_DateTime__c
                                                            from    Substage_Mapping1__c
                                                            where   Stage_Mapping__c = :subStageMapping.Stage_Mapping__c
                                                                and Started__c = false
                                                            order by Substage_Sort_Order__c ASC
                                                            limit   :Limits.getLimitQueryRows() - Limits.getQueryRows() ];
                                                            
        if( newSubStageMappings.size() > 0 ) 
        {
            newSubStageMappings[0].Started__c           = true;
            newSubStageMappings[0].Start_DateTime__c    = DateTime.now();
            
            update newSubStageMappings[0]; 
        }
        
        //2. If there is no substage in the same stage, identify next stage and start its first substage
        else 
        {
            //Get the next not completed stage
            List<Stage_Mapping__c> stageMappings = [    select  Id, IsCompleted__c 
                                                        from    Stage_Mapping__c
                                                        where   IsCompleted__c = false
                                                            and Playbook__c = :subStageMapping.Stage_Mapping__r.Playbook__c
                                                            and Opportunity__c = :opp.Id
                                                        order by Stage_Sort_Order__c ASC
                                                        limit   1];
            if( stageMappings.size() > 0 )
             {
                //Activate the stage in it
                newSubStageMappings = [ select  Started__c, Start_DateTime__c
                                        from    Substage_Mapping1__c
                                        where   Stage_Mapping__c = :stageMappings[0].Id
                                            and Started__c = false
                                        order by Substage_Sort_Order__c ASC
                                        limit   :Limits.getLimitQueryRows() - Limits.getQueryRows() ];
                                                        
                if( newSubStageMappings.size() > 0 ) 
                {
                    newSubStageMappings[0].Started__c           = true;
                    newSubStageMappings[0].Start_DateTime__c    = DateTime.now();
                    
                    update newSubStageMappings[0]; 
                }
            }
        } 
        }catch(Exception e)
        {
            System.debug( 'Exception : ' +e.getMessage() );
            throw e;
        }
    }
    
    public PageReference updateTaskStatus() 
    {
        String subStageIdForTasks                       = ApexPages.currentPage().getParameters().get( 'subStageIdForTasks' );
        List<Task_Mapping__c> taskMappingsToBeUpdated   = new List<Task_Mapping__c>(); 
        List<Case> casesToBeCreated                     = new List<Case>();
        
        casesRelatedToOpportunity                       = getCasesRelatedToOpportunity();
        pniOwnerId                                      = populatePNIOwnerId();
        system.debug('=========='+subStageIdForTasks+'========='+mapTasksBySubstage.containsKey( subStageIdForTasks ) );

        if( mapTasksBySubstage.containsKey( subStageIdForTasks ) ) {
            taskMappingsToBeUpdated = mapTasksBySubstage.get( subStageIdForTasks );
        }
        try{
        
        for( Task_Mapping__c t :taskMappingsToBeUpdated ) {
            
            if( t.Completed__c && t.Date_Time_Completed__c == null ) {
                
                t.Date_Time_Completed__c = DateTime.now();
                
                if( String.isNotBlank( t.Task__r.Trigger_After_Completion__c ) && t.Task__r.Trigger_After_Completion__c == 'Create a Case' 
                    && !casesRelatedToOpportunity.containsKey( t.Task__r.Case_Record_Type__c ) ) 
                    {
                    system.debug('updateTaskStatus');
                    casesToBeCreated.add( createCaseRecord( t ) );
                }
            }
            
            if( !t.Completed__c )
            {
                t.Date_Time_Completed__c = null;
            }
        }
        
        update taskMappingsToBeUpdated;
        
        if( casesToBeCreated.size() > 0 ) 
        { 
            try 
            {
                
                Database.SaveResult[] srList = database.insert(casesToBeCreated,false);
                list<Case> successfullCases = new list<Case>();
                for(Integer i=0;i<srList.size();i++){
                    Database.SaveResult s = srList[i];
                    Case origRecord = casesToBeCreated[i];
                    if (s.isSuccess()) {
                        successfullCases.add(origRecord);
                     } 
                }
                if(successfullCases.size()>0){
                    updateRelatedCases( successfullCases );
                    createCaseTeamMember( successfullCases );
                }
                
            } catch( Exception e )
             {
                System.debug( 'Error: ' + e.getMessage() );
                ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.Info, e.getMessage());
                ApexPages.addMessage(errMsg);
            }
            
            
        }
        }catch(Exception e)
        {            
            System.debug( 'Exception : ' +e.getMessage() );
            CreateExceptionLog.insertErrorLog(e, null, null, null, 'Apex Class', 'HomePage', null, 'OpportunityPlaybookController.updateTaskStatus()','High'); 
        }
        initPlaybook();
        return null;
    }
    
    private Id populatePNIOwnerId() 
    {
        try
        {
        List<Group> queues = [  SELECT  Id 
                                        FROM    Group 
                                        where   Type = 'Queue' 
                                            and DeveloperName = 'Proposal_Delivery_Unit'
                                        limit   1 ];
        if( queues.size() > 0 ) {
            return queues[0].Id;
        }
       }catch(Exception e)
       {
           System.debug( 'Exception : ' +e.getMessage() );
           throw e;
           
       }    
        return null;
    }
    
    private Case createCaseRecord( Task_Mapping__c taskMapping ) {
        Case caseRec = new Case();
        try {
            system.debug('========' + casesRelatedToOpportunity.keySet() + '====' + taskMapping.Task__r.Case_Record_Type__c + '======' + Schema.SObjectType.Case.getRecordTypeInfosByName());
            /*if(taskMapping.Task__r.Case_Record_Type__c == 'Dental Underwriting' && casesRelatedToOpportunity.containsKey('Underwriting')){
                Case underwritingCase = getUnderwritingCaseRecord();
                system.debug('abcd');
                //caseRec = underwritingCase.clone(false,false,false,false);
                RecordType rType = [SELECT Id FROM RecordType where SobjectType = 'Case' and DeveloperName='Dental_Underwriting'];
                //caseRec.RecordTypeId = rType.Id;
                caseRec = createDentalUnderwriting(underwritingCase,taskMapping,rType.Id);
                //dentalUnderwritingCase.insert();
                caseRec.Subject                     = opp.Name + ' ' + (taskMapping.Task__r.Case_Record_Type__c == null ? '' : taskMapping.Task__r.Case_Record_Type__c);
            }else{*/

            caseRec.AccountId                   = opp.AccountId;
            caseRec.RecordTypeId                = Schema.SObjectType.Case.getRecordTypeInfosByName().get( taskMapping.Task__r.Case_Record_Type__c ).getRecordTypeId();
            caseRec.Opportunity_Name__c         = opp.Id;
            if(caseRec.RecordTypeId == Schema.SObjectType.Case.getRecordTypeInfosByName().get( 'Proposal' ).getRecordTypeId())
                caseRec.Bypass_Validation__c = TRUE;
            if (caseRec.RecordTypeId == Schema.SObjectType.Case.getRecordTypeInfosByName().get( System.label.Custom_Benefit_Service).getRecordTypeId()
                    || caseRec.RecordTypeId == Schema.SObjectType.Case.getRecordTypeInfosByName().get( 'Mid-Market Underwriting' ).getRecordTypeId()
                    || caseRec.RecordTypeId == Schema.SObjectType.Case.getRecordTypeInfosByName().get( Label.Case_Private_Exchange_Blue_Directions ).getRecordTypeId()
                    || caseRec.RecordTypeId == Schema.SObjectType.Case.getRecordTypeInfosByName().get( Label.Case_Private_Exchange_External ).getRecordTypeId())
                caseRec.Status                      = 'Draft';
            else
                caseRec.Status                      = 'New';
            caseRec.Requested_Effective_Date__c = opp.Requested_Effective_Date__c;
            caseRec.FSU_Location__c             = opp.FSU_Location__c;
            caseRec.Other_FSU_Location__c       = opp.Other_FSU_Location__c;
            caseRec.HCSC_Division__c            = opp.HCSC_Division__c;
            caseRec.Funding_Type_Multiselect__c = getFundingType();  //opp.Account.Funding_Type__c;
            caseRec.Premium_Type__c             = getPremiumType();
            caseRec.Number_of_Subscribers__c    = opp.Account.of_BCBS_Enrolled_Subscribers__c;
            caseRec.Subject                     = opp.Name + ' ' + (taskMapping.Task__r.Case_Record_Type__c == null ? '' : taskMapping.Task__r.Case_Record_Type__c);
            caseRec.Sales_Executive__c          = opp.OwnerId;
            for (Producer_Association_For_Opportunity__c pao : opp.Producer_Association_For_Opportunity__r) {
                caseRec.Consulting_Firm__c = pao.Producer_Consultant__c;
            }

            if (!oppTeamMembers.isEmpty()) {
                /*if(oppTeamMembers.containsKey('Sales Executive')){
                    caseRec.Sales_Executive__c = oppTeamMembers.get('Sales Executive')[0].UserId;
                }*/
                if (oppTeamMembers.containsKey('Account Executive')) {
                    caseRec.Account_Executive__c = oppTeamMembers.get('Account Executive')[0].UserId;
                }
            }

            if (!oppTeamMembersNonSF.isEmpty()) {
                if (oppTeamMembersNonSF.containsKey('Underwriter')) {
                    caseRec.Underwriter_Lookup__c = oppTeamMembersNonSF.get('Underwriter')[0].Opportunity_Team_Member__r.Name + ' (' + oppTeamMembersNonSF.get('Underwriter')[0].Opportunity_Team_Member__r.Email + ')';
                }
            }

            if ( pniOwnerId != null && ( taskMapping.Task__r.Case_Record_Type__c == 'Proposal' || taskMapping.Task__r.Case_Record_Type__c == 'Network Information' ) ) {
                caseRec.OwnerId = UserInfo.getUserId() ;
            }
            if (taskMapping.Task__r.Case_Record_Type__c == 'Performance Guarantee') {
                caseRec.Requested_By__c = UserInfo.getUserId();
                caseRec.Group_Status__c = getGroupStatus();
                caseRec.Group_Number_s__c = opp.Account.External_ID__c;
                caseRec.Consulting_Firm__c = null;
                caseRec.Expected_Health_Contracts__c = opp.Expected_Health_Contracts__c ;
                caseRec.Expected_Dental_Contracts__c = opp.Expected_Dental_Contracts__c ;

                if (oppTeamMembers.containsKey('Underwriter')) {
                    caseRec.Underwriter_Lookup__c = oppTeamMembers.get('Underwriter')[0].UserId;
                }
                for (Producer_Association_For_Opportunity__c pao : opp.Producer_Association_For_Opportunity__r) {
                    if (pao.Account_Record_Type__c == 'Consultant Account')
                        caseRec.Consulting_Firm__c = pao.Producer_Consultant__c;
                    if (pao.Account_Record_Type__c == 'Producer Account')
                        caseRec.Producer_Account__c = pao.Producer_Consultant__c;
                }

            }
            if (taskMapping.Task__r.Case_Record_Type__c == 'Custom Benefit/Service') {
                caseRec.Marketing_District__c = opp.District__c;
                caseRec.Group_Anniversary_Date__c = opp.Account.Group_Anniversary_Date__c;
                caseRec.Number_of_Subscribers__c = opp.Expected_Health_Contracts__c;
                caseRec.Requested_Effective_Date__c = opp.Requested_Effective_Date__c;
                if (oppTeamMembers.containsKey('Underwriter')) {
                    caseRec.Underwriter_Lookup__c = oppTeamMembers.get('Underwriter')[0].UserId;
                }
            }
            if (taskMapping.Task__r.Case_Record_Type__c == 'Proposal') {
                caseRec.Expected_Health_Contracts__c = opp.Expected_Health_Contracts__c ;
                caseRec.Expected_Dental_Contracts__c = opp.Expected_Dental_Contracts__c ;
                caseRec.Requested_By__c = opp.OwnerId;
            }
            // Private Exchange - Blue Directions
            if (taskMapping.Task__r.Case_Record_Type__c == Label.Case_Private_Exchange_Blue_Directions) {
                caseRec.Requested_By__c = opp.OwnerId;
            }
            // Private Exchange - External
            if (taskMapping.Task__r.Case_Record_Type__c == Label.Case_Private_Exchange_External) {
                caseRec.Requested_By__c = opp.OwnerId;
            }
            if (taskMapping.Task__r.Case_Record_Type__c == 'UnderWriting') {
                caseRec.Proposal_Due_Date__c = opp.CloseDate;
                caseRec.Expected_Health_Contracts__c = opp.Expected_Health_Contracts__c;
                caseRec.Expected_Dental_Contracts__c = opp.Expected_Dental_Contracts__c ;
                caseRec.Total_Expected_Members__c = opp.Expected_Health_Members__c;
                for ( OpportunityContactRole oppConRole : opp.OpportunityContactRoles) {
                    if (oppConRole.Role == 'Producer') {

                        if (caseRec.Producer__c == null || caseRec.Producer__c == '')
                            caseRec.Producer__c = oppConRole.Contact.Name;
                        else
                            caseRec.Producer__c += ',' + oppConRole.Contact.Name;
                    }
                    if (oppConRole.Role == 'Consultant')
                        caseRec.Consultant__c = oppConRole.Contact.Name;
                }
            }
            if (taskMapping.Task__r.Case_Record_Type__c == 'Dental Underwriting') {
                Case underwritingCase = getUnderwritingCaseRecord();
                if (underwritingCase != null && underwritingCase.Id != null)
                    caseRec = createDentalUnderwriting(underwritingCase, caseRec);
                caseRec.Requested_Effective_Date__c = opp.Requested_Effective_Date__c;
                caseRec.Proposal_Due_Date__c = opp.CloseDate;
                caseRec.Expected_Health_Contracts__c = opp.Expected_Health_Contracts__c;
                caseRec.Expected_Dental_Contracts__c = opp.Expected_Dental_Contracts__c ;
                caseRec.Total_Expected_Members__c = opp.Expected_Health_Members__c;
                system.debug('==========' + caseRec.Proposal_Due_Date__c + '=======' + caseRec.Expected_Dental_Contracts__c);
                for ( OpportunityContactRole oppConRole : opp.OpportunityContactRoles) {
                    if (oppConRole.Role == 'Producer') {
                        if (caseRec.Producer__c == null || caseRec.Producer__c == '')
                            caseRec.Producer__c = oppConRole.Contact.Name;
                        else
                            caseRec.Producer__c += ',' + oppConRole.Contact.Name;
                    }
                    if (oppConRole.Role == 'Consultant')
                        caseRec.Consultant__c = oppConRole.Contact.Name;
                }
            }
            if (taskMapping.Task__r.Case_Record_Type__c == 'Cede') {
                Account tempAcocuntRecord                    = getAccountRecord(opp.AccountId);
                caseRec.Ceded_From_ICL__c                    = tempAcocuntRecord.Ceded_From_ICL__c;
                caseRec.Ceded_To_ACL__c                      = tempAcocuntRecord.Ceded_To_ACL__c;

                if (tempAcocuntRecord.ShippingStreet != null)
                    caseRec.Ceded_Account_HQ_Address__c = tempAcocuntRecord.ShippingStreet;
                if (tempAcocuntRecord.ShippingCity != null) {
                    if (caseRec.Ceded_Account_HQ_Address__c == null)
                        caseRec.Ceded_Account_HQ_Address__c = tempAcocuntRecord.ShippingCity;
                    else
                        caseRec.Ceded_Account_HQ_Address__c += ',' + tempAcocuntRecord.ShippingCity;
                }
                if (tempAcocuntRecord.ShippingState != null ) {
                    if (caseRec.Ceded_Account_HQ_Address__c == null)
                        caseRec.Ceded_Account_HQ_Address__c = tempAcocuntRecord.ShippingState;
                    else
                        caseRec.Ceded_Account_HQ_Address__c += ',' + tempAcocuntRecord.ShippingState;
                }
                if (tempAcocuntRecord.ShippingPostalCode != null ) {
                    if (caseRec.Ceded_Account_HQ_Address__c == null)
                        caseRec.Ceded_Account_HQ_Address__c = tempAcocuntRecord.ShippingPostalCode;
                    else
                        caseRec.Ceded_Account_HQ_Address__c += '    ' + tempAcocuntRecord.ShippingPostalCode;
                }
                caseRec.Account_Owner__c                     = tempAcocuntRecord.OwnerId;
                system.debug('====================' + tempAcocuntRecord.RecordType.DeveloperName);
                caseRec.Account_Type__c                      = (tempAcocuntRecord.RecordType.DeveloperName == 'Group_Prospect_Account' ? 'Prospect' : (tempAcocuntRecord.RecordType.DeveloperName == 'Group_Account' ? 'Renewal' : ''));
                caseRec.OwnerId                              = UserInfo.getUserId();
                caseRec.Expected_Health_Contracts__c         = opp.Expected_Health_Contracts__c;
                caseRec.Expected_Health_Members__c           = opp.Expected_Health_Members__c;
                caseRec.Cede_Effective_Date__c               = opp.Requested_Effective_Date__c;
                caseRec.Cede_End_Date__c                     = opp.Rate_End_Date__c;
                for ( OpportunityContactRole oppConRole : opp.OpportunityContactRoles) {
                    if (oppConRole.Role == 'Decision Maker') {
                        caseRec.Decision_Maker__c           = oppConRole.ContactId;
                        break;
                    }
                }
                for ( Producer_Association_For_Opportunity__c prodAssOpp : opp.Producer_Association_For_Opportunity__r) {
                    if (prodAssOpp.Account_Record_Type__c == 'Producer Account' || prodAssOpp.Account_Record_Type__c == 'Consultant Account') {
                        caseRec.Producer_Account__c             = prodAssOpp.Producer_Consultant__c;
                        break;
                    }
                }
                system.debug('===========assig==' + caseRec.Producer_Account__c    );
            }


            //}


        } catch (Exception e) {
            System.debug( 'Exception : ' + e.getMessage() );
            CreateExceptionLog.insertErrorLog(e, null, null, null, 'Apex Class', 'Opportunity', null, 'OpportunityPlaybookController.Createcaserecord()', 'High');
        }
        return caseRec;
    }
    
    
    public Account getAccountRecord(String accId){
        return [select Active_Health_Subscribers__c,Labor__c,OwnerId,Active_Health_Members__c,Ceded_From_ICL__c,Ceded_To_ACL__c,
                Effective_Date__c,Cede_End_Date__c,RecordType.DeveloperName,Funding_Type__c,ShippingStreet,ShippingCity,ShippingState,ShippingPostalCode,Market_Segment__c from Account 
                where Id =:accId order By CreatedDate Desc limit 1][0];
    }
    
    public String getGroupStatus(){
        if(opp.Account.RecordType.DeveloperName == 'Group_Prospect_Account')
            return 'New Group';
        if(opp.Account.RecordType.DeveloperName == 'Group_Account')
            return 'Existing Group';
        return '';
    }
    
    public String getFundingType()
    {
        
        String funding_type ;
        try
        {
            for(Opportunity_Product__c op :[select id , Funding_type__c from Opportunity_Product__c where  Opportunity_Name__c=:oppId and Funding_type__c != null]){
                if(funding_type==null)
                {
                    funding_type= op.Funding_type__c;
                }else if(!funding_type.contains(op.Funding_type__c))
                {
                    funding_type= funding_type+';'+op.Funding_type__c;
                }
            }
        }catch(Exception e)
        {
            throw e;
        }
        return funding_type;
    }
    public String getPremiumType()
    {
        
        String premiumType  = '';
        try
        {
            for(Opportunity_Product__c op :[select id , Premium_Type__c from Opportunity_Product__c where  Opportunity_Name__c=:oppId and Premium_Type__c != null]){
                if(premiumType == '')
                {
                    premiumType= op.Premium_Type__c;
                }else if(!premiumType.contains(op.Premium_Type__c)){
                    premiumType= premiumType+';'+op.Premium_Type__c;
                }
            }
        }catch(Exception e){
            throw e;
        }
        return premiumType;
    }
   
    private void updateRelatedCases( List<Case> cases ) 
    {
        try
        {
        casesRelatedToOpportunity = getCasesRelatedToOpportunity();
        
        List<Case> relatedCases = new List<Case>();
        
        if( casesRelatedToOpportunity.containsKey( 'Proposal' ) && casesRelatedToOpportunity.containsKey( 'Network Information' ) ) {
            casesRelatedToOpportunity.get( 'Proposal' ).Related_Case__c             = casesRelatedToOpportunity.get( 'Network Information' ).Id;
            casesRelatedToOpportunity.get( 'Network Information' ).Related_Case__c  = casesRelatedToOpportunity.get( 'Proposal' ).Id; 
        
            relatedCases.add( casesRelatedToOpportunity.get( 'Proposal' ) );
            relatedCases.add( casesRelatedToOpportunity.get( 'Network Information' ) );
            relatedCases[0].Bypass_Validation__c = True;

            update relatedCases;            
        }
        
       }catch(Exception e)
       {
           System.debug( 'Exception : ' +e.getMessage() );
            CreateExceptionLog.insertErrorLog(e, null, null, null, 'Apex Class', 'Opportunity', null, 'OpportunityPlaybookController.Createcaserecord()','High'); 
       }                                                            
    }
    
    private void createCaseTeamMember( List<Case> cases )
     {
        List<CaseTeamMember> caseTeamMembers = new List<CaseTeamMember>();
        try
        { 
        Id requestorRoleId = getRequestorRoleId();
        if( requestorRoleId != null ) 
        {
            for( Case caseRec :cases ) 
            {
                CaseTeamMember ctm  = new CaseTeamMember();
                ctm.ParentId        = caseRec.Id;
                ctm.MemberId        = UserInfo.getUserId();
                ctm.TeamRoleId      = requestorRoleId; 
                caseTeamMembers.add( ctm );
            } 
            
            insert caseTeamMembers;
            
        }
        }catch(Exception e)
        {
            System.debug( 'Exception : ' +e.getMessage() );
            CreateExceptionLog.insertErrorLog(e, null, null, null, 'Apex Class', 'Opportunity', null, 'OpportunityPlaybookController.Createcaserecord()','High'); 
         }   
    }
    
    private Id getRequestorRoleId()
     {
        List<CaseTeamRole> caseTeamRoles = [    SELECT  Id 
                                                FROM    CaseTeamRole 
                                                where   Name = 'Requestor'
                                                limit   1 ];
        if( caseTeamRoles.size() > 0 ) 
        {
            return caseTeamRoles[0].Id;
        }
        return null;                                                
    }
    
    
    public PageReference editPlaybook()
     {
        
        showEdit = true;
        
        playbooks = [   select  Id, Name, Stage_Progression__c
                        from    Playbook__c
                        where   Active__c = true
                        limit   :Limits.getLimitQueryRows() - Limits.getQueryRows() ];
        
        return null;
    }

    public PageReference goToPlaybook() 
    {
        
        showEdit = false;
        
        return null;
    }
        
    public PageReference savePlaybookSelection() 
    {
        try 
        {
            if( selectedPlaybook != null && opp.Playbook__c != selectedPlaybook ) 
            {
                List<Stage_Mapping__c> stageMappings = [    select  Id
                                                            from    Stage_Mapping__c
                                                            where   Opportunity__c = :oppId
                                                            limit   :Limits.getLimitQueryRows() - Limits.getQueryRows() ];
                
                if( stageMappings.size() > 0 ) 
                {
                    delete stageMappings;
                } 
                
                opp = getOpportunityRecord();
                opp.Playbook__c = selectedPlaybook;
                update opp;
            }
            initPlaybook();
            goToPlaybook();
        } catch (Exception e) 
        {
            System.debug( 'Exception : ' +e.getMessage() );
            CreateExceptionLog.insertErrorLog(e, null, null, null, 'Apex Class', 'Opportunity', null, 'OpportunityPlaybookController.Createcaserecord()','High'); 
        }
        return null;
    }    
    
    
    
    /**    
    * @Description: Wrapper to define the Stage Mappings
    */  
    class CommonStageWrapper 
    {
        public Stage_Mapping__c stageMappingRec { get; set; }
        public List<LOBStageWrapper> lOBStages {set; get;}
    }
    
    /**    
    * @Description: Wrapper to define the Sub Stage Mappings
    */  
    class LOBStageWrapper 
    {
        public Substage_Mapping1__c subStageMappingRec { get; set; }
        public String lastModified {set; get;}
        public List<TaskWrapper> Tasks {set; get;}
    }

    /**    
    * @Description: Wrapper to define the Task Mappings
    */  
    class TaskWrapper 
    {
        public Task_Mapping__c taskMappingRec           { get; set; }
        public List<OpportunityTeamMember> taskOwners   { get; set; }
        
        public TaskWrapper() 
        {
            taskOwners = new List<OpportunityTeamMember>();
        }
    }
    
public Case getUnderwritingCaseRecord(){
    /*Schema.DescribeSObjectResult dsoResult = Case.sObjectType.getDescribe();
    Map<String,Schema.SObjectField> fieldMap = Schema.SObjectType.Case.fields.getMap();

    //build a list of all fieldnames for the object
    List<String> fieldList = getFieldList(fieldMap,false);*/
    list<String> fieldList = new list<String>();
    for (Dental_UW_Fields_PrePopulated__c item : Dental_UW_Fields_PrePopulated__c.getAll().values()) {
        fieldList.add(item.Case_FIeld_API_Name__c);
    }
    String fieldNames = getFieldNamesFromList(fieldList);
    RecordType rType = [SELECT id FROM RecordType where SobjectType = 'Case' and DeveloperName='Underwriting'];
    String q = 'select '+fieldNames+' from Case where RecordTypeId =\''+rType.Id+'\' and Opportunity_Name__c =\''+oppId+'\'';

                                     
    //guery using dynamic query
    
    list<Case> caseObjs = Database.query(q);
    if(caseObjs.size()>0)
        return caseObjs[0];
    return new Case();
    
}

public static List<String> getFieldList(

        Map<String,Schema.SObjectField> fieldMap, Boolean selectAllFields)

    {
        List<String> fieldList = new List<String>();
        
        //build dynamic list of fieldnames
        for (String fieldKey : fieldMap.keySet()) {
            Schema.SObjectField fsObj = fieldMap.get(fieldKey);
            Schema.DescribeFieldResult f = fsObj.getDescribe();
            String fieldName = f.getName();
            
            if (selectAllFields) {
                fieldList.add(fieldName);
            } else {
                if (f.getName()=='Id' || f.isNameField() || f.isCustom()) {
                    fieldList.add(fieldName);
                }
            }
        }
        
        return fieldList;
    }
    
    public static String getFieldNamesFromList(List<String> fieldList) {
        String fieldNames = 'Id';
        for (String field : fieldList) {
            if (fieldNames.length()>0) {
                fieldNames += ',';
            }
            fieldNames += field;
        }
        
        /*if (fieldNames.length()>10000) {
            throw new Exception('Fieldnames length > 10000 characters');
        }*/
        
        return fieldNames;
    }
    
    public Case createDentalUnderwriting(Case uCase,Case caseRec){
        
        
               
                for (Dental_UW_Fields_PrePopulated__c item : Dental_UW_Fields_PrePopulated__c.getAll().values()) {
                    caseRec.put(item.Case_FIeld_API_Name__c,uCase.get(item.Case_FIeld_API_Name__c));
                }
                
                
        return caseRec;
    }
    
}