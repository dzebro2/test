/**************************************************************************************
  Apex Class Name     : TestStrategicPlanController
  Version             : 1.0
  Function            : This is a test class for StrategicPlanController.
  Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
*  Deloitte            10/28/2015
*************************************************************************************/
@isTest(seeAllData = true)
public class TestStrategicPlanController {
    static testMethod void myUnitTest1() {
        
        List<Account> testAccount1 = new List<Account>();
        Account testAcc = TestClassUtiltity.CreateAccountRecord('Test Account');
        testAccount1.add(testAcc);
        
        List<Strategic_Plan__c> lStrategicPlan =  TestClassUtiltity.createStrategicPlans(testAccount1[0].Id);
        insert lStrategicPlan;
        
        Contact TestCon1 = TestClassUtiltity.CreateContactRecord(testAccount1[0].id, 'TestFirstName1', 'TestLastname1', null);
        TestCon1.Fax = '1234568';
        update TestCon1;
        Contact TestCon = TestClassUtiltity.CreateContactRecord(testAccount1[0].id, 'Test', 'Last1', TestCon1.Id);
        TestCon.Buyer_Role__c = 'Test';
        TestCon.HCSC_Sentiment__c = 'Test1';
        update TestCon;
                
        list<AccountContactRole> accContactRoles = TestClassUtiltity.createAccountContactRoleRecords(testAccount1[0].Id,TestCon.Id);
        accContactRoles[0].Role = 'Test';
        insert accContactRoles;
        
        Buyer_Hierarchy__c TestBuyerHierarchy = new Buyer_Hierarchy__c();
        TestBuyerHierarchy.Contact__c = TestCon1.id;
        TestBuyerHierarchy.Account__c = testAccount1[0].id;
        TestBuyerHierarchy.Active__C = true;
        TestBuyerHierarchy.Role__c = 'Test';
        insert TestBuyerHierarchy;
        
        list<Task> newTasks = TestClassUtiltity.createTasks(testAccount1[0].id);
        newTasks[0].whoId = TestCon.id;
        insert newTasks;
                
        list<Event> newEvents = TestClassUtiltity.createEvents(testAccount1[0].id);
        newEvents[0].whoId =  TestCon.id;
        
        test.StartTest();
        ApexPages.currentPage().getParameters().put('id',lStrategicPlan[0].Id);
        StrategicPlanController testController1 = new StrategicPlanController();
        ApexPAges.StandardController sc2 = new ApexPages.StandardController(lStrategicPlan[0]);
        StrategicPlanController testController2 = new StrategicPlanController(sc2);
        system.assertEquals(testController2.fullView,null);
        
        test.StopTest();
    }
    
    
}