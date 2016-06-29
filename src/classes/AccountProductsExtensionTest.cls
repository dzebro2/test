/**************************************************************************************
  Apex Class Name     : AccountProductsExtensionTest
  Version             : 1.0
  Function            : This is a test class for AccountProductsExtension.
  Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
*  Nick Serafin           2/11/2016
*************************************************************************************/
@isTest
private class AccountProductsExtensionTest {
	
	@isTest static void test_method_one() {
		try{
			
			test.StartTest();

			Account TestAcnt = TestClassUtiltity.CreateAccountRecord('TestAccount');
            TestAcnt.ShippingStreet = 'TestStreet';
            TestAcnt.ShippingCity= 'TestCity';
            TestAcnt.ShippingState= 'IL';
            TestAcnt.ShippingPostalCode= '62401-2940';
            
            update TestAcnt;
            
            //StageName = Won, To make sure that an opportunity product is pulled up that is realted to the opportunity 
            Opportunity opp2 = new Opportunity(AccountId = TestAcnt.id, Name='oppName 2',StageName = 'Won', CloseDate = system.Today().addYears(2), Expected_Decision_Date__c = system.Today().addYears(1), RFI_RFP_Received_Date__c = system.Today().addYears(1), Primary_Closed_Reason__c = 'Savings');
          
            insert opp2;

            list<Product2> products = TestClassUtiltity.createProducts();
            insert products;
                
            list<Opportunity_Product__c> OppProducts = TestClassUtiltity.createOppProducts(opp2.id,products[0].Id);
            oppProducts[0].Status__c = 'Won';

            insert OppProducts;
            //test to make sure that the page is recieving the account id
			PageReference myVfPage2 = new PageReference('/apex/AccountProductsPage');
	        myVfPage2.getParameters().put('id',TestAcnt.id);

	        Test.setCurrentPage(myVfPage2);

	        System.assertNotEquals(null, myVfPage2);
	       

	        Map<String,String> pageParameters = myVfPage2.getParameters();
    		System.assertEquals(1,pageParameters.values().size());
    	
    		List<Opportunity> opps = new List<Opportunity>();
	         opps = [SELECT Id FROM Opportunity WHERE AccountId =:TestAcnt.id AND StageName = 'Won'];  

            Integer totalNoOfRecs = [SELECT count() FROM Opportunity_Product__c WHERE Opportunity_Name__c IN :opps AND Status__c = 'Won'];
            List<Opportunity_Product__c> opptys = [SELECT Id, Name, Product__c, Product__r.Name, Opportunity_Name__c, Opportunity_Name__r.Name,Account_Product_Name__c, Member_Count__c, Projected_Members__c, Status__c FROM Opportunity_Product__c WHERE Opportunity_Name__c IN :opps AND Status__c = 'Won'];

	        ApexPages.StandardController sc2 = new ApexPages.StandardController(TestAcnt);
	        AccountProductsExtension myCntrl = new AccountProductsExtension(sc2);
	        myCntrl.pageNumber = 0;
	        myCntrl.getInitialProductSet();
	        myCntrl.next();
	        myCntrl.previous();
	        //asserts to make sure that the pagination is working 
	        //and one Opportunity product is being returned
	        System.assertEquals(myCntrl.previous(), null);
	        System.assertEquals(myCntrl.opportunities, opptys);
	        System.assertEquals(totalNoOfRecs, 1);

		 test.StopTest(); 
            
         }catch(Exception e){
            throw e;
         }
	}
	
	@isTest static void test_method_two() {
		try{
			test.StartTest();
			Account TestAcnt = TestClassUtiltity.CreateAccountRecord('TestAccount');
            TestAcnt.ShippingStreet = 'TestStreet';
            TestAcnt.ShippingCity= 'TestCity';
            TestAcnt.ShippingState= 'IL';
            TestAcnt.ShippingPostalCode= '62401-2940';
            
            update TestAcnt;
          
            //StageName = Expected In,  In this scenario no opportunity prdoucts realted to this opp should be returned
            Opportunity opp1 = new Opportunity(AccountId = TestAcnt.id, Name='oppName 1',StageName = 'Expected In', CloseDate = system.Today().addYears(2), Expected_RFP_Release_Date__c = System.Today() ,Expected_Decision_Date__c = system.Today().addYears(1), RFI_RFP_Received_Date__c = system.Today().addYears(1));
          
            insert opp1;
                
            list<Product2> products = TestClassUtiltity.createProducts();
            insert products;
                
            list<Opportunity_Product__c> OppProducts = TestClassUtiltity.createOppProducts(opp1.id,products[0].Id);
            oppProducts[0].Status__c = 'In Progress';

            insert OppProducts;

			PageReference myVfPage2 = new PageReference('/apex/AccountProductPage');
	        myVfPage2.getParameters().put('id',TestAcnt.id);
	        Test.setCurrentPage(myVfPage2);
	        System.assertNotEquals(null, myVfPage2);

	        ApexPages.StandardController sc2 = new ApexPages.StandardController(TestAcnt);
	        AccountProductsExtension myCntrl = new AccountProductsExtension(sc2);
	        myCntrl.getInitialProductSet();
	        myCntrl.next();
	        myCntrl.previous();
	        
	        List<Opportunity> opps = new List<Opportunity>();
	        opps = [SELECT Id FROM Opportunity WHERE AccountId =:TestAcnt.id AND StageName = 'Won'];  

            Integer totalNoOfRecs = [SELECT count() FROM Opportunity_Product__c WHERE Opportunity_Name__c IN :opps AND Status__c ='Won'];
            //asserts that show no opportunity products are returned from the controller when StageName does not equal won
            System.assertEquals(true, myCntrl.opportunities.isEmpty());
	        System.assertEquals(totalNoOfRecs, 0);

		 test.StopTest();
            
         }catch(Exception e){
            throw e;
         }
	}
	
	
}