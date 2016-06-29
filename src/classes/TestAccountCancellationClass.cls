/**************************************************************************************
  Apex Class Name     : TestAccountCancellationClass
  Version             : 1.0
  Function            : This is a test class for AccountCancellationClass .
  Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
*  Sruthy Dileep            6/1/2015
*************************************************************************************/
@isTest(seeAllData = true)
public class TestAccountCancellationClass {
    
     static testMethod void myUnitTest1() {
        try{
        List<Account> testAccount1 = new List<Account>();
        Account testAcc = TestClassUtiltity.CreateAccountRecord('Test Account');
        testAccount1.add(testAcc);
        list<Product2> LstProduct =  TestClassUtiltity.createProducts();
        insert LstProduct;

       
        list<Benefit_Agreement__c> TestBenefitAgreementLst = new list<Benefit_Agreement__c>();
        Benefit_Agreement__c TestBnftAgrmt1 = new Benefit_Agreement__c ();
        TestBnftAgrmt1.Group_Account__c= testAccount1[0].id;
        TestBnftAgrmt1.Effective_Date__c =  system.today()-1;
        TestBnftAgrmt1.Product__c = LstProduct[0].id;
        TestBnftAgrmt1.status__c = 'Active';
        TestBnftAgrmt1.Cancellation_Status__c = 'Cancellation Rejected';
        TestBenefitAgreementLst.add(TestBnftAgrmt1);
        Benefit_Agreement__c TestBnftAgrmt2 = new Benefit_Agreement__c ();
        TestBnftAgrmt2.Group_Account__c= testAccount1[0].id;
        TestBnftAgrmt2.Effective_Date__c =  system.today()-1;
        TestBnftAgrmt2.Product__c = LstProduct[0].id;
        TestBnftAgrmt2.status__c = 'Active';
        TestBnftAgrmt2.Cancellation_Status__c = 'Cancellation Rejected';
        TestBenefitAgreementLst.add(TestBnftAgrmt2);
        insert TestBenefitAgreementLst;
        
        
        Group_Section__c TestGroupSection = new Group_Section__c();
        TestGroupSection.Group_Account__c = testAccount1[0].id;
        TestGroupSection.status__c = 'Active';
        TestGroupSection.Cancellation_Status__c = 'Cancellation Rejected';
        insert TestGroupSection;
        set<id> TestGpId = new set<id>();
        TestGpId.add(TestGroupSection.id);
        
        BA_GS_Assignment__c TestBAGSAsgnt = new BA_GS_Assignment__c();
        TestBAGSAsgnt.Benefit_Agreement__c = TestBenefitAgreementLst[0].id;
        TestBAGSAsgnt.Group_Section__c = TestGroupSection.id;
        TestBAGSAsgnt.External_ID__c = '101010';
        insert TestBAGSAsgnt;
        
        
        Billing__c TestBilling = new Billing__c();
        TestBilling.Group_Account__c = testAccount1[0].id;
        TestBilling.Cancellation_Status__c = 'Cancellation Rejected';
        TestBilling.status__c = 'Active';
        insert TestBilling;
            
        
        
        test.StartTest();
        
        PageReference myVfPage2 = new PageReference('/apex/AccountCancellationHome');
        myVfPage2.getParameters().put('id',testAccount1[0].id);
        Test.setCurrentPage(myVfPage2);
        
        ApexPAges.StandardController sc2 = new ApexPages.StandardController(testAccount1[0]);
        AccountCancellationClass testController2 = new AccountCancellationClass(sc2);
        
        testController2.accountid = testAccount1[0].id;
        
        testController2.getRelatedBenefitAgreementWrapper();
        testController2.setRelatedBenefitAgreementWrapper(testController2.BAWrapperList);        
        
       // testController2.BAWrapperList[0].entrySelected  = true;
       // testController2.BAWrapperList[1].entrySelected  = true;
        testController2.grpSectionWrapperList[0].entrySelected  = true;
        testController2.BillingWrapperList[0].entrySelected  = true;
        
        testController2 .grpSecIds = TestGpId;
        testController2.selectedValue = 'Group';
        testController2.NavigateToSelectedPage();
        testController2.AccountRecord = testAccount1;
        testController2.getItems();
        //testController2.getCancellationReasonValues();
        testController2.confirmcancellationAccount();
        testController2.cancel();
        testController2.backToAccountHome();
        testController2.moveToAccountCompCancelReviewPg();
        testController2.moveToAccountCompCancel();
        testController2.getGroupSectionList();
        testController2.getGroupSectionWrapperList();
        testController2.getSelectedGroupSectionWrapperList();
        testController2.getRelatedBenefitAgreement();
        testController2.MassUpdate();
        testController2.FinishGroupSection();
        testController2.backToGroupSection();
        testController2.MoveTonextPage();
        
         testController2.getRelatedGroupSectionWrapper();
         testController2.setRelatedGroupSectionWrapper(testController2.grpSectionWrapperList);
        
        testController2.grpSectionWrapperList[0].entry.Requested_Cancellation_Date__c = system.Today().addyears(-1);
        testController2.grpSectionWrapperList[0].entry.Cancellation_Explanation__c = 'test';
        testController2.grpSectionWrapperList[0].entry.Cancellation_Reason__c = 'test';
        testController2.grpSectionWrapperList[0].entry.Cancellation_Code__c = 'test';
        testController2.MoveTonextPage();
        
        testController2.HideMessagePanel();
        testController2.getBAList();
        testController2.getBAWrapperList();
        testController2.getSelectedBAWrapperList();
        testController2.getRelatedGroupSection();
        testController2.MassUpdateBenefitAgree();
        testController2.FinishBenefitAgreeCancel();
        testController2.backToBenefitAgreementCan();
        testController2.MoveTonextBenefitAgreePage();
        
        
       // testController2.BAWrapperList[0].entry.Requested_Cancellation_Date__c = system.Today().addyears(-1);
      //  testController2.BAWrapperList[0].entry.Cancellation_Explanation__c = 'test';
      //  testController2.BAWrapperList[0].entry.Cancellation_Reason__c = 'test';
      //  testController2.BAWrapperList[0].entry.Cancellation_Code__c = 'test';
        testController2.MoveTonextBenefitAgreePage();
        
        testController2.HideMessagePanelBA();
        testController2.getBillingList();
        testController2.getBillingProfileWrapperList();
        testController2.getSeelectedBillingWrapperList();
        testController2.CancelExplanation = 'test';
        testController2.CancelReason = 'test';
        testController2.CancelCode = '12';
        testController2.CancelDate = system.today();        
        
       // testController2.MassUpdateBilling();
       // testController2.showselectedBillingProf();
        
        testController2.BillingWrapperList[0].entry.Requested_Cancellation_Date__c = system.Today().addyears(-1);
        testController2.BillingWrapperList[0].entry.Cancellation_Explanation__c = 'test';
        testController2.BillingWrapperList[0].entry.Cancellation_Reason__c = 'test';
        testController2.BillingWrapperList[0].entry.Cancellation_Code__c = 'test';
        
        testController2.showselectedBillingProf();
        
        testController2.backTobillingsection();
        testController2.FinishBillingProfileCancel();
        testController2.HideMessagePanelBP();
        testController2.backcancellationAccount();
        testController2.DiplaycancellationAccountMessage();
        
        testController2.selectedValue = 'Complete';
        testController2.NavigateToSelectedPage();
        
        testController2.selectedValue = 'Benefit';
        testController2.NavigateToSelectedPage();
        
        testController2.selectedValue = 'Billing';
        pageReference pg = testController2.NavigateToSelectedPage();
        
     //   testController2.BAWrapperList[0].entrySelected  = false;
      //  testController2.BAWrapperList[1].entrySelected  = false;
        testController2.grpSectionWrapperList[0].entrySelected  = false;
        testController2.BillingWrapperList[0].entrySelected  = false;
        testController2.MoveTonextPage();
        testController2.MoveTonextBenefitAgreePage();
        testController2.showselectedBillingProf();
        
        testController2.CancelExplanation = 'test';
        testController2.CancelReason = 'test';
        testController2.CancelDate = system.today();
        testController2.CancelCode = '12';
        testController2.MassUpdate();
        testController2.MassUpdateBilling();
        testController2.MassUpdateBenefitAgree();

   
        //system.assertEquals(pg.getURL(),'/apex/billingProfileCancellation?Id=' + testAccount1[0].Id);
        test.StopTest();

        }catch(Exception e){
        throw e;
        }
    }
    
}