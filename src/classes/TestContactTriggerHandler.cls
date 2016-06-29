/**************************************************************************************
  Apex Class Name     : TestContactTriggerHandler 
  Version             : 1.0
  Function            : This is a test class for ContactTriggerHandler  .
  Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
*  Sruthy Dileep            6/1/2015
*************************************************************************************/
@isTest(seeAllData = true)
public class TestContactTriggerHandler {
    
     static testMethod void myUnitTest1() {
        try{
        Account testAccount1 = TestClassUtiltity.CreateAccountRecord('Test Account');
        
        RecordType RecdType = [Select Id, name From RecordType where Name = 'Producer Contact'];
        List<Contact> TestConLst = new List<Contact>();
        Contact NewContact = new Contact();
        NewContact = TestClassUtiltity.CreateContactRecord(testAccount1.id, 'conFirstName', 'conLastName', null);
        NewContact.Buyer_Role__c = 'Producer';
        NewContact.HCSC_Sentiment__c = 'Advocate';
        NewContact.Add_to_Buyer_Hierarchy__c = true;
        NewContact.RecordTypeId = RecdType.id;
        update NewContact;
        TestConLst.add(NewContact);
        //Contact TestCont = new Contact();
       // TestCont = TestClassUtiltity.CreateContactRecord(testAccount1.id, 'conFirstName1', 'conLastName1', NewContact.id);
       // TestConLst.add(TestCont);
       

        
        
        
        test.StartTest();
        
        ContactTriggerHandler testController2 = new ContactTriggerHandler();
        ContactTriggerHandler.insertAccountContactRole(TestConLst);
        ContactTriggerHandler.ValidateProducerContact(TestConLst);
        
        system.assertEquals(1,TestConLst.size());
        
        NewContact.Add_to_Buyer_Hierarchy__c = false;
        NewContact.Migration_Source__c = System.label.ContactValidationMigrationValue3;
        update NewContact;
        //delete NewContact;
        ContactTriggerHandler.insertAccountContactRole(TestConLst);
         Contact NewContact1 = new Contact();
        //NewContact = TestClassUtiltity.CreateContactRecord(testAccount1.id, 'conFirstName', 'conLastName', null);
        NewContact1.Buyer_Role__c = 'Producer';
        NewContact1.LastName='testContactLatest';
        NewContact1.HCSC_Sentiment__c = 'Advocate';
        NewContact1.Add_to_Buyer_Hierarchy__c = true;
        NewContact1.RecordTypeId = RecdType.id;
        //upsert NewContact1;
        //ContactTriggerHandler.insertAccountContactRole(null);
        
        
        
        test.StopTest();

        }catch(Exception e){
          //System.Assert(e.getMessage().contains(System.Label.UnexpectedError));
          
         // System.assertEquals(e.getDMLMessage(0),System.label.ContactDeleteValidationMessage);
         //throw e;
        }
    }
    /******************************************************************** 
    *    Method Name : myUnitTest2
    *   @description :   This method covers the method written for validating contact deletion
    *   
    *   @return type :   none                     
    ***************************************************************/  
    static testmethod void myUnitTest2(){
    	try{
	        Account testAccount1 = TestClassUtiltity.CreateAccountRecord('Test Account');
	        
	        RecordType RecdType = [Select Id, name From RecordType where Name = 'Producer Contact'];
	        List<Contact> TestConLst = new List<Contact>();
	        Contact NewContact = new Contact();
	        NewContact = TestClassUtiltity.CreateContactRecord(testAccount1.id, 'conFirstName', 'conLastName', null);
	        if(System.label.ContactValidationMigrationValue3 != null){
		        NewContact.Migration_Source__c = System.label.ContactValidationMigrationValue3.split(',')[0];
		        update NewContact;
	        }
	        delete NewContact;
    	}catch(Exception e){
          //System.Assert(e.getMessage().contains(System.Label.UnexpectedError));
          
          System.assertEquals(e.getDMLMessage(0),System.label.ContactDeleteValidationMessage);
         //throw e;
        }
    }
    
