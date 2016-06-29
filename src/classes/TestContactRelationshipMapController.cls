/**************************************************************************************
  Apex Class Name     : TestContactRelationShipController
  Version             : 1.0
  Function            : This is a test class for ContactRelationShipController .
  Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
*  
*************************************************************************************/

@isTest
public class TestContactRelationshipMapController{
    
    public static testMethod void TestMethod1(){
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User testUser = TestClassUtiltity.CreateUserRecord(p.Id, 'testlgnadev@user.com', 'testUser', 'test@user.com');
        Account testAccount = TestClassUtiltity.CreateAccountRecord('Test Account');
        
        Contact testContact1 = TestClassUtiltity.CreateContactRecord(testAccount.id, 'Test1', 'Contact1', null);
         testContact1.phone= '1234556776' ;
         testContact1.email = 'm@m.com' ;
         update testContact1;
        Contact testContact2 = TestClassUtiltity.CreateContactRecord(testAccount.id, 'Test2', 'Contact2', testContact1.id);
        Contact testContact3 = TestClassUtiltity.CreateContactRecord(testAccount.id, 'Contact3', 'testCon3', testContact2.id);
        Contact testContact4 = TestClassUtiltity.CreateContactRecord(testAccount.id, 'testCont4', 'Contact4', testContact2.id);
        Contact_Relationship__c ContactRel = TestClassUtiltity.CreateContactRelationship(testContact2.Id,testContact1.Id, testUser.Id);
        ContactRel.Related_Contact__c = null;
        ContactRel.Relationship_Info__c = 'ABCD';
        ContactRel.Account__c = testAccount.Id;
        update ContactRel;
        ApexPages.StandardController sc = new ApexPages.StandardController(testContact2);
        ContactRelationshipMapController ContactRelationshipMapControllerRec = new ContactRelationshipMapController(sc);
        
        ContactRelationshipMapControllerRec.showPrimaryContacts = false;
        ContactRelationshipMapControllerRec.showRelatedAccounts = true;
        ContactRelationshipMapControllerRec.populateContactRelationshipInfo();
        ContactRel.Related_Contact__c = testContact2.id;
        ContactRel.Related_User__c = null;
        update ContactRel;
        
        
        
        Contact_Relationship__c ContactRel2 = TestClassUtiltity.CreateContactRelationship(testContact2.Id,testContact1.Id, testUser.Id);
        ContactRel2.Related_Contact__c = testContact3.Id;
        ContactRel2.Relationship_Info__c = 'ABCD';
        update ContactRel2;
        Contact_Relationship__c ContactRel3 = TestClassUtiltity.CreateContactRelationship(testContact3.Id,testContact1.Id, testUser.Id);
       /* ContactRel3.Related_Contact__c = testContact4.Id;
        ContactRel3.Relationship_Info__c = 'ABCD';
        update ContactRel3;*/
        ContactRelationshipMapControllerRec = new ContactRelationshipMapController(sc);
        ContactRelationshipMapControllerRec.showSecondayContacts = true;
        ContactRelationshipMapControllerRec.populateContactRelationshipInfo();
        system.assertEquals(ContactRelationshipMapControllerRec.showSecondayContacts,true);
        
        
        ContactRel3.Related_Contact__c = null;
        update ContactRel3;
        ContactRelationshipMapControllerRec = new ContactRelationshipMapController(sc);
        ContactRelationshipMapControllerRec.showPrimaryContacts = true;
        ContactRelationshipMapControllerRec.showSecondayContacts = true;
        ContactRelationshipMapControllerRec.populateContactRelationshipInfo();
        
    }
    
}