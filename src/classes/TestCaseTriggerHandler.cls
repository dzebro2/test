/**************************************************************************************
  Apex Class Name     : TestCaseTriggerHandler
  Version             : 1.0
  Function            : This class is serves as Unit Test class for CaseTriggerHandler.
  Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------
*   Dinesh Talreja       14/11/2014                Original Version
*************************************************************************************/

@isTest
public  class TestCaseTriggerHandler {


    /*  CheckCaseEditability
    *   @description:   This method is used to test the CheckCaseEditability method of CaseTriggerHandler
    *   @parameters     N/A
    *   @return type    N/A
    */

    public static testMethod void CheckCaseEditability() {

        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];

        User ManagerUser = new User(Alias = 'manager', Email = 'manager@testorg.com', EmailEncodingKey = 'UTF-8', LastName = 'Manager', LanguageLocaleKey = 'en_US',
                                    LocaleSidKey = 'en_US', ProfileId = p.Id, department = 'STP', TimeZoneSidKey = 'America/Los_Angeles', UserName = Math.random() + '@test.com');

        User ClientRepUser = new User(Alias = 'client', Email = 'client@testorg.com', EmailEncodingKey = 'UTF-8', LastName = 'Client', LanguageLocaleKey = 'en_US',
                                      LocaleSidKey = 'en_US', Is_Super_User__c = true, ProfileId = p.Id, department = 'STP', TimeZoneSidKey = 'America/Los_Angeles', UserName = Math.random() + '@test.com');

