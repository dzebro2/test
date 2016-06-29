/**************************************************************************************
  Apex Class Name     : TestAccountTriggerHandler
  Version             : 1.0
  Function            : This is a test class for AccountTriggerHandler.
  Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------
*  Sruthy Dileep            6/1/2015
*************************************************************************************/
@isTest
public class TestAccountTriggerHandler {

    static testMethod void myUnitTest1() {
        try {
            Account testAccount1 = TestClassUtiltity.CreateAccountRecord('Test Account');
            List<Account> TestLstAcnt = new List<Account>();
            Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
            User testUser = TestClassUtiltity.CreateUserRecord(p.Id, 'testlgnadev@user.com', 'testUser', 'test@user.com');
            RecordType RecdType = [Select Id, name From RecordType where Name = 'Producer Account'];
            testAccount1.RecordTypeId = RecdType.id;
            testAccount1.Type  = 'Sub Producer';
            testAccount1.Name = 'tester';
            testAccount1.Current_Risk_Level__c = ConstantsController.Risk_level_4;
            testAccount1.Effective_Date__c = date.today().addDays(2);
            Set<id> userid = new Set<id>();
            userid.add(testUser.Id);
            ConstantsController.getAllSubordinateUsers(userid);
            update testAccount1;
            TestLstAcnt.add(testAccount1);

            list<AccountTeamMember> atMembers = TestClassUtiltity.createAccTeamMember(testAccount1.Id, testUser.Id);
            atMembers[0].TeamMemberRole = 'Account Executive';
            insert atMembers;



            Account testAccount2 = TestClassUtiltity.CreateAccountRecord('Test Account 1');
            List<Account> TestLstAcnt1 = new List<Account>();

            testAccount2.RecordTypeId = RecdType.id;
            testAccount1.Type  = 'Sub Producer';
            testAccount1.Current_Risk_Level__c = ConstantsController.Risk_level_5;
            update testAccount1;
            TestLstAcnt1.add(testAccount1);



            list<Product2> LstProduct =  TestClassUtiltity.createProducts();
            insert LstProduct;

            list<Benefit_Agreement__c> TestBenefitAgreementLst = new list<Benefit_Agreement__c>();
            Benefit_Agreement__c TestBnftAgrmt1 = new Benefit_Agreement__c ();
            TestBnftAgrmt1.Group_Account__c = testAccount1.id;
            TestBnftAgrmt1.Effective_Date__c =  system.today() - 1;
            TestBnftAgrmt1.Product__c = LstProduct[0].id;
            TestBnftAgrmt1.status__c = 'Active';
            TestBnftAgrmt1.Cancellation_Status__c = 'Cancellation Rejected';
            TestBenefitAgreementLst.add(TestBnftAgrmt1);
            Benefit_Agreement__c TestBnftAgrmt2 = new Benefit_Agreement__c ();
            TestBnftAgrmt2.Group_Account__c = testAccount1.id;
            TestBnftAgrmt2.Effective_Date__c =  system.today() - 1;
            TestBnftAgrmt2.Product__c = LstProduct[0].id;
            TestBnftAgrmt2.status__c = 'Active';
            TestBnftAgrmt2.Cancellation_Status__c = 'Cancellation Rejected';
            TestBenefitAgreementLst.add(TestBnftAgrmt2);
            insert TestBenefitAgreementLst;

            Group_Section__c TestGroupSection = new Group_Section__c();
            TestGroupSection.Group_Account__c = testAccount1.id;
            TestGroupSection.status__c = 'Active';
            TestGroupSection.Cancellation_Status__c = 'Cancellation Rejected';
            insert TestGroupSection;
            set<id> TestGpId = new set<id>();
            TestGpId.add(TestGroupSection.id);

            BA_GS_Assignment__c TestBAGSAsgnt = new BA_GS_Assignment__c();
            TestBAGSAsgnt.Benefit_Agreement__c = TestBenefitAgreementLst[0].id;
            TestBAGSAsgnt.Group_Section__c = TestGroupSection.id;
            TestBAGSAsgnt.External_ID__c = '101010';
            insert TestBAGSAsgnt;


            Billing__c TestBilling = new Billing__c();
            TestBilling.Group_Account__c = testAccount1.id;
            TestBilling.Cancellation_Status__c = 'Cancellation Rejected';
            insert TestBilling;


            test.StartTest();

            testAccount1.Cancellation_Status__c = 'Cancelled';
            update testAccount1;


            AccountTriggerHandler testController2 = new AccountTriggerHandler();


            AccountTriggerHandler.createProducerContact(TestLstAcnt);
            AccountTriggerHandler.createProducerContact(TestLstAcnt, TestLstAcnt1);
            AccountTriggerHandler.createChatterPost(TestLstAcnt);
            AccountTriggerHandler.createChatterPost(TestLstAcnt, TestLstAcnt1);

            system.assertEquals('Sub Producer', testAccount1.Type);

            User testUser_New = TestClassUtiltity.CreateUserRecord(p.Id, 'testNewgnadev@user.com', 'test_New_User', 'test_New@user.com');



            Map<id, Account> AccountOldMap = new Map<id, Account>();
            Account a = TestLstAcnt[0].clone();
            a.id = TestLstAcnt[0].id;
            a.ownerid = testUser_New.id;
            AccountOldMap.put(a.id, a);
            TestLstAcnt[0].ownerid = UserInfo.getUserId();

            list<AccountTeamMember> members = TestClassUtiltity.createAccTeamMember(TestLstAcnt[0].Id, testUser_New.id);
            insert members;
            AccountTriggerHandler.ReatainPreviousOwnersAccess(TestLstAcnt,  AccountOldMap);

            AccountShare accountShare = new AccountShare();
            accountShare.AccountId = TestLstAcnt[0].Id;
            accountShare.UserOrGroupId = testUser_New.id;
            accountShare.AccountAccessLevel = 'Edit' ;
            accountShare.OpportunityAccessLevel = 'Edit' ;
            accountShare.caseAccessLevel = 'Edit' ;
            insert accountShare;
            AccountTriggerHandler.ReatainPreviousOwnersAccess(TestLstAcnt,  AccountOldMap);
            test.StopTest();

        } catch (Exception e) {
            throw e;
        }
    }

