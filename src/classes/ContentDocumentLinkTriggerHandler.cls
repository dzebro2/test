/*
    @Description : This is an handler class for ContentDocumentLink
    @author      : Deloitte
    @date        : 10/16/2015
*/
public with sharing class ContentDocumentLinkTriggerHandler {
    /*
        @Name        : UpdateContentDocumentFields
        @Description : This is a  method which would update the Content version fields
        @author      : Deloitte
        @date        : 10/16/2015
        @return      : void 
    */
    public static void UpdateContentDocumentFields(list<ContentDocumentLink> newList){
        set<String> contentVersionIds           = new set<String>();
        list<ContentVersion> contentVersions    = new list<ContentVersion>();
        set<String> contentDocumentIds          = new set<String>();
        for(ContentDocumentLink cdl : newList){
            contentDocumentIds.add(cdl.ContentDocumentId);
        }
        for(ContentDocumentLink cdl : [select ContentDocument.LatestPublishedVersionId,LinkedEntityId,ContentDocument.OwnerId
                                        from ContentDocumentLink where Id In :newList and ContentDocumentId In :contentDocumentIds]){
            if(cdl.ContentDocument.OwnerId != cdl.LinkedEntityId){
                contentVersionIds.add(cdl.ContentDocument.LatestPublishedVersionId);
            }
        }
        for(ContentVersion cv : [select Actual_Renewal_Release_Date__c from ContentVersion 
                                where Id In :contentVersionIds and Actual_Renewal_Release_Date__c = null and RecordType.DeveloperName = 'Renewals']){
            cv.Actual_Renewal_Release_Date__c = Date.today();   
            contentVersions.add(cv);                
        }
        if(contentVersions.size()>0){
        	ConstantsController.fireContentVersionValidation = false;
            update contentVersions;
            
        }
    }
}