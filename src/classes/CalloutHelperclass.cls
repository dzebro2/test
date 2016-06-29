/**************************************************************************************
  Apex Class Name     : CalloutHelperclass
  Version             : 1.0
  Function            : This is a 
  Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Mayuri Bhadane           04/30/2015                Original Version
*************************************************************************************/
global  class CalloutHelperclass{ 
   public static String CBSRInsertXML;
   private static String certName='eamsg_salesforce_hcscexttest_net';
    Public static Integer CalloutProcessedCount =0 ;
  
 
 /******************************************************************** 
    * Method Name : SubmitAccountCallout
    *   @description :   This method checks updates Integration Action field of case.
    *   @parameters  :   List<Case> NewCaseList ,Map<id,Case> oldmap
    *   @return type :   none                     
    ***************************************************************/   
 // @future (callout=true)
  webservice static void SubmitAccountCallout(String caseId){
      try{
      List<Case> caselist = [select Id,CaseNumber,Performance_Guarantees__c,Priority,Reasons_for_Request__c ,Requested_Effective_Date__c, owner.name,Recordtypeid,External_ID__c,Time_Sent__c,Integration_Action__c,Integration_Status__c,lastmodifiedbyid,createdbyid,status from case where id =: caseid ];
      CaseTriggerHandlerLGNA.restrictExecution = true;
      caselist[0].time_sent__c = system.now();
      caselist[0].Integration_Action__c= 'Account Submit';
      Update caselist[0];
      CaseTriggerHandlerLGNA.restrictExecution = false;
      CaseTriggerHandlerLGNA.calloutHelperMethod(caselist, 'Button');
      }catch(Exception ex){
           CreateExceptionLog.insertErrorLog(ex, null, null, null, 'Apex Class','Case' , null, 'CalloutHelperclass.SubmitAccountCallout()','High');
      }
  }   

  /******************************************************************** 
    * Method Name : SendCalloutsToCBSR
    *   @description :   This method checks updates Integration Action field of case.
    *   @parameters  :   List<Case> NewCaseList ,Map<id,Case> oldmap
    *   @return type :   none                     
    ***************************************************************/  
    @future (callout=true)
    public static void SendCalloutsToCBSR(String Body , String UserName1 , String Password1 , String Endpoint1  ){
      //Case newcase = [select Id,CaseNumber,Performance_Guarantees__c,Priority,Reasons_for_Request__c ,Requested_Effective_Date__c, owner.name from case where id =: caseid Limit 1];
               
         
            if(CalloutProcessedCount < Integer.valueOf(system.label.CallOutLimit)  &&  Limits.getCallouts() < Limits.getLimitCallouts()){
                HttpRequest req = new HttpRequest();
                Http http = new Http();
                HttpResponse resp = new HttpResponse();
                req.setHeader('content-type', 'application/xml');
                req.setHeader('Content-Length','10240');
                req.setHeader('Username',UserName1);
                req.setHeader('Password',Password1);
                req.setEndpoint(Endpoint1);
                if(certName!=null) {
                      req.setClientCertificateName(certName);
                }      
                try{           
                        CBSRInsertXML= '<?xml version="1.0" encoding="UTF-8"?> \n<soapenv:Envelope xmlns:soapenv="http://www.w3.org/2003/05/soap-envelope" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"> \n<soapenv:Header>\n\t<wsse:Security soapenv:actor="http://schemas.xmlsoap.org/soap/actor/next" soapenv:mustUnderstand="0" xmlns:wsse="http://schemas.xmlsoap.org/ws/2003/06/secext">\n\t\t<wsse:UsernameToken>\n';
                        CBSRInsertXML=CBSRInsertXML+'\t\t\t<wsse:Username>'+ UserName1 +'</wsse:Username>\n'; 
                        CBSRInsertXML=CBSRInsertXML+'\t\t\t<wsse:Password>'+ Password1 +'</wsse:Password>\n';
                        CBSRInsertXML=CBSRInsertXML+'\t\t</wsse:UsernameToken>\n\t</wsse:Security>';
                        CBSRInsertXML=CBSRInsertXML+'\n\t<OrganizationId>00De0000005UsP5EAK</OrganizationId>';
                        CBSRInsertXML=CBSRInsertXML+'\n\t<SessionId xsi:nil="true"/>';
                        CBSRInsertXML=CBSRInsertXML+'\n\t<EnterpriseUrl>'+Label.CallOut_EnterpriseUrl+'</EnterpriseUrl>';
                        CBSRInsertXML=CBSRInsertXML+'\n\t<PartnerUrl>'+Label.CallOut_PartnerUrl+'</PartnerUrl>';
                        CBSRInsertXML=CBSRInsertXML+'\n</soapenv:Header>\n<soapenv:Body>\n\t<notifications xmlns="http://soap.sforce.com/2005/09/outbound">\n\t\t<Notification>\n';
                        CBSRInsertXML=CBSRInsertXML+Body+'\n\t\t</Notification>\n\t</notifications>\n</soapenv:Body>\n</soapenv:Envelope>';
                        
                        //set body 
                        req.setBody(CBSRInsertXML);                        
                        
                        System.debug('**++'+body);
						System.debug(CBSRInsertXML);
                        
                        req.setMethod('POST');
                        //if(!Test.isRunningTest())
                        //    resp = http.send(req);
                        
                        system.debug('***+++'+resp);
                        CalloutProcessedCount++;                
                    
                }catch(System.CalloutException e) {
                            System.debug('Callout error: '+ e);
                            System.debug(resp.toString()); 
                            System.debug('**++++++'+body); 
                             CreateExceptionLog.insertErrorLog(e, null, null, null, 'Apex Class','Case' , null, 'CalloutHelperclass.SendCalloutsToCBSR()','High');               
                }
            }
        
    }  
    
  /*  public static void MidMarketUnderwritingCallout(String Body, String UserName, String Password, String Endpoint){
        if(CalloutProcessedCount < Integer.valueOf(system.label.CallOutLimit)  &&  Limits.getCallouts() < Limits.getLimitCallouts()){
            HttpRequest req = new HttpRequest();
            Http http = new Http();
            HttpResponse resp = new HttpResponse();
            try{ 
                req.setEndpoint(Endpoint);
                Blob headerValue = Blob.valueOf(UserName + ':' + Password);
                String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
                req.setHeader('Authorization', authorizationHeader);
                req.setMethod('POST');
                req.setBody(Body); 
                resp = http.send(req);
                system.debug('***+++'+resp);
                CalloutProcessedCount++; 
            }catch(System.CalloutException e) {
                System.debug('Callout error: '+ e);
                System.debug(resp.toString()); 
                System.debug('**++++++'+body);               
            }
        }
    }*/
    
}