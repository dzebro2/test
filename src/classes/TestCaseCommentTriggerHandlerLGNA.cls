/**************************************************************************************
  Apex Class Name     : TestCaseCommentTriggerHandlerLGNA
  Version             : 1.0
  Function            : This is a test class for CaseCommentTriggerHandlerLGNA.
  Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
*  Sruthy Dileep            6/1/2015
*************************************************************************************/
@isTest(seeAllData = true)
public class TestCaseCommentTriggerHandlerLGNA{
    
     static testMethod void myUnitTest1() {
        try{
        Account testAccount1 = TestClassUtiltity.CreateAccountRecord('Test Account');
        List<Account> TestLstAcnt = new List<Account>();
        
          Id CBSR_IssueId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(system.label.CBSR_Issue).getRecordTypeId();
        
        List<Case> TestCaseLst = TestClassUtiltity.createCaseRecords(testAccount1.id);
        TestCaseLst[0].Subject = 'Testing';
        TestCaseLst[0].Origin='Test';
        TestCaseLst[0].Description = 'TestDescription';
        TestCaseLst[0].Recordtypeid = CBSR_IssueId;
        TestCaseLst[0].Proposed_Employee__c = 65;
        TestCaseLst[0].External_id__c = '123456';
        insert TestCaseLst;
        
        casecomment ccom = new casecomment ();
        ccom.commentBody = TestCaseLst[0].Description;
        ccom.parentid = TestCaseLst[0].id; 
        insert ccom;
        List<casecomment> TstCaseCommentList = new List<casecomment>();
        TstCaseCommentList.add(ccom);
        
        set<id> caseIds = new set<id>();
        for(Case cas : TestCaseLst){
            caseIds.add(cas.id);
        }

        test.StartTest();
        
        CaseCommentTriggerHandlerLGNA testController2 = new CaseCommentTriggerHandlerLGNA();
        CaseCommentTriggerHandlerLGNA.UpdateIntegrationActionObject(TstCaseCommentList);
        CaseCommentTriggerHandlerLGNA.GetCBSRCaseRecord(caseIds);
        CaseCommentTriggerHandlerLGNA.ValidateCaseCommnetInsert(TstCaseCommentList);
         
         delete TstCaseCommentList;
        
        system.assertEquals(1,TstCaseCommentList.size());

        
        test.StopTest();

        }catch(Exception e){
        throw e;
        }
    }
    
}