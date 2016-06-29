/*
    @Description : This is an test class for BatchAccountRenewalNotification
    @author      : Deloitte
    @date        : 10/29/2015
*/
@isTest
public with sharing class TestContentDocumentLinkTriggerHandler {
	/*
        @Description : This is a testMethod for testing the contentDocumentLink trigger
        @author      : Deloitte
        @date        : 10/29/2015
    */
    static testMethod void myUnitTest1() {
    	//ContentWorkspace cw  = [select Id from ContentWorkspace][0];
      	/*ContentVersion cv = new ContentVersion( Title = 'Test Title ',PathOnClient = 'txt',VersionData = Blob.valueOf('Test Content Version File Body'));
      	insert cv;*/
      	try{
      		Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
		    User testUser = TestClassUtiltity.CreateUserRecord(p.Id, 'testlgnadev@user.com', 'testUser', 'test@user.com');
	      	FeedItem feeditem = new FeedItem();
	        feedItem.Type = 'ContentPost';
	        feedItem.Body = 'Place holder file. Upload attachmenet using Upload new version.';
	        feedItem.ContentData = Blob.valueOf('Test Content Version File Body');
	        feedItem.ContentFileName = 'Test File';
	        feedItem.ParentId = UserInfo.getUserId();
	        insert feedItem;
	      	feeditem = [Select ID,RelatedRecordId  From FeedItem Where id  =:feedItem.Id][0];
	      	RecordType rt = [Select Id from RecordType where DeveloperName = 'Renewals'][0];
	      	ContentVersion cv = [select RecordTypeId,ContentDocumentId from ContentVersion where Id  =:feeditem.RelatedRecordId][0];
	      	cv.RecordTypeId = rt.Id;
	      	update cv;
	      	system.debug('======tHere'+cv.ContentDocumentId);
	      	ContentDocumentLink cdl = new ContentDocumentLink(ContentDocumentId = cv.ContentDocumentId,LinkedEntityId =testUser.Id,ShareType='V');
	      	database.insert(cdl);
	      	
	      	cv = [select RecordTypeId,Actual_Renewal_Release_Date__c from ContentVersion where Id  =:feeditem.RelatedRecordId][0];
	      	system.assertEquals(date.today(),cv.Actual_Renewal_Release_Date__c);
	      	system.debug('======Here'+cdl.Id);
	      	delete cdl;
      	}catch(Exception e){
      		throw e;
      	}
    }
}