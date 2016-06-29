/**************************************************************************************
  Apex Class Name     : TestImportAccountOpportunityClass
  Version             : 1.0
  Function            : This is a test class for ImportAccountOpportunityClass .
  Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
*  Sruthy Dileep            6/1/2015
*************************************************************************************/
@isTest(seeAllData = false)
public class TestImportAccountOpportunityClass {
    
     static testMethod void myUnitTest1() {
        try{
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User testUser = TestClassUtiltity.CreateUserRecord(p.Id, 'testlgnadev@user.com', 'testUser', 'test@user.com');
        User testUser2 = TestClassUtiltity.CreateUserRecord(p.Id, 'testlgnadev2@user.com', 'testUser2', 'test2@user.com');
        Account testAccount1 = TestClassUtiltity.CreateAccountRecord('Test Account');
        list<AccountTeamMember> accTeamMembers = TestClassUtiltity.createAccTeamMember(testAccount1.Id,testUser.Id);
        insert accTeamMembers;
        accTeamMembers = TestClassUtiltity.createAccTeamMember(testAccount1.Id,testUser2.Id);
        insert accTeamMembers;
        //create Opportunity records
        list<Opportunity> opportunities = TestClassUtiltity.CreateOpportunities(testAccount1.Id);
        opportunities[0].RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal').getRecordTypeId();
        opportunities[0].StageName = 'Lost';
        opportunities[0].Primary_Closed_Reason__c ='Organizational Changes';
        
        opportunities[1].RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('New Sale').getRecordTypeId();
        opportunities[1].StageName = 'Prospective';
        insert opportunities;
        
        list<OpportunityTeamMember> oppTeamMembers = TestClassUtiltity.createOppTeamMember(opportunities[0].Id,testUser.Id);
        insert oppTeamMembers;
        
        TestClassUtiltity.createAccountFieldMapping();
        TestClassUtiltity.createAccountOpportunityObjectRelations();
        TestClassUtiltity.createObjectFieldSet();
        TestClassUtiltity.createImportOpptyFields();
        
        test.StartTest();

        ImportAccountOpportunityClass testController2 = new ImportAccountOpportunityClass();
        testController2.CurrentObjectName = 'Opportunity';
        testController2.Type = 'TeamMember';
        testController2.CurrentObjectId = opportunities[0].Id;
        testController2.getDisplayWrapperList();
        testController2.testRec = new Account();
        testController2.currentOpportunity = new Opportunity();
        for(ImportAccountOpportunityClass.DisplayWrapper var : testController2.DisplayWrapperList){
            var.selected = true;
        }
        testController2.setDisplayWrapperList(testController2.DisplayWrapperList);
        testController2.ImportRecords();
        testController2.resetDisplayMessageFlag();
        pageReference pg = testController2.cancelMethod();
        //testController2.setDisplayWrapperList();
    
        system.assertEquals(pg.getURL(),'/'+opportunities[0].Id);
        test.StopTest();

        }catch(Exception e){
        throw e;
        }
    }
    
}