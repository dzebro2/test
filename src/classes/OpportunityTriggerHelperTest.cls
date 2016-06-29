/***************************************************************************************
  Apex Class Name     : OpportunityTriggerHelperTest
  Version             : 1.0
  Function            : This is a test class for OpportunityTriggerHelper
  Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------
* Sana Fatima 				  2/26/2016				Unit Testing for OpportunityTriggerHelper Class
*************************************************************************************/
@isTest
private class OpportunityTriggerHelperTest {

	/**
	* @developer: Sana Fatima/Slalom LLC
	* @description: Test Method for PopulateFieldsFromAccount method in OpportunityTriggerHelper for a New Sale Opportunity
	*/
	static testMethod void PopulateFieldsFromAccountNewSaleOppTest() {
		try {
			Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
			User testUser = TestClassUtiltity.CreateUserRecord(p.Id, 'testlgnadev@user.com', 'testUser', 'test@user.com');
			system.runAs(testUser) {
				//create test account record
				Account testAccount = TestClassUtiltity.CreateAccountRecord('Test Account');
				testAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Group Account').getRecordTypeId();
				testAccount.HCSC_Division__c = 'IL';
				testAccount.Market_Segment__c = 'LG';
				testAccount.Cluster__c = '005';
				testAccount.Region__c = 'IL';
				testAccount.District__c = '116';
				update testAccount;

				//create test opportunity record
				list<Opportunity> opportunities = TestClassUtiltity.CreateOpportunities(testAccount.Id);
				Opportunity testOpp = opportunities[0];
				testOpp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('New Sale').getRecordTypeId();

				Test.startTest();

				insert testOpp;
				//retrieve inserted opportunity field values
				testOpp = [SELECT Id, Expected_Dental_Members__c, Expected_Dental_Contracts__c,
				           Expected_Health_Members__c, Expected_Health_Contracts__c, HCSC_Division__c, Account_Market_Segment__c, Clusters__c, Region__c, District__c FROM Opportunity WHERE Id = :testOpp.Id];

				//test that the correct values are populated in the test opportunity fields
				System.assertEquals('IL', testOpp.HCSC_Division__c);
				System.assertEquals('LG', testOpp.Account_Market_Segment__c);
				System.assertEquals('005', testOpp.Clusters__c);
				System.assertEquals('IL', testOpp.Region__c);
				System.assertEquals('116', testOpp.District__c);
				System.assertEquals(null, testOpp.Expected_Dental_Members__c);
				System.assertEquals(null, testOpp.Expected_Dental_Contracts__c);
				System.assertEquals(null, testOpp.Expected_Health_Members__c);
				System.assertEquals(null, testOpp.Expected_Health_Contracts__c);

				Test.stopTest();
			}
		} catch (Exception ex) {
			System.debug('Exception: ' + ex.getMessage());
			throw ex;
		}
	}

	/**
	* @developer: Sana Fatima/Slalom LLC
	* @description: Test Method for PopulateFieldsFromAccount method in OpportunityTriggerHelper for a Renewal Opportunity
	*/
	static testMethod void PopulateFieldsFromAccountRenewalOppTest() {
		try {
			Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
			User testUser = TestClassUtiltity.CreateUserRecord(p.Id, 'testlgnadev@user.com', 'testUser', 'test@user.com');
			system.runAs(testUser) {
				//create test account record
				Account testAccount = TestClassUtiltity.CreateAccountRecord('Test Account');
				testAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Group Account').getRecordTypeId();
				testAccount.HCSC_Division__c = 'IL';
				testAccount.Market_Segment__c = 'LG';
				testAccount.Cluster__c = '005';
				testAccount.Region__c = 'IL';
				testAccount.District__c = '116';
				testAccount.Active_Dental_Members__c = 40;
				testAccount.Active_Dental_Subscribers__c = 42;
				testAccount.Active_Health_Members__c = 50;
				testAccount.Active_Health_Subscribers__c = 52;
				update testAccount;

				//create test opportunity record
				list<Opportunity> opportunities = TestClassUtiltity.CreateOpportunities(testAccount.Id);
				Opportunity testOpp = opportunities[0];
				testOpp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal').getRecordTypeId();

				Test.startTest();

				insert testOpp;
				//retrieve inserted opportunity field values
				testOpp = [SELECT Id, Expected_Dental_Members__c, Expected_Dental_Contracts__c,
				           Expected_Health_Members__c, Expected_Health_Contracts__c, HCSC_Division__c, Account_Market_Segment__c, Clusters__c, Region__c, District__c FROM Opportunity WHERE Id = :testOpp.Id];

				//test that the correct values are populated in the test opportunity fields
				System.assertEquals('IL', testOpp.HCSC_Division__c);
				System.assertEquals('LG', testOpp.Account_Market_Segment__c);
				System.assertEquals('005', testOpp.Clusters__c);
				System.assertEquals('IL', testOpp.Region__c);
				System.assertEquals('116', testOpp.District__c);
				System.assertEquals(40, testOpp.Expected_Dental_Members__c);
				System.assertEquals(42, testOpp.Expected_Dental_Contracts__c);
				System.assertEquals(50, testOpp.Expected_Health_Members__c);
				System.assertEquals(52, testOpp.Expected_Health_Contracts__c);

				Test.stopTest();
			}
		} catch (Exception ex) {
			System.debug('Exception: ' + ex.getMessage());
			throw ex;
		}
	}

