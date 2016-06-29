@isTest
private class NPNTriggerHandlerTest {


	@isTest
	static void testAddUpdateOfProducer() {
		Test.startTest();
		//Declare variables
		Id recTypeProducer = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Producer Account').getRecordTypeId();
		Id recTypeHouse = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Producer House').getRecordTypeId();
		List<National_Producer_Number__c> npnList;
		List<Account> accountList;

		try{

			//1b.If NPN entered not already associated with any producer house, save producer and create NPN
			Account house1 = TestClassUtiltity.createAccountWithRecType('House1', recTypeHouse);
			Account producer1 = TestClassUtiltity.createAccountWithRecType('Producer1', recTypeProducer);
			producer1.ParentId = house1.Id;
			producer1.National_Producer_Number__c = '1111111111';
			update producer1;

			//1a. If NPN entered already associated with the parent producer house selected, just add new producer
			Account producer2 = TestClassUtiltity.createAccountWithRecType('Producer2', recTypeProducer);
			producer2.ParentId = house1.Id;
			producer2.National_Producer_Number__c = '1111111111';
			update producer2;

			npnList = [SELECT House_Account__c, NPN__c, Producer_Count__c from National_Producer_Number__c
				where House_Account__c =: house1.Id];
			National_Producer_Number__c npn1 = npnList[0];

			System.assertEquals(1, npnList.size());
			System.assertEquals(producer1.National_Producer_Number__c, npnList[0].NPN__c);
			System.assertEquals(producer2.National_Producer_Number__c, npnList[0].NPN__c);

			//2a.If NPN not already associated to any house account, just save the producer house with no parent.
			Account house2 = TestClassUtiltity.createAccountWithRecType('House1', recTypeHouse);
			Account producer3 = TestClassUtiltity.createAccountWithRecType('Producer3', recTypeProducer);
			producer3.National_Producer_Number__c = '2222222222';
			update producer3;

			accountList = [SELECT Name, National_Producer_Number__c, ParentId from Account where Id =: producer3.Id];

			System.assertEquals(null, producer3.parentId);

			//2b.If NPN is already associated to house account, set the parent as the related house.
			National_Producer_Number__c npn2 = new National_Producer_Number__c(House_Account__c = house2.id, NPN__c = '2222222222');
			insert npn2;

			accountList = [SELECT Name, National_Producer_Number__c, ParentId from Account where Id =: producer3.Id];

			//Account parent should have been updated to house 2 now that the NPN has been added.
			System.assertEquals(house2.Id, accountList[0].ParentId);
			System.assertEquals(npn2.NPN__c, accountList[0].National_Producer_Number__c);

			Account producer4 = TestClassUtiltity.createAccountWithRecType('Producer4', recTypeProducer);
			producer4.National_Producer_Number__c = npn2.NPN__c;
			update producer4;

			List <Id> acct34Ids = new List<Id>();
			acct34Ids.add(producer3.Id);
			acct34Ids.add(producer4.Id);

			accountList = [SELECT Name, National_Producer_Number__c, ParentId from Account where Id IN : acct34Ids];
			List<National_Producer_Number__c> npn2List = [SELECT Producer_Count__c from National_Producer_Number__c where NPN__c =: npn2.NPN__c];

			for(Account a: accountList){
				if (a.Id == producer4.Id){
					//Producer 4 should get the parent2 based on NPN
					System.assertEquals(house2.Id, a.ParentId);
					System.assertEquals(npn2.NPN__c, a.National_Producer_Number__c);
					System.assertEquals(2, npn2List[0].Producer_Count__c);
				}

				if (a.Id == producer3.Id){
				//Producer3 should get parent of house 2 based on new NPN record created that matched its NPN;
				System.assertEquals(house2.Id, a.ParentId);
				}
			}

		}catch(Exception ex){
			System.debug('ERROR: ' + ex.getMessage() );
		}
		Test.stopTest();
	}

	@isTest
	static void testNPNRecordCreation() {

		Test.startTest();
		//Declare variables
		Id recTypeProducer = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Producer Account').getRecordTypeId();
		Id recTypeHouse = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Producer House').getRecordTypeId();
		List<National_Producer_Number__c> npnList;
		List<Account> accountList;

		try{

			//3a. When adding a new NPN , system should scan to find any producer account with that NPN and update the parent to the house account.
			Account house1 = TestClassUtiltity.createAccountWithRecType('House1', recTypeHouse);
			Account producer1 = TestClassUtiltity.createAccountWithRecType('Producer1', recTypeProducer);
			producer1.ParentId = house1.Id;
			producer1.National_Producer_Number__c = '1111111111';
			update producer1;

			Account producer2 = TestClassUtiltity.createAccountWithRecType('Producer2', recTypeProducer);
			producer2.ParentId = house1.Id;
			producer2.National_Producer_Number__c = '1111111111';
			update producer2;

			Account house2 = TestClassUtiltity.createAccountWithRecType('House1', recTypeHouse);
			Account producer3 = TestClassUtiltity.createAccountWithRecType('Producer3', recTypeProducer);
			producer3.ParentId = house2.Id;
			producer3.National_Producer_Number__c = '1111111111';
			update producer3;

			npnList = [SELECT House_Account__c, NPN__c, Producer_Count__c from National_Producer_Number__c
				where House_Account__c =: house1.Id];

			System.assertEquals(1, npnList.size());
			National_Producer_Number__c npn1 = npnList[0];
			System.assertEquals(House1.Id, npnList[0].House_Account__c);
			
			System.assertEquals(null, accountList[0].ParentId);
			System.assertEquals(null, accountList[0].National_Producer_Number__c);

		}catch(Exception ex){
				System.debug('ERROR: ' + ex.getMessage());
		}
		Test.stopTest();
	}

	@isTest
	static void testDeleteScenario(){
		Test.startTest();
		//Declare variables
		Id recTypeProducer = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Producer Account').getRecordTypeId();
		Id recTypeHouse = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Producer House').getRecordTypeId();
		List<National_Producer_Number__c> npnList;
		List<Account> accountList;

		try{
			Account house1 = TestClassUtiltity.createAccountWithRecType('House1', recTypeHouse);
			Account producer1 = TestClassUtiltity.createAccountWithRecType('Producer1', recTypeProducer);
			producer1.ParentId = house1.Id;
			producer1.National_Producer_Number__c = '1111111111';
			update producer1;

			npnList = [SELECT House_Account__c, NPN__c, Producer_Count__c from National_Producer_Number__c
				where House_Account__c =: house1.Id];

			National_Producer_Number__c npn1 = npnList[0];

			delete npn1;
		}catch(Exception ex){
			System.debug('ERROR: ' + ex.getMessage());
		}

		Test.stopTest();
	}
}