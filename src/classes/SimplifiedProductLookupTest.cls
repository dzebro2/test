/**************************************************************************************
  Apex Class Name     : SimplifiedProductLookupTest
  Version             : 1.0
  Function            : This is a test class for the SimplifiedProductLookup class
* Developer                   Date                  
* ----------------------------------------------------------------------------                 
* Nick Serafin             3/30/2016
*************************************************************************************/
@isTest
private class SimplifiedProductLookupTest {
	
	
	@isTest static void test_method_one() {
		try {
			test.StartTest();
			Product2 prod = new Product2();
			prod.Name = 'Blue Directions';
			prod.Simplified_Product__c = 'Blue Directions';
			prod.HCSC_State__c = 'IL';
			insert prod;
			Account TestAcnt = TestClassUtiltity.CreateAccountRecord('TestAccount');

			Opportunity opp2 = new Opportunity(AccountId = TestAcnt.Id, HCSC_Division__c = 'IL', Name='oppName 2',StageName = 'Expected In', CloseDate = system.Today(), Expected_RFP_Release_Date__c = system.Today().addYears(1), Expected_Decision_Date__c = system.Today().addYears(1), RFI_RFP_Received_Date__c = system.Today().addYears(1), Primary_Closed_Reason__c = 'Savings');
			insert opp2;
			PageReference pageRef = Page.SimplifiedProductLookup; 
			pageRef.getParameters().put('Id', opp2.Id);
			pageRef.getParameters().put('lksrch', 'Blue Directions');
			Test.setCurrentPage(pageRef);

			SimplifiedProductLookup prods = new SimplifiedProductLookup();
			prods.getFormTag();
			prods.getTextBox();

			System.assertEquals(1, prods.results.size());
			test.StopTest();

		} catch(Exception e){
			 throw e;
		}
	}
		
	@isTest static void test_method_two() {
		try {
			test.StartTest();
			Product2 prod = new Product2();
			prod.Name = 'Blue Directions';
			prod.HCSC_State__c = 'IL';
			insert prod;
			Account TestAcnt = TestClassUtiltity.CreateAccountRecord('TestAccount');

			Opportunity opp2 = new Opportunity(AccountId = TestAcnt.Id, HCSC_Division__c = 'IL', Name='oppName 2',StageName = 'Expected In', CloseDate = system.Today(), Expected_RFP_Release_Date__c = system.Today().addYears(1), Expected_Decision_Date__c = system.Today().addYears(1), RFI_RFP_Received_Date__c = system.Today().addYears(1), Primary_Closed_Reason__c = 'Savings');
			insert opp2;
			PageReference pageRef = Page.SimplifiedProductLookup; 
			pageRef.getParameters().put('Id', opp2.Id);
			pageRef.getParameters().put('lksrch', '');
			Test.setCurrentPage(pageRef);

			SimplifiedProductLookup prods = new SimplifiedProductLookup();
			
			System.assertEquals(1, prods.results.size());
			test.StopTest();

		} catch(Exception e){
			 throw e;
		}

	}
}