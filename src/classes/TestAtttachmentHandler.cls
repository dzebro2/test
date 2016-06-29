/**************************************************************************************
  Apex Class Name     : TestAtttachmentHandler
  Version             : 1.0
  Function            : This is a test class for AtttachmentHandler .
  Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
*  Sruthy Dileep            6/1/2015
*************************************************************************************/
@isTest
public with sharing class TestAtttachmentHandler {

    static testMethod void myUnitTest() {
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
         User testUser = TestClassUtiltity.CreateUserRecord(p.Id, 'testlgnadev@user.com', 'testUser', 'test@user.com');
         system.runAs(testUser){
        try{
       // Id CBSRId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(system.label.Custom_Benefit_Service).getRecordTypeId();
        Id CBSR_IssueId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(system.label.CBSR_Issue).getRecordTypeId();
        Id grp_acountid = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Group Account').getRecordTypeId(); 
        test.StartTest();
        Account testAccount = TestClassUtiltity.CreateAccountRecord('Test Account');
        testAccount.Recordtypeid = grp_acountid;
        update testAccount;
        list<case> LstCase = TestClassUtiltity.createCaseRecords(testAccount.id);
        LstCase[0].Recordtypeid = CBSR_IssueId;
        LstCase[0].External_id__C = '12345';
        LstCase[0].Status = 'New';
        Insert LstCase;
        set<id> SetId = new set<id>();
        for(Case caseid : LstCase){
            SetId.add(caseid.id);
        }
        Blob b = Blob.valueOf('Test Data');  
      
        Attachment attachment = new Attachment();  
        attachment.ParentId = testAccount.id;  
        attachment.Name = 'Test Attachment';  
        attachment.Body = b;  
          
        insert(attachment);        
       List<Integration_Status__c> intStLst = TestClassUtiltity.createIntegrationStatus(attachment.Id);
        insert intStLst;
        
        list<Attachment> lstAttachment = new list<Attachment>{attachment }; 
        
       
        
        AtttachmentHandler.UpdateIntegrationActionObject(lstAttachment);
        AtttachmentHandler.DeleteIntegrationActionObject(lstAttachment);
        AtttachmentHandler.GetCBSRCaseRecord(SetId);
        
        Attachment attachment1 = new Attachment();  
        attachment1.ParentId = LstCase[0].id;  
        attachment1.Name = 'Test Attachment';  
        attachment1.Body = b;  
        insert(attachment1); 
        intStLst = TestClassUtiltity.createIntegrationStatus(attachment1.Id);
        insert intStLst;
        Delete attachment1;
        
        AtttachmentHandler.UpdateIntegrationActionObject(new List<Attachment>{attachment1});
        list<Attachment> attachments = [select Id from Attachment];
            system.assertEquals(attachments.size(),1);
        test.StopTest();
        }catch(Exception e){
          //System.Assert(e.getMessage().contains(system.label.MIME_type_not_allowed));
        //        throw e;
        }
         }
    }
}