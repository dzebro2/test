/**
* This class contains unit tests for validating the behavior of Apex classes
*
*TODO
*test exception?
*Current code coverage: 81%
*/
@isTest
private class ResubmitCasePageControllerTest {
    
    static testMethod void testResubmitCasePageController() {
        try {
            //create test profile
            Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' limit 1];
            User testUser = TestClassUtiltity.CreateUserRecord(p.Id, 'testlgnadev@user.com', 'testUser', 'test@user.com');
            system.runAs(testUser) {
                
                Test.StartTest();
                //create test account
                Account TestAct = TestClassUtiltity.CreateAccountRecord('TestAccount');
                
                TestAct.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Group Account').getRecordTypeId();
                TestAct.status__c = 'Sold';
                TestAct.Fax = '1234567';
                TestAct.ShippingStreet = 'test';
                TestAct.ShippingCity = 'Florida';
                TestAct.ShippingState = 'IL';
                TestAct.ShippingPostalCode = '12345';
                update TestAct;
                
                //create test opportunity
                List<Opportunity> TestOptys = TestClassUtiltity.CreateOpportunities(TestAct.id);
                Opportunity TestOpp = TestOptys.get(0);
                TestOpp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal').getRecordTypeId();
                insert TestOpp;
                
                list<Product2> products = TestClassUtiltity.createProducts();
                insert products;
                
                Opportunity_Product__c op1 = new Opportunity_Product__c(Premium_Type__c = 'RP', Funding_Type__c = 'PREM', Opportunity_Name__c = TestOpp.Id, Product__c = products[0].Id);
                Opportunity_Product__c op2 = new Opportunity_Product__c(Premium_Type__c = 'PP', Funding_Type__c = 'ASO', Opportunity_Name__c = TestOpp.Id, Product__c = products[1].Id);
                insert op1;
                insert op2;
                
                //create Producer Association for Opportunity
                List<Producer_Association_For_Opportunity__c> pAOList = TestClassUtiltity.createProducerAssociationForOpportunity(TestAct.Id, TestOpp.Id);
                insert pAOList;
                
                //create Internal Contact
                Contact TestCon = TestClassUtiltity.CreateContactRecord(TestAct.id, 'TestFirstName', 'TestLastname', null);
                testCon.RecordTypeId =    Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Internal Contact').getRecordTypeId();
                update TestCon;
                
                //create Opportunity Team Members
                List<OpportunityTeamMember> oppTeamMembers = TestClassUtiltity.createOppTeamMember(TestOpp.Id, testUser.Id);
                oppTeamMembers[0].TeamMemberRole = 'Account Executive';
                insert oppTeamMembers;
                
                //create Opportunity Team NON SF Members
                list<Opportunity_Team_Non_SF__c> oppTeamMembersNonSF = TestClassUtiltity.createOppTeamNonSF(TestOpp.Id, TestCon.Id);
                insert oppTeamMembersNonSF;
                
                PageReference initialPage = new PageReference('/apex/ResubmitCasePage');
                Test.setCurrentPage(initialPage);
                System.assertNotEquals(null, InitialPage);
                
                ApexPages.StandardController sc = new ApexPages.StandardController(TestOpp);
                ApexPages.currentPage().getParameters().put( 'oid' , TestOpp.id );
                
                
                ResubmitCasePageController controller = new ResubmitCasePageController(sc);
                controller.SelectedRecordType = 'Network Information';
                controller.setRecordType();
                
                //Assert created case information
                Case testCase = Controller.thecase;
                System.assertEquals( TestAct.id, testCase.AccountId);
                           
                //Test controller cancel function
                Test.setCurrentPage(InitialPage);
                PageReference result = controller.cancel();
                Test.setCurrentPage(result);
                System.assertEquals(result.getUrl(), ApexPages.currentPage().getUrl());
                
                Test.StopTest();
            }
        } catch (Exception ex) {
            System.debug('Exception: ' + ex.getMessage());
            throw ex;
        }
    }
    
    static testMethod void testGetItems(){
        
        //create test profile
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
        User testUser = TestClassUtiltity.CreateUserRecord(p.Id, 'testlgnadev@user.com', 'testUser', 'test@user.com');
        system.runAs(testUser) {
            
            Test.startTest();
            
            //create test account
            Account TestAct = TestClassUtiltity.CreateAccountRecord('TestAccount');
            TestAct.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Group Account').getRecordTypeId();
            TestAct.status__c = 'Sold';
            TestAct.Fax = '1234567';
            TestAct.ShippingStreet = 'test';
            TestAct.ShippingCity = 'Florida';
            TestAct.ShippingState = 'IL';
            TestAct.ShippingPostalCode = '12345';
            update TestAct;
            
            //create test opportunity
            List<Opportunity> TestOptys = TestClassUtiltity.CreateOpportunities(TestAct.id);
            Opportunity TestOpp = TestOptys.get(0);
            TestOpp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal').getRecordTypeId();
            insert TestOpp;
            
            PageReference initialPage = new PageReference('/apex/ResubmitCasePage');
            Test.setCurrentPage(initialPage);
            System.assertNotEquals(null, InitialPage);
            
            ApexPages.StandardController sc = new ApexPages.StandardController(TestOpp);
            ApexPages.currentPage().getParameters().put( 'oid' , TestOpp.id );
            
            
            
            //Test controller save function
            ResubmitCasePageController controller = new ResubmitCasePageController(sc);
            
            //ResubmitCasePageController testController = new ResubmitCasePageController(new ApexPages.StandardController(new Case()));
            upsert new ResubmitActionNames__c(Name = 'Network Information', Action_Name__c = 'Network Information');
            upsert new ResubmitActionNames__c(Name = 'Performance Guarantee', Action_Name__c = 'Performance Guarantee');
            upsert new ResubmitActionNames__c(Name = 'Proposal', Action_Name__c = 'Proposal');
            
            controller.isNetwork = '1';
            controller.isPerformance = '1';
            controller.isProposal = '1';
            List<SelectOption> testSelectList = controller.getItems();
            
            System.assertEquals(4, testSelectList.size());
            System.assertEquals(testSelectList[0].getLabel(), '-None-');
            System.assertEquals(testSelectList[1].getLabel(), 'Network Information');
            System.assertEquals(testSelectList[2].getLabel(), 'Performance Guarantee');
            System.assertEquals(testSelectList[3].getLabel(), 'Proposal');
            Test.stopTest();
        }
        
    }
}