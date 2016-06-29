/**************************************************************************************
  Apex Class Name     : TestBuyerHierarchyOnAccountController
  Version             : 1.0
  Function            : This is a test class for BuyerHierarchyOnAccountController.
  Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
*  Sruthy Dileep            6/2/2015
*************************************************************************************/
@isTest
public class TestBuyerHierarchyOnAccountController{
    
     static testMethod void myUnitTest1() {
        try{
            test.StartTest();
	            Account TestAcnt = TestClassUtiltity.CreateAccountRecord('TestAccount');
	            Contact TestCon = TestClassUtiltity.CreateContactRecord(TestAcnt.id, 'TestFirstName', 'O\'Reily', null);
	            TestCon.Buyer_Role__c = 'Test';
	            TestCon.HCSC_Sentiment__c = 'Test1';
	            update TestCon;
	            list<AccountContactRole> accContactRoles = TestClassUtiltity.createAccountContactRoleRecords(TestAcnt.Id,TestCon.Id);
	            accContactRoles[0].Role = 'Test';
	            insert accContactRoles;
	            Buyer_Hierarchy__c TestBuyerHierarchy = new Buyer_Hierarchy__c();
	            TestBuyerHierarchy.Contact__c = TestCon.id;
	            TestBuyerHierarchy.Account__c = TestAcnt.id;
	            TestBuyerHierarchy.Contact_Role_Id__c = accContactRoles[0].Id;
	            TestBuyerHierarchy.Role__c = 'Test';
	            insert TestBuyerHierarchy;
	            
	            list<Task> newTasks = TestClassUtiltity.createTasks(TestAcnt.id);
	            newTasks[0].whoId = TestCon.id;
	            insert newTasks;
	            
	            list<Event> newEvents = TestClassUtiltity.createEvents(TestAcnt.id);
	            newEvents[0].whoId =  TestCon.id;
	            
	            
	            PageReference myVfPage2 = new PageReference('/apex/BuyerHierarchyOnAccount');
	            myVfPage2.getParameters().put('id',TestAcnt.id);
	            Test.setCurrentPage(myVfPage2);
	            
	            
	            ApexPAges.StandardController sc2 = new ApexPages.StandardController(TestAcnt);
	            BuyerHierarchyOnAccountController myCntrl = new BuyerHierarchyOnAccountController(sc2);
	            myCntrl.contactRoleId = accContactRoles[0].Id;
 				myCntrl.changeSentimentApex = true;
 				myCntrl.checkJSCall = 'activeMobile';
	            myCntrl.fetchBuyerHierarchyData();
	            myCntrl.buildBuyerHierarchy();
	            System.assertEquals(myCntrl.parentContactNameAndBuyerHierarchyMap.size(),0);
 				
 				
 				insert newEvents;
 				myCntrl = new BuyerHierarchyOnAccountController(sc2);
 				myCntrl.checkJSCall = 'activeMobile';
	            myCntrl.fetchBuyerHierarchyData();
	            myCntrl.buildBuyerHierarchy();
	            
	            delete newTasks;
	            myCntrl = new BuyerHierarchyOnAccountController(sc2);
	            myCntrl.checkJSCall = 'active';
	            myCntrl.fetchBuyerHierarchyData();
	            myCntrl.buildBuyerHierarchy();
	            
	            delete newEvents;
	            
	            list<Strategic_Plan__c> strategicplans = TestClassUtiltity.createStrategicPlans(TestAcnt.id);
	          	insert strategicplans;
	            ApexPages.currentPage().getParameters().put('spId',strategicplans[0].id);
	            myCntrl = new BuyerHierarchyOnAccountController(sc2);
	            myCntrl.blobValue = 'test,test';
	            myCntrl.saveasAttachment();
	            Account acc = myCntrl.acc;
	            myCntrl.fetchBuyerHierarchyData();
	            myCntrl.buildBuyerHierarchy();
 				
            test.StopTest();
            
            }catch(Exception e){
            throw e;
            }
        
    }
    
    static testMethod void myUnitTest2() {
        try{
            test.StartTest();
	            Account TestAcnt = TestClassUtiltity.CreateAccountRecord('TestAccount');
	            Account TestAcnt1 = TestClassUtiltity.CreateAccountRecord('TestAccount1');
	            Contact TestCon1 = TestClassUtiltity.CreateContactRecord(TestAcnt.id, 'TestFirstName1', 'TestLastname1', null);
	            TestCon1.Fax = '1234568';
	            update TestCon1;
	            Contact TestCon = TestClassUtiltity.CreateContactRecord(TestAcnt.id, 'Test', 'Last1', TestCon1.Id);
	            TestCon.Buyer_Role__c = 'Test';
	            TestCon.HCSC_Sentiment__c = 'Test1';
	            update TestCon;
	            list<AccountContactRole> accContactRoles = TestClassUtiltity.createAccountContactRoleRecords(TestAcnt.Id,TestCon.Id);
	            accContactRoles[0].Role = 'Test';
	            insert accContactRoles;
	            Buyer_Hierarchy__c TestBuyerHierarchy = new Buyer_Hierarchy__c();
	            TestBuyerHierarchy.Contact__c = TestCon1.id;
	            TestBuyerHierarchy.Account__c = TestAcnt.id;
	            TestBuyerHierarchy.Active__C = true;
	            TestBuyerHierarchy.Role__c = 'Test';
	            insert TestBuyerHierarchy;
	            
	            list<Task> newTasks = TestClassUtiltity.createTasks(TestAcnt.id);
	            newTasks[0].whoId = TestCon.id;
	            insert newTasks;
	            
	            list<Event> newEvents = TestClassUtiltity.createEvents(TestAcnt.id);
	            newEvents[0].whoId =  TestCon.id;
	            
	            PageReference myVfPage2 = new PageReference('/apex/BuyerHierarchyOnAccount');
	            myVfPage2.getParameters().put('id',TestAcnt.id);
	            Test.setCurrentPage(myVfPage2);
	            
	            ApexPAges.StandardController sc2 = new ApexPages.StandardController(TestAcnt);
	            
	            BuyerHierarchyOnAccountController myCntrl = new BuyerHierarchyOnAccountController(sc2);
	            myCntrl.contactRoleId = accContactRoles[0].Id;
 				myCntrl.changeSentimentApex = false;
 				myCntrl.checkJSCall = 'active';
	            myCntrl.fetchBuyerHierarchyData();
	            myCntrl.buildBuyerHierarchy();
	            //myCntrl.createNode(TestBuyerHierarchy);
	            Buyer_Hierarchy__c tempObj = [select Id,Role__c,Contact_Role__c,Contact__c,Contact__r.Name from Buyer_Hierarchy__c where Id =:TestBuyerHierarchy.Id][0];
	            myCntrl.getTreeJSON(tempObj);
				 System.assertEquals(myCntrl.parentContactNameAndBuyerHierarchyMap.size(),1);
 			
            test.StopTest();
            
            }catch(Exception e){
            throw e;
            }
        
    }
    static testMethod void myUnitTest3() {
        try{
            test.StartTest();
	            Account TestAcnt = TestClassUtiltity.CreateAccountRecord('TestAccount');
	            
	            BuyerHierarchyOnAccountController myCntrl = new BuyerHierarchyOnAccountController();
	           
				 System.assertEquals(myCntrl.contactIds.size(),0);
 			
            test.StopTest();
            
            }catch(Exception e){
            throw e;
            }
        
    }
    
}