/**************************************************************************************
  Apex Class Name     : ESalesUtilityClass
  Version             : 1.0
  Function            : This is a handler class for AccountTrigger. The methods in this class are used as utility methods for CaseTrigger
  Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
*  Sumedh Amdbokar                                  Original Version
*************************************************************************************/
public class ESalesUtilityClass{
   
    /*************************************************************************************************************************************
     *  UpdateCaseRecordESales
    *   @description:  Method used to update Time sent , Integratio status and Integration action during callout
    *   @parameters     List<Case> CaseTriggerNew)
    *   @return type    void                        
    *******************************************************************************************************************************************/  
    public static void UpdateCaseRecordESales(List<Case> CaseTriggerNew){
        ID CaseRecordTypeId;
        for(RecordType rt : [select Id from RecordType where SobjectType = 'Case' and DeveloperName =:ConstantsController.CaseMidMarketingRecordType]){
            CaseRecordTypeId = rt.Id;
        }
        Map<String,Callout_Restricted_Users__c> mapUSerProfile  = Callout_Restricted_Users__c.getAll();
        User loggedinUser = [select id , profile.name from user where id =: Userinfo.getUserId() limit 1];
       
       // if logged in user is not integration user and record type is mid market underwriting then stamp time sent , integrationaction and status
        if(!mapUSerProfile.containskey(loggedinUser.profile.name)){
            for(Case cs : CaseTriggerNew){
                if(cs.RecordTypeId == CaseRecordTypeId && cs.Status == 'New' && cs.External_ID__c==NULL){
                    cs.Time_Sent__c = System.Now();
                    cs.Integration_Status__c = 'Sent';
                    cs.Integration_Action__c = 'Create eSales';
                }
            }
        }
    }
    
