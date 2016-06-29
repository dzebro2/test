/**************************************************************************************
  Apex Class Name     : TestDisplayResultsController
  Version             : 1.0
  Function            : This class serves as Unit Test Class for DisplayResultsController
  Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
*   Dinesh Talreja       14/11/2014                Original Version
*************************************************************************************/

@isTest

public class TestDisplayResultsController{
    
    /*  TestGroupAccount
    *   @description:   This method is used to test the Search Criteria as Group Account of DisplayResultsController
    *   @parameters     N/A
    *   @return type    N/A                     
    */
    public static testMethod void TestGroupAccount(){
       
        RecordType GroupAccountRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Account' AND Name = 'Group Account'];
        
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.External_Id__c = '1234';
        acc.recordTypeId = GroupAccountRecordType.id;
        insert acc;
        
        System.assertEquals(acc.Name,'Test Account');
        
        PageReference pageRef = Page.DisplayResults;
        pageRef.getParameters().put('accountName','Test Account');
        pageRef.getParameters().put('accountID','1234');
        pageRef.getParameters().put('accountType','Group Account');
        pageRef.getParameters().put('search','Account');
        
        Test.setCurrentPage(pageRef);
        Test.startTest();
        DisplayResultsController controllerObj = new DisplayResultsController();    
        Test.stopTest();
    }
    /*  TestProducerAccount
    *   @description:   This method is used to test the Search Criteria as Producer Account of DisplayResultsController
    *   @parameters     N/A
    *   @return type    N/A                     
    */
    public static testMethod void TestProducerAccount(){
        
        
        RecordType ProducerAccountRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Account' AND Name = 'Producer Account'];
        
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.External_Id__c = '1234';
        acc.recordTypeId = ProducerAccountRecordType.id;
        insert acc;
        
        System.assertEquals(acc.Name,'Test Account');
        
        PageReference pageRef = Page.DisplayResults;
        pageRef.getParameters().put('accountName','Test Account');
        pageRef.getParameters().put('accountID','1234');
        pageRef.getParameters().put('accountType','Producer Account');
        pageRef.getParameters().put('search','Account');
        
        Test.setCurrentPage(pageRef);
        Test.startTest();
        DisplayResultsController controllerObj = new DisplayResultsController();    
        Test.stopTest();
    }
    /*  TestGroupContact
    *   @description:   This method is used to test the Search Criteria as Group Contact of DisplayResultsController
    *   @parameters     N/A
    *   @return type    N/A                     
    */
    public static testMethod void TestGroupContact(){
    
        
        RecordType GroupAccountRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Account' AND Name = 'Group Account'];
        RecordType GroupContactRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Contact' AND Name = 'Group Contact'];
        
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.External_Id__c = '1234';
        acc.recordTypeId = GroupAccountRecordType.id;
        insert acc;
        
        System.assertEquals(acc.Name,'Test Account');
        
        Contact con = new Contact();
        con.FirstName = 'Test';
        con.LastName = 'Contact';
        con.External_Id__c = '1234';
        con.Phone = '8007541100';
        con.Email = 'dtalreja@deloitte.com';
        con.AccountId = acc.Id;
        con.RecordTypeId = GroupContactRecordType.Id;
        insert con;
        
        System.assertEquals(con.FirstName,'Test');
        
        PageReference pageRef = Page.DisplayResults;
        pageRef.getParameters().put('contactName','Test Contact');
        pageRef.getParameters().put('contactID','1234');
        pageRef.getParameters().put('contactPhone','8007541100');
        pageRef.getParameters().put('contactEmail','dtalreja@deloitte.com');
        pageRef.getParameters().put('contactType','Group Contact');
        pageRef.getParameters().put('search','Contact');
        
        Test.setCurrentPage(pageRef);
        Test.startTest();
        DisplayResultsController controllerObj = new DisplayResultsController();    
        Test.stopTest();
    }
    /*  TestProducerContact
    *   @description:   This method is used to test the Search Criteria as Producer Contact of DisplayResultsController
    *   @parameters     N/A
    *   @return type    N/A                     
    */
    public static testMethod void TestProducerContact(){
        
        
        RecordType ProducerAccountRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Account' AND Name = 'Producer Account'];
        RecordType ProducerContactRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Contact' AND Name = 'Producer Contact'];
        
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.External_Id__c = '1234';
        acc.recordTypeId = ProducerAccountRecordType.id;
        insert acc;
        
        System.assertEquals(acc.Name,'Test Account');
        
        Contact con = new Contact();
        con.FirstName = 'Test';
        con.LastName = 'Contact';
        con.External_Id__c = '1234';
        con.Phone = '8007541100';
        con.Email = 'dtalreja@deloitte.com';
        con.AccountId = acc.Id;
        con.RecordTypeId = ProducerContactRecordType.Id;
        insert con;
        
        System.assertEquals(con.FirstName,'Test');
        
        PageReference pageRef = Page.DisplayResults;
        pageRef.getParameters().put('contactName','Test Contact');
        pageRef.getParameters().put('contactID','1234');
        pageRef.getParameters().put('contactPhone','8007541100');
        pageRef.getParameters().put('contactEmail','dtalreja@deloitte.com');
        pageRef.getParameters().put('contactType','Producer Contact');
        pageRef.getParameters().put('search','Contact');
        
        Test.setCurrentPage(pageRef);
        Test.startTest();
        DisplayResultsController controllerObj = new DisplayResultsController();    
        Test.stopTest();
    }
}