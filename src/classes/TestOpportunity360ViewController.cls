/**************************************************************************************
  Apex Class Name     : TestOpportunity360ViewController
  Version             : 1.0
  Function            : This is a test class for Opportunity360ViewController .
  Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
*  
*************************************************************************************/
@isTest
public with sharing class TestOpportunity360ViewController {
    
    static testMethod void myUnitTest() {
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
        testAccount.AnnualRevenue = 1000;
        testAccount.Net_Income__c = 10000;
        testAccount.Market_Capitalization__c = 1000;
        testAccount.Effective_Date__c = system.today().addYears(1);
        testAccount.Open_Enrollment_Date__c = system.today().addYears(-2);
        testAccount.HCSC_Client_Since__c = system.today().addYears(-4);
        testAccount.Contract_End__c = system.today().addYears(2);
        testAccount.Open_Enrollment_End_Date__c = system.today().addYears(3);
        update testAccount;
        Team_Member_360Views__c tempTeam = new Team_Member_360Views__c();
        tempTeam.Opportunity_Record_Type__c = 'New_Sale';
        tempTeam.Team_Role_Name__c = 'Consultant';
        tempTeam.Name = 'Default';
        insert tempTeam;
        Strategic_Plan__c testStrategicPlan = new Strategic_Plan__c(Account_Name__c = testAccount.Id, Effective_Date__c = System.today());
        insert testStrategicPlan;
        Id renewalRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal').getRecordTypeId();
        List<Opportunity> Opportunitylst = TestClassUtiltity.CreateOpportunities(testAccount.Id);
        Opportunitylst[0].RecordTypeId = renewalRecordTypeId;
        List<Opportunity> opptyList = new List<Opportunity>();
        opptyList.add(Opportunitylst[0]);
        opptyList.add(Opportunitylst[1]);
        insert opptyList;
        
        list<OpportunityTeamMember> tempOppTeam = TestClassUtiltity.createOppTeamMember(opptyList[1].Id,UserInfo.getUserId());
        tempOppTeam[0].TeamMemberRole = 'Consultant';
        insert tempOppTeam;
        
        
        list<Opportunity_Team_Non_SF__c> tempOppTeamNonSF = TestClassUtiltity.createOppTeamNonSF(opptyList[1].Id,null);
        tempOppTeamNonSF[0].Member_Role__c = 'Consultant';
        insert tempOppTeamNonSF;
        
        
        Product2 testProduct = new Product2(Name = 'test',IsActive = true,hcsc_state__c='TX');
        insert testProduct;
        Opportunity_Product__c opptyProd = new Opportunity_Product__c(Product__c = testProduct.id, Opportunity_Name__c = Opportunitylst[1].id,funding_type__c='PREM',Premium_type__c ='PP' );
        insert opptyProd;
                
        test.startTest();
            Test.setCurrentPageReference(new PageReference('Page.RenewalOpportunity360View'));
            System.currentPageReference().getParameters().put('id', Opportunitylst[1].id);
            ApexPages.StandardController sc = new ApexPages.StandardController(Opportunitylst[1]);
            Opportunity360ViewController oppController = new Opportunity360ViewController(sc);
            oppController.NetIncome = null;
            oppController.MrktCapital = null;
            oppController.openActivitiesReportObj = new Report();
            oppController.pastDueActivitiesReportObj = new Report();
           // system.assertEquals(1,oppController.listOfOpportunityProducts.size());
           System.assertEquals(oppController.accountObj.Market_Segment__c, 'NA' );
        test.stopTest();
        
    }
}