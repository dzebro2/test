/**************************************************************************************
  Apex Class Name     : TestRenewalOpportunity360ViewController
  Version             : 1.0
  Function            : This is a test class for RenewalOpportunity360ViewController.
  Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
*  
*************************************************************************************/

@isTest(SeeAllData = true)
private Class TestRenewalOpportunity360ViewController{
    public static testmethod void testMethod1(){
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
        update testAccount;
        
        Strategic_Plan__c testStrategicPlan = new Strategic_Plan__c(Account_Name__c = testAccount.Id, Active__c = true, Effective_Date__c = System.today());
        insert testStrategicPlan;
        Id renewalRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal').getRecordTypeId();
        Opportunity testOppty1 = new Opportunity(Name = 'testOppty1', AccountId = testAccount.Id, Type = 'RFP', StageName = 'Qualification', CloseDate = system.Today().addYears(2), Expected_Decision_Date__c = system.Today().addYears(1));
        testOppty1.RFI_RFP_Received_Date__c = system.today().addYears(-2);
        Opportunity testOppty2 = new Opportunity(Name = 'testOppty2', AccountId = testAccount.Id, Type = 'RFP', StageName = 'Qualification', CloseDate = system.Today().addYears(2), Expected_Decision_Date__c = system.Today().addYears(1), RecordTypeId = renewalRecordTypeId);
        testOppty1.RFI_RFP_Received_Date__c = system.today().addYears(-3);
        List<Opportunity> opptyList = new List<Opportunity>();
        opptyList.add(testOppty1);
        opptyList.add(testOppty2);
        insert opptyList;
        Product2 testProduct = new Product2(Name = 'test',IsActive = true);
        insert testProduct;
        Opportunity_Product__c opptyProd = new Opportunity_Product__c(Product__c = testProduct.id, Opportunity_Name__c = testOppty1.id);
        insert opptyProd;
        Team_Member_360Views__c tempTeam = new Team_Member_360Views__c();
        tempTeam.Opportunity_Record_Type__c = 'Renewal';
        tempTeam.Team_Role_Name__c = 'Consultant';
        tempTeam.Name = 'Default';
        insert tempTeam;
        list<OpportunityTeamMember> tempOppTeam = TestClassUtiltity.createOppTeamMember(opptyList[0].Id,UserInfo.getUserId());
        tempOppTeam[0].TeamMemberRole = 'Consultant';
        insert tempOppTeam;
        
        
        list<Opportunity_Team_Non_SF__c> tempOppTeamNonSF = TestClassUtiltity.createOppTeamNonSF(opptyList[0].Id,null);
        tempOppTeamNonSF[0].Member_Role__c = 'Consultant';
        insert tempOppTeamNonSF;
        test.StartTest(); 
        Test.setCurrentPageReference(new PageReference('Page.RenewalOpportunity360View'));
        System.currentPageReference().getParameters().put('id', testOppty1.id);
        ApexPages.StandardController sc = new ApexPages.StandardController(testOppty1);
        RenewalOpportunity360ViewController RenewalOpportunity360ViewControllerRec = new RenewalOpportunity360ViewController(sc);
        RenewalOpportunity360ViewControllerRec.strategyPlanId = null;
        RenewalOpportunity360ViewControllerRec.openActivitiesReportObj = new Report();
        RenewalOpportunity360ViewControllerRec.pastDueActivitiesReportObj = new Report();
        System.assertEquals(RenewalOpportunity360ViewControllerRec.accountObj.Market_Segment__c, 'NA' );
        test.StopTest(); 
    }
}