	/**
	* @developer: Nick Serafin/Slalom LLC
	* @description: Test Method for PopulateRenewalProducts method in OpportunityTriggerHelper for a Renewal Opportunity
	*/
	static testMethod void PopulateRenewalProducts() {
		try {
			Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
			User testUser = TestClassUtiltity.CreateUserRecord(p.Id, 'testlgnadev@user.com', 'testUser', 'test@user.com');
			system.runAs(testUser) {

				Account testAccount = TestClassUtiltity.CreateAccountRecord('Test Account');
				testAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Group Account').getRecordTypeId();
				testAccount.HCSC_Division__c = 'IL';
				testAccount.Funding_Type__c = 'ACAP';
				update testAccount;

				list<Product2> product = TestClassUtiltity.createProducts();
				product[0].Name = 'HMO';
				product[0].HCSC_State__c = 'IL';
				product[0].Product_Type__c = 'Medical';
				product[0].Simplified_Product__c = 'HMO';
				insert product;

				Group_Section__c temp = new Group_Section__c();
				temp.Group_Account__c = testAccount.id;
				temp.status__c = 'Active';
				temp.Total_Healthcare_Active_Members__c = 10;
				temp.Total_Active_Subscribers__c = 5;
				insert temp;







				Benefit_Agreement__c TestBnftAgrmt6 = new Benefit_Agreement__c ();
				TestBnftAgrmt6.Group_Account__c = testAccount.id;
				TestBnftAgrmt6.Effective_Date__c =  system.today() - 1;
				TestBnftAgrmt6.Product__c = product[0].id;
				TestBnftAgrmt6.Status__c = 'Active';
				TestBnftAgrmt6.Funding_Type__c = 'PAR';
				TestBnftAgrmt6.Renewal_Date__c = system.today();
				insert TestBnftAgrmt6;

				Benefit_Agreement__c TestBnftAgrmt7 = new Benefit_Agreement__c ();
				TestBnftAgrmt7.Group_Account__c = testAccount.id;
				TestBnftAgrmt7.Effective_Date__c =  system.today() - 1;
				TestBnftAgrmt7.Product__c = product[0].id;
				TestBnftAgrmt7.Status__c = 'Active';
				TestBnftAgrmt7.Funding_Type__c = 'ASO';
				TestBnftAgrmt7.Renewal_Date__c = system.today();
				insert TestBnftAgrmt7;

			/*	Benefit_Agreement__c TestBnftAgrmt8 = new Benefit_Agreement__c ();
				TestBnftAgrmt8.Group_Account__c = testAccount.id;
				TestBnftAgrmt8.Effective_Date__c =  system.today() - 1;
				TestBnftAgrmt8.Product__c = product[0].id;
				TestBnftAgrmt8.Status__c = 'Active';
				TestBnftAgrmt8.Funding_Type__c = 'MPP';
				TestBnftAgrmt8.Renewal_Date__c = system.today();
				insert TestBnftAgrmt8;

				BA_GS_Assignment__c tempBAGS10 = new BA_GS_Assignment__c();
				tempBAGS10.Benefit_Agreement__c = TestBnftAgrmt8.id;
				tempBAGS10.Group_Section__c = temp.id;
				tempBAGS10.External_ID__c = '101454234556846';
				insert tempBAGS10;*/



				BA_GS_Assignment__c tempBAGS12 = new BA_GS_Assignment__c();
				tempBAGS12.Benefit_Agreement__c = TestBnftAgrmt7.id;
				tempBAGS12.Group_Section__c = temp.id;
				tempBAGS12.External_ID__c = '10145423454546';
				insert tempBAGS12;

				BA_GS_Assignment__c tempBAGS8 = new BA_GS_Assignment__c();
				tempBAGS8.Benefit_Agreement__c = TestBnftAgrmt6.id;
				tempBAGS8.Group_Section__c = temp.id;
				tempBAGS8.External_ID__c = '1010123454546';
				insert tempBAGS8;



				Opportunity opp2 = new Opportunity(AccountId = testAccount.Id, HCSC_Division__c = 'IL', Name = 'oppName 2', StageName = 'Expected In', CloseDate = system.Today(), Expected_RFP_Release_Date__c = system.Today().addYears(1), Expected_Decision_Date__c = system.Today().addYears(1), RFI_RFP_Received_Date__c = system.Today().addYears(1), Primary_Closed_Reason__c = 'Savings');
				opp2.Requested_Effective_Date__c = System.Today() - 1;
				opp2.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('New Sale').getRecordTypeId();
				insert opp2;

				list<Opportunity_Product__c> OpptyProd2 = TestClassUtiltity.createOppProducts(opp2.id, product[0].Id);
				OpptyProd2[0].Status__c = 'Won';
				OpptyProd2[0].State__c = 'IL';
				OpptyProd2[0].Product__c = product[0].id;
				insert OpptyProd2;

				opp2.StageName = 'Won';
				opp2.Date_Closed__c = system.today();
				update opp2;


				list<Opportunity> opportunities = TestClassUtiltity.CreateOpportunities(testAccount.Id);
				Opportunity testOpp = opportunities[0];
				testOpp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal').getRecordTypeId();

				Test.startTest();

				insert testOpp;

				List<Opportunity_Product__c> prod = [SELECT id FROM Opportunity_Product__c WHERE Opportunity_Name__c = :testOpp.Id];

				system.assertEquals(2, prod.size());

				Test.stopTest();
			}
		} catch (Exception ex) {
			System.debug('Exception: ' + ex.getMessage());
			throw ex;
		}

	}

