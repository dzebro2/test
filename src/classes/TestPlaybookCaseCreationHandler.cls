@isTest
private class TestPlaybookCaseCreationHandler {


    static testMethod void myUnitTest() {
	
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
         User testUser = TestClassUtiltity.CreateUserRecord(p.Id, 'testlgnadev@user.com', 'testUser', 'test@user.com');
         system.runAs(testUser){
            //create Account
            List<Account> accList = new List<Account>();
            Account testAccount = TestClassUtiltity.CreateAccountRecord('Test Account');
            testAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Group Account').getRecordTypeId();
            testAccount.status__c = 'Sold';
            testAccount.Fax = '1234567';
            update testAccount;
            
            Contact TestCon = TestClassUtiltity.CreateContactRecord(testAccount.id, 'TestFirstName', 'TestLastname', null);
            testCon.RecordTypeId =    Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Internal Contact').getRecordTypeId(); 
            update testCon;
            
            TestClassUtiltity.createPlaybookSettingsFields();
            
            list<Playbook__c> playBooks = TestClassUtiltity.createPlayBookRecords();
            insert playBooks;
            
            list<Stage__c> stages = TestClassUtiltity.createStageRecords(playBooks[0].Id);
            insert stages;
            
            list<Substage__c> substages = TestClassUtiltity.createSubStageRecords(stages[0].Id);
            insert substages;
            
            list<Task__c> tasks = TestClassUtiltity.createTaskSubStageRecords(substages[0].Id);
            tasks[0].Case_Record_Type__c = 'Custom Benefit/Service';
            tasks[1].Case_Record_Type__c = 'Underwriting';
            insert tasks;
      
            //create Opportunity records
			List<Opportunity> opportunities = new List<Opportunity>();
			opportunities.add(new Opportunity(AccountId = testAccount.Id, Name = 'oppName 1', StageName = 'Qualification', CloseDate = system.Today().addYears(2), Expected_Decision_Date__c = system.Today().addYears(1), RFI_RFP_Received_Date__c = system.Today().addYears(1)));

            opportunities[0].RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal').getRecordTypeId();
            opportunities[0].StageName = 'Closed Won';
			opportunities[0].Primary_Closed_Reason__c = 'Savings';
            opportunities[0].Exchange_Offering_Type__c = 'No Private Exchange';
            
            insert opportunities;               
            
            //create Opportunity Team Members
            list<OpportunityTeamMember> oppTeamMembers = TestClassUtiltity.createOppTeamMember(opportunities[0].Id,testUser.Id);
            oppTeamMembers[0].TeamMemberRole = 'Accountant';
            insert oppTeamMembers;
            
            //create Opportunity Team NON SF Members
            list<Opportunity_Team_Non_SF__c> oppTeamMembersNonSF = TestClassUtiltity.createOppTeamNonSF(opportunities[0].Id,TestCon.Id);
            insert oppTeamMembersNonSF;
            
            list<Stage_Mapping__c> stageMapping = TestClassUtiltity.createStageMappings(stages[0].Id,playBooks[0].Id,opportunities[0].Id);
            insert stageMapping;
            
            list<Substage_Mapping1__c> substageMapping = TestClassUtiltity.createSubStageMappings(stageMapping[0].Id,substages[0].Id);
            insert substageMapping;
            
            list<Task_Mapping__c> taskMappings = TestClassUtiltity.createTaskMappings(substageMapping[0].Id,tasks[0].Id);
            taskMappings[0].Task__c = tasks[1].Id;
            insert taskMappings;            
            
            list<Id> taskMappingIds = new list<Id>();
            for(Task_Mapping__c tm: taskMappings)
                taskMappingIds.add(tm.Id);

            test.startTest();
            PlaybookCaseCreationHandler.createCases(opportunities[0].Id,taskMappingIds);

            list<Case> tempcases = [select Id from Case];
            system.assertequals(2,tempcases.size());
               
            test.stopTest();
         }
    }