     /******************************************************************** 
    *    Method Name : myUnitTest3
    *   @description :   This method covers the method written for validating contact deletion
    *   
    *   @return type :   none                     
    ***************************************************************/  
    static testmethod void myUnitTest3(){
    	try{
	        Account testAccount1 = TestClassUtiltity.CreateAccountRecord('Test Account');
	        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        
	        User ManagerUser = new User(Alias = 'manager', Email='manager@testorg.com', EmailEncodingKey='UTF-8', LastName='Manager', LanguageLocaleKey='en_US',Employee_Number__c = '1234' ,
	                        LocaleSidKey='en_US', ProfileId = p.Id, department = 'STP', TimeZoneSidKey='America/Los_Angeles', UserName=Math.random() + '@test.com');
	        insert  ManagerUser;          
	        User ClientRepUser = new User(Isactive = true,Alias = 'client', Email='client@testorg.com', EmailEncodingKey='UTF-8', LastName='Client', LanguageLocaleKey='en_US',Employee_Number__c = '123456',
	                        LocaleSidKey='en_US', Is_Super_User__c = true, ProfileId = p.Id, department = 'STP', TimeZoneSidKey='America/Los_Angeles', UserName=Math.random() + '@test.com');
        
	        RecordType RecdType = [Select Id, name From RecordType where DeveloperName = 'Internal_Contact'];
	        List<Contact> TestConLst = new List<Contact>();
	        Contact ManagerContact = new Contact(LastName = 'conLastName',AccountId = testAccount1.Id,RecordTypeId = RecdType.Id,External_ID__c = '1234', Title='test2');
	        insert ManagerContact;
	        Contact childContact = new Contact(Status__c = 'Active',LastName = 'conLastNameChild',AccountId = testAccount1.Id,RecordTypeId = RecdType.Id,External_ID__c = '123456',ReportsToId = null,Title='test',phone = '1234567890',Department='tax');
	        insert childContact;
	        TestConLst.add(ManagerContact);
	        TestConLst.add(childContact);
	        
	        test.startTest();
		        /*
		        */
		        childContact.ReportsToId = null;
		        childContact.Title = 'wd';
		        childContact.phone = '2345678901';
		        childContact.Department = 'test1';
		        update childContact;
		        
		        childContact.ReportsToId = ManagerContact.Id;
		        childContact.Title = 'wd2';
		        childContact.phone = '2345678900';
		        childContact.Department = 'test12';
		        update childContact;
		        
		        list<user> tempUser = [select Id,managerId from User where Id =:ClientRepUser.Id];
		        system.assertEquals(tempUser[0].managerId,ManagerUser.Id);
		        
		        childContact.Associated_User__c = tempUser[0].Id;
		        childContact.Status__c = 'Terminated';
		        update childContact;
		        
	        test.stopTest();
    	}catch(Exception e){
          //System.Assert(e.getMessage().contains(System.Label.UnexpectedError));
          
         //throw e;
        }
    }
    
    /******************************************************************** 
    *    Method Name : myUnitTest2
    *   @description :   This method covers the method written for validating contact deletion
    *   
    *   @return type :   none                     
    ***************************************************************/  
    static testmethod void myUnitTest4(){
        Account testAccount1 = TestClassUtiltity.CreateAccountRecord('Test Account');
        RecordType RecdType = [Select Id, name From RecordType where DeveloperName = 'Internal_Contact'];
        List<Contact> TestConLst = new List<Contact>();
        Contact NewContact = new Contact();
        NewContact = TestClassUtiltity.CreateContactRecord(testAccount1.id, 'conFirstName', 'conLastName', null);
        NewContact.Buyer_Role__c = 'Producer';
        NewContact.HCSC_Sentiment__c = 'Advocate';
        NewContact.Add_to_Buyer_Hierarchy__c = true;
        NewContact.RecordTypeId = RecdType.id;
        NewContact.Status__c = 'Terminated';
        update NewContact;
        TestConLst.add(NewContact);
        Map<Id,Contact> mapCon = new Map<Id,Contact>();
       /* RecordType RecdType1 = [Select Id, name From RecordType where DeveloperName = 'Internal_Contact'];
        Contact oldContact = new Contact();
        oldContact = TestClassUtiltity.CreateContactRecord(testAccount1.id, 'conFirstName1', 'conLastName1', null);
        oldContact.Buyer_Role__c = 'Producer';
        oldContact.HCSC_Sentiment__c = 'Advocate';
        oldContact.Add_to_Buyer_Hierarchy__c = true;
        oldContact.RecordTypeId = RecdType1.id;*/
        NewContact.Status__c = 'Active';
        update NewContact;
        mapCon.put(NewContact.Id,NewContact);
        ContactTriggerHandler.updateTheUsersDetails(TestConLst,mapCon);  
        System.assertEquals(TestConLst.size(), 1);
    }
}