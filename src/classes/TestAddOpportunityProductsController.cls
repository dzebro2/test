/**************************************************************************************
  Apex Class Name     : TestAddOpportunityProductsController
  Version             : 1.0
  Function            : This is a test class for AddOpportunityProductsController .
  Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------
*  Sruthy Dileep            6/2/2015
*************************************************************************************/
@isTest
public class TestAddOpportunityProductsController {

	static testMethod void myUnitTest1() {
		try {
			test.StartTest();


			Account testAcnt = new Account(ShippingStreet = 'TestStreet', ShippingCity = 'TestCity', ShippingState = 'IL', ShippingPostalCode = '62401-2940');
			testAcnt.Id = fflib_IDGenerator.generate(Account.SObjectType);

			Opportunity opp = new Opportunity(AccountId = testAcnt.Id, Name = 'oppName 1', StageName = 'Qualification', CloseDate = system.Today().addYears(2), Expected_Decision_Date__c = system.Today().addYears(1), RFI_RFP_Received_Date__c = system.Today().addYears(1));
			opp.Id = fflib_IDGenerator.generate(Opportunity.SObjectType);
			opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal').getRecordTypeId();


			Benefit_Agreement__c testBenefitAgreement = new Benefit_Agreement__c();
			testBenefitAgreement.Group_Account__c = TestAcnt.id;
			testBenefitAgreement.Status__c = 'Active';
			testBenefitAgreement.Id = fflib_IDGenerator.generate(Benefit_Agreement__c.SObjectType);

			list<Product2> products = TestClassUtiltity.createProducts();
			products[0].Id = fflib_IDGenerator.generate( Product2.SObjectType );

			list<Opportunity_Product__c> oppProducts = TestClassUtiltity.createOppProducts(opp.id, products[0].Id);
			oppProducts[0].Benefit_Agreement__c = testBenefitAgreement.Id;
			oppProducts[0].Id = fflib_IDGenerator.generate(Opportunity_Product__c.SObjectType);

			PageReference myVfPage2 = new PageReference('/apex/AddOpportunityProducts');
			myVfPage2.getParameters().put('opportunityId', opp.id);
			Test.setCurrentPage(myVfPage2);

			List<Opportunity> oppList = new List<Opportunity>();
			oppList.add(opp);

			List<Schema.FieldSetMember> fields = SObjectType.Opportunity_Product__c.FieldSets.Renewal_Opportunity_Products.getFields();

			fflib_ApexMocks oppProdMocks = new fflib_ApexMocks();

			OpportunityProductDAO.IOpportunityProductDAO opportunityProductInstance;
			opportunityProductInstance = new MockDAOs.OpportunityProductDAOMock(oppProdMocks);

			oppProdMocks.startStubbing();
			oppProdMocks.when(opportunityProductInstance.getExistingOpProducts(fields)).thenReturn(oppProducts);
			oppProdMocks.stopStubbing();

			fflib_ApexMocks benefitMocks = new fflib_ApexMocks();

			BenefitAgreementDAO.IBenefitAgreementDAO benefitAgreementInstance;
			benefitAgreementInstance = new MockDAOs.BenefitAgreementDAOMock(benefitMocks);

			fflib_ApexMocks userMocks = new fflib_ApexMocks();
			UserDAO.IUserDAO userInstance;
			userInstance = new MockDAOs.UserDAOMock(userMocks);

			fflib_ApexMocks productMocks = new fflib_ApexMocks();
			ProductDAO.IProductDAO productInstance = new MockDAOs.ProductDAOMock(productMocks);



			/*
						ApexPages.StandardSetController sc2 = new ApexPages.StandardSetController(oppList);
						AddOpportunityProductsController myCntrl = new AddOpportunityProductsController(sc2, userInstance, opportunityProductInstance, productInstance, benefitAgreementInstance);

						myCntrl.productDAOInstance = productInstance;
						myCntrl.userDAOInstance = userInstance;
						myCntrl.opportunityProductDAOInstance = opportunityProductInstance;
						myCntrl.benefitAgreementDAOInstance = benefitAgreementInstance;

						myCntrl.opportunityObj = opp;
						myCntrl.numberOfRowToRemove = 1;
						myCntrl.recordToDelete = oppProducts[0].Id;
						myCntrl.removeRow();

						myCntrl.AddNewOpportunityProduct();
						myCntrl.saveOpportunityProducts();
						myCntrl.gotoOpportunity();
						System.assertEquals(1, myCntrl.listOfOpportunityProducts.size());


						/*


						Account TestAcnt = TestClassUtiltity.CreateAccountRecord('TestAccount');
						TestAcnt.ShippingStreet = 'TestStreet';
						TestAcnt.ShippingCity = 'TestCity';
						TestAcnt.ShippingState = 'IL';
						TestAcnt.ShippingPostalCode = '62401-2940';
						//TestAcnt.ShippingCountry = 'United States';
						update TestAcnt;
						List<Opportunity> TestOppLst = TestClassUtiltity.CreateOpportunities(TestAcnt.id);
						TestOppLst[0].RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal').getRecordTypeId();
						insert TestOppLst;

						Benefit_Agreement__c TestBenefitAgreement = new Benefit_Agreement__c();
						TestBenefitAgreement.Group_Account__c = TestAcnt.id;
						TestBenefitAgreement.Status__c = 'Active';
						insert TestBenefitAgreement;

						list<Product2> products = TestClassUtiltity.createProducts();
						insert products;

						list<Opportunity_Product__c> OppProducts = TestClassUtiltity.createOppProducts(TestOppLst[0].id, products[0].Id);
						OppProducts[0].Benefit_Agreement__c = TestBenefitAgreement.Id;
						OppProducts[0].Product_Type__c = 'Renewal';
						insert OppProducts;

						PageReference myVfPage2 = new PageReference('/apex/AddOpportunityProducts');
						myVfPage2.getParameters().put('opportunityId', TestOppLst[0].id);
						Test.setCurrentPage(myVfPage2);

						ApexPAges.StandardSetController sc2 = new ApexPages.StandardSetController(TestOppLst);
						AddOpportunityProductsController myCntrl = new AddOpportunityProductsController(sc2);
						myCntrl.opportunityObj = TestOppLst[0];
						myCntrl.numberOfRowToRemove = 1;
						myCntrl.recordToDelete = OppProducts[0].Id;
						myCntrl.removeRow();

						myCntrl.AddNewOpportunityProduct();
						myCntrl.saveOpportunityProducts();
						myCntrl.gotoOpportunity();
						System.assertEquals(1, myCntrl.listOfOpportunityProducts.size());

						*/
			test.StopTest();

		} catch (Exception e) {
			throw e;
		}

	}

