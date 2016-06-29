/**************************************************************************************
  Apex Class Name     : CaseCommentTriggerHandlerLGNA
  Version             : 1.0
  Function            : This is a handler class for CaseTrigger. The methods in this class are used as utility methods for CaseTrigger
  Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Mayuri Bhadane           04/30/2015                Original Version
*************************************************************************************/
public with sharing class CaseCommentTriggerHandlerLGNA { 
     
    /******************************************************************** 
    * Method Name : UpdateIntegrationActionObject
    *   @description :   This method upserts Integration status Object.
    *   @parameters  :   N/A
    *   @return type :   none                     
    ***************************************************************/
    public static void UpdateIntegrationActionObject(List<CaseComment> NewCaseCommentList ){
               
       Map<id,CaseComment>          caseCommentMap        = new Map<id,CaseComment>();
       List<Integration_Status__c>  IntegrationStatusList = new List<Integration_Status__c>();
       Set<id>                      caseIds               = new Set<id>();
       Map<id,case>                 caseMap; 
       Integration_Status__c       newIntegrationStatus ;  
       try{
           for(CaseComment newCc : NewCaseCommentList){             
                caseIds.add(newCc.parentid);
           }
           caseMap =  GetCBSRCaseRecord(caseIds);   
           
           if(caseMap.size()>0){
               for(CaseComment casecomm: NewCaseCommentList){
                   if(caseMap.containskey(casecomm.parentid)){
                     newIntegrationStatus = new Integration_Status__c();
                     newIntegrationStatus.ObjectID__c             =   casecomm.id;
                     newIntegrationStatus.ObjectType__c           =   'CaseComment';                    
                     newIntegrationStatus.Case_Comments__c        =   casecomm.CommentBody;
                     newIntegrationStatus.Integration_Action__c   =   System.label.Note_Insert;
                     newIntegrationStatus.Parent_External_ID__c   =   caseMap.get(casecomm.parentid).External_Id__c;
                     newIntegrationStatus.Parent_Object_ID__c     =   casecomm.parentid; 
                     IntegrationStatusList.add(newIntegrationStatus);
                   }  
               }  
           }  
           if(IntegrationStatusList.size()>0){
               List<Database.SaveResult> sr = Database.Insert(IntegrationStatusList,false);   
           }    
       }catch(Exception e){
           CreateExceptionLog.insertErrorLog(e, null, null, null, 'Apex Class','CaseComment' , null, 'CaseCommentTriggerHandlerLGNA.UpdateIntegrationActionObject()','High'); 
       }
    }  
 
  
  /******************************************************************** 
    * Method Name    : GetCBSRcaseRecord
    *   @description : This method colects CBSR case records in map.
    *   @parameters  : set<ids> caseIds
    *   @return type : Map<id,Case>                     
    ***************************************************************/
    public static Map<id,Case> GetCBSRCaseRecord(set<id> caseIds ){ 
         Map<id,case> caseIdRecMap = new Map<id,case>();
         try{  
            for(Case caserec: [select id,External_Id__c,recordtypeid,recordtype.name from case where id in : caseIds Limit :Limits.getLimitQueryRows() - Limits.getQueryRows()]){
                if(caserec.recordtype.name==system.label.Custom_Benefit_Service || caserec.recordtype.name==system.label.CBSR_Issue){
                   caseIdRecMap.put(caserec.id,caserec);
                }            
            }
         }catch(Exception e){
             CreateExceptionLog.insertErrorLog(e, null, null, null, 'Apex Class','CaseComment' , null, 'CaseCommentTriggerHandlerLGNA.GetCBSRCaseRecord()','High'); 
         } 
       return caseIdRecMap;       
    }     
    /******************************************************************** 
    * Method Name    : ValidateCaseCommnetInsert
    *   @description : This method validates case comment insertion.
    *   @parameters  : set<ids> caseIds
    *   @return type : Map<id,Case>                     
    ***************************************************************/
    public static void ValidateCaseCommnetInsert(List<CaseComment> NewCaseCommentList){    
        
        Set<id>                      caseIds               = new Set<id>();
       Map<id,case>                 caseMap; 
       
       try{
           for(CaseComment newCc : NewCaseCommentList){             
                caseIds.add(newCc.parentid);
           }
           caseMap =  GetCBSRCaseRecord(caseIds); 
           
           if(caseMap.size()>0){
               for(CaseComment casecomm: NewCaseCommentList){
                   if(caseMap.containskey(casecomm.parentid)){
                       if(caseMap.get(casecomm.parentid).recordtype.name==system.label.CBSR_Issue && (caseMap.get(casecomm.parentid).External_Id__c == null || caseMap.get(casecomm.parentid).External_Id__c == '')  ){
                           casecomm.adderror(system.Label.Case_Comment_Insert_Validation_Error);
                       }
                   }
               }
           }     
       }catch(Exception e){
           CreateExceptionLog.insertErrorLog(e, null, null, null, 'Apex Class','CaseComment' , null, 'CaseCommentTriggerHandlerLGNA.ValidateCaseCommnetInsert()','High'); 
       } 
    }        

    
    
      /******************************************************************** 
    * Method Name    : DeleteIntegrationActionObject
    *   @description : Insert record in integration status if attachment is deleted
    *   @parameters  : List<Attachment> AttachmentList
    *   @return type : void                    
    ***************************************************************/
    public static void DeleteIntegrationActionObject(List<CaseComment> CaseCommentList ){
        Set<id> caseCommentIds = new Set<id>();
        try{
            List<Integration_Status__c> intUpdateList = new List<Integration_Status__c>();
            Set<id>                      caseIds               = new Set<id>();
            Map<id,case>                 caseMap; 
           
            for(CaseComment newCc : CaseCommentList ){             
                caseIds.add(newCc.parentid);
            }
            caseMap =  GetCBSRCaseRecord(caseIds);   
           
            if(caseMap.size()>0){
               for(CaseComment oldCc : CaseCommentList){ 
                   if(caseMap.containskey(oldCc.parentid)){
                       caseCommentIds.add(oldCc.id);
                   }    
               }
            }
            for(Integration_Status__c intStatus : [Select ID, ObjectID__c, Integration_Action__c from Integration_Status__c where ObjectID__c in :caseCommentIds])
            {
                intStatus.Integration_Action__c='Delete';
                intStatus.Integration_Status__c   =   'Sent';
                intStatus.Time_Sent__c   =   system.Now();
                intUpdateList.add(intStatus);
            }
            
            Update intUpdateList;   
        }catch(Exception ex){
            CreateExceptionLog.insertErrorLog(ex, null, null, null, 'Apex Class', 'CaseComment', 'CaseCommentTriggerHandlerLGNA', 'CaseCommentTriggerHandlerLGNA.DeleteIntegrationActionObject()','High'); 
        }     
    }    

}