        System.runAs(ClientRepUser) {

            Group GroupObj = new Group();
            GroupObj.Name = 'Oklahoma';
            GroupObj.Type = 'Queue';
            insert GroupObj;

            system.assertEquals(GroupObj.Name, 'Oklahoma');

            GroupMember GroupMemberObj = new GroupMember();
            GroupMemberObj.GroupId = GroupObj.Id;
            GroupMemberObj.UserOrGroupId = ClientRepUser.Id;
            insert GroupMemberObj;
            string underWritingCase;

            Test.startTest();
            Case CaseObj = new Case();
            CaseObj.Subject = 'Test';
            CaseObj.Type = 'Benefits';
            CaseObj.Sub_Category__c = 'Benefit Booklet';
            CaseObj.Status = 'Working';
            CaseObj.Priority = 'Low';
            CaseObj.Origin = 'Email';
            CaseObj.ownerId = GroupObj.Id;

            CaseObj.Assigned_To__c = ClientRepUser.Id;
            insert CaseObj;

            system.assert(CaseObj.Id != null);

            CaseObj.Priority = 'Medium';
            CaseObj.OwnerId = ClientRepUser.Id;
            CaseObj.Assigned_To__c = ManagerUser.Id;
            update CaseObj;


            Test.stopTest();
        }
    }

    /*  UpdateCaseOwnerByQueue
    *   @description:   This method is used to test the UpdateCaseOwnerByQueue method of CaseTriggerHandler
    *   @parameters     N/A
    *   @return type    N/A
    */

    public static testMethod void UpdateCaseOwnerByQueue() {

        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];

        User ManagerUser = new User(Alias = 'manager', Email = 'manager@testorg.com', EmailEncodingKey = 'UTF-8', LastName = 'Manager', LanguageLocaleKey = 'en_US',
                                    LocaleSidKey = 'en_US', ProfileId = p.Id, department = 'STP', TimeZoneSidKey = 'America/Los_Angeles', UserName = Math.random() + '@test.com');

        User ClientRepUser = new User(Alias = 'client', Email = 'client@testorg.com', EmailEncodingKey = 'UTF-8', LastName = 'Client', LanguageLocaleKey = 'en_US',
                                      LocaleSidKey = 'en_US', Is_Super_User__c = true, ProfileId = p.Id, department = 'STP', TimeZoneSidKey = 'America/Los_Angeles', UserName = Math.random() + '@test.com');

        RecordType SGCaseRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Case' AND DeveloperName = 'SG_General_Case'];

        System.runAs(ClientRepUser) {

            Test.startTest();
            Case_Partner_Queues__c CasePartnerQueueObj = new Case_Partner_Queues__c();
            CasePartnerQueueObj.Name = '45';
            CasePartnerQueueObj.Assigned_Partner__c = 'Underwiting';
            CasePartnerQueueObj.Queue__c = 'Underwriting';
            insert CasePartnerQueueObj;

            system.assert(CasePartnerQueueObj.Id != null);

            Case_Partner_Queues__c CasePartnerQueueObj1 = new Case_Partner_Queues__c();
            CasePartnerQueueObj1.Name = '7' + system.now();
            CasePartnerQueueObj1.Assigned_Partner__c = 'SWSC';
            CasePartnerQueueObj1.Queue__c = 'SWSC';
            insert CasePartnerQueueObj1;

            system.assert(CasePartnerQueueObj1.Id != null);

            Group GroupObj = new Group();
            GroupObj.Name = 'TestQueue';
            GroupObj.Type = 'Queue';
            insert GroupObj;

            system.assertEquals(GroupObj.Name, 'TestQueue');

            GroupMember GroupMemberObj = new GroupMember();
            GroupMemberObj.GroupId = GroupObj.Id;
            GroupMemberObj.UserOrGroupId = ClientRepUser.Id;
            insert GroupMemberObj;

            Group GroupObj1 = new Group();
            GroupObj1.Name = 'SWSC';
            GroupObj1.Type = 'Queue';
            insert GroupObj1;

            system.assertEquals(GroupObj1.Name, 'SWSC');

            GroupMember GroupMemberObj1 = new GroupMember();
            GroupMemberObj1.GroupId = GroupObj1.Id;
            GroupMemberObj1.UserOrGroupId = ClientRepUser.Id;
            insert GroupMemberObj1;


            Case CaseObj = new Case();
            CaseObj.Subject = 'Test';
            CaseObj.Type = 'Benefits';
            CaseObj.Sub_Category__c = 'Benefit Booklet';
            CaseObj.Status = 'New';
            CaseObj.Priority = 'Low';
            CaseObj.Origin = 'Email';
            caseobj.RecordTypeId = SGCaseRecordType.Id;
            CaseObj.Assigned_Partner__c = 'Underwiting';
            insert CaseObj;

            system.assert(CaseObj.Id != null);

            CaseObj.Assigned_Partner__c = 'SWSC';
            update CaseObj;

            CaseObj.Assigned_Partner__c = null;
            update CaseObj;
            Test.stopTest();
        }
    }

    /*  UpdateCaseOwnerByEmail
    *   @description:   This method is used to test the UpdateCaseOwnerByEmail method of CaseTriggerHandler
    *   @parameters     N/A
    *   @return type    N/A
    */

    public static testMethod void UpdateCaseOwnerByEmail() {

        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];

        User ClientRepUser = new User(Alias = 'client', Email = 'client@testorg.com', EmailEncodingKey = 'UTF-8', LastName = 'Client', LanguageLocaleKey = 'en_US',
                                      LocaleSidKey = 'en_US', Is_Super_User__c = true, ProfileId = p.Id, department = 'STP', TimeZoneSidKey = 'America/Los_Angeles', UserName = Math.random() + '@test.com');

        System.runAs(ClientRepUser) {
            Test.startTest();
            RecordType SGCaseRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Case' AND DeveloperName = 'SG_General_Case'];
            Email_To_Case_Queues__c EmailToCaseQueueObj = new Email_To_Case_Queues__c();
            EmailToCaseQueueObj.Name = '2' + system.now();
            EmailToCaseQueueObj.Email__c = 'devokmarketingoperations@bcbsok.com';
            EmailToCaseQueueObj.Queue_Name__c = 'Oklahoma';
            insert EmailToCaseQueueObj;

            Group GroupObj = new Group();
            GroupObj.Name = 'Oklahoma';
            GroupObj.Type = 'Queue';
            insert GroupObj;

            system.assertEquals(GroupObj.Name, 'Oklahoma');

            QueueSobject mappingObject = new QueueSobject(QueueId = GroupObj.Id, SobjectType = 'Case');
            insert mappingObject;

            //Test.startTest();
            Case CaseObj = new Case();
            CaseObj.Subject = 'Test';
            CaseObj.Type = 'Benefits';
            CaseObj.Sub_Category__c = 'Benefit Booklet';
            CaseObj.Status = 'New';
            CaseObj.Priority = 'Low';
            CaseObj.Origin = 'Email';
            CaseObj.recordTypeId = SGCaseRecordType.Id;
            CaseObj.Initial_Email_To_Address__c = 'devokmarketingoperations@bcbsok.com';
            insert CaseObj;
            Test.stopTest();
            system.assert(CaseObj.Id != null);
        }
    }

    /*  ManageCaseAccountLookups
    *   @description:   This method is used to test the manageCaseAccountLookups method of CaseTriggerHandler
    *   @parameters     N/A
    *   @return type    N/A
    */

    public static testMethod void ManageCaseAccountLookups() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];

        User ManagerUser = new User(Alias = 'manager', Email = 'manager@testorg.com', EmailEncodingKey = 'UTF-8', LastName = 'Manager', LanguageLocaleKey = 'en_US',
                                    LocaleSidKey = 'en_US', ProfileId = p.Id, department = 'STP', TimeZoneSidKey = 'America/Los_Angeles', UserName = Math.random() + '@test.com');

        User ClientRepUser = new User(Alias = 'client', Email = 'client@testorg.com', EmailEncodingKey = 'UTF-8', LastName = 'Client', LanguageLocaleKey = 'en_US',
                                      LocaleSidKey = 'en_US', Is_Super_User__c = true, ProfileId = p.Id, department = 'STP', TimeZoneSidKey = 'America/Los_Angeles', UserName = Math.random() + '@test.com');

        //System.runAs( ClientRepUser){
        RecordType GroupAccountRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Account' AND Name = 'Group Account'];

        RecordType ProducerAccountRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Account' AND Name = 'Producer Account'];

        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.RecordTypeId = ProducerAccountRecordType.id;
        insert acc;
        Account acc1 = new Account();
        acc1.Name = 'Test Account';
        acc1.RecordTypeId = GroupAccountRecordType.id;
        insert acc1;

        Group GroupObj = new Group();
        GroupObj.Name = 'Oklahoma';
        GroupObj.Type = 'Queue';
        insert GroupObj;

        system.assertEquals(acc.Name, 'Test Account');

        Contact con = new Contact();
        con.FirstName = 'Test';
        con.LastName = 'Contact';
        con.AccountId = acc.Id;
        con.email = 'a@a.com';
        insert con;

        system.assertEquals(con.FirstName, 'Test');

        Test.startTest();
        Case CaseObj = new Case();
        CaseObj.Subject = 'Test';
        CaseObj.Type = 'Benefits';
        CaseObj.Sub_Category__c = 'Benefit Booklet';
        CaseObj.Status = 'New';
        CaseObj.Priority = 'Low';
        CaseObj.Origin = 'Email';
        CaseObj.Initial_Email_To_Address__c = 'devokmarketingoperations@bcbsok.com';
        CaseObj.ContactId = con.Id;
        CaseObj.AccountId = acc1.Id;
        insert CaseObj;


        system.assert(CaseObj.Id != null);

        acc.RecordTypeId = ProducerAccountRecordType.Id;
        update acc;

        // CaseObj.AccountId = null;
        //update CaseObj;
        Test.stopTest();
        //}
    }

    /*  ManageCaseAccountLookupsGroupAccount
    *   @description:   This method is used to test the manageCaseAccountLookups method of CaseTriggerHandler
    *   @parameters     N/A
    *   @return type    N/A
    */

    public static testMethod void ManageCaseAccountLookupsGroupAccount() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];

        User ManagerUser = new User(Alias = 'manager', Email = 'manager@testorg.com', EmailEncodingKey = 'UTF-8', LastName = 'Manager', LanguageLocaleKey = 'en_US',
                                    LocaleSidKey = 'en_US', ProfileId = p.Id, department = 'STP', TimeZoneSidKey = 'America/Los_Angeles', UserName = Math.random() + '@test.com');

        User ClientRepUser = new User(Alias = 'client', Email = 'client@testorg.com', EmailEncodingKey = 'UTF-8', LastName = 'Client', LanguageLocaleKey = 'en_US',
                                      LocaleSidKey = 'en_US', Is_Super_User__c = true, ProfileId = p.Id, department = 'STP', TimeZoneSidKey = 'America/Los_Angeles', UserName = Math.random() + '@test.com');

        //System.runAs(ClientRepUser){

        RecordType GroupAccountRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Account' AND Name = 'Group Account'];

        RecordType ProducerAccountRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Account' AND Name = 'Producer Account'];

        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.RecordTypeId = ProducerAccountRecordType.id;
        insert acc;

        Account acc1 = new Account();
        acc1.Name = 'Test Account';
        acc1.RecordTypeId = GroupAccountRecordType.id;
        insert acc1;

        System.assertEquals(acc.Name, 'Test Account');

        Group GroupObj = new Group();
        GroupObj.Name = 'Oklahoma';
        GroupObj.Type = 'Queue';
        insert GroupObj;

        Contact con = new Contact();
        con.FirstName = 'Test';
        con.LastName = 'Contact';
        con.AccountId = acc.Id;
        con.email = 'b@b.com';
        insert con;

        System.assertEquals(con.FirstName, 'Test');

        Test.startTest();
        Case CaseObj = new Case();
        CaseObj.Subject = 'Test';
        CaseObj.Type = 'Benefits';
        CaseObj.Sub_Category__c = 'Benefit Booklet';
        CaseObj.Status = 'New';
        CaseObj.Priority = 'Low';
        CaseObj.Origin = 'Email';
        CaseObj.Initial_Email_To_Address__c = 'devokmarketingoperations@bcbsok.com';
        CaseObj.ContactId = con.Id;
        CaseObj.AccountId = acc1.Id;
        insert CaseObj;

        System.assert(CaseObj.Id != null);

        acc.RecordTypeId = GroupAccountRecordType.Id;
        update acc;

        CaseObj.AccountId = null;
        update CaseObj;
        Test.stopTest();
        //}
    }

    /*  ManageCaseAccountLookupsProducerAccount
    *   @description:   This method is used to test the manageCaseAccountLookups method of CaseTriggerHandler
    *   @parameters     N/A
    *   @return type    N/A
    */

    public static testMethod void ManageCaseAccountLookupsProducerAccount() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];

        User ManagerUser = new User(Alias = 'manager', Email = 'manager@testorg.com', EmailEncodingKey = 'UTF-8', LastName = 'Manager', LanguageLocaleKey = 'en_US',
                                    LocaleSidKey = 'en_US', ProfileId = p.Id, department = 'STP', TimeZoneSidKey = 'America/Los_Angeles', UserName = Math.random() + '@test.com');

        User ClientRepUser = new User(Alias = 'client', Email = 'client@testorg.com', EmailEncodingKey = 'UTF-8', LastName = 'Client', LanguageLocaleKey = 'en_US',
                                      LocaleSidKey = 'en_US', Is_Super_User__c = true, ProfileId = p.Id, department = 'STP', TimeZoneSidKey = 'America/Los_Angeles', UserName = Math.random() + '@test.com');

        //System.runAs(ClientRepUser){
        RecordType GroupAccountRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Account' AND Name = 'Group Account'];

        RecordType ProducerAccountRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Account' AND Name = 'Producer Account'];

        Account acc = new Account();
        acc.Name = 'Test Account1';
        acc.RecordTypeId = GroupAccountRecordType.id;
        insert acc;

        Account acc1 = new Account();
        acc1.Name = 'Test Account1';
        acc1.RecordTypeId = ProducerAccountRecordType.id;
        insert acc1;

        Group GroupObj = new Group();
        GroupObj.Name = 'Oklahoma';
        GroupObj.Type = 'Queue';
        insert GroupObj;

        System.assertEquals(acc.Name, 'Test Account1');

        Contact con = new Contact();
        con.FirstName = 'Test1';
        con.LastName = 'Contact';
        con.AccountId = acc.Id;
        con.email = 'c@c.com';
        insert con;

        System.assertEquals(con.FirstName, 'Test1');

        Test.startTest();
        Case CaseObj = new Case();
        CaseObj.Subject = 'Test';
        CaseObj.Type = 'Benefits';
        CaseObj.Sub_Category__c = 'Benefit Booklet';
        CaseObj.Status = 'New';
        CaseObj.Priority = 'Low';
        CaseObj.Origin = 'Email';
        CaseObj.Initial_Email_To_Address__c = 'devokmarketingoperations@bcbsok.com';
        CaseObj.ContactId = con.Id;
        CaseObj.Producer_Account__c = acc1.Id;
        CaseObj.AccountId = acc.Id;
        insert CaseObj;

        System.assert(CaseObj.Id != null);
        Test.stopTest();
        //}
    }

    /*  TestCalloutHelper Method
    *   @description:   This method is used to test the manageCaseAccountLookups method of CaseTriggerHandler
    *   @parameters     N/A
    *   @return type    N/A
    */

    public static testMethod void TestCallouthelperMethod() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];

        User ManagerUser = new User(Alias = 'manager', Email = 'manager@testorg.com', EmailEncodingKey = 'UTF-8', LastName = 'Manager', LanguageLocaleKey = 'en_US',
                                    LocaleSidKey = 'en_US', ProfileId = p.Id, department = 'STP', TimeZoneSidKey = 'America/Los_Angeles', UserName = Math.random() + '@test.com');
        insert  ManagerUser;
        User ClientRepUser = new User(Alias = 'client', Email = 'client@testorg.com', EmailEncodingKey = 'UTF-8', LastName = 'Client', LanguageLocaleKey = 'en_US', ManagerId = ManagerUser.id,
                                      LocaleSidKey = 'en_US', Is_Super_User__c = true, ProfileId = p.Id, department = 'STP', TimeZoneSidKey = 'America/Los_Angeles', UserName = Math.random() + '@test.com');

        System.runAs(ClientRepUser) {
            Id CBSRId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(system.label.Custom_Benefit_Service).getRecordTypeId();
            Id CBSR_IssueId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(system.label.CBSR_Issue).getRecordTypeId();

            Group GroupObj = new Group();
            GroupObj.Name = 'Oklahoma';
            GroupObj.Type = 'Queue';
            insert GroupObj;
            RecordType GroupAccountRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Account' AND Name = 'Group Account'];
            Account acc = new Account();
            acc.Name = 'Test Account';
            acc.RecordTypeId = GroupAccountRecordType.id;
            acc.HCSC_Division__c = 'TX';
            acc.Market_Segment__c = 'NRMM';

            insert acc;
            list<Opportunity> opps = TestClassUtiltity.CreateOpportunities(acc.Id);
            opps[0].Requested_Effective_Date__c = date.today() + 5;
            opps[0].HCSC_Division__c = 'TX';
            opps[0].Account_Market_Segment__c = 'NRMM';
            insert opps;
            //Insert esales case
            ID CaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Mid-Market Underwriting').getRecordTypeId();
            list<Case> CaseObjs = new list<Case> ();
            Case CaseObj2 = new Case();
            CaseObj2.Subject = 'Test';
            CaseObj2.Type = 'Benefits';
            CaseObj2.status = 'In Progress';
            CaseObj2.recordtypeid = CaseRecordTypeId;
            CaseObj2.Sub_Category__c = 'Benefit Booklet';
            CaseObj2.Priority = 'Low';
            caseobj2.AccountId = acc.Id;
            CaseObj2.Opportunity_Name__c = opps[0].Id;
            CaseObj2.Origin = 'Email';

            CaseObjs.add( CaseObj2);

            Test.startTest();
            //create CBSR header case
            Case CaseObj = new Case();
            CaseObj.Subject = 'Test';
            CaseObj.Type = 'Benefits';
            CaseObj.status = 'New';
            CaseObj.recordtypeid = CBSRId ;
            CaseObj.Sub_Category__c = 'Benefit Booklet';
            CaseObj.Priority = 'Low';
            CaseObj.Origin = 'Email';
            CaseObj.AccountId = acc.Id;
            CaseObj.Opportunity_Name__c = opps[0].Id;
            CaseObj.Initial_Email_To_Address__c = 'devokmarketingoperations@bcbsok.com';
            CaseObjs.add (CaseObj);

            //create CBSR issue case
            Case CaseObj1 = new Case();
            CaseObj1.Subject = 'Test';
            CaseObj1.Type = 'Benefits';
            CaseObj1.status = 'In Progress';
            CaseObj1.recordtypeid = CBSR_IssueId;
            CaseObj1.Sub_Category__c = 'Benefit Booklet';
            CaseObj1.Priority = 'Low';
            CaseObj1.AccountId = acc.Id;
            CaseObj1.Opportunity_Name__c = opps[0].Id;
            CaseObj1.Origin = 'Email';
            CaseObjs.add (CaseObj1);

            Case CaseObj3 = new Case();
            CaseObj3.Subject = 'Test';
            CaseObj3.Type = 'Benefits';
            CaseObj3.status = 'In Progress';
            CaseObj3.recordtypeid = CBSR_IssueId;
            CaseObj3.Sub_Category__c = 'Benefit Booklet';
            CaseObj3.Priority = 'Low';
            CaseObj3.AccountId = acc.Id;
            CaseObj3.Opportunity_Name__c = opps[0].Id;
            CaseObj3.Origin = 'Email';
            CaseObjs.add (CaseObj3);

            Case CaseObj4 = new Case();
            CaseObj4.Subject = 'Test';
            CaseObj4.Type = 'Benefits';
            CaseObj4.status = 'In Progress';
            CaseObj4.recordtypeid = CBSR_IssueId;
            CaseObj4.Sub_Category__c = 'Benefit Booklet';
            CaseObj4.Priority = 'Low';
            CaseObj4.AccountId = acc.Id;
            CaseObj4.Opportunity_Name__c = opps[0].Id;
            CaseObj4.Origin = 'Email';
            CaseObj4.external_id__C = '1236445';
            CaseObjs.add (CaseObj4);
            insert CaseObjs;


            Case_Callout_Fields__c temp = new Case_Callout_Fields__c();
            temp.name = 'test';
            temp.CBSR_Insert__c = true;
            temp.CBSR_Issue_Insert__c = true;
            temp.CBSR_Delete__c = true;
            temp.CBSR_Issue_Update__c = true;
            temp.CBSR_Button__c = true;
            temp.API_Name__c = 'status';
            insert temp;
            try {
                System.assert(CaseObj1.Id != null);
                CaseObjs[0].status = 'Submitted';
                CaseObjs[0].integration_status__c = 'New';
                update CaseObjs[0];

                //update CaseObjs[0];
                CaseObjs[2].external_id__C = '1234445';
                CaseObjs[2].Priority = 'Medium';
                CaseObjs[2].time_sent__c = system.today() + 1;
                CaseObjs[2].Status = Label.Re_review;
                //update CaseObjs[1];
                CaseObjs[3].status = 'Closed (Marked for Delete)' ;
                //update CaseObjs[1];
                CaseObjs[4].Status = Label.Withdrawn;
                CaseObjs.remove(0);
                CaseObjs.remove(1);
                update CaseObjs;
                List<Case> caselst = new List<Case> {CaseObjs[1]};
                CaseTriggerHandlerLGNA.checkIfExecutionRestricted(caselst);
                CaseTriggerHandlerLGNA.CascadeDeleteDetailsTrigger(caselst);
                delete CaseObj1;



            } catch (Exception e) {

            }
            Test.stopTest();
        }
    }
    public static testMethod void TestCBSRCaseTriggerHandler1() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];

        User ManagerUser = new User(Alias = 'manager', Email = 'manager@testorg.com', EmailEncodingKey = 'UTF-8', LastName = 'Manager', LanguageLocaleKey = 'en_US',
                                    LocaleSidKey = 'en_US', ProfileId = p.Id, department = 'STP', TimeZoneSidKey = 'America/Los_Angeles', UserName = Math.random() + '@test.com');
        insert  ManagerUser;
        User ClientRepUser = new User(Alias = 'client', Email = 'client@testorg.com', EmailEncodingKey = 'UTF-8', LastName = 'Client', LanguageLocaleKey = 'en_US', ManagerId = ManagerUser.id,
                                      LocaleSidKey = 'en_US', Is_Super_User__c = true, ProfileId = p.Id, department = 'STP', TimeZoneSidKey = 'America/Los_Angeles', UserName = Math.random() + '@test.com');

        System.runAs(ClientRepUser) {
            TestClassUtiltity.createUserNamePasswordFields();
            TestClassUtiltity.createCaseCalloutFields();
            Id CBSRId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(system.label.Custom_Benefit_Service).getRecordTypeId();
            Id CBSR_IssueId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(system.label.CBSR_Issue).getRecordTypeId();

            Group GroupObj = new Group();
            GroupObj.Name = 'Oklahoma';
            GroupObj.Type = 'Queue';
            insert GroupObj;
            RecordType GroupAccountRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Account' AND Name = 'Group Account'];
            Account acc = new Account();
            acc.Name = 'Test Account';
            acc.RecordTypeId = GroupAccountRecordType.id;
            acc.HCSC_Division__c = 'TX';
            acc.Market_Segment__c = 'NRMM';

            insert acc;
            list<Opportunity> opps = TestClassUtiltity.CreateOpportunities(acc.Id);
            opps[0].Requested_Effective_Date__c = date.today() + 5;
            insert opps;

            List<Competitor_Relationship__c> lstCompRel = TestClassUtiltity.createCompRel(acc.Id);
            lstCompRel[0].RecordTypeId = Schema.SObjectType.Competitor_Relationship__c.getRecordTypeInfosByName().get('Carrier').getRecordTypeId();
            lstCompRel[1].RecordTypeId = Schema.SObjectType.Competitor_Relationship__c.getRecordTypeInfosByName().get('Carrier').getRecordTypeId();
            insert lstCompRel;
            Case CaseObj = new Case();
            CaseObj.Subject = 'Test';
            CaseObj.Type = 'Benefits';
            CaseObj.status = 'New';
            CaseObj.recordtypeid = CBSRId ;
            CaseObj.Sub_Category__c = 'Benefit Booklet';
            CaseObj.Status = 'New';
            CaseObj.Priority = 'Low';
            CaseObj.Origin = 'Email';
            CaseObj.AccountId = acc.Id;
            CaseObj.Opportunity_Name__c = opps[0].Id;
            CaseObj.Initial_Email_To_Address__c = 'devokmarketingoperations@bcbsok.com';
            insert CaseObj;
            Test.startTest();

            Case CaseObjUnd = new Case();
            CaseObjUnd = CaseObj.clone();
            CaseObjUnd.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Underwriting').getRecordTypeId();
            CaseObjUnd.Proposed_Employee__c = 100;
            CaseObjUnd.Status = 'New';
            insert CaseObjUnd;

            // update CaseObjUnd;
            //create CBSR issue case
            Case CaseObj1 = new Case();
            CaseObj1.Subject = 'Test';
            CaseObj1.Type = 'Benefits';
            CaseObj1.status = 'New';
            CaseObj1.recordtypeid = CBSR_IssueId;
            CaseObj1.Sub_Category__c = 'Benefit Booklet';
            CaseObj1.Priority = 'Low';
            CaseObj1.AccountId = acc.Id;
            CaseObj1.Opportunity_Name__c = opps[0].Id;
            CaseObj1.Origin = 'Email';
            insert CaseObj1;
            System.assert(CaseObj1.Id != null);

            Case CaseObj2 = new Case();
            CaseObj2.Subject = 'Test';
            CaseObj2.Type = 'Benefits';
            CaseObj2.status = 'Closed (Marked for Delete)' ;
            CaseObj2.recordtypeid = CBSR_IssueId;
            CaseObj2.Sub_Category__c = 'Benefit Booklet';
            CaseObj2.Priority = 'Low';
            CaseObj2.AccountId = acc.Id;
            CaseObj2.Opportunity_Name__c = opps[0].Id;
            CaseObj2.Origin = 'Email';
            insert CaseObj2;
            System.assert(CaseObj2.Id != null);
            List<Case> caselst = new List<Case> {CaseObj2};
            CaseTriggerHandlerLGNA.checkIfExecutionRestricted(caselst);
            delete CaseObj2;
            Test.stopTest();
        }
    }
    public static testMethod void TestCBSRCaseTriggerHandler() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];

        User ManagerUser = new User(Alias = 'manager', Email = 'manager@testorg.com', EmailEncodingKey = 'UTF-8', LastName = 'Manager', LanguageLocaleKey = 'en_US',
                                    LocaleSidKey = 'en_US', ProfileId = p.Id, department = 'STP', TimeZoneSidKey = 'America/Los_Angeles', UserName = Math.random() + '@test.com');
        insert  ManagerUser;
        User ClientRepUser = new User(Alias = 'client', Email = 'client@testorg.com', EmailEncodingKey = 'UTF-8', LastName = 'Client', LanguageLocaleKey = 'en_US', ManagerId = ManagerUser.id,
                                      LocaleSidKey = 'en_US', Is_Super_User__c = true, ProfileId = p.Id, department = 'STP', TimeZoneSidKey = 'America/Los_Angeles', UserName = Math.random() + '@test.com');

        System.runAs(ClientRepUser) {
            TestClassUtiltity.createUserNamePasswordFields();
            TestClassUtiltity.createCaseCalloutFields();
            Id CBSRId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(system.label.Custom_Benefit_Service).getRecordTypeId();
            Id CBSR_IssueId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(system.label.CBSR_Issue).getRecordTypeId();

            Group GroupObj = new Group();
            GroupObj.Name = 'Oklahoma';
            GroupObj.Type = 'Queue';
            insert GroupObj;
            RecordType GroupAccountRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Account' AND Name = 'Group Account'];
            Account acc = new Account();
            acc.Name = 'Test Account';
            acc.RecordTypeId = GroupAccountRecordType.id;
            acc.HCSC_Division__c = 'TX';
            acc.Market_Segment__c = 'NRMM';

            insert acc;
            list<Opportunity> opps = TestClassUtiltity.CreateOpportunities(acc.Id);
            opps[0].Requested_Effective_Date__c = date.today() + 5;
            insert opps;

            List<Competitor_Relationship__c> lstCompRel = TestClassUtiltity.createCompRel(acc.Id);
            lstCompRel[0].RecordTypeId = Schema.SObjectType.Competitor_Relationship__c.getRecordTypeInfosByName().get('Carrier').getRecordTypeId();
            lstCompRel[1].RecordTypeId = Schema.SObjectType.Competitor_Relationship__c.getRecordTypeInfosByName().get('Carrier').getRecordTypeId();
            insert lstCompRel;

            //create CBSR header case
            Case CaseObj = new Case();
            CaseObj.Subject = 'Test';
            CaseObj.Type = 'Benefits';
            CaseObj.status = 'New';
            CaseObj.recordtypeid = CBSRId ;
            CaseObj.Sub_Category__c = 'Benefit Booklet';
            CaseObj.Status = 'New';
            CaseObj.Priority = 'Low';
            CaseObj.Origin = 'Email';
            CaseObj.AccountId = acc.Id;
            CaseObj.Opportunity_Name__c = opps[0].Id;
            CaseObj.Initial_Email_To_Address__c = 'devokmarketingoperations@bcbsok.com';
            insert CaseObj;
            CaseObj.Integration_Status__c = 'Failure';
            CaseObj.Time_Sent__c = System.Now().addYears(-1);
            CaseObj.Status = System.Label.Re_review;
            test.startTest();
            update CaseObj;
            CaseObj.Integration_Status__c = 'Failure';
            CaseObj.Status = System.Label.Withdrawn;
            CaseObj.Time_Sent__c = System.Now().addYears(-1);
            update CaseObj;
            CaseObj.Integration_Status__c = 'Failure';
            CaseObj.Status = System.Label.Closed_Marked_for_Delete;
            CaseObj.Time_Sent__c = System.Now().addYears(-1);
            update CaseObj;
            System.assert(CaseObj.Id != null);
            delete CaseObj;
            test.stopTest();


        }
    }

    static testMethod void checkForValidationAndDueDatesPopulation() {
        RecordType GroupAccountRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Account' AND Name = 'Group Account'];
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.RecordTypeId = GroupAccountRecordType.id;
        acc.HCSC_Division__c = 'TX';
        acc.Market_Segment__c = 'NRMM';
        list<Profile> p = [select Id from Profile where Name = 'System Administrator' or Name = 'Underwriting'];
        User testUser = TestClassUtiltity.CreateUserRecord(p[0].Id, 'testlgnadev@user.com', 'testUser', 'test@user.com');
        User testUser1 = TestClassUtiltity.CreateUserRecord(p[1].Id, 'testlgnadev123@user.com', 'testUser123', 'test123@user.com');
        User testUser2 = TestClassUtiltity.CreateUserRecord(p[1].Id, 'testlgnadev1234@user.com', 'testUser1234', 'test1234@user.com');
        insert acc;
        String competitorRelationShipRecordTypeId;
        for (RecordType rt : [select Id from RecordType where SobjectType = 'Competitor_Relationship__c' and DeveloperName = 'Carrier']) {
            competitorRelationShipRecordTypeId = rt.Id;
        }
        List<Competitor_Relationship__c> compRel = TestClassUtiltity.createCompRel(acc.Id);
        compRel[0].RecordTypeId = competitorRelationShipRecordTypeId;
        compRel[1].RecordTypeId = competitorRelationShipRecordTypeId;
        insert compRel;

        list<Opportunity> opps = TestClassUtiltity.CreateOpportunities(acc.Id);
        opps[0].Requested_Effective_Date__c = date.today() + 5;
        insert opps;
        string underWritingCase;
        for (RecordType rt : [select Id from RecordType where SobjectType = 'Case' and DeveloperName = 'Underwriting']) {
            underWritingCase = rt.Id;
        }
        Case CaseObj = new Case();
        CaseObj.Subject = 'Test';
        CaseObj.Type = 'Benefits';
        CaseObj.status = 'New';
        CaseObj.recordtypeid = underWritingCase ;
        CaseObj.Sub_Category__c = 'Benefit Booklet';
        CaseObj.Status = 'New';
        CaseObj.Priority = 'Low';
        CaseObj.Origin = 'Email';
        CaseObj.AccountId = acc.Id;
        CaseObj.Opportunity_Name__c = opps[0].Id;
        CaseObj.OwnerId = testUser.Id;
        caseObj.Non_HMO__c = '5';
        caseObj.HMO_Current_Participation__c = 4;
        CaseObj.Total_Eligible__c = 3;
        insert CaseObj;
        try {

            CaseObj.Date_Assigned_to_Underwriting__c = Date.today();
            CaseObj.PUG__c = true;
            caseObj.Funding_Type_Multiselect__c = 'Prem';
            caseObj.HCSC_Division__c = 'OK';
            CaseObj.OwnerId = testUser1.Id;
            caseObj.Employer_Contribution_Same_as_Current__c  = true;
            update CaseObj;


            CaseObj.Date_Assigned_to_Underwriting__c = null;
            update CaseObj;
            test.startTest();

            CaseObj.OwnerId = testUser2.Id;
            update CaseObj;

            LGNA_Constants__c temp = new LGNA_Constants__c();
            temp.name = 'Default';
            temp.Group_Account_Task_Batch_RUn__c = 'test';
            temp.UW_Due_Date_PrePop_Bigger_Interval__c = 10;
            temp.UW_Due_Date_PrePop_Smaller_Interval__c = 5;
            temp.Total_Working_Hours_per_Day__c = 9;

            insert temp;

            CaseObj.Date_Assigned_to_Underwriting__c = Date.today();
            caseObj.Funding_Type_Multiselect__c = 'Prem;ACAP';
            CaseObj.OwnerId = testUser.Id;
            CaseObj.status = 'Assigned';
            CaseObj.PUG__c = false;
            update CaseObj;

            CaseObj.status = 'Assigned';
            CaseObj.Proposed_Employee__c = 10;
            CaseObj.OwnerId = testUser1.Id;
            CaseObj.PUG__c = false;
            caseObj.Employer_Contribution_Same_as_Current__c  = true;
            update CaseObj;
            test.stopTest();
        } catch (Exception e) {
            System.assertEquals(e.getDMLMessage(0), System.label.UnderwritingCaseCarrierHistory);
        }
    }
    static testMethod void unitTest1() {
        RecordType GroupAccountRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Account' AND Name = 'Group Account'];
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.RecordTypeId = GroupAccountRecordType.id;
        acc.HCSC_Division__c = 'TX';
        acc.Market_Segment__c = 'NRMM';
        insert acc;
        String competitorRelationShipRecordTypeId;
        for (RecordType rt : [select Id from RecordType where SobjectType = 'Competitor_Relationship__c' and DeveloperName = 'Carrier']) {
            competitorRelationShipRecordTypeId = rt.Id;
        }
        List<Competitor_Relationship__c> compRel = TestClassUtiltity.createCompRel(acc.Id);
        compRel[0].RecordTypeId = competitorRelationShipRecordTypeId;
        compRel[0].Dental__c = true;
        compRel[1].RecordTypeId = competitorRelationShipRecordTypeId;
        compRel[1].Dental__c = true;
        insert compRel;
        Profile p = [select Id from Profile where Name = 'Underwriting'][0];
        User testUser = TestClassUtiltity.CreateUserRecord(p.Id, 'testlgnadev@user.com', 'testUser', 'test@user.com');
        list<Opportunity> opps = TestClassUtiltity.CreateOpportunities(acc.Id);
        opps[0].Requested_Effective_Date__c = date.today() + 5;
        insert opps;
        string underWritingCase;
        for (RecordType rt : [select Id from RecordType where SobjectType = 'Case' and DeveloperName = 'Dental_Underwriting']) {
            underWritingCase = rt.Id;
        }
        Case CaseObj = new Case();
        CaseObj.Subject = 'Test';
        CaseObj.Type = 'Benefits';
        CaseObj.status = 'New';
        CaseObj.recordtypeid = underWritingCase ;
        CaseObj.Sub_Category__c = 'Benefit Booklet';
        CaseObj.Status = 'New';
        CaseObj.Priority = 'Low';
        CaseObj.Origin = 'Email';
        CaseObj.AccountId = acc.Id;
        CaseObj.Opportunity_Name__c = opps[0].Id;
        caseObj.Dental_days__c = 4;
        caseObj.DHMO_Current_Participation__c = 4;
        caseObj.Dental_Current_Participation__c = 4;
        caseObj.Total_Eligible__c = 4;
        insert CaseObj;
        try {
            test.startTest();
            /*CaseObj.Status = 'In Progress';
            CaseObj.PUG__c = true;
            CaseObj.Proposed_Employee__c = 10;
            caseObj.Employer_Contribution_Same_as_Current__c  = true;
            caseObj.Proposed_Contribution_Type__c = 'tes';
            update caseObj;
            */
            CaseObj.PUG__c = false;
            CaseObj.Status = 'Assigned';
            CaseObj.OwnerId = testUser.Id;
            CaseObj.Proposed_Employee__c = 10;
            caseObj.Employer_Contribution_Same_as_Current__c  = true;
            caseObj.Proposed_Contribution_Type__c = 'tes';
            update caseObj;
            test.stopTest();
        } catch (Exception e) {
            System.assertEquals(e.getDMLMessage(0), System.label.UnderwritingCaseCarrierHistory);
        }
    }

	static testMethod void clonePrivateExchangeRecordsTest() {
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;

        Case testCase = new Case();
        testCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Private Exchange - Blue Directions').getRecordTypeId();
        testCase.AccountId = acc.Id;
        testCase.HCSC_Division__c = 'IL';
        testCase.Status = 'New';
        testCase.Group_Exchange_Platform_Blue_Directions__c = 'Blue Directions for Large Business';
        testCase.Exchange_Lines_of_Business__c = 'Medical';

        Case testCase2 = new Case();
        testCase2.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Private Exchange - External').getRecordTypeId();
        testCase2.AccountId = acc.Id;
        testCase2.HCSC_Division__c = 'NM';
        testCase2.Status = 'New';
        testCase2.Group_Exchange_Platform__c = 'Buck RightOpt';
        testCase2.Exchange_Lines_of_Business__c = 'Dental';

        List<Case> testCaseList = new List<Case>();
        testCaseList.add(testCase);
        testCaseList.add(testCase2);

        insert testCaseList;

        Test.startTest();

        testCaseList[0].Status = 'In Progress';
        testCaseList[1].Status = 'In Progress';

        update testCaseList;

        List<Case> parentCases = [SELECT Id, (SELECT Id FROM Cases) FROM Case WHERE Id IN :testCaseList];

        System.assert(parentCases[0].Cases.size() > 0);
        System.assert(parentCases[1].Cases.size() > 0);

        Test.stopTest();
    }

    static testMethod void privateExchangeCheckSubCasesIfClosedTest() {
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;

        Case testCase = new Case();
        testCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Private Exchange - Blue Directions').getRecordTypeId();
        testCase.AccountId = acc.Id;
        testCase.HCSC_Division__c = 'IL';
        testCase.Status = 'In Progress';
        testCase.Group_Exchange_Platform_Blue_Directions__c = 'Blue Directions for Large Business';
        testCase.Exchange_Lines_of_Business__c = 'Medical';

        Case testCase2 = new Case();
        testCase2.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Private Exchange - External').getRecordTypeId();
        testCase2.AccountId = acc.Id;
        testCase2.HCSC_Division__c = 'NM';
        testCase2.Status = 'In Progress';
        testCase2.Group_Exchange_Platform__c = 'Buck RightOpt';
        testCase2.Exchange_Lines_of_Business__c = 'Dental';

        List<Case> testCaseList = new List<Case>();
        testCaseList.add(testCase);
        testCaseList.add(testCase2);

        insert testCaseList;

        Test.startTest();

        testCaseList[0].Status = 'Closed';
        testCaseList[1].Status = 'Closed';

        try {
            update testCaseList;
        } catch (Exception e) {
            List<Case> caseList = [SELECT Status FROM Case WHERE ID IN :testCaseList];

            System.assert(caseList[0].Status != 'Closed');
            System.assert(caseList[1].Status != 'Closed');
        }

        Test.stopTest();
    }
    
    /*  updateTypeFieldOnCustomContract
	*	@developer:		Alec Klein/Slalom, LLC
	*	@date:			4/1/2016
    *   @description:   Test if Type__c is mapped to Type on Custom Contract Cases
    */
	static testMethod void checkCustomContractTypeMapping(){
		Account accRec = new Account(Name='TestAccount');
		Case caseRec = new Case();
		accRec.RecordType = [SELECT Id FROM RecordType WHERE Id = '01233000000QMOm'];
		insert accRec;
		caseRec.AccountId = accRec.Id;
		caseRec.Number_of_Lives__c = 10;
		caseRec.Negotiation_Type__c = 'Negotiation Type';
		caseRec.Agreement_Submitted__c = 'Agreement Submitted';
		caseRec.State__c = 'State';
		caseRec.Status = 'Request from Sales & Marketing, Draft';
		caseRec.Account_Type_Custom_Contract__c = 'Account Type';
		caseRec.Type__c = 'Value 1';
		caseRec.Type = 'Value 2';
		caseRec.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Custom Contracts').getRecordTypeId();
		Test.StartTest();
		insert caseRec;
		Case insertedCase = [SELECT Id, Type__c, Type, RecordType.Name FROM Case WHERE Id =: caseRec.Id];
		System.assertEquals(insertedCase.Type__c, insertedCase.Type);
		Test.StopTest();
	}
}