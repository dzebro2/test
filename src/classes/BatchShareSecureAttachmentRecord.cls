/*
    @Description : This is an BatchShareSecureAttachmentRecord
    @author      : Deloitte
    @date        : 10/16/2015
*/
global  class BatchShareSecureAttachmentRecord implements Database.Batchable<sObject>{
	Map<String, Schema.SObjectType> gd;
	global BatchShareSecureAttachmentRecord(){
		gd 														=  Schema.getGlobalDescribe();
	}
	/*************************************************
     * @Name  			: start
     * @Description  	: Start method queries all the records matching criteria and returns a Database.QueryLocator for it.
 * 	   @Return  		: Database.QueryLocator
   	*************************************************/
	global Database.QueryLocator start( Database.BatchableContext BC ){
		//string recId = 'a17540000004Fit';
		dateTime dt = System.now().addYears(-3);
		String query = 'select Account__c,Opportunity_Name__c,OwnerId from Secure_Information__c where CreatedDate >=:dt';
		return Database.getQueryLocator( query ); 
	}
	/*************************************************
     * @name  			: execute
     * @Description  	: This method gets Secure Attachment records in scope . 
     * @Return			: void
   	*************************************************/
   	global void execute(Database.BatchableContext BC, List<sObject> scope){
   		map<String,map<String,string>> secureAttachmentUserIds			= new map<String,map<String,string>>();
   		list<Sobject> shareRecords 								= new list<Sobject>();
   		secureAttachmentUserIds 								= LGNAUtilityClass.createSecureAttachmentSharingData((List<Secure_Information__c>)scope);
   		
		for(String recordId : secureAttachmentUserIds.keySet()){
				shareRecords.addAll(LGNAUtilityClass.ShareRecords(recordId,secureAttachmentUserIds.get(recordId),'Edit',gd.get('Secure_Information__share'),Schema.Secure_Information__share.RowCause.Secure_Information_Sharing_Reason__c));
		}
		Database.SaveResult[] lsr 			= Database.insert(shareRecords,false);
   	}
   	/*************************************************
     * @Name  			: finish
     * @Description  	: No finish method behaviour is identified yet. 
     * @Return			: void
   	*************************************************/	
	global void finish(Database.BatchableContext BC){
	
	}
}