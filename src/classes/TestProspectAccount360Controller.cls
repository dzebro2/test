/**************************************************************************************
  Apex Class Name     : TestProspectAccount360Controller
  Version             : 1.0
  Function            : This is a test class for ProspectAccount360Controller .
  Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
*  
*************************************************************************************/

@isTest
public  class TestProspectAccount360Controller {

    public static testMethod void TestMethod1() {
        try{
            Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
            User testUser = TestClassUtiltity.CreateUserRecord(p.Id, 'testlgnadev@user.com', 'testUser', 'test@user.com');
            //create account
            Account testAccount = TestClassUtiltity.CreateAccountRecord('Test Account');
            testAccount.ShippingStreet = 'test';
            testAccount.ShippingCity = 'test';
            testAccount.ShippingPostalCode = '1002';
            testAccount.Website = 'test.com';
            testAccount.Industry = 'test';
            testAccount.External_ID__c = 'test';
            testAccount.Market_Segment__c = 'NA';
            testAccount.Effective_Date__c = system.today().addYears(1);
            testAccount.Open_Enrollment_Date__c = system.today().addYears(-2);
            testAccount.HCSC_Client_Since__c = system.today().addYears(-4);
            testAccount.Contract_End__c = system.today().addYears(2);
            testAccount.Open_Enrollment_End_Date__c = system.today().addYears(3);
            update testAccount;
            
            Contact contactRecord = TestClassUtiltity.CreateContactRecord(testAccount.id,'test','lastName',null);
            
            //create Opportunity
            list<Opportunity> opportunities = TestClassUtiltity.CreateOpportunities(testAccount.Id);
            insert opportunities;
            
            //create Activities
            list<Event> events = TestClassUtiltity.createEvents(testAccount.Id);
            insert events;
            
            //create Strategic plans
            list<Strategic_Plan__c> strategicPlans = TestClassUtiltity.createStrategicPlans(testAccount.Id);
            strategicPlans[0].Active__c = true;
            insert strategicPlans;
            
            //create tasks
            list<Task> tasks = TestClassUtiltity.createTasks(testAccount.Id);
            insert tasks;
            
            list<AccountContactRole> accountContactRoles = TestClassUtiltity.createAccountContactRoleRecords(testAccount.Id,contactRecord.Id);
            insert accountContactRoles;
            
            list<AccountTeamMember> accountTeamMembers = TestClassUtiltity.createAccountTeamMembersRecords(testAccount.Id,testUser.Id);
            accountTeamMembers[0].TeamMemberRole = 'Consultant';
            insert accountTeamMembers;
            
            Account_Team_Non_SF__c att = new Account_Team_Non_SF__c();
            att.Member_Role__c = 'Consultant';
            att.Account_Name__c = testAccount.Id;
            att.Team_Member_Name__c = null;
            insert att;
            
            
            Team_Member_360Views__c tM = new Team_Member_360Views__c();
            tM.Account_Record_Types__c = 'Group_Prospect_Account';
            tM.Name = 'Test1';
            tM.Team_Role_Name__c = 'Consultant';
            insert tM;
            
            test.startTest();
                ApexPages.StandardController sc = new ApexPages.StandardController(testAccount);
                ApexPages.currentPage().getParameters().put('id',testAccount.Id);
                ProspectAccount360Controller tempExtension = new ProspectAccount360Controller(sc);
                tempExtension.strategyPlanId = null;
                tempExtension.openActivitiesReportObj = new Report();
                tempExtension.pastDueActivitiesReportObj = new Report();
                system.assertEquals(accountTeamMembers.size(),1);
            test.stopTest();
            
        }catch(Exception e){
            throw e;
        }
    }
}