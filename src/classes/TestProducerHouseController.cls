/**************************************************************************************
  Apex Class Name     : TestProducerHouseController
  Version             : 1.0
  Function            : This is a test class for ProducerHouseController.
  Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
*  Jermaine Lindsay           3/4/2016
*************************************************************************************/
@isTest
public class TestProducerHouseController {
    
     static testMethod void myUnitTest1() {
        try{
            test.StartTest();
            
                Account GroupAcnt = TestClassUtiltity.CreateAccountRecord('Group Account');
                GroupAcnt.BillingStreet = '123 Main St';
                GroupAcnt.BillingCity= 'AnyCity';
                GroupAcnt.BillingState= 'IL';
                GroupAcnt.BillingPostalCode= '60053-0000';
                GroupAcnt.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Group Account').getRecordTypeId();
                update GroupAcnt;

                Account HouseAcnt = TestClassUtiltity.CreateAccountRecord('Producer House Account');
                HouseAcnt.BillingStreet = '100 Commercial Ave';
                HouseAcnt.BillingCity= 'AnyCity';
                HouseAcnt.BillingState= 'IL';
                HouseAcnt.BillingPostalCode= '60601-0000';
                HouseAcnt.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Producer House').getRecordTypeId();
                update HouseAcnt;

                Account PrdcrAcnt = TestClassUtiltity.CreateAccountRecord('Producer Account');
                PrdcrAcnt.BillingStreet = '100 Commercial Ave';
                PrdcrAcnt.BillingCity= 'AnyCity';
                PrdcrAcnt.BillingState= 'IL';
                PrdcrAcnt.BillingPostalCode= '60601-0000';
                PrdcrAcnt.parentId = HouseAcnt.Id;
                PrdcrAcnt.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Producer Account').getRecordTypeId();
                update PrdcrAcnt;
          
                List<Contact> ContactList = new List<Contact>();
                ContactList.add(new Contact(AccountId = GroupAcnt.Id,Fax = '1234457', FirstName = 'Group', LastName = 'Contact', ReportsToId = null));
                ContactList.add(new Contact(AccountId = PrdcrAcnt.Id,Fax = '1234567', FirstName = 'Producer1', LastName = 'Contact', ReportsToId = null));
                ContactList.add(new Contact(AccountId = PrdcrAcnt.Id,Fax = '1234567', FirstName = 'Producer2', LastName = 'Contact', ReportsToId = null));
                ContactList[0].RecordTypeId =Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Group Contact').getRecordTypeId();
                ContactList[1].RecordTypeId =Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Producer Contact').getRecordTypeId();
                ContactList[2].RecordTypeId =Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Producer Contact').getRecordTypeId();
                insert ContactList;
               
                PageReference houseAccountPage = new PageReference('Page.ProducerHouseContactList');
                houseAccountPage.getParameters().put('Id',HouseAcnt.Id);
                Test.setCurrentPage(houseAccountPage);
                
                ApexPages.StandardController sc2 = new ApexPages.StandardController(HouseAcnt);
                ProducerHouseController myCntrl = new ProducerHouseController(sc2);

                List<Account> houseList = [SELECT Id, Name, NPN__r.id, NPN__r.NPN__c, Producer_Number__c, BillingStreet, BillingState, BillingPostalCode, BillingCity FROM Account WHERE Id = :myCntrl.accountId];
                System.debug('House Name is: ' + houseList[0].Name);
                System.debug(HouseAcnt.id + ' : ' + myCntrl.accountId + ' : ' + houseList[0].Id + ' : ' + myCntrl.producerList.size() + ' : ' + myCntrl.myContactList.size()) ;

                System.assertEquals(1,myCntrl.producerList.size());
                System.assertEquals(2,myCntrl.myContactList.size());

                //Pass is incorrect Id to throw error and increase code coverage
                houseAccountPage.getParameters().put('Id',HouseAcnt.Name);
                Test.setCurrentPage(houseAccountPage);
                sc2 = new ApexPages.StandardController(HouseAcnt);
                myCntrl = new ProducerHouseController(sc2);
                 
            test.StopTest();
            
            }catch(Exception e){
            throw e;
            } 
        }
}