	static testMethod void PopulateRenewalProducts2() {
		try {
			Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
			User testUser = TestClassUtiltity.CreateUserRecord(p.Id, 'testlgnadev@user.com', 'testUser', 'test@user.com');
			system.runAs(testUser) {

				Account testAccount = TestClassUtiltity.CreateAccountRecord('Test Account');
				testAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Group Account').getRecordTypeId();
				testAccount.HCSC_Division__c = 'IL';
				testAccount.Funding_Type__c = 'ACAP';
				update testAccount;

				list<Product2> product = TestClassUtiltity.createProducts();
				product[0].Name = 'HMO';
				product[0].HCSC_State__c = 'IL';
				product[0].Product_Type__c = 'Medical';
				product[0].Simplified_Product__c = 'HMO';
				insert product;

				Group_Section__c temp = new Group_Section__c();
				temp.Group_Account__c = testAccount.id;
				temp.status__c = 'Active';
				temp.Total_Healthcare_Active_Members__c = 10;
				temp.Total_Active_Subscribers__c = 5;
				insert temp;

				Benefit_Agreement__c TestBnftAgrmt1 = new Benefit_Agreement__c();
				TestBnftAgrmt1.Group_Account__c = testAccount.id;
				TestBnftAgrmt1.Effective_Date__c =  system.today() - 1;
				TestBnftAgrmt1.Product__c = product[0].id;
				TestBnftAgrmt1.Renewal_Date__c = system.today();
				TestBnftAgrmt1.Status__c = 'Active';
				TestBnftAgrmt1.Funding_type__c = 'ACAP';
				insert TestBnftAgrmt1;

				Benefit_Agreement__c TestBnftAgrmt2 = new Benefit_Agreement__c();
				TestBnftAgrmt2.Group_Account__c = testAccount.id;
				TestBnftAgrmt2.Effective_Date__c =  system.today() - 1;
				TestBnftAgrmt2.Product__c = product[0].id;
				TestBnftAgrmt2.Renewal_Date__c = system.today();
				TestBnftAgrmt2.Status__c = 'Active';
				TestBnftAgrmt2.Funding_type__c = 'PREM';
				insert TestBnftAgrmt2;


				BA_GS_Assignment__c tempBAGS2 = new BA_GS_Assignment__c();
				tempBAGS2.Benefit_Agreement__c = TestBnftAgrmt2.id;
				tempBAGS2.Group_Section__c = temp.id;
				tempBAGS2.External_ID__c = '101011234';
				insert tempBAGS2;

				BA_GS_Assignment__c tempBAGS = new BA_GS_Assignment__c();
				tempBAGS.Benefit_Agreement__c = TestBnftAgrmt1.id;
				tempBAGS.Group_Section__c = temp.id;
				tempBAGS.External_ID__c = '101011';
				insert tempBAGS;

				Opportunity opp2 = new Opportunity(AccountId = testAccount.Id, HCSC_Division__c = 'IL', Name = 'oppName 2', StageName = 'Expected In', CloseDate = system.Today(), Expected_RFP_Release_Date__c = system.Today().addYears(1), Expected_Decision_Date__c = system.Today().addYears(1), RFI_RFP_Received_Date__c = system.Today().addYears(1), Primary_Closed_Reason__c = 'Savings');
				opp2.Requested_Effective_Date__c = System.Today() - 1;
				opp2.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('New Sale').getRecordTypeId();
				insert opp2;

				list<Opportunity_Product__c> OpptyProd2 = TestClassUtiltity.createOppProducts(opp2.id, product[0].Id);
				OpptyProd2[0].Status__c = 'Won';
				OpptyProd2[0].State__c = 'IL';
				OpptyProd2[0].Product__c = product[0].id;
				insert OpptyProd2;

				opp2.StageName = 'Won';
				opp2.Date_Closed__c = system.today();
				update opp2;


				list<Opportunity> opportunities = TestClassUtiltity.CreateOpportunities(testAccount.Id);
				Opportunity testOpp = opportunities[0];
				testOpp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal').getRecordTypeId();

				Test.startTest();

				insert testOpp;

				List<Opportunity_Product__c> prod = [SELECT id FROM Opportunity_Product__c WHERE Opportunity_Name__c = :testOpp.Id];

				system.assertEquals(2, prod.size());

				Test.stopTest();
			}
		} catch (Exception ex) {
			System.debug('Exception: ' + ex.getMessage());
			throw ex;
		}
	}

