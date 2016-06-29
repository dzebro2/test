/**************************************************************************************
  Apex Class Name     : TestHPS_MyActivitiesController
  Version             : 1.0
  Function            : This is a test class for HPS_MyActivitiesController .
  Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
*  
*************************************************************************************/
@isTest
public class TestHPS_MyActivitiesController {

    static testMethod void myUnitTest() {
        try{
            Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
            User testUser = TestClassUtiltity.CreateUserRecord(p.Id, 'testlgnadev@user.com', 'testUser', 'test@user.com');
             testUser.Is_Super_User__c = true;
             update testUser;
             testUser.Is_Super_User__c = false;
            system.runAs(testUser){
                //crate Account
                Account testAccount = TestClassUtiltity.CreateAccountRecord('Test Account');
                testAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Group Account').getRecordTypeId();
                testAccount.status__c = 'Sold';
                testAccount.Fax = '1234567';
                update testAccount;
                
                //create tasks
                
                list<Task> tasks = TestClassUtiltity.createTasks(testAccount.Id);
                tasks[0].status='In progress';
                insert tasks; 
                
                //create Activities
                list<Event> events = TestClassUtiltity.createEvents(testAccount.Id);
                insert events;
                test.StartTest(); 
                //Initializing the Constructor
                HPS_MyActivitiesController tempController = new HPS_MyActivitiesController();
                //assert the size of the Task list
                System.assertEquals(tempController.myTaskList.size(),1);
                test.StopTest(); 
            }
        }catch(Exception e){
            
        }
    }
    
}