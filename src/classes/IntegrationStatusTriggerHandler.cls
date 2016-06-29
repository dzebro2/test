/**************************************************************************************
  Apex Class Name     : IntegrationStatusTriggerHandler
  Version             : 1.0
  Function            : This is a handler class for CaseTrigger. The methods in this class are used as utility methods for CaseTrigger
  Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Mayuri Bhadane           04/30/2015                Original Version
*************************************************************************************/
public with sharing class IntegrationStatusTriggerHandler{
      Public static Integer CalloutProcessedCount =0 ;
      
      private static String certName=System.label.HCSCCertificate;
   
   
      public static void updateIntegrationAction(List<Integration_Status__c> IsList){
           Set<string> idSet = new Set<string>();
           
           for(Integration_Status__c isrec: IsList){             
               if(isrec.ObjectType__c =='CaseComment'){
                   isrec.Integration_Action__c = 'Note Insert' ;
                   isrec.time_sent__C = system.now();
               }
           }  
      }
 
 
     /******************************************************************** 
    * Method Name    : calloutHelperMethod
    *   @description :   This method checks updates Integration Action field of case.
    *   @parameters  :   List<Case> NewCaseList ,Map<id,Case> oldmap
    *   @return type :   none                     
    ***************************************************************/      
    
    public static void calloutHelperMethod(List<Integration_Status__c> IsList ){
        
        String Body=''; 
        List<String> fieldAPInames = new List<String>();
        Id CBSRId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(system.label.Custom_Benefit_Service).getRecordTypeId();
         Id CBSR_IssueId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(system.label.CBSR_Issue).getRecordTypeId();
        try{
        Map<String,Integration_Status_Callout_fields__c> IS_Callout_Fields  = Integration_Status_Callout_fields__c.getAll();
            for(String cs : IS_Callout_Fields.keyset()){                
                
                fieldAPInames.add(IS_Callout_Fields.get(cs).API_Name__c); 
                              
            } 
        for(Integration_Status__c isrec: IsList){
             body=null;
             if(isrec.ObjectType__c =='CaseComment'){
               // isrec.Integration_Action__c = 'Sent' ;
               // isrec.time_sent__C = system.now();
                 body='<sObject xsi:type="sf:Integration_Status__c" xmlns:sf="urn:sobject.enterprise.soap.sforce.com">' ;
                 for(String api:fieldAPInames){
                         if(isrec.get(api)!=null && ((isrec.get(api)) instanceof String))
                            Body=Body+ '<sf:'+ api +'>'+ ((String)isrec.get(api)).escapeXml()   +'</sf:'+ api +'>';                        
                        else if(isrec.get(api)==null )
                             Body=Body+ '<sf:'+ api +'>'+ ''  +'</sf:'+ api +'>';
                        else
                            Body=Body+ '<sf:'+ api +'>'+  isrec.get(api)  +'</sf:'+ api +'>';
                           
                     
                 } 
                 Body=Body+'</sObject>'; 
             }  
             if(Body!=null && Body!='' && !Test.isRunningTest() )
             SendCalloutsToCBSR(Body);    
        }
        }catch(exception e){
              CreateExceptionLog.insertErrorLog(e, null, null, null, 'Apex Class', 'Integration Status', null, 'IntegrationStatusTriggerHandler.calloutHelperMethod()','High'); 
            System.debug( 'Exception : ' +e.getMessage() );
        } 
    }
    
     
 /******************************************************************** 
    * Method Name : SendCalloutsToCBSR
    *   @description :   This method checks updates Integration Action field of case.
    *   @parameters  :   List<Case> NewCaseList ,Map<id,Case> oldmap
    *   @return type :   none                     
    ***************************************************************/  
    @future (callout=true)
    public static void SendCalloutsToCBSR(String Body){
      //Case newcase = [select Id,CaseNumber,Performance_Guarantees__c,Priority,Reasons_for_Request__c ,Requested_Effective_Date__c, owner.name from case where id =: caseid Limit 1];
            Map<String,Username_Password__c> mapUSerPass  = Username_Password__c.getAll();
            String CBSRInsertXML;
            String UserName;
            String Password;
            String Endpoint;
            for(String cs : mapUSerPass.keyset()){
                if(mapUSerPass.get(cs).name == System.label.ModuleName){
                    UserName=mapUSerPass.get(cs).UserName__c;
                    Password=mapUSerPass.get(cs).Password__c;
                    Endpoint=mapUSerPass.get(cs).EndPoinUrl__c;
                }    
            } 
         
            if(CalloutProcessedCount < Integer.valueOf(system.label.CallOutLimit)  &&  Limits.getCallouts() < Limits.getLimitCallouts()){
                HttpRequest req = new HttpRequest();
                Http http = new Http();
                HttpResponse resp = new HttpResponse();
                req.setHeader('content-type', 'application/xml');
                req.setHeader('Content-Length','10240');
                req.setHeader('Username',UserName);
                req.setHeader('Password',Password);
                req.setEndpoint(Endpoint);
                req.setClientCertificateName(certName);
                try{           
                        CBSRInsertXML= '<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://www.w3.org/2003/05/soap-envelope" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"> <soapenv:Header><wsse:Security soapenv:actor="http://schemas.xmlsoap.org/soap/actor/next" soapenv:mustUnderstand="0" xmlns:wsse="http://schemas.xmlsoap.org/ws/2003/06/secext"><wsse:UsernameToken>';
                        CBSRInsertXML=CBSRInsertXML+'<wsse:Username>'+ UserName +'</wsse:Username>'; 
                        CBSRInsertXML=CBSRInsertXML+'<wsse:Password>'+ Password +'</wsse:Password>';
                        CBSRInsertXML=CBSRInsertXML+'</wsse:UsernameToken></wsse:Security>';
                        CBSRInsertXML=CBSRInsertXML+'<OrganizationId>UserInfo.getOrganizationId()</OrganizationId>';
                        CBSRInsertXML=CBSRInsertXML+'<SessionId xsi:nil="true"/>';
                        CBSRInsertXML=CBSRInsertXML+'<EnterpriseUrl>'+system.label.CallOut_EnterpriseUrl+'</EnterpriseUrl>';
                        CBSRInsertXML=CBSRInsertXML+'<PartnerUrl>'+system.label.CallOut_PartnerUrl+'</PartnerUrl>';
                        CBSRInsertXML=CBSRInsertXML+'</soapenv:Header><soapenv:Body><notifications xmlns="http://soap.sforce.com/2005/09/outbound"><Notification>';
                        CBSRInsertXML=CBSRInsertXML+Body+'</Notification></notifications> </soapenv:Body></soapenv:Envelope>';
                        
                        //set body 
                        req.setBody(CBSRInsertXML);                        
                        
                        System.debug('**++'+body);
                        
                        req.setMethod('POST');
                        if(!Test.isRunningTest())
                            resp = http.send(req);
                        system.debug('***+++'+resp);
                        CalloutProcessedCount++;                
                    
                }catch(System.CalloutException e) {
                            System.debug('Callout error: '+ e);
                            System.debug(resp.toString()); 
                            System.debug('**++++++'+body); 
                            CreateExceptionLog.insertErrorLog(e, null, null, null, 'Apex Class', 'Integration Status', null, 'IntegrationStatusTriggerHandler.SendCalloutsToCBSR()','High');               
                }
            }
        
    }
     

}