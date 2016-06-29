/*
    @Description : This is an test class for Sharing the Financial records with the Opportunity Team Member
    @author      : Deloitte
    @date        : 10/29/2015
*/
@isTest
public with sharing class TestShareSecureAttachmentRecords {
	/*
        @Description : This is a testMethod for testing the share Secure Information page
        @author      : Deloitte
        @date        : 10/29/2015
    */
	static testMethod void myUnitTest1() {
		Account TestAcnt = TestClassUtiltity.CreateAccountRecord('TestAccount');
        
        
        List<Opportunity> TestOppLst = TestClassUtiltity.CreateOpportunities(TestAcnt.id);
        TestOppLst[0].RecordTypeId =Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal').getRecordTypeId();
        insert TestOppLst;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
	    User testUser = TestClassUtiltity.CreateUserRecord(p.Id, 'testlgnadev@user.com', 'testUser', 'test@user.com');
	    User testUser1 = TestClassUtiltity.CreateUserRecord(p.Id, 'testlgnadev123@user.com', 'testUser132', 'test123@user.com');
        
        list<AccountTeamMember> accountTeamMembers = TestClassUtiltity.createAccountTeamMembersRecords(TestAcnt.Id,testUser.Id);
	    insert accountTeamMembers; 
	    
	    list<OpportunityTeamMember> oppTeamMembers = TestClassUtiltity.createOppTeamMember(TestOppLst[0].Id,testUser1.Id);
	    oppTeamMembers.addAll(TestClassUtiltity.createOppTeamMember(TestOppLst[1].Id,testUser.Id));
        insert oppTeamMembers;
        
        Secure_Information__c secureInformation  = new Secure_Information__c(Opportunity_Name__c = TestOppLst[0].Id,Account__c = TestAcnt.Id);
        insert secureInformation;
        
        test.startTest();
        	list<Secure_Information__c> secureInformations = new list<Secure_Information__c>();
        	secureInformations.add(secureInformation);
        	ApexPages.StandardSetController sc2 = new ApexPages.StandardSetController(secureInformations);
        	ApexPages.currentPage().getParameters().put('OppId',TestOppLst[0].Id);
        	ShareSecureAttachmentRecords myCntrl = new ShareSecureAttachmentRecords(sc2);
        	myCntrl.shareRecordToOpportunityTeam();
        	myCntrl.goBack();
        	list<Secure_Information__share> shareRecords = [select Id,ParentId,UserOrGroupId,Parent.OwnerId from Secure_Information__share 
                                                                where ParentId = :secureInformation.Id  
                                                                and RowCause =:Schema.Secure_Information__share.RowCause.Secure_Information_Sharing_Reason__c];
            system.assertEquals(shareRecords.size(),2);
            
            sc2 = new ApexPages.StandardSetController(secureInformations);
            ApexPages.currentPage().getParameters().put('OppId',null);
        	ApexPages.currentPage().getParameters().put('accId',TestAcnt.Id);
        	myCntrl = new ShareSecureAttachmentRecords(sc2);
        	myCntrl.shareRecordToOpportunityTeam();
        	myCntrl.goBack();
        	
        	sc2 = new ApexPages.StandardSetController(secureInformations);
        	ApexPages.currentPage().getParameters().put('OppId',null);
        	ApexPages.currentPage().getParameters().put('accId',null);
        	myCntrl = new ShareSecureAttachmentRecords(sc2);
        	myCntrl.shareRecordToOpportunityTeam();
        test.stopTest();
	}
	/*
        @Description : This is a testMethod for checking the secure information trigger
        @author      : Deloitte
        @date        : 10/29/2015
    */
	static testMethod void myUnitTest2() {
		Account TestAcnt = TestClassUtiltity.CreateAccountRecord('TestAccount');
        TestAcnt.ShippingStreet = 'TestStreet';
        TestAcnt.ShippingCity= 'TestCity';
        TestAcnt.ShippingState= 'IL';
        TestAcnt.ShippingPostalCode= '62401-2940';
        //TestAcnt.ShippingCountry = 'United States';
        update TestAcnt;
        
        List<Opportunity> TestOppLst = TestClassUtiltity.CreateOpportunities(TestAcnt.id);
        TestOppLst[0].RecordTypeId =Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal').getRecordTypeId();
        insert TestOppLst;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
	    User testUser = TestClassUtiltity.CreateUserRecord(p.Id, 'testlgnadev@user.com', 'testUser', 'test@user.com');
	    User testUser1 = TestClassUtiltity.CreateUserRecord(p.Id, 'testlgnadev123@user.com', 'testUser132', 'test123@user.com');
        
        list<AccountTeamMember> accountTeamMembers = TestClassUtiltity.createAccountTeamMembersRecords(TestAcnt.Id,testUser.Id);
	    insert accountTeamMembers; 
	    
	    list<OpportunityTeamMember> oppTeamMembers = TestClassUtiltity.createOppTeamMember(TestOppLst[0].Id,testUser1.Id);
	    oppTeamMembers.addAll(TestClassUtiltity.createOppTeamMember(TestOppLst[1].Id,testUser.Id));
        insert oppTeamMembers;
        
        Secure_Information__c secureInformation  = new Secure_Information__c(Opportunity_Name__c = TestOppLst[0].Id,Account__c = TestAcnt.Id);
        insert secureInformation;
        
        secureInformation.Account__c = null;
        secureInformation.Opportunity_Name__c = TestOppLst[1].Id;
        update secureInformation;
        
        test.startTest();
        	
        	list<Secure_Information__share> shareRecords = [select Id,ParentId,UserOrGroupId,Parent.OwnerId from Secure_Information__share 
                                                                where ParentId = :secureInformation.Id  
                                                                and RowCause =:Schema.Secure_Information__share.RowCause.Secure_Information_Sharing_Reason__c];
            system.assertEquals(shareRecords.size(),1);
        test.stopTest();
	}
	/*
        @Description : This is a testMethod for checking the secure information batch
        @author      : Deloitte
        @date        : 10/29/2015
    */
	static testMethod void myUnitTest3() {
		Account TestAcnt = TestClassUtiltity.CreateAccountRecord('TestAccount');
        TestAcnt.ShippingStreet = 'TestStreet';
        TestAcnt.ShippingCity= 'TestCity';
        TestAcnt.ShippingState= 'IL';
        TestAcnt.ShippingPostalCode= '62401-2940';
        //TestAcnt.ShippingCountry = 'United States';
        update TestAcnt;
        
        List<Opportunity> TestOppLst = TestClassUtiltity.CreateOpportunities(TestAcnt.id);
        TestOppLst[0].RecordTypeId =Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal').getRecordTypeId();
        TestOppLst[1].RecordTypeId =Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal').getRecordTypeId();
        insert TestOppLst;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
	    User testUser = TestClassUtiltity.CreateUserRecord(p.Id, 'testlgnadev@user.com', 'testUser', 'test@user.com');
	    User testUser1 = TestClassUtiltity.CreateUserRecord(p.Id, 'testlgnadev123@user.com', 'testUser132', 'test123@user.com');
        
        list<AccountTeamMember> accountTeamMembers = TestClassUtiltity.createAccountTeamMembersRecords(TestAcnt.Id,testUser.Id);
	    insert accountTeamMembers; 
	    
	    list<OpportunityTeamMember> oppTeamMembers = TestClassUtiltity.createOppTeamMember(TestOppLst[0].Id,testUser1.Id);
	    oppTeamMembers.addAll(TestClassUtiltity.createOppTeamMember(TestOppLst[1].Id,testUser.Id));
        insert oppTeamMembers;
        
        list<Secure_Information__c> secureInformation  = new list<Secure_Information__c>();
        secureInformation.add(new Secure_Information__c(Opportunity_Name__c = TestOppLst[0].Id,Account__c = TestAcnt.Id));
        secureInformation.add(new Secure_Information__c(Opportunity_Name__c = TestOppLst[1].Id));
        secureInformation.add(new Secure_Information__c(Account__c = TestAcnt.Id));
        
        try{
        	insert secureInformation;
        
        
        
	        test.startTest();
	        	BatchShareSecureAttachmentRecord bt = new BatchShareSecureAttachmentRecord();
	        	Id batchId=database.executeBatch(bt);
	        	list<Secure_Information__share> shareRecords = [select Id,ParentId,UserOrGroupId,Parent.OwnerId from Secure_Information__share 
	                                                                where ParentId = :secureInformation[0].Id  
	                                                                and RowCause =:Schema.Secure_Information__share.RowCause.Secure_Information_Sharing_Reason__c];
	            system.assertEquals(shareRecords.size(),2);
	            secureInformation.add(new Secure_Information__c(Type__c = 'ASO'));
	            upsert  secureInformation;
	        test.stopTest();
        }catch(Exception e){
        	
        }
	}
}