    @isTest
    static void AddAE2toAccountTeamTest() {
        Test.startTest();
        Account testAccount = new Account( Name = 'Q Test Account' );

        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User u = new User(Alias = 'standt', FirstName = 'User', Email = 'standarduser@testorg.com',
                          EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
                          LocaleSidKey = 'en_US', ProfileId = p.Id,
                          TimeZoneSidKey = 'America/Los_Angeles', UserName = 'standarduser23423@testorg.com');

        User u2 = new User(Alias = 'standt2', FirstName = 'User2', Email = 'standarduser2@testorg.com',
                           EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
                           LocaleSidKey = 'en_US', ProfileId = p.Id,
                           TimeZoneSidKey = 'America/Los_Angeles', UserName = 'standarduser234232@testorg.com');

        insert u;
        insert u2;


        testAccount.Account_Cluster_Name__c = u.FirstName + ' ' + u.LastName;
        testAccount.Account_Executive_2__c = u2.FirstName + ' ' + u2.LastName;
        List<Account> accts = new List<Account>();
        List<AccountTeamMember> acctTeamMember = new List<AccountTeamMember>();

        /*List<String> memberName = new List<String>();
        List<String> memberNamequery = new List<String>(); */

        accts.add(testAccount);
        insert accts;
        acctTeamMember = [select User.Name, Account.Name, AccountAccessLevel, CreatedDate, CreatedBy.Name from AccountTeamMember where Account.Name = 'Q Test Account'];

        /*for (AccountTeamMember atm : acctTeamMember) {

            memberNamequery.add(atm.User.Name);
        }
        memberName.add('Alec Klein');
        memberName.add('Sana Fatima');*/

        System.assertEquals(2, acctTeamMember.size());

        Test.stopTest();


    }


}