	 static testMethod void myUnitTest1() {
	
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
         User testUser = TestClassUtiltity.CreateUserRecord(p.Id, 'testlgnadev@user.com', 'testUser', 'test@user.com');
         system.runAs(testUser){
            //create Account
            List<Account> accList = new List<Account>();
            Account testAccount = TestClassUtiltity.CreateAccountRecord('Test Account');
            testAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Group Account').getRecordTypeId();
            testAccount.status__c = 'Sold';
            testAccount.Fax = '1234567';
            update testAccount;
               
            Contact TestCon = TestClassUtiltity.CreateContactRecord(testAccount.id, 'TestFirstName', 'TestLastname', null);
            testCon.RecordTypeId =    Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Internal Contact').getRecordTypeId(); 
            update testCon;
            
            TestClassUtiltity.createPlaybookSettingsFields();
            
            list<Playbook__c> playBooks = TestClassUtiltity.createPlayBookRecords();
            insert playBooks;
            
            list<Stage__c> stages = TestClassUtiltity.createStageRecords(playBooks[0].Id);
            insert stages;
            
            list<Substage__c> substages = TestClassUtiltity.createSubStageRecords(stages[0].Id);
            insert substages;
            
            list<Task__c> tasks = TestClassUtiltity.createTaskSubStageRecords(substages[0].Id);
            tasks[0].Case_Record_Type__c = 'Cede';
            tasks[1].Case_Record_Type__c = 'Private Exchange - Blue Directions';
            insert tasks;    
            
            //create Opportunity records
			List<Opportunity> opportunities = new List<Opportunity>();
			opportunities.add(new Opportunity(AccountId = testAccount.Id, Name = 'oppName 1', StageName = 'Qualification', CloseDate = system.Today().addYears(2), Expected_Decision_Date__c = system.Today().addYears(1), RFI_RFP_Received_Date__c = system.Today().addYears(1)));	
            opportunities[0].RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal').getRecordTypeId();
            opportunities[0].StageName = 'Closed Won';
			opportunities[0].Primary_Closed_Reason__c = 'Savings';
            opportunities[0].Exchange_Offering_Type__c = 'No Private Exchange';   
			
			insert opportunities;    
            
            //create Opportunity Team Members
            list<OpportunityTeamMember> oppTeamMembers = TestClassUtiltity.createOppTeamMember(opportunities[0].Id,testUser.Id);
            oppTeamMembers[0].TeamMemberRole = 'Underwriter';
            insert oppTeamMembers;
            
            //create Opportunity Team NON SF Members
            list<Opportunity_Team_Non_SF__c> oppTeamMembersNonSF = TestClassUtiltity.createOppTeamNonSF(opportunities[0].Id,TestCon.Id);
            insert oppTeamMembersNonSF;
            
            list<Stage_Mapping__c> stageMapping = TestClassUtiltity.createStageMappings(stages[0].Id,playBooks[0].Id,opportunities[0].Id);
            insert stageMapping;
            
            list<Substage_Mapping1__c> substageMapping = TestClassUtiltity.createSubStageMappings(stageMapping[0].Id,substages[0].Id);
            insert substageMapping;
            
            list<Task_Mapping__c> taskMappings = TestClassUtiltity.createTaskMappings(substageMapping[0].Id,tasks[0].Id);
            taskMappings[0].Task__c = tasks[1].Id;
            insert taskMappings;    
            
            list<Id> taskMappingIds = new list<Id>();
            for(Task_Mapping__c tm: taskMappings)
                taskMappingIds.add(tm.Id);  
				    
            test.startTest();
            PlaybookCaseCreationHandler.createCases(opportunities[0].Id,taskMappingIds);

            list<Case> tempcases = [select Id from Case];
            system.assertequals(2,tempcases.size());
      
            test.stopTest();
         }
    }
    
