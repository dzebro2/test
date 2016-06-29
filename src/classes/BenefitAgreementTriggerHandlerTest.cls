@isTest
private class BenefitAgreementTriggerHandlerTest {

	@isTest
	static void updateAccountFundingTypeTest() {
		Test.startTest();
		
		Account GroupAcnt = TestClassUtiltity.CreateAccountRecord('Group Account');
        GroupAcnt.BillingStreet = '123 Main St';
        GroupAcnt.BillingCity= 'AnyCity';
        GroupAcnt.BillingState= 'IL';
        GroupAcnt.BillingPostalCode= '60053-0000';
        GroupAcnt.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Group Account').getRecordTypeId();
        update GroupAcnt;
 		
        List<Product2> products = TestClassUtiltity.createProducts();

        Benefit_Agreement__c ba = new Benefit_Agreement__c();
        ba.Group_Account__c = GroupAcnt.Id;
        ba.Product__c = products[0].Id;
        ba.Funding_Type__c = 'ASO';
		insert ba;
		
		List<Account> accountToCheck;
		accountToCheck = [SELECT Funding_Type__c from Account where id =: GroupAcnt.Id];
		String[] fundingTypeList;
		fundingTypeList = accountToCheck[0].Funding_Type__c.split(';');
		System.assertEquals(1, fundingTypeList.size()); 

		Id NonBluestarRecordType = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('HCSC Non BlueStar Product').getRecordTypeId();
		products[1].RecordTypeId = NonBluestarRecordType;
		insert products;

		Benefit_Agreement__c ba2 = new Benefit_Agreement__c();
        ba2.Group_Account__c = GroupAcnt.Id;
        ba2.Product__c = products[1].Id;
        ba2.Funding_Type__c = 'PREM';
		insert ba2;

		accountToCheck = [SELECT Funding_Type__c from Account where id =: GroupAcnt.Id];
		fundingTypeList = accountToCheck[0].Funding_Type__c.split(';');
		System.assertEquals(2, fundingTypeList.size()); 

	}
}