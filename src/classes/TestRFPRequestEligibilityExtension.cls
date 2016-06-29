/**************************************************************************************
  Apex Class Name     : TestRFPRequestEligibilityExtension
  Version             : 1.0
  Function            : This is a test class for RFPRequestEligibilityExtension .
  Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
*  Sruthy Dileep            6/1/2015
*************************************************************************************/
@isTest
private class TestRFPRequestEligibilityExtension {

    static testMethod void myUnitTest() {
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User testUser = TestClassUtiltity.CreateUserRecord(p.Id, 'testlgnadev@user.com', 'testUser', 'test@user.com');
        system.runAs(testUser){
         //crate Account
         Account testAccount = TestClassUtiltity.CreateAccountRecord('Test Account');
          testAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Group Account').getRecordTypeId();
        testAccount.status__c = 'Sold';
        testAccount.Fax = '1234567';
        update testAccount;
        
        list<Case> cases = TestClassUtiltity.createCaseRecords(testAccount.Id);
        cases[0].Part_Time__c = 1;
        cases[0].Total_Eligible_for_Dental__c = 2;
        cases[0].Covered_ElseWhere__c = 1;
        cases[0].Total_on_Payroll__c = 5;
        cases[0].Waiving_Not_Covered_ElseWhere__c =1;   
        cases.addAll(TestClassUtiltity.createCaseRecords(testAccount.Id));
        cases[1].Part_Time__c = 1;
        cases[1].Total_Eligible_For_Health__c = -1;
        cases[1].Covered_ElseWhere__c = 1;
        cases[1].Waiving_Not_Covered_ElseWhere__c =1; 
        cases[1].RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Underwriting').getRecordTypeId();
        insert cases;
        
     //   list<Carrier_History__c> carrierHistories = TestClassUtiltity.createCarrierHistories(cases[0].Id);
      //  insert carrierHistories;
        
        ApexPages.currentPage().getParameters().put('CaseId',cases[0].Id);
        
        ApexPAges.StandardController sc2 = new ApexPages.StandardController(cases[0]);
        RFPRequestEligibilityExtension myCntrl = new RFPRequestEligibilityExtension(sc2);
        system.assertEquals(mycntrl.medicalRecordType,false);
         myCntrl.saveRecord();
         myCntrl.CancelRecord();
        try{
          myCntrl.caseObj=null;
          myCntrl.CancelRecord();
        }catch(Exception e){} 
        
         try{
           cases[0].id=null;
             ApexPAges.StandardController sc3 = new ApexPages.StandardController(cases[0]);
        RFPRequestEligibilityExtension myCntrl1 = new RFPRequestEligibilityExtension(sc3);
        
         ApexPages.currentPage().getParameters().put('CaseId',cases[1].Id);
        sc3 = new ApexPages.StandardController(cases[1]);
        myCntrl1 = new RFPRequestEligibilityExtension(sc3);
        myCntrl1.saveRecord();
         }catch(Exception e){}
       }
    }
}