/**************************************************************************************
  Apex Class Name     : TestHPS_MyFrequentContactsController
  Version             : 1.0
  Function            : This is a test class for HPS_MyFrequentContactsController
  Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
*  
*************************************************************************************/
@isTest
public class TestHPS_MyFrequentContactsController {

    static testMethod void myUnitTest() {
         try{
             Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
             User testUser = TestClassUtiltity.CreateUserRecord(p.Id, 'testlgnadev@user.com', 'testUser', 'test@user.com');
             system.runAs(testUser){
                //crate Account
                Account testAccount = TestClassUtiltity.CreateAccountRecord('Test Account');
                testAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Group Account').getRecordTypeId();
                testAccount.status__c = 'Sold';
                testAccount.Fax = '1234567';
                update testAccount;
                
                Contact contacts = TestClassUtiltity.CreateContactRecord(testAccount.Id,'test','last',null);
                
                
                
                //create tasks
                list<Task> tasks = TestClassUtiltity.createTasks(testAccount.Id);
                tasks[0].whoId = contacts.Id;
                insert tasks; 
                
                //create Activities
                list<Event> events = TestClassUtiltity.createEvents(testAccount.Id);
                events[0].whoId = contacts.Id;
                events[2].whoId = contacts.Id;
                insert events;
                test.StartTest(); 
                HPS_MyFrequentContactsController testController = new HPS_MyFrequentContactsController();
                System.assertEquals(testController.myFrequentContactsList.size(),1);
                HPS_MyFrequentContactsController.MyFrequentContactsWrapper var = new HPS_MyFrequentContactsController.MyFrequentContactsWrapper();
                var.activityHistoryObj = new ActivityHistory();
                test.StopTest(); 
             }
         }catch(Exception e){
            throw e;
         }
    }
}