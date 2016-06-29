/**************************************************************************************
  Apex Class Name     : TestContentVersionTrigger
  Version             : 1.0
  Function            : This is a test class for ContentVersion trigger
  Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
*  
*************************************************************************************/
@isTest
public with sharing class TestContentVersionTrigger {
	static testMethod void unitTest1(){
		String rectypeId;
    	for(RecordType rt : [select Id from RecordType where SobjectType='ContentVersion' and DeveloperName ='Renewals']){
    		rectypeId = rt.Id;
    	}
    	Account testAccount = TestClassUtiltity.CreateAccountRecord('Test Account');
		ContentVersion cv = new ContentVersion(recordTypeId = rectypeId, Title = 'Test Title ',PathOnClient = 'txt',VersionData = Blob.valueOf('Test Content Version File Body'));
      	insert cv;
      	cv.Account__c = testAccount.Id;
      	update cv;
      	cv = [select RecordTypeId,Underwriter__c,ContentDocumentId from ContentVersion where Id  =:cv.Id][0];
      	system.assertEquals(userInfo.getUserId(),cv.Underwriter__c);
	}
}