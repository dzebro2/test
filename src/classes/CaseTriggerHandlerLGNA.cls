/**************************************************************************************
  Apex Class Name     : CaseTriggerHandlerLGNA
  Version             : 1.0
  Function            : This is a handler class for CaseTrigger. The methods in this class are used as utility methods for CaseTrigger
  Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Mayuri Bhadane           04/30/2015                Original Version
*************************************************************************************/
public with sharing class CaseTriggerHandlerLGNA { 
     Public static Integer CalloutProcessedCount =0 ;
     public static List<case> StaticCaseList = new List<case>();
     public static String CBSRInsertXML;
     public static String UserName;
     public static String Password;
     public static string Endpoint;
     public static boolean restrictExecution =false;
    
    
    public static void checkIfExecutionRestricted( List<Case> NewCasesList ) {
        for( Case caseRec :NewCasesList ) {
            if( caseRec.Status == 'Closed (Marked for Delete)' ) {
                restrictExecution = true;
            }
        }
    }
    
    
    /******************************************************************** 
    *    Method Name : Update
    Action
    *   @description :   This method checks updates Integration Action field of case.
    *   @parameters  :   List<Case> NewCaseList ,Map<id,Case> oldmap
    *   @return type :   none                     
    ***************************************************************/  
     
     public static void UpdateIntegrationAction(List<Case> NewCaseList ,Map<id,Case> oldmap){
         try{
             Id CBSRId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(system.label.Custom_Benefit_Service).getRecordTypeId();
             Id CBSR_IssueId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(system.label.CBSR_Issue).getRecordTypeId();
              User loggedinUser = ConstantsController.LoggedInUserInfo; 
            Map<String,Callout_Restricted_Users__c> mapUSerProfile  = Callout_Restricted_Users__c.getAll();   
            if(!mapUSerProfile.containskey(loggedinUser.profile.name)){
               for(Case newcase :NewCaseList){
                   if(oldmap ==null){ // Update Integration action for New cases
                       if((newcase.recordtypeId==CBSRId || newcase.recordtypeId == CBSR_IssueId) && newcase.External_Id__c==null ){
                          if(newcase.recordtypeId==CBSRId){
                              newcase.Integration_Action__c='Account Insert'; 
                          }else{                          
                             
                              newcase.Integration_Action__c='Issue Insert'; 
                          }                  
                       }               
                   }else{// Update Integration action for Updated cases
                       Case oldcase = oldmap.get(newcase.id);
                       if(newcase.recordtypeId==CBSRId || newcase.recordtypeId == CBSR_IssueId){                         
                        
                           if(newcase.status != oldcase.status && newcase.status == System.Label.Re_review && newcase.External_Id__c!=null){
                               newcase.Integration_Action__c=System.Label.Re_review;
                           }else if(newcase.status != oldcase.status && newcase.status==System.Label.Withdrawn && newcase.External_Id__c!=null){
                               newcase.Integration_Action__c=System.Label.Withdrawn;
                           }else if(newcase.status != oldcase.status && newcase.status == System.Label.Closed_Marked_for_Delete && newcase.External_Id__c!=null){
                               if(newcase.recordtypeId == CBSR_IssueId){
                                   newcase.Integration_Action__c='Issue Delete';
                               }
                           }else if(newcase.External_Id__c!=null){
                               if(newcase.recordtypeId == CBSR_IssueId){
                                   newcase.Integration_Action__c='Issue Update';
                               }
                               
                           }                                              
                       }
                   } 
               }
             }  
           }catch(Exception ex){
              
              CreateExceptionLog.insertErrorLog(ex,null,null ,null, 'UpdateIntegrationAction', 'Case', 'Caetrigger', 'CasetriggerhelperLGNA','High');
           }            
     
     }
     
     /*  validateCarrierHistoryValidation
    *   @description:   This method checks if the carrier history is covering the 24 months duration.
    *   @parameters     N/A
    *   @return type    none                    
    */ 
    
    public static void ValidateCarrierHistoryValidation(list<Case> newCases,map<Id,Case> oldCasesMap,map<Id,Case> newCasesMap){
        try{
            set<String> statusUpdatedUnderWritingCaseAccIds = new set<String>();
            map<String,Date> caseCarrierHistoryStartDate = new map<String,Date>();
            map<String,Date> caseCarrierHistoryEndDate = new map<String,Date>();
            map<String,Date> dentalUWCarrierHistoryStartDate = new map<String,Date>();
            map<String,Date> dentalUWCarrierHistoryEndDate = new map<String,Date>();
            
            for(Case caseObj : newCases){
                if((caseObj.RecordTypeId == Schema.SObjectType.Case.getRecordTypeInfosByName().get('Underwriting').getRecordTypeId() 
                    || caseObj.RecordTypeId == Schema.SObjectType.Case.getRecordTypeInfosByName().get('Dental Underwriting').getRecordTypeId()) && !caseObj.PUG__c && ConstantsController.shouldCarrierHistoryValidationFire){
                    if(caseObj.status != oldCasesMap.get(caseObj.Id).Status && caseObj.AccountId != null)
                        statusUpdatedUnderWritingCaseAccIds.add(caseObj.AccountId);
                }
            }
            //String competitorRelationShipRecordTypeId = Schema.SObjectType.Competitor_Relationship__c.getRecordTypeInfosByName().get('Carrier').getRecordTypeId();
            String competitorRelationShipRecordTypeId;
            
            
            
            if(statusUpdatedUnderWritingCaseAccIds.size()>0){
                for(RecordType rt : [select Id from RecordType where SobjectType = 'Competitor_Relationship__c' and DeveloperName = 'Carrier']){
                    competitorRelationShipRecordTypeId = rt.Id;
                }
                for(Competitor_Relationship__c ch : [select Rate_Effective_Date__c,Dental__c,Contract_End_Date__c,Group_Account__c from Competitor_Relationship__c where Group_Account__c In :statusUpdatedUnderWritingCaseAccIds and RecordTypeId =:competitorRelationShipRecordTypeId]){
                    if(!ch.Dental__c){
                        if(!caseCarrierHistoryStartDate.containsKey(ch.Group_Account__c))   
                            caseCarrierHistoryStartDate.put(ch.Group_Account__c,ch.Rate_Effective_Date__c);
                        else{
    
                            if(caseCarrierHistoryStartDate.get(ch.Group_Account__c) > ch.Rate_Effective_Date__c)
                                caseCarrierHistoryStartDate.put(ch.Group_Account__c,ch.Rate_Effective_Date__c);
                        }
                        if(!caseCarrierHistoryEndDate.containsKey(ch.Group_Account__c)) 
                            caseCarrierHistoryEndDate.put(ch.Group_Account__c,ch.Contract_End_Date__c);
                        else{
                            if(caseCarrierHistoryEndDate.get(ch.Group_Account__c) < ch.Contract_End_Date__c)
                                caseCarrierHistoryEndDate.put(ch.Group_Account__c,ch.Contract_End_Date__c);
                        }
                    }
                    else if(ch.Dental__c){
                        if(!dentalUWCarrierHistoryStartDate.containsKey(ch.Group_Account__c))   
                            dentalUWCarrierHistoryStartDate.put(ch.Group_Account__c,ch.Rate_Effective_Date__c);
                        else{
                            if(dentalUWCarrierHistoryStartDate.get(ch.Group_Account__c) > ch.Rate_Effective_Date__c)
                                dentalUWCarrierHistoryStartDate.put(ch.Group_Account__c,ch.Rate_Effective_Date__c);
                        }
                        if(!dentalUWCarrierHistoryEndDate.containsKey(ch.Group_Account__c)) 
                            dentalUWCarrierHistoryEndDate.put(ch.Group_Account__c,ch.Contract_End_Date__c);
                        else{
    
                            if(dentalUWCarrierHistoryEndDate.get(ch.Group_Account__c) < ch.Contract_End_Date__c)
                                dentalUWCarrierHistoryEndDate.put(ch.Group_Account__c,ch.Contract_End_Date__c);
                        }
                    }
                }
            
            /*for(Case caseObj : newCases){
                if(     caseObj.AccountId != null 
                    &&  caseObj.status != oldCasesMap.get(caseObj.Id).Status 
                    &&  caseObj.RecordTypeId == Schema.SObjectType.Case.getRecordTypeInfosByName().get('Underwriting').getRecordTypeId() 
                    &&  (   !caseCarrierHistoryStartDate.containsKey(caseObj.AccountId) 
                            ||  (   caseCarrierHistoryStartDate.containsKey(caseObj.AccountId) 
                                &&  (   caseCarrierHistoryStartDate.get(caseObj.AccountId)== null 
                                    ||  caseCarrierHistoryEndDate.get(caseObj.AccountId) == null 
                                    ||  caseCarrierHistoryStartDate.get(caseObj.AccountId).monthsBetween(caseCarrierHistoryEndDate.get(caseObj.AccountId)) < ( integer.valueOf(System.label.CarrierHistoryValidationMonths ) - 1 ) ) ) ) )
                    
                    caseObj.addError(System.label.UnderwritingCaseCarrierHistory);
            }*/
                for(Case caseObj : newCases){
    
                    if(caseObj.AccountId != null && caseObj.status != oldCasesMap.get(caseObj.Id).Status && !caseObj.PUG__c && ConstantsController.shouldCarrierHistoryValidationFire){
                        if(caseObj.RecordTypeId == Schema.SObjectType.Case.getRecordTypeInfosByName().get('Underwriting').getRecordTypeId() &&  (   !caseCarrierHistoryStartDate.containsKey(caseObj.AccountId) 
    
                                ||  (   caseCarrierHistoryStartDate.containsKey(caseObj.AccountId) 
                                    &&  (   caseCarrierHistoryStartDate.get(caseObj.AccountId)== null 
                                        ||  caseCarrierHistoryEndDate.get(caseObj.AccountId) == null 
                                        ||  caseCarrierHistoryStartDate.get(caseObj.AccountId).monthsBetween(caseCarrierHistoryEndDate.get(caseObj.AccountId)) < ( integer.valueOf(System.label.CarrierHistoryValidationMonths ) - 1 ) ) ) ) ){
                        
                            caseObj.addError(System.label.UnderwritingCaseCarrierHistory);
                        }
                        if(caseObj.RecordTypeId == Schema.SObjectType.Case.getRecordTypeInfosByName().get('Dental Underwriting').getRecordTypeId() &&   (   !dentalUWCarrierHistoryStartDate.containsKey(caseObj.AccountId) 
                                ||  (   dentalUWCarrierHistoryStartDate.containsKey(caseObj.AccountId) 
                                    &&  (   dentalUWCarrierHistoryStartDate.get(caseObj.AccountId)== null 
                                        ||  dentalUWCarrierHistoryEndDate.get(caseObj.AccountId) == null 
                                        ||  dentalUWCarrierHistoryStartDate.get(caseObj.AccountId).monthsBetween(dentalUWCarrierHistoryEndDate.get(caseObj.AccountId)) < ( integer.valueOf(System.label.CarrierHistoryValidationMonths ) - 1 ) ) ) ) ){
                        
                            caseObj.addError(System.label.UnderwritingCaseCarrierHistory);
                        }   
                    }
    
                }
            }
        }catch(Exception e){
            throw e;
        }
        
        
    }


     
 /******************************************************************** 
    * Method Name    : calloutHelperMethod
    *   @description :   This method checks updates Integration Action field of case.
    *   @parameters  :   List<Case> NewCaseList ,Map<id,Case> oldmap
    *   @return type :   none                     
    ***************************************************************/      
    public static void CalloutHelperMethod(List<case> CaseList ,String Event){
        
        
        String Body=''; 
        List<String> fieldAPInames = new List<String>();
        List<String> CBSRIssuefieldAPInames = new List<String>();
        Id CBSRId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(system.label.Custom_Benefit_Service).getRecordTypeId();
        Id CBSR_IssueId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(system.label.CBSR_Issue).getRecordTypeId();
        Set<id> UserIds = new Set<id>();
        Map<id ,String> userLanId = new Map<id ,String>();
        try{
      
         Map<String,Username_Password__c> mapUSerPass  = Username_Password__c.getAll();
        User loggedinUser = ConstantsController.LoggedInUserInfo;        
       
           Map<String,Callout_Restricted_Users__c> mapUSerProfile  = Callout_Restricted_Users__c.getAll();   
            if(!mapUSerProfile.containskey(loggedinUser.profile.name)){    
                for(String cs : mapUSerPass.keyset()){
                    if(mapUSerPass.get(cs).name == System.label.ModuleName){
                        UserName=mapUSerPass.get(cs).UserName__c;
                        Password=mapUSerPass.get(cs).Password__c;
                        Endpoint=mapUSerPass.get(cs).EndPoinUrl__c;
                    }    
                } 
                Map<String,Case_Callout_Fields__c> Case_Callout_Fields  = Case_Callout_Fields__c.getAll();
                
                //colect userids of case lastmodified by  and created by use
                for(Case caserec : CaseList){
                    UserIds.add(caserec.lastmodifiedbyid); 
                    UserIds.add(caserec.createdbyid);   
                }
                for(USer u: [select id ,Lan_ID__c,name from User where id in : UserIds]){
                    userLanId.put(u.id,u.Lan_ID__c);
                } 
                
                
                for(Case caserec : CaseList){
                    fieldAPInames.clear();
                    Body = null;
                    if(Event=='Insert' &&  (caserec.RecordTypeId== CBSR_IssueId || caserec.RecordTypeId== CBSRId) && caserec.status=='New' ){                    
                        for(String cs : Case_Callout_Fields.keyset()){ 
                            if(caserec.RecordTypeId== CBSRId && Case_Callout_Fields.get(cs).CBSR_Insert__c ){ 
                                fieldAPInames.add(Case_Callout_Fields.get(cs).API_Name__c); 
                            }else if(caserec.RecordTypeId== CBSR_IssueId && Case_Callout_Fields.get(cs).CBSR_Issue_Insert__c){
                                fieldAPInames.add(Case_Callout_Fields.get(cs).API_Name__c); 
                            }
                        } 
                    }
                    if(Event=='Update' &&  (caserec.RecordTypeId== CBSR_IssueId || caserec.RecordTypeId== CBSRId) ){     
                        if(caserec.RecordTypeId== CBSRId && caserec.status=='New'){
                            for(String cs : Case_Callout_Fields.keyset()){ 
                               if( Case_Callout_Fields.get(cs).CBSR_Insert__c ){ 
                                    fieldAPInames.add(Case_Callout_Fields.get(cs).API_Name__c); 
                                }
                            }
                        }
                        if(caserec.RecordTypeId== CBSR_IssueId  && caserec.status=='New' && caserec.External_Id__c==null){
                            for(String cs : Case_Callout_Fields.keyset()){ 
                               if( Case_Callout_Fields.get(cs).CBSR_Issue_Insert__c ){ 
                                    fieldAPInames.add(Case_Callout_Fields.get(cs).API_Name__c); 
                                }
                            }
                        }else if(caserec.RecordTypeId== CBSR_IssueId  && caserec.status=='Closed (Marked for Delete)'){
                            for(String cs : Case_Callout_Fields.keyset()){ 
                               if( Case_Callout_Fields.get(cs).CBSR_Delete__c ){ 
                                    fieldAPInames.add(Case_Callout_Fields.get(cs).API_Name__c); 
                                }
                            }
                        }else if(caserec.RecordTypeId== CBSR_IssueId && caserec.External_Id__c!=null ){
                            for(String cs : Case_Callout_Fields.keyset()){ 
                               if( Case_Callout_Fields.get(cs).CBSR_Issue_Update__c){ 
                                    fieldAPInames.add(Case_Callout_Fields.get(cs).API_Name__c); 
                                }
                            }
                        }
                    }
                    if(Event=='Update' && caserec.RecordTypeId== CBSRId && ( (caserec.status=='Submitted' && caserec.integration_status__C!='Success'))) { //caserec.status!='Submitted' ||
                        for(String cs : Case_Callout_Fields.keyset()){ 
                           if( Case_Callout_Fields.get(cs).CBSR_Button__c){ 
                                fieldAPInames.add(Case_Callout_Fields.get(cs).API_Name__c); 
                            }
                        } 
                    }
                      
                  
                  if(fieldAPInames.size()>0)
                      Body = CreateCalloutBody( fieldAPInames ,caserec ,  userLanId) ; 
                  
                  system.debug('body*****'+Body);
                    if((Body!=null && Body!='') && !Test.isRunningTest() && ConstantsController.shouldCBSRCalloutProcess){
                        CalloutHelperclass.SendCalloutsToCBSR(Body ,UserName ,Password ,Endpoint); 
                        ConstantsController.shouldCBSRCalloutProcess = false;
                    }
                }
            }
              
        }catch(Exception ex){
          CreateExceptionLog.insertErrorLog(ex,null,null ,null, 'calloutHelperMethod', 'Case', 'Caetrigger', 'CasetriggerhelperLGNA','High');
        }    
    }
    
      /******************************************************************** 
    *    Method Name :    changeIntegrationAction
    *   @description :   This method  updates Integration Action field of case.
    *   @parameters  :   List<Case> NewCaseList ,Map<id,Case> oldmap
    *   @return type :   none                     
    ***************************************************************/   
    public static void ChangeIntegrationAction(List<case> CaseList ,String Event){
        try{
            if( ConstantsController.changeIntegrationAction ) {
                Id CBSRId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(system.label.Custom_Benefit_Service).getRecordTypeId();
                Id CBSR_IssueId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(system.label.CBSR_Issue).getRecordTypeId();
                //User loggedinUser = [select id , profile.name from user where id =: Userinfo.getUserId() limit 1]; 
                User loggedinUser = ConstantsController.LoggedInUserInfo;
                Map<String,Callout_Restricted_Users__c> mapUSerProfile  = Callout_Restricted_Users__c.getAll();   
                    if(!mapUSerProfile.containskey(loggedinUser.profile.name)){   
                        
                        for(Case caserec : CaseList){
                       
                            if( (Event=='Insert' || Event=='Update'))
                            if(Event=='Insert' &&  (caserec.RecordTypeId== CBSR_IssueId || caserec.RecordTypeId== CBSRId) && caserec.status=='New'){
                                caserec.time_sent__c = system.now();
                                caserec.integration_status__C = 'Sent';
                            }else  if(Event=='Update' &&   caserec.RecordTypeId== CBSRId && caserec.status=='New'){
                                caserec.time_sent__c = system.now();
                                caserec.integration_status__C = 'Sent';
                            }else  if(Event=='Update' &&   caserec.RecordTypeId== CBSR_IssueId ){
                                caserec.time_sent__c = system.now();
                                caserec.integration_status__C = 'Sent';
                            }
                        }
                    }
            }
            ConstantsController.changeIntegrationAction = false ;
        }catch(Exception e){
            throw e;
        }
    }
      
      /******************************************************************** 
    *    Method Name :   CreateCalloutBody
    *   @description :   This method  updates Integration Action field of case.
    *   @parameters  :   List<String> fieldAPInames ,Case caserec , Map<id,String> userLanId
    *   @return type :   none                     
    ***************************************************************/   
   

     public static String CreateCalloutBody(List<String> fieldAPInames ,Case caserec , Map<id,String> userLanId){
         String body;
         try{
         body='<sObject xsi:type="sf:Case" xmlns:sf="urn:sobject.enterprise.soap.sforce.com">' ;
          for(String api : fieldAPInames){
             if(api=='LastModifiedBy_LanID__c'){                         
                 Body=Body+ '<sf:'+ api +'>'+( (userLanId.get(caserec.LastModifiedByid) != null) ? ((String)userLanId.get(caserec.LastModifiedByid)).escapeXml():'')+'</sf:'+ api +'>';
             }else if(api=='CreatedBy_LanID__c'){
                 Body=Body+ '<sf:'+ api +'>'+( (userLanId.get(caserec.CreatedByid) != null) ? ((String)userLanId.get(caserec.CreatedByid)).escapeXml():'')  +'</sf:'+ api +'>';
             }else if(api=='External_ID__c' && caserec.get(api) != null && ((String)caserec.get(api)).contains('-'+caserec.casenumber)){
                 Body=Body+ '<sf:'+ api +'>'+((String)caserec.get(api)).substringBefore('-'+caserec.casenumber)  +'</sf:'+ api +'>';
             }else{
                 if(caserec.get(api)!=null && (caserec.get(api) instanceof String )  )
                      Body=Body+ '<sf:'+ api +'>'+ ((String)caserec.get(api)).escapeXml()   +'</sf:'+ api +'>';
                else if(caserec.get(api)==null )
                     Body=Body+ '<sf:'+ api +'>'+ '' +'</sf:'+ api +'>';
                else
                     Body=Body+ '<sf:'+ api +'>'+  caserec.get(api)  +'</sf:'+ api +'>';
             }
          } 
           Body=Body+'</sObject>';
          return  Body;   
         }catch(Exception ex){
          CreateExceptionLog.insertErrorLog(ex,null,null ,null, 'calloutHelperMethod', 'Case', 'Caetrigger', 'CasetriggerhelperLGNA.CreateCalloutBody','High');
          return null;
         }
     }
     
     /******************************************************************** 
    *    Method Name :   DeleteCasesWithCloseMArkedStatus
    *   @description :   This method  deletes CBSR issue cases with status = 'Closed (Marked for Delete)' and integration as success
    *   @parameters  :   List<Case> updatedCases
    *   @return type :   none                     
    ***************************************************************/   
  public static void  DeleteCasesWithCloseMArkedStatus(List<Case> updatedCases){
      List<Case> deletecaselist = new List<Case>();
      Set<id> caseIds = new Set<id>();
      Id CBSR_IssueId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(system.label.CBSR_Issue).getRecordTypeId();
      for(case c :updatedCases){
          if(c.RecordTypeId== CBSR_IssueId  && c.status=='Closed (Marked for Delete)' && c.integration_status__C == 'Success'){
              caseIds.add(c.id);    
          }      
      }
      try{
          if(caseIds.size()>0){
              deletecaselist = [select id from case where id in :caseIds];
              if(deletecaselist.size()>0){
                  delete deletecaselist;
              }
          }
      }catch(Exception e){
        throw e;
      }
  
  }
  
   
     /******************************************************************** 
    *    Method Name :   AppendExternalIdWithCaseNumber
    *   @description :   This method  appends case numbe to external id n order to identify unique header and issue
    *   @parameters  :   List<Case> updatedCases , Map<id,case> OldMAp
    *   @return type :   none                     
    ***************************************************************/   
  public static void  AppendExternalIdWithCaseNumber(List<Case> updatedCases , Map<id,case> OldMAp){
    Id CBSRId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(system.label.Custom_Benefit_Service).getRecordTypeId();
      for(Case updateCase : updatedCases){
          
          if(updateCase.External_Id__C!=null && updateCase.External_Id__C != OldMAp.get(updateCase.id).External_Id__C && updateCase.recordtypeid == CBSRId ){
              updateCase.External_Id__C = updateCase.External_Id__C +'-'+ updateCase.CaseNumber ;
          }
      }  
  
  }
    
   /******************************************************************** 
    *    Method Name :   CascadeDeleteDetailsTrigger
    *   @description :   This method  invokes delete methods of attachment and casecomment
    *   @parameters  :   List<Case> DeleteCaseList
    *   @return type :   none                     
    ***************************************************************/   
  public static void  CascadeDeleteDetailsTrigger(List<Case> DeleteCaseList){
      Set<id> caseIds = new Set<id>();
      Id CBSR_IssueId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(system.label.CBSR_Issue).getRecordTypeId();
      for(case c : DeleteCaseList){
          if(c.RecordTypeId== CBSR_IssueId ){
              caseIds.add(c.id);    
          }
      }
      if(caseIds.size()>0){
          List<Attachment> attlist = [select id , body,parentId from Attachment where parentId = :caseIds limit: Limits.getLimitQueryRows() - Limits.getQueryRows() ];
              AtttachmentHandler.DeleteIntegrationActionObject(attlist);  
          
          List<CaseComment> casecommList = [select id , parentId from CaseComment where parentId = :caseIds  limit: Limits.getLimitQueryRows() - Limits.getQueryRows()] ; 
             CaseCommentTriggerHandlerLGNA.DeleteIntegrationActionObject(casecommList);   
      }
  }
  
  
  /******************************************************************** 
    *    Method Name :   SendChatterNotifications
    *   @description :   This method  will post chatter on Opportunity owner and Opportunity Team members when the case is closed/Declined
    *   @parameters  :   map<Id,Case> newCasesMap,map<Id,Case> oldCasesMap
    *   @return type :   none                     
    ***************************************************************/   
  public static void  SendChatterNotifications( Map<Id,Case> newCasesMap, Map<Id,Case> oldCasesMap ) {
    try {
        set<String> opportunityIds              = new set<String>();
        list<Case> updatedcases                 = new list<Case>();
        set<String> permissibleCaseRecordTypeIds    = new set<String>();
        set<String> userIds                     = new set<String>();
        list<FeedItem> feedItems                    = new list<FeedItem>();
        for(RecordType rt : [   select  Id 
                                from    RecordType 
                                where   SobjectType= 'Case' 
                                    and ( DeveloperName In :ConstantsController.caseRecordTypePermissibleWhenCaseUpdatedChatter )
                                limit: Limits.getLimitQueryRows() - Limits.getQueryRows() ] ) {
            permissibleCaseRecordTypeIds.add( rt.Id );
        }
        
        for( Case caseRec : newCasesMap.values() ) {
            if( ( ( oldCasesMap != null && oldCasesMap.containsKey( caseRec.Id ) && oldCasesMap.get( caseRec.Id ).Status != caseRec.Status ) 
                || ( oldCasesMap == null || !oldCasesMap.containsKey( caseRec.Id ) ) )
                && ( constantsController.CaseStatusConsideredForChatterPost.contains( caseRec.Status ) )
                && permissibleCaseRecordTypeIds.contains( caseRec.recordTypeId ) && ConstantsController.shouldCaseTriggerProcess ) {
                
                opportunityIds.add(caseRec.Opportunity_Name__c);    
                updatedcases.add(caseRec);
                ConstantsController.shouldCaseTriggerProcess = false;
            }
        }
        Map<Id,Opportunity> opportunityMap = new Map<Id,Opportunity>( [ select  Id, OwnerId, Name, 
                                                                                ( Select userId from OpportunityTeamMembers ) 
                                                                        from    Opportunity 
                                                                        where   Id In :opportunityIds
                                                                        limit:  Limits.getLimitQueryRows() - Limits.getQueryRows() ] );
        for( Case caseRec : updatedcases ){
            if( opportunityMap.containsKey( caseRec.Opportunity_Name__c ) ) {
                Opportunity opp                     = opportunityMap.get( caseRec.Opportunity_Name__c );
                userIds                             = new set<String>();
                userIds.add( opp.OwnerId ); 
                
                for(OpportunityTeamMember otm : opp.OpportunityTeamMembers){
                    userIds.add( otm.userId );
                }
                
                string caseLinkId                   = URL.getSalesforceBaseUrl().toExternalForm()+ '/' + caseRec.Id;
                string caseTitle                    = caseRec.CaseNumber;
                string chatterMessage               = Label.CaseUpdatePostChatterToOpportunityOwner.replace('<<CaseNumber>>',caseRec.CaseNumber).replace('<<OpportunityName>>',opp.Name).replace('<<CaseStatus>>',caseRec.status);
                feedItems.addAll(ConstantsController.sendChattertoTeams( userIds, chatterMessage, caseLinkId, caseTitle ) );
            }
          }
          
          if( feedItems.size() > 0 ) {
                insert feedItems;
          }
      } catch( Exception e ) {
          CreateExceptionLog.insertErrorLog(e,null,null ,null, 'SendChatterNotifications', 'Case', 'Caetrigger', 'CasetriggerhelperLGNA.SendChatterNotifications','High');
         
      }
  }
  
  public static void updateUnderwritingDueDates(list<Case> newCases,map<Id,Case> oldCasesMap){
        set<String> recordTypeIds   = new set<String>();
        Integer workingHours; 
        boolean processForward = false;
        for(Case tempCase : newCases){
            if(oldCasesMap.get(tempCase.Id).Date_Assigned_to_Underwriting__c == null && tempCase.Date_Assigned_to_Underwriting__c != null)
                processForward = true;
        }
        if(processForward){
            for(RecordType rt : [select DeveloperName from RecordType where SobjectType= 'Case' ]){
                if(rt.DeveloperName == 'Dental_Underwriting' || rt.DeveloperName == 'Underwriting'){
                    recordTypeIds.add(rt.Id);
                }
            }
            BusinessHours defaultBusinessHours;
            
            /*BusinessHours defaultBusinessHours = [    SELECT  IsActive, Id 
                                                    FROM    BusinessHours 
                                                    where   IsActive= true 
                                                        and IsDefault = true 
                                                    limit   1 ];    
            List<LGNA_Constants__c> lgnaConstants = [   select  Total_Working_Hours_per_Day__c
                                                        from    LGNA_Constants__c
                                                        limit   1 ];*/
            
            if(ConstantsController.defaultBusinessHours.IsActive && ConstantsController.defaultBusinessHours.IsDefault)
                defaultBusinessHours = ConstantsController.defaultBusinessHours;
            
            
            /*if( lgnaConstants.size() > 0 ) {
                workingHours = ( Integer )lgnaConstants[0].Total_Working_Hours_per_Day__c;
            }                                       
            else {
                workingHours = 9;
            }*/
            LGNA_Constants__c constants;
            for(LGNA_Constants__c temp : LGNA_Constants__c.getAll().values()){
                if(temp.name == 'Default'){
                    constants = temp;
                    workingHours = ( Integer )temp.Total_Working_Hours_per_Day__c;
                }
            }
            if(constants == null){
                constants = new LGNA_Constants__c(UW_Due_Date_PrePop_Bigger_Interval__c = 8,UW_Due_Date_PrePop_Smaller_Interval__c = 5);
                workingHours = 9;
            }
            for(Case tempCase : newCases){
                if(recordTypeIds.contains(tempCase.RecordTypeId) && tempCase.HCSC_Division__c != 'IL' 
                    && tempCase.Underwriting_Due_Date__c == null 
                    &&(oldCasesMap.get(tempCase.Id).Date_Assigned_to_Underwriting__c == null && tempCase.Date_Assigned_to_Underwriting__c != null) && tempCase.Funding_Type_Multiselect__c != null){
                    DateTime tempDate;
                    if(tempCase.HCSC_Division__c == 'TX' || tempCase.HCSC_Division__c == 'MT' || 
                        tempCase.HCSC_Division__c == 'OK'  ||tempCase.HCSC_Division__c == 'NM' ){
                        /*if(tempCase.Premium_Type__c != null && tempCase.Premium_Type__c.contains('PP') && tempCase.Funding_Type_Multiselect__c != null && tempCase.Funding_Type_Multiselect__c.contains('Prem')){
                            integer nextInterval                = (tempCase.Is_this_a_Formal_Bid__c ? 8 : 5);
                            tempDate                            = LGNAUtilityClass.getNextBuisnessDate(defaultBusinessHours.Id,date.valueOf(tempCase.Date_Assigned_to_Underwriting__c),nextInterval,workingHours);
                            
                            
                        }
                        else if(tempCase.Premium_Type__c == null || !tempCase.Premium_Type__c.contains('PP') || tempCase.Funding_Type_Multiselect__c == null || !tempCase.Funding_Type_Multiselect__c.contains('Prem')){
                            integer nextInterval                = 8;
                            tempDate                            = LGNAUtilityClass.getNextBuisnessDate(defaultBusinessHours.Id,date.valueOf(tempCase.Date_Assigned_to_Underwriting__c),nextInterval,workingHours);
                        }*/
                        if(tempCase.Funding_Type_Multiselect__c.contains('Prem') && tempCase.Funding_Type_Multiselect__c.split(';').size() == 1){
                            integer nextInterval                = (tempCase.Is_this_a_Formal_Bid__c ? integer.valueof(constants.UW_Due_Date_PrePop_Bigger_Interval__c) : integer.valueOf(constants.UW_Due_Date_PrePop_Smaller_Interval__c));
                            tempDate                            = LGNAUtilityClass.getNextBuisnessDate(defaultBusinessHours.Id,DateTime.newInstance(Date.valueOf(tempCase.Date_Assigned_to_Underwriting__c),Time.newInstance(0,0,0,0)),nextInterval,workingHours);
                        }
                        else if((tempCase.Funding_Type_Multiselect__c.contains('Prem') && tempCase.Funding_Type_Multiselect__c.split(';').size() > 1) || (!tempCase.Funding_Type_Multiselect__c.contains('Prem'))){
                            integer nextInterval                = integer.valueof(constants.UW_Due_Date_PrePop_Bigger_Interval__c);
                            tempDate                            = LGNAUtilityClass.getNextBuisnessDate(defaultBusinessHours.Id,DateTime.newInstance(Date.valueOf(tempCase.Date_Assigned_to_Underwriting__c),Time.newInstance(0,0,0,0)),nextInterval,workingHours);
                        
                        }   
                        
                    }
                    else{
                        tempDate                                = tempCase.Date_Assigned_to_Underwriting__c;
                    }
                    tempCase.Underwriting_Due_Date__c   = date.valueOf((tempDate<= tempCase.Proposal_Due_Date__c ? tempCase.Proposal_Due_Date__c : tempDate));
                }
            }
        }
  }
  public static void validateOwnerChange(list<Case> newCases,map<Id,Case> oldCaseMap){
        map<String,String> ownerProfileName = new map<String,string>();
        map<String,String> ownerQueueName   = new map<String,string>();
        
        ownerProfileName.put(UserInfo.getUserId(),'');
        set<string> allowedCaseRecordTypes = new set<String>();
        for(RecordType rt : [select Id,DeveloperName from RecordType where SobjectType = 'Case']){
            if(rt.developerName == 'Dental_Underwriting' || rt.developerName == 'Underwriting' )
                allowedCaseRecordTypes.add(rt.Id);
        }
        for(Case tempCase : newCases){
            if(oldCaseMap.get(tempCase.Id).OwnerId != tempCase.OwnerId && tempCase.Status  != 'Assigned' && allowedCaseRecordTypes.contains(tempCase.RecordTypeId)){
                ownerProfileName.put(oldCaseMap.get(tempCase.Id).OwnerId,'');
                ownerProfileName.put(tempCase.OwnerId,'');
            }
        }
        for(User u : [select Profile.Name,Id from User where Id In :ownerProfileName.keySet()]){
            ownerProfileName.put(u.Id,u.Profile.Name);
        }
        for(Group gp  : ConstantsController.groups){
            if(ownerProfileName.containsKey(gp.Id))
                ownerProfileName.put(gp.Id,gp.DeveloperName);
        }
        
        for(Case tempCase : newCases){
            if(oldCaseMap.get(tempCase.Id).OwnerId != tempCase.OwnerId && allowedCaseRecordTypes.contains(tempCase.RecordTypeId) && tempCase.Status  != 'Assigned' && ownerProfileName.get(UserInfo.getUserId()) != 'Underwriting' && ownerProfileName.containsKey(oldCaseMap.get(tempCase.Id).OwnerId) && ownerProfileName.containsKey(tempCase.OwnerId)){
                if(!((ownerProfileName.get(oldCaseMap.get(tempCase.Id).OwnerId) == ownerProfileName.get(tempCase.OwnerId) ) || 
                    (ownerProfileName.get(oldCaseMap.get(tempCase.Id).OwnerId) != ownerProfileName.get(tempCase.OwnerId)  &&
                    (ownerProfileName.get(oldCaseMap.get(tempCase.Id).OwnerId) == 'Underwriting_5_000_25_000' || 
                    ownerProfileName.get(oldCaseMap.get(tempCase.Id).OwnerId) == 'Underwriting_IL_LG_151_5_000' || 
                    ownerProfileName.get(oldCaseMap.get(tempCase.Id).OwnerId) == 'Underwriting_IL_NA_151_5_000' || 
                    ownerProfileName.get(oldCaseMap.get(tempCase.Id).OwnerId) == 'Underwriting_25_000_Exchange_Only_RFP' || 
                    ownerProfileName.get(oldCaseMap.get(tempCase.Id).OwnerId) == 'Dental_Underwriting' || 
                    ownerProfileName.get(oldCaseMap.get(tempCase.Id).OwnerId) == 'Underwriting' ))) &&
                    (ownerProfileName.get(tempCase.OwnerId) == 'Underwriting_5_000_25_000' || 
                    ownerProfileName.get(tempCase.OwnerId) == 'Underwriting_IL_LG_151_5_000' || 
                    ownerProfileName.get(tempCase.OwnerId) == 'Underwriting_IL_NA_151_5_000' || 
                    ownerProfileName.get(tempCase.OwnerId) == 'Underwriting_25_000_Exchange_Only_RFP' || 
                    ownerProfileName.get(tempCase.OwnerId) == 'Dental_Underwriting' || 
                    ownerProfileName.get(tempCase.OwnerId) == 'Underwriting' )){
                    tempCase.addError(Label.Case_Owner_Change_Validation);
                }
                
            }
        }
  }
 
}