    static testMethod void myUnitTest2() {
	  
         Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
         User testUser = TestClassUtiltity.CreateUserRecord(p.Id, 'testlgnadev@user.com', 'testUser', 'test@user.com');
         User testUser1 = TestClassUtiltity.CreateUserRecord(p.Id, 'testlgnadev1@user.com', 'testUser1', 'test1@user.com');
      
         system.runAs(testUser){
            //create Account
            Account testAccount = TestClassUtiltity.CreateAccountRecord('Test Account');
            testAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Group Account').getRecordTypeId();
            testAccount.status__c = 'Sold';
            testAccount.Fax = '1234567';
            testAccount.Ceded_From_ICL__c = 'LA';
            testAccount.Ceded_To_ACL__c = 'AL';
            testAccount.Effective_Date__c = date.today();
            testAccount.Cede_End_Date__c = date.today();
            testAccount.Funding_Type__c = 'ACAP';
            testAccount.Active_Health_Subscribers__c = 20 ;
                             
            update testAccount;
            Contact TestCon = TestClassUtiltity.CreateContactRecord(testAccount.id, 'TestFirstName', 'TestLastname', null);
            testCon.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Internal Contact').getRecordTypeId(); 
            update testCon;       
            
            TestClassUtiltity.createPlaybookSettingsFields();
            
            list<Playbook__c> playBooks = TestClassUtiltity.createPlayBookRecords();
            insert playBooks;
            
            list<Stage__c> stages = TestClassUtiltity.createStageRecords(playBooks[1].Id);
            insert stages;
            
            list<Substage__c> substages = TestClassUtiltity.createSubStageRecords(stages[0].Id);
            insert substages;
            
            list<Task__c> tasks = TestClassUtiltity.createTaskSubStageRecords(substages[0].Id);
            tasks[0].Case_Record_Type__c = 'Performance Guarantee';
            tasks[1].Case_Record_Type__c = 'Underwriting';
            insert tasks;
      
             //create Opportunity records
			List<Opportunity> opportunities = new List<Opportunity>();
			opportunities.add(new Opportunity(AccountId = testAccount.Id, Name = 'oppName 1', StageName = 'Qualification', CloseDate = system.Today().addYears(2), Expected_Decision_Date__c = system.Today().addYears(1), RFI_RFP_Received_Date__c = system.Today().addYears(1)));
		
            opportunities[0].RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal').getRecordTypeId();
            opportunities[0].StageName = 'Lost';
			opportunities[0].Primary_Closed_Reason__c = 'Savings';
            opportunities[0].Exchange_Offering_Type__c = 'No Private Exchange';
    
            insert opportunities;    
            
            // create Opportunity Contact Roles
            list<OpportunityContactRole> oppConRoleList = new list<OpportunityContactRole>();      
            OpportunityContactRole oppConRole3 = new OpportunityContactRole(ContactId = testCon.Id, OpportunityId = opportunities[0].Id, Role = 'Producer' );
            oppConRoleList.add(oppConRole3);
        
            insert oppConRoleList;
                                       
            list<OpportunityTeamMember> oppTeamMembers = TestClassUtiltity.createOppTeamMember(opportunities[0].Id,testUser.Id);
            list<OpportunityTeamMember> oppTeamMembers1 = TestClassUtiltity.createOppTeamMember(opportunities[0].Id,testUser1.Id);      
            list<OpportunityTeamMember> oppTeamMembersList = new list<OpportunityTeamMember>();
            oppTeamMembers[0].TeamMemberRole = 'Accountant';
            oppTeamMembers1[0].TeamMemberRole = 'Sales Executive';        
            oppTeamMembersList.add(oppTeamMembers[0]);
            oppTeamMembersList.add(oppTeamMembers1[0]);
        
            insert oppTeamMembersList;
                                        
            list<Stage_Mapping__c> stageMapping = TestClassUtiltity.createStageMappings(stages[0].Id,playBooks[1].Id,opportunities[0].Id);
            insert stageMapping;
            
            list<Substage_Mapping1__c> substageMapping = TestClassUtiltity.createSubStageMappings(stageMapping[0].Id,substages[0].Id);
            insert substageMapping;
            
            list<Task_Mapping__c> taskMappings = TestClassUtiltity.createTaskMappings(substageMapping[0].Id,tasks[0].Id);
            taskMappings[0].Task__c = tasks[1].Id;
            insert taskMappings;
            
            for(Task_Mapping__c tm: taskMappings)
                tm.Completed__c = true;
            update taskMappings;
            
            list<Id> taskMappingIds = new list<Id>();
            for(Task_Mapping__c tm: taskMappings)
                taskMappingIds.add(tm.Id);

			test.startTest();
            PlaybookCaseCreationHandler.createCases(opportunities[0].Id,taskMappingIds);
            list<Case> tempcases = [select Id from Case];
            system.assertequals(2,tempcases.size());
        
            test.stopTest();
         }
	}

