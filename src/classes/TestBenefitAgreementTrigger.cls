@isTest
public with sharing class TestBenefitAgreementTrigger {
    static testMethod void myUnitTest1() {
        Id productRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('HCSC Non BlueStar Product').getRecordTypeId();
        list<Product2> products = TestClassUtiltity.createProducts();
        products[0].RecordTypeId = productRecordTypeId;
        insert products;
        Account TestAcnt = TestClassUtiltity.CreateAccountRecord('TestAccount');
        TestAcnt.ShippingStreet = 'TestStreet';
        TestAcnt.ShippingCity= 'TestCity';
        TestAcnt.ShippingState= 'IL';
        TestAcnt.ShippingPostalCode= '62401-2940';
        //TestAcnt.ShippingCountry = 'United States';
        update TestAcnt;
        List<Opportunity> TestOppLst = TestClassUtiltity.CreateOpportunities(TestAcnt.id);
        TestOppLst[0].RecordTypeId =Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal').getRecordTypeId();
        insert TestOppLst;
        Benefit_Agreement__c TestBenefitAgreement = new Benefit_Agreement__c();
        TestBenefitAgreement.Group_Account__c= TestAcnt.id;
        TestBenefitAgreement.Status__c = 'Active';
        TestBenefitAgreement.Product__c = products[0].Id;
        insert TestBenefitAgreement;
        list<Benefit_Agreement__c> tempBAs = [select Id from Benefit_Agreement__c];
        system.assertEquals(tempBAs.size(),1);
    }
}