  /*************************************************************************************************************************************
     *  GenerateXMLFile
    *   @description:  Method used to generate xml body used for callout
    *   @parameters     List<Case> CaseTriggerNew)
    *   @return type    void                        
    *******************************************************************************************************************************************/   
    public static void GenerateXMLFile(List<Case> CaseTriggerNew){
     try{
        ID CaseRecordTypeId;
        for(RecordType rt : [select Id from RecordType where SobjectType = 'Case' and DeveloperName =:ConstantsController.CaseMidMarketingRecordType]){
            CaseRecordTypeId = rt.Id;
        }
        Map<String,Callout_Restricted_Users__c> mapUSerProfile  = Callout_Restricted_Users__c.getAll();
        User loggedinUser = [select id , profile.name from user where id =: Userinfo.getUserId() limit 1];
        // if logged in user is not ingetegration user and status is new collect case ids
        if(!mapUSerProfile.containskey(loggedinUser.profile.name)){
            Set<Id> CaseRecordIdSet = new Set<Id>();
            for(Case cs : CaseTriggerNew){
                if(cs.RecordTypeId == CaseRecordTypeId && cs.Status == 'New'){
                    CaseRecordIdSet.add(cs.id);
                }
            }
            system.debug('#### CaseRecordIdSet ' + CaseRecordIdSet);
            if(CaseRecordIdSet.size() > 0){
                Map<String,ESales_Callout_Fields_Set__c> FieldNameFieldSetMap = ESales_Callout_Fields_Set__c.getAll();
                Map<String,Username_Password__c> AuthenticationDetails = Username_Password__c.getAll();
                Map<String,String> FieldNameTagNameMap = new Map<String, String>();
                if(FieldNameFieldSetMap.size() > 0){
                    String UserName;
                    String Password;
                    String Endpoint;
              // get usr name and password from custom setting fro esales
                    for(Username_Password__c record : AuthenticationDetails.values()){
                        if(record.Name == 'ESalesModule'){
                            UserName = record.UserName__c;
                            Password = record.Password__c;
                            Endpoint = record.EndPoinUrl__c;
                        }
                    }
                    Integer RowLimit = Limits.getLimitQueryRows() - Limits.getQueryRows();
                    String CaseQuery = 'SELECT ';
               // collect fields to be used for callout from esales custom setting
                    for(ESales_Callout_Fields_Set__c Field : FieldNameFieldSetMap.Values()){
                        if(Field.Insert__c == true){
                            CaseQuery += Field.FieldName__c + ',';
                            FieldNameTagNameMap.put(Field.FieldName__c,Field.Tag_Name__c);
                        }
                    }
                    CaseQuery = CaseQuery.removeEnd(',');
                    CaseQuery += ' FROM Case WHERE id In: CaseRecordIdSet limit: RowLimit';
                    system.debug('#### CaseQuery ' + CaseQuery);
                    List<Case> CaseRecordList = Database.Query(CaseQuery);
               // Generate XML body using field aPI name aand tag    
                    for(Case CaseRecord : CaseRecordList){
                        String XMLBody = '\t\t\t<sObject xsi:type="sf:Case" xmlns:sf="urn:sobject.enterprise.soap.sforce.com">\n';
                        for(String FieldName : FieldNameTagNameMap.keySet()){
                            if(FieldNameTagNameMap.get(FieldName) != null){
                                if(!FieldName.contains('.')){
                                    if(CaseRecord.get(FieldName)!=null && CaseRecord.get(FieldName) instanceof String )
                                    XMLBody += '\t\t\t\t <' +  FieldNameTagNameMap.get(FieldName) + '>' + ((String)CaseRecord.get(FieldName)).escapeXml() + '</' + FieldNameTagNameMap.get(FieldName) + '> \n';
                                    else if(CaseRecord.get(FieldName)==null)
                                    XMLBody += '\t\t\t\t <' +  FieldNameTagNameMap.get(FieldName) + '>' + '' + '</' + FieldNameTagNameMap.get(FieldName) + '> \n';
                                    else
                                    XMLBody += '\t\t\t\t <' +  FieldNameTagNameMap.get(FieldName) + '>' + CaseRecord.get(FieldName) + '</' + FieldNameTagNameMap.get(FieldName) + '> \n';
                                    
                                 }   
                            }
                        }
                        /******************************************************************/
                        XMLBody += '\t\t\t\t <sf:LANID__c>' +( CaseRecord.LastModifiedby.Lan_ID__c==null? '' : CaseRecord.LastModifiedby.Lan_ID__c.escapeXml()) + '</sf:LANID__c>\n';
                        XMLBody += '\t\t\t\t <sf:Account_Number__c>' +( CaseRecord.Account.Id==null? '' :CaseRecord.Account.Id )+ '</sf:Account_Number__c>\n';
                        XMLBody += '\t\t\t\t <sf:Account_Name__c>' + (CaseRecord.Account.Name==null? '' :CaseRecord.Account.Name.escapeXml() ) + '</sf:Account_Name__c>\n';
                        XMLBody += '\t\t\t\t <sf:Account_Market_Segment__c>' + (CaseRecord.Opportunity_Name__r.Account_Market_Segment__c==null? '' : CaseRecord.Opportunity_Name__r.Account_Market_Segment__c.escapeXml()) + '</sf:Account_Market_Segment__c>\n';
                        XMLBody += '\t\t\t\t <sf:Account_Phone__c>' +( CaseRecord.Account.Phone==null? '' : CaseRecord.Account.Phone.escapeXml())+ '</sf:Account_Phone__c>\n';
                        XMLBody += '\t\t\t\t <sf:Account_Fax__c>' + (CaseRecord.Account.Fax==null? '' :CaseRecord.Account.Fax.escapeXml()) + '</sf:Account_Fax__c>\n';
                        XMLBody += '\t\t\t\t <sf:Account_Street1__c>' +( CaseRecord.Account.BillingStreet==null? '' : CaseRecord.Account.BillingStreet.escapeXml())+ '</sf:Account_Street1__c>\n';
                        XMLBody += '\t\t\t\t <sf:Account_State__c>' +( CaseRecord.Account.Billingstate==null? '' : CaseRecord.Account.Billingstate.escapeXml()) + '</sf:Account_State__c>\n';
                        XMLBody += '\t\t\t\t <sf:Account_City__c>' + (CaseRecord.Account.BillingCity==null? '' : CaseRecord.Account.BillingCity.escapeXml()) + '</sf:Account_City__c>\n';
                        XMLBody += '\t\t\t\t <sf:Account_PostalCode__c>' +( CaseRecord.Account.Billingpostalcode ==null? '' : CaseRecord.Account.Billingpostalcode.escapeXml())+ '</sf:Account_PostalCode__c>\n';
                        XMLBody += '\t\t\t\t <sf:Producer_Account_TaxID__c>' +( CaseRecord.Producer_Account__r.Tax_ID__c==null? '' : CaseRecord.Producer_Account__r.Tax_ID__c.escapeXml()) + '</sf:Producer_Account_TaxID__c>\n';
                        XMLBody += '\t\t\t\t <sf:Opportunity_Effective_Date__c>' +( CaseRecord.Opportunity_Name__r.Requested_Effective_Date__c==null? '' :string.valueof(CaseRecord.Opportunity_Name__r.Requested_Effective_Date__c)) + '</sf:Opportunity_Effective_Date__c>\n';
                      //  XMLBody += '\t\t\t\t <sf:Opportunity_Expected_Members__c>' + CaseRecord.Opportunity_Name__r.Expected_Health_Members__c.escapeXml()  + '</sf:Opportunity_Expected_Members__c>\n';
                        XMLBody += '\t\t\t\t <sf:Account_District__c>' + (CaseRecord.Account.District__c==null? '' : CaseRecord.Account.District__c.escapeXml())+ '</sf:Account_District__c>\n';
                        XMLBody += '\t\t\t\t <sf:Account_Cluster__c>' + (CaseRecord.Account.Cluster__c==null? '' : CaseRecord.Account.Cluster__c.escapeXml()) + '</sf:Account_Cluster__c>\n';
                        XMLBody += '\t\t\t\t <sf:Account_Region__c>' +( CaseRecord.Account.Region__c==null? '' :CaseRecord.Account.Region__c.escapeXml()) + '</sf:Account_Region__c>\n';
                        XMLBody += '\t\t\t\t <sf:Account_SIC_Code__c>' +( CaseRecord.Account.Sic==null? '' : CaseRecord.Account.Sic.escapeXml()) + '</sf:Account_SIC_Code__c>\n';
                        XMLBody += '\t\t\t\t <sf:HCSC_Division__c>' +( CaseRecord.Account.Hcsc_Division__c==null? '' : CaseRecord.Account.Hcsc_Division__c.escapeXml()) + '</sf:HCSC_Division__c>\n';
                        /*****************************************************************/
                        XMLBody += '\t\t\t</sObject>';
                       if(!Test.isRunningTest() && CaseRecord.External_ID__c==NULL)
                       CalloutHelperclass.SendCalloutsToCBSR(XMLBody,UserName,Password,Endpoint);
                    }
                }
            }
        }
      }catch(Exception ex){
           CreateExceptionLog.insertErrorLog(ex,null,null ,null, 'GenerateXMLFile', 'Case', 'Caetrigger', 'ESalesUtilityClass','High');
           system.debug('ERROR: ' + ex.getMessage() + '  ' + ex.getStackTraceString());
           //ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));  
      }
    }
}