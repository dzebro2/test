/*
    @Description : This is an trigger handler class for SecureAttachmentTrigger
    @author      : Deloitte
    @date        : 10/19/2015
*/
public without sharing class SecureAttachmentTriggerHandler {
    /*
        @Name        : shareSecureAttachmentRecords
        @Description : This is a trigger method to share the secure attachment record
        @author      : Deloitte
        @date        : 10/19/2015
        @return      : void 
    */
    public static void shareSecureAttachmentRecords(list<Secure_Information__c> secureNewList,map<Id,Secure_Information__c> secureOldmap){
        try{
            list<Secure_Information__c> shareSecureAttachmentRecords = new list< Secure_Information__c>();
            list<Sobject> shareRecords                              = new list<Sobject>();
            map<String,map<String,string>> secureAttachmentUserIds         = new map<String,map<String,string>>();
            Map<String, Schema.SObjectType> gd                      =  Schema.getGlobalDescribe();
            for(Secure_Information__c sa : secureNewList ){
                if((secureOldmap != null && secureOldmap.containsKey(sa.Id) 
                    && (secureOldmap.get(sa.Id).Account__c != sa.Account__c || secureOldmap.get(sa.Id).Opportunity_Name__c != sa.Opportunity_Name__c)
                    ) || (secureOldmap == null || !secureOldmap.containsKey(sa.Id))){
                    shareSecureAttachmentRecords.add(sa);
                }
            }
            secureAttachmentUserIds                                 = LGNAUtilityClass.createSecureAttachmentSharingData(shareSecureAttachmentRecords);
            for(String recordId : secureAttachmentUserIds.keySet()){
                    shareRecords.addAll(LGNAUtilityClass.ShareRecords(recordId,secureAttachmentUserIds.get(recordId),'Edit',gd.get('Secure_Information__share'),Schema.Secure_Information__share.RowCause.Secure_Information_Sharing_Reason__c));
            }
            Database.SaveResult[] lsr                               = Database.insert(shareRecords,false);  
        }catch(Exception e){
            throw e;
        }
    }
    /*
        @Name        : prepopulateAccountValue
        @Description : This is a trigger method to populate the opportunities account in the Account field of the secure information
        @author      : Deloitte
        @date        : 10/28/2015
        @return      : void 
    */
    public static void prepopulateAccountValue(list<Secure_Information__c> secureNewList,map<Id,Secure_Information__c> secureOldmap){
        try
        {
            set<String> opportunityIds                  = new set<String>();
            map<String,string> oppAccountIdMap          = new map<String,string>();
            for(Secure_Information__c sa : secureNewList){
                if((secureOldmap != null && secureOldmap.containsKey(sa.Id) 
                        && (secureOldmap.get(sa.Id).Opportunity_Name__c != sa.Opportunity_Name__c)
                        ) || (secureOldmap == null || !secureOldmap.containsKey(sa.Id))){
                    if(sa.Opportunity_Name__c != null)
                         opportunityIds.add(sa.Opportunity_Name__c) ;       
                }
            }
            for(Opportunity opp : [select AccountId from Opportunity where Id In :opportunityIds]){
                oppAccountIdMap.put(opp.Id,opp.AccountId);
            }
            for(Secure_Information__c sc : secureNewList){
                if(sc.Opportunity_Name__c != null && oppAccountIdMap.containskey(string.valueOf(sc.Opportunity_Name__c))){
                    sc.Account__c                       = oppAccountIdMap.get(sc.Opportunity_Name__c);
                }
            }
        }catch(Exception e){
            throw e;
        }
    }
    /*
        @Name        : checkforSecurityIssues
        @Description : This is a trigger method to check whether the current user has edit permission on the account or opportunity selected
        @author      : Deloitte
        @date        : 10/29/2015
        @return      : void 
    */
    public static void checkforSecurityIssues(list<Secure_Information__c> secureNewList){
        try{
            map<String,Boolean> recordsEditableMap = new map<String,Boolean>();
            Ignore_Validations__c ig = Ignore_Validations__c.getInstance(UserInfo.getProfileId());
            boolean hasAccountAccess,hasOppAccess;
            if(!ig.Ignore_Secure_Sharing_Validation__c){
	            for(Secure_Information__c sa : secureNewList){
	                if(sa.Account__c != null)
	                    recordsEditableMap.put(sa.Account__c,true);
	                if(sa.Opportunity_Name__c != null)
	                    recordsEditableMap.put(sa.Opportunity_Name__c,true);
	            }
	            for(UserRecordAccess ur : [select RecordId,HasEditAccess from UserRecordAccess where UserId =: UserInfo.getUserId() and RecordId In :recordsEditableMap.keySet()]){
	                recordsEditableMap.put(ur.RecordId,ur.HasEditAccess);
	            }
	            for(Secure_Information__c sa : secureNewList){
	            	hasAccountAccess = hasOppAccess = true;
	                if(sa.Account__c != null ){
	                	if(!recordsEditableMap.containsKey(sa.Account__c) || !recordsEditableMap.get(sa.Account__c))
	                		hasAccountAccess = false;
	                }
	                else if(sa.Account__c == null ){
	                	hasAccountAccess = false;
	                }
	                if(sa.Opportunity_Name__c != null ){
	                	if(!recordsEditableMap.containsKey(sa.Opportunity_Name__c) || !recordsEditableMap.get(sa.Opportunity_Name__c))
	                		hasOppAccess = false;
	                }
	                else if(sa.Opportunity_Name__c == null ){
	                	hasOppAccess = false;
	                }
	                if(!hasAccountAccess && !hasOppAccess)
	                    sa.addError(Label.SecureInformationCreateError);
	            }
            }
        }catch(Exception e){
            throw e;
        }
    }
}