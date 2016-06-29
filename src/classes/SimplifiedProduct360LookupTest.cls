@isTest
private class SimplifiedProduct360LookupTest {
		
	@isTest static void testSearch() {
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
			PageReference pageRef = Page.SimplifiedProduct360Lookup; 
			pageRef.getParameters().put('Id', opp2.Id);
			
			Test.setCurrentPage(pageRef);

			SimplifiedProduct360Lookup prods = new SimplifiedProduct360Lookup();
			
			System.assertEquals(1, prods.results.size());
            prods.searchString = 'zzz';
            prods.search();
            System.assertEquals(0, prods.results.size());
			test.StopTest();

		} catch(Exception e){
			 throw e;
		}
	}
}