	static testMethod void myUnitTest2() {
		try {
			test.StartTest();
			Account TestAcnt = TestClassUtiltity.CreateAccountRecord('TestAccount');
			TestAcnt.ShippingStreet = 'TestStreet';
			TestAcnt.ShippingCity = 'TestCity';
			TestAcnt.ShippingState = 'IL';
			TestAcnt.ShippingPostalCode = '62401-2940';
			//TestAcnt.ShippingCountry = 'United States';
			update TestAcnt;

			List<Opportunity> TestOppLst = TestClassUtiltity.CreateOpportunities(TestAcnt.id);
			TestOppLst[0].RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('New Sale').getRecordTypeId();
			TestOppLst[1].RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('New Sale').getRecordTypeId();
			insert TestOppLst;

			Benefit_Agreement__c TestBenefitAgreement = new Benefit_Agreement__c();
			TestBenefitAgreement.Group_Account__c = TestAcnt.id;
			TestBenefitAgreement.Status__c = 'Active';
			insert TestBenefitAgreement;

			list<Product2> products = TestClassUtiltity.createProducts();
			insert products;

			list<Opportunity_Product__c> OppProducts = TestClassUtiltity.createOppProducts(TestOppLst[0].id, products[0].Id);
			OppProducts[0].Benefit_Agreement__c = TestBenefitAgreement.Id;
			insert OppProducts;

			PageReference myVfPage2 = new PageReference('/apex/AddOpportunityProducts');
			myVfPage2.getParameters().put('opportunityId', TestOppLst[0].id);
			Test.setCurrentPage(myVfPage2);


			ApexPAges.StandardSetController sc2 = new ApexPages.StandardSetController(TestOppLst);
			AddOpportunityProductsController myCntrl = new AddOpportunityProductsController(sc2);
			myCntrl.opportunityObj = TestOppLst[0];
			myCntrl.numberOfRowToRemove = 1;
			myCntrl.recordToDelete = OppProducts[0].Id;
			myCntrl.removeRow();
			myCntrl.AddNewOpportunityProduct();
			myCntrl.saveOpportunityProducts();
			myCntrl.gotoOpportunity();
			myCntrl.getTheUpdatedMembersCount();
			System.assertEquals(1, myCntrl.listOfOpportunityProducts.size());

			myVfPage2 = new PageReference('/apex/AddOpportunityProducts');
			myVfPage2.getParameters().put('opportunityId', TestOppLst[1].id);
			Test.setCurrentPage(myVfPage2);


			sc2 = new ApexPages.StandardSetController(TestOppLst);
			myCntrl = new AddOpportunityProductsController(sc2);

			test.StopTest();

		} catch (Exception e) {
			throw e;
		}

	}

