/*
    @Description : This is a test class for M_GroupAccount360Controller
    @author      : Deloitte
    @date        : 11/02/2015
*/
@isTest
public with sharing class TestM_GroupAccount360Controller {
	 static testMethod void myUnitTest() {
       try{
            Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
            User testUser = TestClassUtiltity.CreateUserRecord(p.Id, 'testlgnadev@user.com', 'testUser', 'test@user.com');
            //create account
            Account testAccount = TestClassUtiltity.CreateAccountRecord('Test Account');
            testAccount.ShippingStreet = 'test';
            testAccount.ShippingCity = 'test';
            testAccount.ShippingState = 'TX';
            //testAccount.ShippingCountry= 'United States';
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
            testAccount.Total_Num_of_Potential_Subscribers__c = 10;
            testAccount.Active_Health_Subscribers__c = 8;
            update testAccount;
            
            list<AccountTeamMember> accountTeamMembers = TestClassUtiltity.createAccountTeamMembersRecords(testAccount.Id,testUser.Id);
            insert accountTeamMembers;
            
            test.startTest();
                ApexPages.StandardController sc = new ApexPages.StandardController(testAccount);
                ApexPages.currentPage().getParameters().put('id',testAccount.Id);
                M_GroupAccount360Controller tempExtension = new M_GroupAccount360Controller(sc);
                tempExtension.getPieData();
                tempExtension.nextActivityDate = null;
                tempExtension.lastActivityDate = null;
                tempExtension.strategyPlanId = null;
                tempExtension.openActivitiesReportObj = new Report();
                tempExtension.pastDueActivitiesReportObj = new Report();
                tempExtension.openCasesByPriorityReportObj = new Report();
                tempExtension.LastrenewalOppId = null;
                system.assertEquals(accountTeamMembers.size(),1);
            test.stopTest();
            
        }catch(Exception e){
            throw e;
        }
    }
}