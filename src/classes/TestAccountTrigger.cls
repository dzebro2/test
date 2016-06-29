/**************************************************************************************
  Apex Class Name     : TestAccountTrigger
  Version             : 1.0
  Function            : This is a test class for AccountTrigger and its handler AccountTriggerHandler.
  Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
*   Suyog Dongaonkar       11/21/2014                Original Version
*************************************************************************************/

@isTest
private class TestAccountTrigger {

    /*  TestAccountTriggerAfterInsert
    *   @description:   This method tests AccountTrigger after insert.
    *   @parameters     null
    *   @return type    void                        
    */
    public static testMethod void TestAccountTriggerAfterInsert(){
        
        Account acc = new Account();
        acc.Name            = 'test account';
        acc.RecordTypeId    = Schema.SObjectType.Account.getRecordTypeInfosByName().get( Label.Producer_Account ).getRecordTypeId();
        acc.Type            = 'Sub Producer';
        acc.External_Id__c  = '1234';
        acc.Email__c        = 'test@test.com'; 
        
        Test.startTest();
        
        insert acc;
        
        Test.stopTest();
        
        List<Contact> contacts = [  select  Id, LastName, Email
                                    from    Contact
                                    where   AccountId = :acc.Id
                                    limit   1];
        System.assert( contacts.size() == 1 );
        System.assert( contacts[0].LastName == 'test account' );
        System.assert( contacts[0].Email == 'test@test.com' );
        
    }
    
    
    /*  TestAccountTriggerAfterInsert
    *   @description:   This method tests AccountTrigger after update.
    *   @parameters     null
    *   @return type    void                        
    */  
    public static testMethod void TestAccountTriggerAfterUpdate(){
        
        Account acc         = new Account();
        acc.Name            = 'test account';
        acc.RecordTypeId    = Schema.SObjectType.Account.getRecordTypeInfosByName().get( Label.Producer_Account ).getRecordTypeId();
        acc.Type            = 'Sub Producer';
        acc.External_Id__c  = '1234';
        acc.Email__c        = 'test@test.com'; 
        
        insert acc;

        List<Contact> contacts = [  select  Id, LastName, Email
                                    from    Contact
                                    where   AccountId = :acc.Id
                                    limit   1];
        System.assert( contacts.size() == 1 );
        System.assert( contacts[0].LastName == 'test account' );        
        System.assert( contacts[0].Email == 'test@test.com' );
        
        Test.startTest();
        
        acc.Email__c    = 'testupdated@test.com';
        update acc;
        
        Test.stopTest();

        contacts = [    select  Id, LastName, Email
                        from    Contact
                        where   AccountId = :acc.Id
                        limit   1];
        System.assert( contacts.size() == 1 );
        
        System.assert( contacts[0].Email == 'testupdated@test.com' );
    }
}