	/**
	* @developer: Ralph Tariga/Slalom LLC
	* @description: Test Method for PopulateFieldsFromAccountCheckAccountTeamForUnderwriter method in OpportunityTriggerHelper for a Renewal Opportunity
	*/
	static testMethod void CheckAccountTeamForUnderwriterTest() {
		try {
			Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
			User testUser = TestClassUtiltity.CreateUserRecord(p.Id, 'testlgnadev@user.com', 'testUser', 'test@user.com');

			System.runAs(testUser) {
				List<RenewalOpportunityStages__c> stages = new List<RenewalOpportunityStages__c>();
				stages.add(new RenewalOpportunityStages__c(Name = 'Finalist Named', Stage_to_Check__c = 'Finalist Named'));
				stages.add(new RenewalOpportunityStages__c(Name = 'Renewal Delivered', Stage_to_Check__c = 'Renewal Delivered'));
				stages.add(new RenewalOpportunityStages__c(Name = 'Renewal In Negotiation', Stage_to_Check__c = 'Renewal In Negotiation'));
				stages.add(new RenewalOpportunityStages__c(Name = 'Renewal Initiated', Stage_to_Check__c = 'Renewal Initiated'));
				stages.add(new RenewalOpportunityStages__c(Name = 'Won', Stage_to_Check__c = 'Won'));
				insert stages;

				List<Account> accList = new List<Account>();

				//create test account record
				Account testAccount = new Account(Name = 'Test Account', Fax = '1234567', Effective_Date__c = system.today().addyears(2));
				testAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Group Account').getRecordTypeId();
				testAccount.HCSC_Division__c = 'IL';
				testAccount.Market_Segment__c = 'LG';
				testAccount.Cluster__c = '005';
				testAccount.Region__c = 'IL';
				testAccount.District__c = '116';
				testAccount.Active_Dental_Members__c = 40;
				testAccount.Active_Dental_Subscribers__c = 42;
				testAccount.Active_Health_Members__c = 50;
				testAccount.Active_Health_Subscribers__c = 52;
				accList.add(testAccount);

				Account testAccount2 = new Account(Name = 'Test Account 2', Fax = '1234567', Effective_Date__c = system.today().addyears(2));
				testAccount2.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Group Account').getRecordTypeId();
				testAccount2.HCSC_Division__c = 'IL';
				testAccount2.Market_Segment__c = 'LG';
				testAccount2.Cluster__c = '005';
				testAccount2.Region__c = 'IL';
				testAccount2.District__c = '116';
				testAccount2.Active_Dental_Members__c = 40;
				testAccount2.Active_Dental_Subscribers__c = 42;
				testAccount2.Active_Health_Members__c = 50;
				testAccount2.Active_Health_Subscribers__c = 52;
				accList.add(testAccount2);

				insert accList;

				String teamMemberRole = 'Underwriter';
				String accountAccessLevel = 'Edit';
				String opportunityAccessLevel = 'Edit';
				String caseAccessLevel = 'Edit';
				String contactAccessLevel = 'Edit';
				List<AccountTeamMember> members = new list<AccountTeamMember>();
				List<AccountShare> sharingRules = new list<AccountShare>();

				members.add(new AccountTeamMember(AccountId = testAccount2.Id, TeamMemberRole = teamMemberRole, UserId = testUser.Id));
				//sharingRules.add(new AccountShare(AccountAccessLevel = accountAccessLevel, OpportunityAccessLevel = opportunityAccessLevel, CaseAccessLevel = caseAccessLevel, UserOrGroupId = testUser.Id, AccountId = testAccount2.Id));

				insert members;
				//insert sharingRules;

				//create test opportunity record
				list<Opportunity> opportunities = TestClassUtiltity.CreateOpportunities(testAccount.Id);
				Opportunity testOpp = opportunities[0];
				testOpp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal').getRecordTypeId();
				testOpp.StageName = 'Renewal Planning';

				list<Opportunity> opportunities2 = TestClassUtiltity.CreateOpportunities(testAccount2.Id);
				Opportunity testOpp2 = opportunities2[0];
				testOpp2.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal').getRecordTypeId();
				testOpp2.StageName = 'Renewal Planning';

				opportunities.addAll(opportunities2);
				insert opportunities;

				Test.startTest();

				testOpp.StageName = 'Renewal Initiated';
				testOpp2.StageName = 'Renewal Initiated';

				try {
					update testOpp;
					// Update Operation not supposed to succeed. If it does, force an exception to fail the test.
					List<Opportunity> makeItFail;
					makeItFail[0].Name = 'Make It Fail';
				} catch (Exception ex) {
					Opportunity resultOpp = [SELECT Id, StageName FROM Opportunity WHERE Id = :testOpp.Id];
					System.assertNotEquals('Renewal Initiated', resultOpp.StageName);
				}

				update testOpp2;
				Opportunity resultOpp2 = [SELECT Id, StageName FROM Opportunity WHERE Id = :testOpp2.Id];
				System.assertEquals('Renewal Initiated', resultOpp2.StageName);

				Test.stopTest();
			}
		} catch (Exception ex) {
			System.debug('Exception: ' + ex.getMessage());
			throw ex;
		}
	}
	/**
	* @developer: Alec Klein/Slalom LLC
	* @description: Test Method for CreateProducerAssociationForOpportunity method in OpportunityTriggerHelper for any Opportunity
	*					Tests creating one Producer Association For Opportunity record
	*/
	static testMethod void CreateOneProducerAssociationForOpportunity(){
		Test.StartTest();
		Map<Id, RecordType> rtMap = new Map<Id, RecordType>([SELECT Id, Name FROM RecordType WHERE SobjectType = 'Account' AND (Name = 'Group Account' OR Name = 'Producer Account')]);
		RecordType groupAccountRecordType;
		RecordType producerAccountRecordType;
		for(RecordType rt: rtMap.values()){
			if(rt.Name == 'Group Account')
				groupAccountRecordType = rt;
			else if(rt.Name == 'Producer Account')
				producerAccountRecordType = rt;
		}
		List<Account> newAccounts = new List<Account>();
	    Account newGroupAccount = new Account(Name = 'TestGroupAccount', RecordTypeId = groupAccountRecordType.Id, HCSC_Division__C = 'IL');
		Account newProducerAccount = new Account(Name = 'TestProspectAccount', RecordTypeId = producerAccountRecordType.Id);

		newAccounts.add(newGroupAccount);
		newAccounts.add(newProducerAccount);
		insert newAccounts;

		Producer_Group_Association__c pga = new Producer_Group_Association__c(Group_Account__c=newGroupAccount.Id, Producer_Account__c = newProducerAccount.Id, External_ID__c = 'ThisIDIsUnique');
		insert pga;
		Opportunity newOpp = new Opportunity(Name = 'TestOpportunity', AccountId = newGroupAccount.Id, RFI_RFP_Received_Date__c = System.today(), StageName = 'Test', CloseDate = System.today()+5);
		insert newOpp;
		System.assert([SELECT Opportunity__c FROM Producer_Association_For_Opportunity__c WHERE Opportunity__c =: newOpp.Id].size() == 1);
		Test.StopTest();
	}

