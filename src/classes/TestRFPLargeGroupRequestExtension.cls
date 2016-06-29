/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class TestRFPLargeGroupRequestExtension {

    static testMethod void myUnitTest() {
         Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
         User testUser = TestClassUtiltity.CreateUserRecord(p.Id, 'testlgnadev@user.com', 'testUser', 'test@user.com');
         system.runAs(testUser){
            //crate Account
            Account testAccount = TestClassUtiltity.CreateAccountRecord('Test Account');
            testAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Group Account').getRecordTypeId();
            testAccount.status__c = 'Sold';
            testAccount.Fax = '1234567';
            update testAccount;
            
            list<Case> cases = TestClassUtiltity.createCaseRecords(testAccount.Id);
             
            insert cases;
            list<Competitor_Relationship__c> carrierHistories = new list<Competitor_Relationship__c>();
            
             Competitor_Relationship__c cr = new Competitor_Relationship__c();
             cr.Group_Account__c = testAccount.id;
             cr.AFA__C = true;
             insert cr;
           // list<Carrier_History__c> carrierHistories = TestClassUtiltity.createCarrierHistories(cases[0].Id);
           // insert carrierHistories;
            
            ApexPages.currentPage().getParameters().put('CaseId',cases[0].Id);
            
            ApexPAges.StandardController sc2 = new ApexPages.StandardController(cases[0]);
            RFPLargeGroupRequestExtension myCntrl = new RFPLargeGroupRequestExtension(sc2);
            system.assertEquals(myCntrl.carrierHistoryList.size(),5);
             myCntrl.addRow();
            myCntrl.rowToRemove = 1;
            myCntrl.removeRow();
            myCntrl.dummyMethod();
            myCntrl.saveRecords();
            myCntrl.cancelRecord();
            try{
                cases[0].id=null;
                ApexPAges.StandardController sc3 = new ApexPages.StandardController(cases[0]);
                RFPLargeGroupRequestExtension myCntrl1 = new RFPLargeGroupRequestExtension(sc3);
                
            }catch(Exception e){
            
            }
            
         }
    }
}