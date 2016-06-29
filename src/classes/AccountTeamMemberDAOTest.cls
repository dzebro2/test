@isTest(SeeAllData=false)
private class AccountTeamMemberDAOTest{

    @isTest
    static void accountTeamMemberDAOTest(){
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User testUser = new User(Alias = 'standt1', Email = 'john.testing@testorg.com',EmailEncodingKey = 'UTF-8', LastName = 'Testing', FirstName = 'John', LanguageLocaleKey = 'en_US',LocaleSidKey = 'en_US', ProfileId = p.Id, TimeZoneSidKey = 'America/Los_Angeles',UserName = 'john.testing@testorg.com', isActive = TRUE);
        insert testUser;

        AccountTeamMemberDAO.IAccountTeamMemberDAO accountTeamMemberDAOInstance = new AccountTeamMemberDAO();

        Account testAcnt = TestClassUtiltity.CreateAccountRecord('TestAccount');

        Opportunity opp = new Opportunity(AccountId = testAcnt.Id, HCSC_Division__c = 'IL', Name='oppName 2',StageName = 'Expected In', CloseDate = system.Today().addYears(2), Expected_RFP_Release_Date__c = system.Today().addYears(1), Expected_Decision_Date__c = system.Today().addYears(1), RFI_RFP_Received_Date__c = system.Today().addYears(1), Primary_Closed_Reason__c = 'Savings');
        opp.Requested_Effective_Date__c = System.Today() + 1;    
        insert opp;
        Set<Id> accountIds = new Set<Id>();
        accountIds.add(testAcnt.Id);
        List<AccountTeamMember> testAccountTeam = TestClassUtiltity.createAccTeamMember(testAcnt.Id, testUser.Id);
        insert testAccountTeam;
        
        List<AccountTeamMember> testAccountTeamDAO = accountTeamMemberDAOInstance.getAccountTeamMemberById(testUser.Id);
        System.assertEquals(testAccountTeamDAO[0].Id, testAccountTeam[0].Id);
        
    
    }
}