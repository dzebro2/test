/**************************************************************************************
  Apex Class Name     : TestAccountCancellationClass
  Version             : 1.0
  Function            : This is a test class for ESalesUtilityClass.
  Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
*  Sumedh Ambokar           6/23/2015
*************************************************************************************/
@isTest
public class TestESalesUtilityClass{
    
    public static testmethod void testmethod1(){
        TestClassUtiltity.createUserNamePasswordFields();
        TestClassUtiltity.createEsalesFields();
        Account acc = TestClassUtiltity.CreateAccountRecord('Test Account');
        acc.HCSC_Division__c = 'TX';
        acc.Market_Segment__c = 'NRMM';
        update acc;
        List<Opportunity> opptys = TestClassUtiltity.CreateOpportunities(String.valueOf(acc.Id));
        opptys[0].Requested_Effective_Date__c = system.Today();
        opptys[0].HCSC_Division__c = 'TX';
        opptys[0].Account_Market_Segment__c = 'NRMM';
        insert opptys[0];
        List<case> cases = TestClassUtiltity.createCaseRecords(String.valueOf(acc.Id));
        Id CaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Mid-Market Underwriting').getRecordTypeId();
        cases[0].RecordTypeId = CaseRecordTypeId;
        cases[0].Status = 'New';
        cases[0].Group_Anniversary_Date__c = '11/30';
        cases[0].opportunity_name__c = opptys[0].id;
        insert cases[0];
        list<Case> updatedCases = [select Integration_Status__c from Case where Id =:cases[0].Id];
        system.assertEquals(updatedCases[0].Integration_Status__c, 'Sent');
    }

}