/**************************************************************************************
  Apex Class Name     : TestBlueStarAccountReservationController
  Version             : 1.0
  Function            : This is a test class for BlueStarAccountReservationController .
  Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
*  Sruthy Dileep            6/2/2015
*************************************************************************************/
@isTest
public class TestBlueStarAccountReservationController {
    
     static testMethod void myUnitTest1() {
        try{
            test.StartTest();
                Account TestAcnt = TestClassUtiltity.CreateAccountRecord('TestAccount');
                
                List<Opportunity> TestOppLst = TestClassUtiltity.CreateOpportunities(TestAcnt.id);
                Benefit_Agreement__c TestBenefitAgreement = new Benefit_Agreement__c();
                TestBenefitAgreement.Group_Account__c= TestAcnt.id;
                insert TestBenefitAgreement;
                
                 TestClassUtiltity.createBlueStartFields();
                TestClassUtiltity.createBlueStartProductFields();
                TestClassUtiltity.createUserNamePasswordFields();
                
                PageReference myVfPage2 = new PageReference('/apex/BlueStarAccountReservation');
                myVfPage2.getParameters().put('id',TestAcnt.id);
                Test.setCurrentPage(myVfPage2);
                
                 Account testAccount = TestClassUtiltity.CreateAccountRecord('Test Account');
                 testAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
                 testAccount.status__c = 'Sold';
                 testAccount.Fax = '1234567';
                 testAccount.HCSC_Division__c = 'IL';
                 testAccount.Effective_Date__c = system.today();
                 update testAccount;
                ApexPages.StandardController controller = new  ApexPages.StandardController(testAccount);
                BlueStarAccountReservationController myCntrl = new BlueStarAccountReservationController(controller);
                myCntrl.setShowPopup();
                System.assertEquals(myCntrl.ShowPopup, true);
                myCntrl.ClosePopUp();
                myCntrl.ReserveAcctCallout();
                BlueStarAccountReservationController.ProductgroupNumberWrapper var = new BlueStarAccountReservationController.ProductgroupNumberWrapper('01','01','XXXXX','XX');
                var.getGroupNos();
                myCntrl.ProdGrpWrapperList[0].selected = '01';
                myCntrl.SetShowPopup();
                testAccount.Time_Sent__c = system.now();
                update testAccount;
                ApexPages.StandardController contrlr = new  ApexPages.StandardController(testAccount);
                BlueStarAccountReservationController myCntrlr = new BlueStarAccountReservationController(contrlr);
                
                testAccount.External_Id__c = 'acbd';
                update testAccount;
                contrlr = new  ApexPages.StandardController(testAccount);
                myCntrlr = new BlueStarAccountReservationController(contrlr);
                
                testAccount.External_Id__c = null;
                testAccount.Effective_Date__c = null;
                update testAccount;
                contrlr = new  ApexPages.StandardController(testAccount);
                myCntrlr = new BlueStarAccountReservationController(contrlr);
            test.StopTest();
            
            }catch(Exception e){
            throw e;
            }
        
    }
    
}