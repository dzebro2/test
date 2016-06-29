/*
    @Description : This is an extension class for Sharing the Financial records with the Opportunity Team Member
    @author      : Deloitte
    @date        : 10/06/2015
*/
public without sharing class ShareSecureAttachmentRecords {
    public set<string> recordIds      {get;set;}
    public boolean hasError     {get;set;}
    public list<Secure_Information__c> secureAttachments;
    public string accId,oppId;
    /*
        @Description : This is an constructor of this class
        @author      : Deloitte
        @date        : 10/06/2015
    */
   
    public ShareSecureAttachmentRecords(ApexPages.StandardSetController controller){
        recordIds = new set<String>();
        oppId = ApexPages.currentPage().getParameters().get('OppId');
        accId = ApexPages.currentPage().getParameters().get('AccId');
        secureAttachments = new list<Secure_Information__c>();
        if(oppId !='' && oppId != null){
            secureAttachments = [select Opportunity_Name__c,Account__c,Account__r.OwnerId,Opportunity_Name__r.AccountId,OwnerId,Opportunity_Name__r.OwnerId 
                                                                        from Secure_Information__c where Opportunity_Name__c =:oppId];
        }
        else if(accId !='' && accId != null){
            secureAttachments = [select Opportunity_Name__c,Account__c,Account__r.OwnerId,Opportunity_Name__r.AccountId,OwnerId,Opportunity_Name__r.OwnerId 
                                                                        from Secure_Information__c where Account__c =:accId];
        }
        
        
        hasError                                = false;
        
    }
    /*
        @Name        : goBack
        @Description : This method will redirect to parent page
        @author      : Deloitte
        @date        : 10/30/2015
        @return      : pageReference 
    */
    public pageReference goBack(){
        if(oppId != null){
            return new PageReference('/'+oppId);
        }
        else{
            return new PageReference('/'+accId);
        }
    }
    
    /*
        @Name        : shareRecordToOpportunityTeam
        @Description : This method will share the Secure Attachment record with the Opportunity team member,account Team and account Owner
        @author      : Deloitte
        @date        : 10/06/2015
        @return      : void 
    */
    public void shareRecordToOpportunityTeam(){
        try{
            if(secureAttachments.size()>0){
                map<String,map<String,string>> secureAttachmentUserIds         = new map<String,map<String,string>>();
                list<Sobject> shareRecords                              = new list<Sobject>();
                secureAttachmentUserIds                                 = LGNAUtilityClass.createSecureAttachmentSharingData(secureAttachments);
                
                Map<String, Schema.SObjectType> gd  = Schema.getGlobalDescribe();
                for(String recordId : secureAttachmentUserIds.keySet()){
                    shareRecords.addAll(LGNAUtilityClass.ShareRecords(recordId,secureAttachmentUserIds.get(recordId),'Edit',gd.get('Secure_Information__share'),Schema.Secure_Information__share.RowCause.Secure_Information_Sharing_Reason__c));
                }
                //list<Sobject> shareRecords            =  LGNAUtilityClass.ShareRecords(recordId,oppTeamUserIds,'Edit',gd.get('Secure_Attachment__share'),Schema.Secure_Attachment__share.RowCause.SecureAttachmentSharingRowCause__c);
                Database.SaveResult[] lsr           = Database.insert(shareRecords,false);
                hasError                            = false;
            }
            else{
                ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.No_Records_To_Share));    
                hasError                            = true;
            }
        }catch(Exception e){
            hasError                            = true;
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));    
            
        }
        
    }
}