	static testMethod void myUnitTest3() {
		try {
			test.StartTest();
			Account TestAcnt = TestClassUtiltity.CreateAccountRecord('TestAccount');
			TestAcnt.ShippingStreet = 'TestStreet';
			TestAcnt.ShippingCity = 'TestCity';
			TestAcnt.ShippingState = 'IL';
			TestAcnt.ShippingPostalCode = '62401-2940';
			//TestAcnt.ShippingCountry = 'United States';
			update TestAcnt;
			List<Opportunity> TestOppLst = TestClassUtiltity.CreateOpportunities(TestAcnt.id);
			TestOppLst[0].RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal').getRecordTypeId();
			TestOppLst[0].HCSC_Division__c = 'IL';
			insert TestOppLst;
			list<Product2> LstProduct2 =  TestClassUtiltity.createProducts();
			LstProduct2[0].RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('HCSC Non BlueStar Product').getRecordTypeId();
			LstProduct2[0].HCSC_State__c = 'IL';
			LstProduct2[0].Simplified_Product__c = 'PPO';
			LstProduct2[0].Product_Type__c = 'Medical';
			LstProduct2[0].Name = 'PPO';
			LstProduct2[0].NotSimple__c = false;
			LstProduct2[0].IsActive = true;
			LstProduct2[1].RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('HCSC Non BlueStar Product').getRecordTypeId();
			LstProduct2[1].HCSC_State__c = 'IL';
			LstProduct2[1].Simplified_Product__c = 'Dental';
			LstProduct2[1].Product_Type__c = 'Medical';
			LstProduct2[1].Name = 'Dental';
			LstProduct2[1].NotSimple__c = false;
			LstProduct2[1].IsActive = true;
			insert LstProduct2;

			list<Product2> LstProduct =  TestClassUtiltity.createProducts();
			LstProduct[0].RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('HCSC Non BlueStar Product').getRecordTypeId();
			LstProduct[0].HCSC_State__c = 'IL';
			LstProduct[0].Simplified_Product__c = 'PPO';
			LstProduct[0].Product_Type__c = 'Medical';
			LstProduct[0].Name = 'PPO';
			LstProduct[0].IsActive = true;
			LstProduct[0].NotSimple__c = true;
			LstProduct[1].RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('HCSC Non BlueStar Product').getRecordTypeId();
			LstProduct[1].HCSC_State__c = 'IL';
			LstProduct[1].Name = 'Dental';
			LstProduct[1].Product_Type__c = 'Dental';
			LstProduct[1].Simplified_Product__c = 'Dental';
			LstProduct[1].IsActive = true;
			LstProduct[1].NotSimple__c = true;

			LstProduct.addAll(TestClassUtiltity.createProducts());
			LstProduct[2].RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('HCSC Non BlueStar Product').getRecordTypeId();
			LstProduct[2].HCSC_State__c = 'IL';
			LstProduct[2].Name = 'Dental';
			LstProduct[2].Product_Type__c = 'Dental';
			LstProduct[2].Simplified_Product__c = 'Dental';
			LstProduct[2].IsActive = true;
			LstProduct[2].NotSimple__c = true;
			LstProduct[3].RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('HCSC Non BlueStar Product').getRecordTypeId();
			LstProduct[3].HCSC_State__c = 'IL';
			LstProduct[3].Name = 'PPO';
			LstProduct[3].Product_Type__c = 'Medical';
			LstProduct[3].Simplified_Product__c = 'PPO';
			LstProduct[3].IsActive = true;
			LstProduct[3].NotSimple__c = true;
			insert LstProduct;

			list<Group_Section__c> TestGroupSection = new list<Group_Section__c>();
			Group_Section__c temp = new Group_Section__c();
			temp.Group_Account__c = TestAcnt.id;
			temp.status__c = 'Active';
			temp.Cancellation_Status__c = 'Cancellation Rejected';
			temp.Total_Healthcare_Active_Members__c = 10;
			temp.Total_Dental_Active_Members__c = 10;
			TestGroupSection.add(temp);
			Group_Section__c temp1 = new Group_Section__c();
			temp1.Group_Account__c = TestAcnt.id;
			temp1.status__c = 'Active';
			temp1.Total_Dental_Active_Members__c = 10;
			temp1.Total_Healthcare_Active_Members__c = 10;
			temp1.Cancellation_Status__c = 'Cancellation Rejected';
			TestGroupSection.add(temp1);
			insert TestGroupSection;

			list<Benefit_Agreement__c> TestBenefitAgreementLst = new list<Benefit_Agreement__c>();
			Benefit_Agreement__c TestBnftAgrmt1 = new Benefit_Agreement__c ();
			TestBnftAgrmt1.Group_Account__c = TestAcnt.id;
			TestBnftAgrmt1.Effective_Date__c =  system.today() - 1;
			TestBnftAgrmt1.Product__c = LstProduct[0].id;
			TestBnftAgrmt1.Renewal_Date__c = system.today();
			TestBnftAgrmt1.Status__c = 'Active';
			TestBnftAgrmt1.Funding_Type__c = 'PREM';
			TestBenefitAgreementLst.add(TestBnftAgrmt1);

			Benefit_Agreement__c TestBnftAgrmt10 = new Benefit_Agreement__c ();
			TestBnftAgrmt10.Group_Account__c = TestAcnt.id;
			TestBnftAgrmt10.Effective_Date__c =  system.today() - 1;
			TestBnftAgrmt10.Product__c = LstProduct[0].id;
			TestBnftAgrmt10.Status__c = 'Active';
			TestBnftAgrmt10.Funding_Type__c = 'MPP';
			TestBnftAgrmt10.Renewal_Date__c = system.today();
			insert TestBnftAgrmt10;

			Benefit_Agreement__c TestBnftAgrmt2 = new Benefit_Agreement__c ();
			TestBnftAgrmt2.Group_Account__c = TestAcnt.id;
			TestBnftAgrmt2.Effective_Date__c =  system.today() - 1;
			TestBnftAgrmt2.Product__c = LstProduct[0].id;
			TestBnftAgrmt2.Status__c = 'Active';
			TestBnftAgrmt2.Funding_Type__c = 'ACAP';
			TestBnftAgrmt2.Renewal_Date__c = system.today();
			TestBenefitAgreementLst.add(TestBnftAgrmt2);
			Benefit_Agreement__c TestBnftAgrmt3 = new Benefit_Agreement__c ();
			TestBnftAgrmt3.Group_Account__c = TestAcnt.id;
			TestBnftAgrmt3.Effective_Date__c =  system.today() - 1;
			TestBnftAgrmt3.Product__c = LstProduct[1].id;
			TestBnftAgrmt3.Status__c = 'Active';
			TestBnftAgrmt3.Funding_Type__c = 'ASO';
			TestBnftAgrmt3.Renewal_Date__c = system.today();
			TestBenefitAgreementLst.add(TestBnftAgrmt3);
			insert TestBenefitAgreementLst;

			Benefit_Agreement__c TestBnftAgrmt4 = new Benefit_Agreement__c ();
			TestBnftAgrmt4.Group_Account__c = TestAcnt.id;
			TestBnftAgrmt4.Effective_Date__c =  system.today() - 1;
			TestBnftAgrmt4.Product__c = LstProduct[1].id;
			TestBnftAgrmt4.Status__c = 'Active';
			TestBnftAgrmt4.Funding_Type__c = 'SERV';
			TestBnftAgrmt4.Renewal_Date__c = system.today();
			insert TestBnftAgrmt4;

			Benefit_Agreement__c TestBnftAgrmt5 = new Benefit_Agreement__c ();
			TestBnftAgrmt5.Group_Account__c = TestAcnt.id;
			TestBnftAgrmt5.Effective_Date__c =  system.today() - 1;
			TestBnftAgrmt5.Product__c = LstProduct[1].id;
			TestBnftAgrmt5.Status__c = 'Active';
			TestBnftAgrmt5.Funding_Type__c = 'COST';
			TestBnftAgrmt5.Renewal_Date__c = system.today();
			insert TestBnftAgrmt5;

			BA_GS_Assignment__c tempBAGS9 = new BA_GS_Assignment__c();
			tempBAGS9.Benefit_Agreement__c = TestBnftAgrmt5.id;
			tempBAGS9.Group_Section__c = TestGroupSection[0].id;
			tempBAGS9.External_ID__c = '1010123454546463';
			insert tempBAGS9;

			BA_GS_Assignment__c tempBAGS1 = new BA_GS_Assignment__c();
			tempBAGS1.Benefit_Agreement__c = TestBnftAgrmt4.id;
			tempBAGS1.Group_Section__c = TestGroupSection[0].id;
			tempBAGS1.External_ID__c = '1010123';
			insert tempBAGS1;

			BA_GS_Assignment__c tempBAGS6 = new BA_GS_Assignment__c();
			tempBAGS6.Benefit_Agreement__c = TestBnftAgrmt10.id;
			tempBAGS6.Group_Section__c = TestGroupSection[1].id;
			tempBAGS6.External_ID__c = '1010123231';
			insert tempBAGS6;

			list<BA_GS_Assignment__c> TestBAGSAsgnt = new list<BA_GS_Assignment__c>();
			BA_GS_Assignment__c tempBAGS = new BA_GS_Assignment__c();
			tempBAGS.Benefit_Agreement__c = TestBenefitAgreementLst[0].id;
			tempBAGS.Group_Section__c = TestGroupSection[0].id;
			tempBAGS.External_ID__c = '101011';
			TestBAGSAsgnt.add(tempBAGS);
			BA_GS_Assignment__c temp1BAGS = new BA_GS_Assignment__c();
			temp1BAGS.Benefit_Agreement__c = TestBenefitAgreementLst[0].id;
			temp1BAGS.Group_Section__c = TestGroupSection[1].id;
			temp1BAGS.External_ID__c = '101012';
			TestBAGSAsgnt.add(temp1BAGS);
			BA_GS_Assignment__c temp2BAGS = new BA_GS_Assignment__c();
			temp2BAGS.Benefit_Agreement__c = TestBenefitAgreementLst[1].id;
			temp2BAGS.Group_Section__c = TestGroupSection[0].id;
			temp2BAGS.External_ID__c = '101013';
			TestBAGSAsgnt.add(temp2BAGS);
			BA_GS_Assignment__c temp3BAGS = new BA_GS_Assignment__c();
			temp3BAGS.Benefit_Agreement__c = TestBenefitAgreementLst[1].id;
			temp3BAGS.Group_Section__c = TestGroupSection[1].id;
			temp3BAGS.External_ID__c = '101014';
			TestBAGSAsgnt.add(temp3BAGS);
			BA_GS_Assignment__c temp4BAGS = new BA_GS_Assignment__c();
			temp4BAGS.Benefit_Agreement__c = TestBenefitAgreementLst[2].id;
			temp4BAGS.Group_Section__c = TestGroupSection[1].id;
			temp4BAGS.External_ID__c = '101015';
			TestBAGSAsgnt.add(temp4BAGS);
			insert TestBAGSAsgnt;

			PageReference myVfPage2 = new PageReference('/apex/AddOpportunityProducts');
			myVfPage2.getParameters().put('opportunityId', TestOppLst[0].id);
			Test.setCurrentPage(myVfPage2);

			TestBenefitAgreementLst = [select Id, Name from Benefit_Agreement__c where id In :TestBenefitAgreementLst];
			ApexPAges.StandardSetController sc2 = new ApexPages.StandardSetController(TestOppLst);
			AddOpportunityProductsController myCntrl = new AddOpportunityProductsController(sc2);

			myCntrl.BARecordId = TestBenefitAgreementLst[0].Name;
			myCntrl.getTheUpdatedMembersCount();
			myCntrl.BARecordId = TestBenefitAgreementLst[1].Name;
			myCntrl.getTheUpdatedMembersCount();
			myCntrl.BARecordId = TestBenefitAgreementLst[2].Name;
			myCntrl.rowCount = '1';
			myCntrl.getTheUpdatedMembersCount();
			myCntrl.opportunityObj = TestOppLst[0];
			System.assertEquals(6, myCntrl.listOfOpportunityProducts.size());
			test.StopTest();

		} catch (Exception e) {
			throw e;
		}

	}

}