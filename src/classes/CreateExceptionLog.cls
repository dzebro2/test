//************************************************************************************
// Name             : CreateExceptionLog.cls
// Description      : This class will capture unhandled exceptions.
// Created By       : Sumedh Ambokar
// Created Date     : 5/20/2015
// 
// ************************Version Updates********************************************
// Date             Developer           Description
// -----------------------------------------------------------------------------------
// ************************************************************************************
public without sharing class CreateExceptionLog
{   


    // **************************************************************************************************************
    // Name       :   insertErrorLog
    // Description:   Method to capture error Log details
    // Parameters :   Exception ex, Database.SaveResult[] lsr,List<SObject> records,String origin, String objName, String truggername,
    //                className 
    // Returns    :   void
    // **************************************************************************************************************
    public static void insertErrorLog(Exception ex, Database.SaveResult[] sr,Database.DeleteResult[] dr,List<SObject> records,String origin, String objName,String triggerName,String className, String severity){
       // if(test.isRunningTest()){return;}
        // Records failed due to exception
        if(ex != null){            
            // Instantiate and populate the Error Log instance.
            Error_Log__c errorLog = new Error_Log__c();

            errorLog.Origin__c = origin;
            errorLog.SObject_Name__c = objName;
            // Capture Exception details like description , cause and Line #
            if(ex.getStackTraceString()!=null){
               errorLog.Error_Message__c = ex.getStackTraceString();
            }
            If((ex.getMessage()!=null || ex.getCause()!=null) && (errorLog.Error_Message__c!=null || errorLog.Error_Message__c!='' )){
                errorLog.Error_Message__c = Label.Err_Exp + ex.getMessage()+ Label.Err_CauseBy+ ex.getCause();
            }
            if(ex.getLineNumber()!=null){
                errorLog.Line_Number__c= Label.Err_Lime +ex.getLineNumber();
            }else{
                errorLog.Line_Number__c ='';
            }
            if(severity!= null){
                errorLog.Error_Severity__c = severity;
            }
            if(triggerName!= null){
                errorLog.Trigger__c = triggerName;
            }
            if(className!=null){
                errorLog.Class__c = className;
            } 
            if(errorLog != null){
                // Insert the exception in Error Log.
                List<Error_Log__c> errorLogs = new List<Error_Log__c>();
                errorLogs.add(errorLog);
                Database.SaveResult[] res = Database.insert(errorLogs,false);

            }                       
        }

        // Records failed due to record insert fail 
        else if(sr != null){

            // Instantiate and populate the Error Log List.
            List<Error_Log__c> errorList = new List<Error_Log__c>();


            for(Integer i = 0; i < sr.size(); i++){
                string errormsg;
                Database.SaveResult result = sr[i]; 
                for(Database.Error err : result.getErrors()) {
                System.debug('The following error has occurred.');                    
                System.debug(err.getStatusCode() + ': ' + err.getMessage());
                System.debug('Account fields that affected this error: ' + err.getFields());
                errormsg = err.getMessage();
                }
                // Capture the exception if any record failed in List.  
                if(!result.isSuccess() ){                    
                    Error_Log__c errorLog = new Error_Log__c();

                    errorLog.Origin__c = origin;

                    if(severity!= null)
                        errorLog.Error_Severity__c = severity;
                    errorLog.SObject_Name__c = objName;
                    if(triggerName!= null)
                        errorLog.Trigger__c = triggerName;
                    if(className!=null)
                        errorLog.Class__c = className;
                        
                         errorLog.Error_Message__c       = errormsg;
                         
                    if(records != NULL){
                        if(records[i].get(Label.QLI_IPN_id)!=null)
                        {
                            errorLog.Error_Detail__c = Label.Err_RecordId +String.valueOf(records[i].get(Label.QLI_IPN_id)) +Label.Err_RecordName+ String.valueOf(records[i].get(Label.Err_Name));
                        }
                        else {
                            errorLog.Error_Detail__c = Label.Err_RecordName + String.valueOf(records[i].get(Label.Err_Name));    
                        }
                    }
                    errorList.add(errorLog);                      
                }
            }

            if(!errorList.isEmpty()){             

                Database.SaveResult[] res = Database.insert(errorList,false);
            }           
        } 

        // Records failed due to record deletion fail
        else if (dr!=null){
            // Instantiate and populate the Error Log List.
            List<Error_Log__c> delErrorList = new List<Error_Log__c>();


            for(Integer i = 0; i < dr.size(); i++){

                Database.DeleteResult result = dr[i];                    

                // Capture the exception if any record failed in List.
                if(!result.isSuccess() ){                    
                    Error_Log__c errorLog = new Error_Log__c();

                    errorLog.Origin__c = origin;

                    if(severity!= null)
                        errorLog.Error_Severity__c = severity;
                    errorLog.SObject_Name__c = objName;
                    if(triggerName!= null)
                        errorLog.Trigger__c = triggerName;
                    if(className!=null)
                        errorLog.Class__c = className;
                    if(records[i].get(Label.QLI_IPN_id)!=null){
                        errorLog.Error_Detail__c = Label.Err_RecordId +String.valueOf(records[i].get(Label.QLI_IPN_id)) +Label.Err_RecordName+ String.valueOf(records[i].get(Label.Err_Name));
                    }
                    else{
                        errorLog.Error_Detail__c = Label.Err_RecordName + String.valueOf(records[i].get(Label.Err_Name));      
                    }
                    delErrorList.add(errorLog);                      
                }
            }

            if(!delErrorList.isEmpty()){             

                Database.SaveResult[] res = Database.insert(delErrorList,false);
            }           
        }
    }

    // **************************************************************************************************************
    // Name       :   insertErrorLogWhileUpsert
    // Description:   Method to capture error Log details of Upsert records
    // Parameters :   Exception ex, Database.UpsertResult[] sr,List<SObject> records,String origin, String objName, String truggername,
    //                className 
    // Returns    :   void
    // **************************************************************************************************************
    public static void insertErrorLogWhileUpsert(Exception ex, Database.UpsertResult[] sr,List<SObject> records,String origin, String objName,String triggerName,String className, String severity){
        if(sr != null){

            // Instantiate and populate the Error Log List.
            List<Error_Log__c> errorList = new List<Error_Log__c>();


            for(Integer i = 0; i < sr.size(); i++){

                Database.UpsertResult result = sr[i];                    

                // Capture the exception if any record failed in List.  
                if(!result.isSuccess()){                    
                    Error_Log__c errorLog = new Error_Log__c();

                    errorLog.Origin__c = origin;

                    if(severity!= null)
                        errorLog.Error_Severity__c = severity;
                    errorLog.SObject_Name__c = objName;
                    if(triggerName!= null)
                        errorLog.Trigger__c = triggerName;
                    if(className!=null)
                        errorLog.Class__c = className;
                    if(records[i].get(Label.QLI_IPN_id)!=null)
                    {
                        errorLog.Error_Detail__c = Label.Err_RecordId +String.valueOf(records[i].get(Label.QLI_IPN_id)) +Label.Err_RecordName+ String.valueOf(records[i].get(Label.Err_Name));
                    }
                    else {
                        errorLog.Error_Detail__c = Label.Err_RecordName + String.valueOf(records[i].get(Label.Err_Name)); 
                    }
                    errorList.add(errorLog);                      
                }
            }

            if(!errorList.isEmpty()){             

                Database.SaveResult[] res = Database.insert(errorList,false);
            } 
        }
    }

    // **************************************************************************************************************
    // Name       :   insertSendEmailException
    // Description:   Method to capture error Log details of email sent through code
    // Parameters :   Messaging.SendEmailResult[] sendEmailResults,List<SObject> records,String origin, String objName, String truggername,
    //                className 
    // Returns    :   void
    // **************************************************************************************************************
   /* public static void insertSendEmailException(Messaging.SendEmailResult[] sendEmailResults,String origin, String objName,String triggerName,String className , String severity){

        // Instantiate and populate the Error Log List.
        List<Error_Log__c> errorList = new List<Error_Log__c>();

        for(Integer i = 0; i < sendEmailResults.size(); i++){

            Messaging.SendEmailResult er = sendEmailResults[i];
            //Checks if records were failed
            Error_Log__c errorLog = new Error_Log__c();

            if(!er.isSuccess() ){

                errorLog.Origin__c = origin;
                // Capture Exception details like description , cause and Line #
                errorLog.Error_Message__c = Label.Err_Exp + er.getErrors()[0].getMessage();
                if(severity!=null){
                    errorLog.Error_Severity__c = severity;
                }
                errorLog.SObject_Name__c = objName;
                if(triggerName!= null)
                    errorLog.Trigger__c = triggerName;
                if(className!=null)
                    errorLog.Class__c = className;
            }

            errorList.add(errorLog);
        }

        if(!errorList.isEmpty()){             

            Database.SaveResult[] res = Database.insert(errorList,false);
        }
    } */

    // **************************************************************************************************************
    // Name       :   insertApprovalProcessException
    // Description:   Method to capture error Log details of Dynamic Approval Process using code.
    // Parameters :   Approval.ProcessResult result,String origin, String objName, String truggername,String severity
    //                className 
    // Returns    :   void
    // **************************************************************************************************************
  /*  public static void insertApprovalProcessException(Approval.ProcessResult result,String origin, String objName,String triggerName,String className , String severity){

        // Instantiate and populate the Error Log List.
        List<Error_Log__c> errorList = new List<Error_Log__c>();
        Error_Log__c errorLog = new Error_Log__c();
        if(result!=null && !result.isSuccess()){

            errorLog.Origin__c = origin;
            // Capture Exception details like description , cause and Line #
            if(!result.getErrors().isEmpty() && result.getErrors()[0]!=null){
                errorLog.Error_Message__c = Label.Err_Exp + result.getErrors()[0].getMessage();
            }
            if(severity!=null){
                errorLog.Error_Severity__c = severity;
            }
            errorLog.SObject_Name__c = objName;
            if(triggerName!= null)
                errorLog.Trigger__c = triggerName;
            if(className!=null)
                errorLog.Class__c = className;

            errorList.add(errorLog);   
        }
        if(!errorList.isEmpty()){             

            Database.SaveResult[] res = Database.insert(errorList,false);
        }


    } */


}