	/**
	* @developer: Alec Klein/Slalom LLC
	* @description: Test Method for CreateProducerAssociationForOpportunity method in OpportunityTriggerHelper for any Opportunity
	*					Tests creating one Producer Association For Opportunity records, where one Producer Account is inactive
	*/
	static testMethod void CreateTwoProducerAssociationForOpportunity(){
		Test.StartTest();
		Map<Id, RecordType> rtMap = new Map<Id, RecordType>([SELECT Id, Name FROM RecordType WHERE SobjectType = 'Account' AND (Name = 'Group Account' OR Name = 'Producer Account')]);
		RecordType groupAccountRecordType;
		RecordType producerAccountRecordType;
		for(RecordType rt: rtMap.values()){
			if(rt.Name == 'Group Account')
				groupAccountRecordType = rt;
			else if(rt.Name == 'Producer Account')
				producerAccountRecordType = rt;
		}

		List<Account> newAccounts = new List<Account>();
	    Account newGroupAccount = new Account(Name = 'TestGroupAccount', RecordTypeId = groupAccountRecordType.Id, HCSC_Division__C = 'IL');
		Account newProducerAccount1 = new Account(Name = 'TestProspectAccount1', RecordTypeId = producerAccountRecordType.Id, Status__c = 'Active');
		Account newProducerAccount2 = new Account(Name = 'TestProspectAccount2', RecordTypeId = producerAccountRecordType.Id, Status__c = 'Inactive');
		newAccounts.add(newGroupAccount);
		newAccounts.add(newProducerAccount1);
		newAccounts.add(newProducerAccount2);
		insert newAccounts;

		List<Producer_Group_Association__c> newPGAs = new List<Producer_Group_Association__c>();
		Producer_Group_Association__c pga1 = new Producer_Group_Association__c(Group_Account__c=newGroupAccount.Id, Producer_Account__c = newProducerAccount1.Id, External_ID__c = 'ThisIDIsUnique');
		Producer_Group_Association__c pga2 = new Producer_Group_Association__c(Group_Account__c=newGroupAccount.Id, Producer_Account__c = newProducerAccount2.Id, External_ID__c = 'ThisIDIsUniqueAlso');
		newPGAs.add(pga1);
		newPGAs.add(pga2);
		insert newPGAs;

		Opportunity newOpp = new Opportunity(Name = 'TestOpportunity', AccountId = newGroupAccount.Id, RFI_RFP_Received_Date__c = System.today(), StageName = 'Test', CloseDate = System.today()+5);
		insert newOpp;
		System.assert([SELECT Opportunity__c FROM Producer_Association_For_Opportunity__c WHERE Opportunity__c =: newOpp.Id].size() == 1);
		Test.StopTest();
	}
}