	static testMethod void myUnitTest3() {
	 
         Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
         User testUser = TestClassUtiltity.CreateUserRecord(p.Id, 'testlgnadev@user.com', 'testUser', 'test@user.com');
         User testUser1 = TestClassUtiltity.CreateUserRecord(p.Id, 'testlgnadev1@user.com', 'testUser1', 'test1@user.com');
          
         system.runAs(testUser){
		 
            //create Account
            Account testAccount = TestClassUtiltity.CreateAccountRecord('Test Account');
            testAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Group Account').getRecordTypeId();
            testAccount.status__c = 'Sold';
            testAccount.Fax = '1234567';
            testAccount.Ceded_From_ICL__c = 'LA';
            testAccount.Ceded_To_ACL__c = 'AL';
            testAccount.Effective_Date__c = date.today();
            testAccount.Cede_End_Date__c = date.today();
            testAccount.Funding_Type__c = 'ACAP';
            testAccount.Active_Health_Subscribers__c = 20 ;
                             
            update testAccount;
            Contact TestCon = TestClassUtiltity.CreateContactRecord(testAccount.id, 'TestFirstName', 'TestLastname', null);
            testCon.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Internal Contact').getRecordTypeId(); 
            update testCon;      
            
            TestClassUtiltity.createPlaybookSettingsFields();
            
            list<Playbook__c> playBooks = TestClassUtiltity.createPlayBookRecords();
            insert playBooks;
            
            list<Stage__c> stages = TestClassUtiltity.createStageRecords(playBooks[1].Id);
            insert stages;
            
            list<Substage__c> substages = TestClassUtiltity.createSubStageRecords(stages[0].Id);
            insert substages;
            
            list<Task__c> tasks = TestClassUtiltity.createTaskSubStageRecords(substages[0].Id);
            tasks[0].Case_Record_Type__c = 'Private Exchange - External';
            tasks[1].Case_Record_Type__c = 'Cede';
            insert tasks;
                                          
            //create Opportunity records
			List<Opportunity> opportunities = new List<Opportunity>();
			opportunities.add(new Opportunity(AccountId = testAccount.Id, Name = 'oppName 1', StageName = 'Qualification', CloseDate = system.Today().addYears(2), Expected_Decision_Date__c = system.Today().addYears(1), RFI_RFP_Received_Date__c = system.Today().addYears(1)));		
            opportunities[0].RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal').getRecordTypeId();
            opportunities[0].StageName = 'Lost';
			opportunities[0].Primary_Closed_Reason__c = 'Savings';
            opportunities[0].Exchange_Offering_Type__c = 'No Private Exchange';
            
            insert opportunities;            
            
            // create Opportunity Contact Roles
            list<OpportunityContactRole> oppConRoleList = new list<OpportunityContactRole>();       
            OpportunityContactRole oppConRole3 = new OpportunityContactRole(ContactId = testCon.Id, OpportunityId = opportunities[0].Id, Role = 'Consultant' );
            oppConRoleList.add(oppConRole3);      
            insert oppConRoleList;                         
            
            list<OpportunityTeamMember> oppTeamMembers = TestClassUtiltity.createOppTeamMember(opportunities[0].Id,testUser.Id);
            list<OpportunityTeamMember> oppTeamMembers1 = TestClassUtiltity.createOppTeamMember(opportunities[0].Id,testUser1.Id);        
            list<OpportunityTeamMember> oppTeamMembersList = new list<OpportunityTeamMember>();
            oppTeamMembers[0].TeamMemberRole = 'Account Executive';
            oppTeamMembers1[0].TeamMemberRole = 'Underwriter';        
            oppTeamMembersList.add(oppTeamMembers[0]);
            oppTeamMembersList.add(oppTeamMembers1[0]);
          
            insert oppTeamMembersList;
          
            List<Product2> products = TestClassUtiltity.createProducts();
            insert products;
            List<Opportunity_Product__c> opptyprods = TestClassUtiltity.createOpptyProducts(opportunities[0].Id,products[0].Id);
            opptyprods[0].Funding_Type__c = 'ACAP';
            opptyprods[0].Premium_Type__c = 'PP';
            opptyprods[1].Funding_Type__c = 'ASO';
            opptyprods[1].Premium_Type__c = 'RP';
            insert opptyprods;
            
            list<Stage_Mapping__c> stageMapping = TestClassUtiltity.createStageMappings(stages[0].Id,playBooks[1].Id,opportunities[0].Id);
            insert stageMapping;
            
            list<Substage_Mapping1__c> substageMapping = TestClassUtiltity.createSubStageMappings(stageMapping[0].Id,substages[0].Id);
            insert substageMapping;
            
            list<Task_Mapping__c> taskMappings = TestClassUtiltity.createTaskMappings(substageMapping[0].Id,tasks[0].Id);
            taskMappings[0].Task__c = tasks[1].Id;
            insert taskMappings;
            
            for(Task_Mapping__c tm: taskMappings)
                tm.Completed__c = true;
            update taskMappings;   
            
            list<Id> taskMappingIds = new list<Id>();
            for(Task_Mapping__c tm: taskMappings)
                taskMappingIds.add(tm.Id);                 
            test.startTest();          
            PlaybookCaseCreationHandler.createCases(opportunities[0].Id,taskMappingIds);
            list<Case> tempcases = [select Id from Case];
            system.assertequals(2,tempcases.size());
			   
            test.stopTest();
         }
    }

}