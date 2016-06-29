/*
    @Description : This is an test class for ReinstatementExtension
    @author      : Deloitte
    @date        : 11/20/2015
*/
@isTest
public with sharing class TestReinstatementExtension {
     /*
        @Description : This is a testMethod 
        @author      : Deloitte
        @date        : 11/20/2015
    */
     static testMethod void myUnitTest1() {
        try{
            list<Account> accounts = new list<Account>();
            Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
            User testUser = TestClassUtiltity.CreateUserRecord(p.Id, 'testlgnadev@user.com', 'testUser', 'test@user.com');
            testUser.ManagerId = UserInfo.getUserId();
            update testUser;
            accounts.add(new Account(OwnerId = testUser.Id,name = 'TestAccount',Status__c = 'Cancelled',Cancellation_Date__c = date.today().addDays(2),Effective_Date__c = system.today().addyears(2)));
            accounts.add(new Account(name = 'TestAccount1',Status__c = 'Active',Cancellation_Status__c = 'Cancelled' ,Cancellation_Submitted_Date__c = date.today(),Cancellation_Date__c = date.today().addDays(2),Effective_Date__c = system.today().addyears(2)));
            accounts.add(new Account(OwnerId = testUser.Id,name = 'TestAccount2',Status__c = 'Active',Cancellation_Status__c = 'Pending Approval',Cancellation_Date__c = date.today().addDays(2),Effective_Date__c = system.today().addyears(2)));
            accounts.add(new Account(name = 'TestAccount3',Status__c = 'Active',Cancellation_Date__c = date.today().addDays(2),Effective_Date__c = system.today().addyears(2)));
            accounts.add(new Account(name = 'TestAccount4',Status__c = 'Cancelled',Cancellation_Date__c = date.today().addYears(-2),Effective_Date__c = system.today().addyears(2)));
            
            insert accounts;
             
             Approval.ProcessSubmitRequest req1 = 
            new Approval.ProcessSubmitRequest();
            req1.setComments('Submitting request for approval.');
            req1.setObjectId(accounts[2].Id);
            req1.setProcessDefinitionNameOrId('Account_Cancellation_Approval');
            req1.setSkipEntryCriteria(true);
            req1.setSubmitterId(testUser.Id);
            
            // Submit the approval request for the account 
        
            Approval.ProcessResult result = Approval.process(req1);
            
            ApexPages.StandardController sc = new ApexPages.StandardController(accounts[0]);
            ReinstatementExtension re = new ReinstatementExtension(sc);
            re.reinstatementType = 'Account';
            re.NavigateToSelectedPage();
            re.withdrawCancellation();
            re.initiateAll();
            re.submitAccountForReinstatement();
            PageReference pg = re.backToHome();
            system.assertEquals(pg.getURL(),'/apex/reinstatementhome');
            
            sc = new ApexPages.StandardController(accounts[1]);
            re = new ReinstatementExtension(sc);
            re.reinstatementType = 'Account';
            re.NavigateToSelectedPage();
            re.withdrawCancellation();
            
            sc = new ApexPages.StandardController(accounts[2]);
            re = new ReinstatementExtension(sc);
            re.reinstatementType = 'Account';
            re.NavigateToSelectedPage();
            re.withdrawCancellation();
            
            sc = new ApexPages.StandardController(accounts[3]);
            re = new ReinstatementExtension(sc);
            re.reinstatementType = 'Account';
            re.NavigateToSelectedPage();
            re.withdrawCancellation();
            
            sc = new ApexPages.StandardController(accounts[4]);
            re = new ReinstatementExtension(sc);
            re.reinstatementType = 'Account';
            re.NavigateToSelectedPage();
            re.withdrawCancellation();
            
        }
        catch(Exception e){
            throw e;
        }
     }
     /*
        @Description : This is a testMethod 
        @author      : Deloitte
        @date        : 11/20/2015
    */
     static testMethod void myUnitTest2() {
        try{
            list<Account> accounts = new list<Account>();
            accounts.add(new Account(name = 'TestAccount',Status__c = 'Cancelled',Cancellation_Date__c = date.today().addDays(2),Effective_Date__c = system.today().addyears(2)));
            accounts.add(new Account(name = 'TestAccount1',Status__c = 'Active',Cancellation_Status__c = 'Active' ,Cancellation_Submitted_Date__c = date.today(),Cancellation_Date__c = date.today().addDays(2),Effective_Date__c = system.today().addyears(2)));
            accounts.add(new Account(name = 'TestAccount2',Status__c = 'Active',Cancellation_Status__c = 'Pending Approval',Cancellation_Date__c = date.today().addDays(2),Effective_Date__c = system.today().addyears(2)));
            accounts.add(new Account(name = 'TestAccount2',Status__c = 'Active',Cancellation_Date__c = date.today().addDays(2),Effective_Date__c = system.today().addyears(2)));
            accounts.add(new Account(name = 'TestAccount2',Status__c = 'Active',Cancellation_Date__c = date.today().addYears(-2),Effective_Date__c = system.today().addyears(2)));
            insert accounts;
            
            list<Benefit_Agreement__c> benefitAgreements = new list<Benefit_Agreement__c>();
            benefitAgreements.add(new Benefit_Agreement__c(Group_Account__c = accounts[0].Id,Status__c = 'Active'));
            benefitAgreements.add(new Benefit_Agreement__c(Group_Account__c = accounts[1].Id,Status__c = 'Cancelled',Requested_Cancellation_Date__c = date.today().addDays(2),Cancellation_Submitted_Date__c = date.today() ));
            benefitAgreements.add(new Benefit_Agreement__c(Group_Account__c = accounts[1].Id,Status__c = 'Cancelled',Cancellation_Status__c = 'Cancelled',Requested_Cancellation_Date__c = date.today().addDays(3),Cancellation_Submitted_Date__c = date.today()));
            benefitAgreements.add(new Benefit_Agreement__c(Group_Account__c = accounts[3].Id,Status__c = 'Active'));
            benefitAgreements.add(new Benefit_Agreement__c(Group_Account__c = accounts[4].Id,Status__c = 'Active'));
            insert benefitAgreements;
            
            ApexPages.StandardController sc = new ApexPages.StandardController(accounts[0]);
            ReinstatementExtension re = new ReinstatementExtension(sc);
            re.reinstatementType = 'Benefit';
            PageReference pg = re.NavigateToSelectedPage();
            system.assertEquals(pg.getURL(),'/apex/benefitagreementreinstatement');
            
            
            sc = new ApexPages.StandardController(accounts[1]);
            re = new ReinstatementExtension(sc);
            re.reinstatementType = 'Benefit';
            
            re.NavigateToSelectedPage();
            re.FromDate = string.valueOf(date.today().addDays(-3).format());
            re.ToDate = string.valueOf(date.today().addDays(4).format());
            re.searchBenefitAgreements();
            re.backToBAScreen();
            re.isFilterPerformed = true;
            re.NavigateToBAReasonPage();
            re.saveBARecords();
            
            
            
        }
        catch(Exception e){
            throw e;
        }
     }
}