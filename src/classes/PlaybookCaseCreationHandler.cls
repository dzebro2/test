global class PlaybookCaseCreationHandler {

    webService static string createCases(String opportunityId, list<String> tMIds) {

        system.debug('oppty ---->' + opportunityId);
        system.debug('task ids ---->' + tMIds);

        // Opportunity Info
        Opportunity opp = [SELECT  Id, StageName, Playbook__c, Expected_Health_Members__c, createdDate, LastModifiedDate, AccountId, Account.RecordType.DeveloperName, Account.of_BCBS_Enrolled_Subscribers__c,
                           Name, Requested_Effective_Date__c, HCSC_Division__c, closeDate, FSU_Location__c, Other_FSU_Location__c, District__c,
                           Account.External_ID__c, Account.Funding_Type__c, Account.Group_Anniversary_Date__c, ownerID, createdbyid, Expected_Health_Contracts__c, Expected_Dental_Contracts__c,
                           (Select Id, OpportunityId, ContactId, Contact.Name , Role, IsPrimary From OpportunityContactRoles),
                           (Select Opportunity__c, Producer_Consultant__c, Account_Record_Type__c from Producer_Association_For_Opportunity__r) From Opportunity Where Id = : opportunityId Limit 1];


        //Opportunity TeamMembers
        Map<String, List<OpportunityTeamMember>> oppTeamMembers = new Map<String, List<OpportunityTeamMember>>();
        try {
            for (OpportunityTeamMember otm : [Select Id, TeamMemberRole, UserId, OpportunityId From OpportunityTeamMember
                                              Where OpportunityId = :opp.Id]) {
                if (!oppTeamMembers.containsKey(otm.TeamMemberRole )) {
                    oppTeamMembers.put( otm.TeamMemberRole, new List<OpportunityTeamMember>() );
                }
                oppTeamMembers.get( otm.TeamMemberRole ).add( otm );
            }
        } catch (exception e) {
            System.debug( 'Exception : ' + e.getMessage() );
            throw e;
        }


        // Opportunity Non SF team members
        Map<String, List<Opportunity_Team_Non_SF__c>> oppTeamMembersNonSF = new Map<String, List<Opportunity_Team_Non_SF__c>>();
        try {
            for (Opportunity_Team_Non_SF__c oppTeamNonSF : [SELECT Id, Member_Role__c, Opportunity_Team_Member__c, Opportunity_Team_Member__r.Name, Opportunity_Team_Member__r.Email
                    FROM Opportunity_Team_Non_SF__c WHERE Opportunity_Name__c = :opp.Id]) {
                if (!oppTeamMembersNonSF.containsKey(oppTeamNonSF.Member_Role__c)) {
                    List<Opportunity_Team_Non_SF__c> tempOppTeamNonSFList = new List<Opportunity_Team_Non_SF__c>();
                    tempOppTeamNonSFList.add(oppTeamNonSF);
                    oppTeamMembersNonSF.put(oppTeamNonSF.Member_Role__c, tempOppTeamNonSFList);
                } else {
                    oppTeamMembersNonSF.get(oppTeamNonSF.Member_Role__c).add(oppTeamNonSF);
                }
            }
        } catch (Exception e) {
            System.debug( 'Exception : ' + e.getMessage() );
            throw e;
        }



        // Cases related to Opportunity
        Map<String, Case> casesRelatedToOpportunity = new Map<String, Case>();
        try {
            for ( Case caseRec : [Select  Id, Related_Case__c, RecordTypeId, RecordType.Name From Case where Opportunity_Name__c = :opp.Id]) {
                casesRelatedToOpportunity.put(caseRec.RecordType.Name, caseRec);
            }
        } catch (Exception e) {
            throw e;
        }


        // Pni userId
        Id pniOwnerId;
        try {
            List<Group> queues = [SELECT  Id FROM Group Where Type = 'Queue' AND DeveloperName = 'Proposal_Delivery_Unit' limit 1];
            if ( queues.size() > 0 ) {
                pniOwnerId = queues[0].Id;
            }
        } catch (Exception e) {
            System.debug( 'Exception : ' + e.getMessage() );
            throw e;
        }



        // Group Status
        String groupStatus = '';
        if (opp.Account.RecordType.DeveloperName == 'Group_Prospect_Account')
            groupStatus = 'New Group';
        if (opp.Account.RecordType.DeveloperName == 'Group_Account')
            groupStatus = 'Existing Group';


        // Account record
        Account accountRecord = new Account();
        accountRecord = [select Active_Health_Subscribers__c, OwnerId, Active_Health_Members__c, Ceded_From_ICL__c, Ceded_To_ACL__c,
                         Effective_Date__c, Cede_End_Date__c, Funding_Type__c, Market_Segment__c from Account
                         where Id = :opp.AccountId order By CreatedDate Desc limit 1][0];


        // cede team queue
        Id cedeTeamQueue;
        string queueId = null;
        for (QueuesObject q : [select Id, QueueId from QueuesObject where queue.DeveloperName = 'Cede_Team' limit 1]) {
            cedeTeamQueue = q.QueueId;
        }


        //underwritingCaseRecord = getUnderwritingCaseRecord();



        // Funding type
        String funding_type ;
        try {
            for (Opportunity_Product__c op : [select id , Funding_type__c from Opportunity_Product__c where  Opportunity_Name__c = :opp.Id]) {
                if (funding_type == null) {
                    funding_type = op.Funding_type__c;
                } else if (!funding_type.contains(op.Funding_type__c)) {
                    funding_type = funding_type + ';' + op.Funding_type__c;
                }
            }
        } catch (Exception e) {
            throw e;
        }



        // premium type
        String premiumType ;
        try {
            for (Opportunity_Product__c op : [select id , Premium_Type__c from Opportunity_Product__c where  Opportunity_Name__c = :opp.Id]) {
                if (premiumType == null) {
                    premiumType = op.Premium_Type__c;
                } else if (!premiumType.contains(op.Premium_Type__c)) {
                    premiumType = premiumType + ';' + op.Premium_Type__c;
                }
            }
        } catch (Exception e) {
            throw e;
        }




        list<Task_Mapping__c> tMappingList = new list<Task_Mapping__c>([Select Id, Name, Task__r.Id, Task__r.Name, Task__r.Case_Record_Type__c,
                Task__r.Trigger_After_Completion__c From Task_Mapping__c
                Where Id = : tMIds]);
        system.debug('--------- queried task maps ---->' + tMappingList);

        list<Case> casesToBeCreated = new list<Case>();

        for (Task_Mapping__c tm : tMappingList) {
            system.debug('----- creat a case? ---> ' + tm.Task__r.Name + ' -- ' + tm.Id + ' -- ' + tm.Task__r.Trigger_After_Completion__c);
            if ( String.isNotBlank(tm.Task__r.Trigger_After_Completion__c) && tm.Task__r.Trigger_After_Completion__c == 'Create a Case'
                    && !casesRelatedToOpportunity.containsKey(tm.Task__r.Case_Record_Type__c)) {


                // ************************ Case Record creation start ***********************

                Case caseRec = new Case();

                try {
                    caseRec.AccountId = opp.AccountId;
                    caseRec.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(tm.Task__r.Case_Record_Type__c).getRecordTypeId();
                    caseRec.Opportunity_Name__c  = opp.Id;
                    if (caseRec.RecordTypeId == Schema.SObjectType.Case.getRecordTypeInfosByName().get( System.label.Custom_Benefit_Service).getRecordTypeId()
                            || caseRec.RecordTypeId == Schema.SObjectType.Case.getRecordTypeInfosByName().get( 'Mid-Market Underwriting' ).getRecordTypeId()
                            || caseRec.RecordTypeId == Schema.SObjectType.Case.getRecordTypeInfosByName().get( 'Private Exchange - Blue Directions').getRecordTypeId()
                            || caseRec.RecordTypeId == Schema.SObjectType.Case.getRecordTypeInfosByName().get( 'Private Exchange - External' ).getRecordTypeId())
                        caseRec.Status = 'Draft';
                    else
                        caseRec.Status = 'New';
                    caseRec.Requested_Effective_Date__c = opp.Requested_Effective_Date__c;
                    caseRec.FSU_Location__c             = opp.FSU_Location__c;
                    caseRec.Other_FSU_Location__c       = opp.Other_FSU_Location__c;
                    caseRec.HCSC_Division__c            = opp.HCSC_Division__c;
                    caseRec.Funding_Type_Multiselect__c = funding_type;
                    caseRec.Premium_Type__c             = premiumType;
                    caseRec.Number_of_Subscribers__c    = opp.Account.of_BCBS_Enrolled_Subscribers__c;
                    caseRec.Subject                     = opp.Name + ' ' + (tm.Task__r.Case_Record_Type__c == null ? '' : tm.Task__r.Case_Record_Type__c);

                    for (Producer_Association_For_Opportunity__c pao : opp.Producer_Association_For_Opportunity__r) {
                        caseRec.Consulting_Firm__c = pao.Producer_Consultant__c;
                    }

                    if (!oppTeamMembers.isEmpty()) {
                        if (oppTeamMembers.containsKey('Sales Executive')) {
                            caseRec.Sales_Executive__c = oppTeamMembers.get('Sales Executive')[0].UserId;
                        }
                        if (oppTeamMembers.containsKey('Account Executive')) {
                            caseRec.Account_Executive__c = oppTeamMembers.get('Account Executive')[0].UserId;
                        }
                    }

                    if (!oppTeamMembersNonSF.isEmpty()) {
                        if (oppTeamMembersNonSF.containsKey('Underwriter')) {
                            caseRec.Underwriter_Lookup__c = oppTeamMembersNonSF.get('Underwriter')[0].Opportunity_Team_Member__r.Name + ' (' + oppTeamMembersNonSF.get('Underwriter')[0].Opportunity_Team_Member__r.Email + ')';
                        }
                    }

                    if ( pniOwnerId != null && ( tm.Task__r.Case_Record_Type__c == 'Proposal' || tm.Task__r.Case_Record_Type__c == 'Network Information' )) {
                        caseRec.OwnerId = UserInfo.getUserId() ;
                    }


                    // Performance Gaurantee
                    if (tm.Task__r.Case_Record_Type__c == 'Performance Guarantee') {
                        caseRec.Requested_By__c = UserInfo.getUserId();
                        caseRec.Group_Status__c = groupStatus;
                        caseRec.Group_Number_s__c = opp.Account.External_ID__c;
                        caseRec.Consulting_Firm__c = null;
                        caseRec.Expected_Health_Contracts__c = opp.Expected_Health_Contracts__c ;
                        caseRec.Expected_Dental_Contracts__c = opp.Expected_Dental_Contracts__c ;

                        if (oppTeamMembers.containsKey('Underwriter')) {
                            caseRec.Underwriter_Lookup__c = oppTeamMembers.get('Underwriter')[0].UserId;
                        }
                        for (Producer_Association_For_Opportunity__c pao : opp.Producer_Association_For_Opportunity__r) {
                            if (pao.Account_Record_Type__c == 'Consultant Account')
                                caseRec.Consulting_Firm__c = pao.Producer_Consultant__c;
                            if (pao.Account_Record_Type__c == 'Producer Account')
                                caseRec.Producer_Account__c = pao.Producer_Consultant__c;
                        }
                    }


                    // Custom Benefit/Service
                    if (tm.Task__r.Case_Record_Type__c == 'Custom Benefit/Service') {
                        caseRec.Marketing_District__c = opp.District__c;
                        caseRec.Group_Anniversary_Date__c = opp.Account.Group_Anniversary_Date__c;
                        caseRec.Number_of_Subscribers__c = opp.Expected_Health_Contracts__c;
                        caseRec.Requested_Effective_Date__c = opp.Requested_Effective_Date__c;
                        if (oppTeamMembers.containsKey('Underwriter')) {
                            caseRec.Underwriter_Lookup__c = oppTeamMembers.get('Underwriter')[0].UserId;
                        }
                    }


                    // Proposal
                    if (tm.Task__r.Case_Record_Type__c == 'Proposal') {
                        caseRec.Expected_Health_Contracts__c = opp.Expected_Health_Contracts__c ;
                        caseRec.Expected_Dental_Contracts__c = opp.Expected_Dental_Contracts__c ;
                        caseRec.Requested_By__c = opp.OwnerId;
                        //caseRec.OwnerId = opp.Consulting_Firm__c;
                    }

                    System.debug('Record Type = ' + tm.Task__r.Case_Record_Type__c);

                    // Private Exchange - Blue Directions
                    if (tm.Task__r.Case_Record_Type__c == 'Private Exchange - Blue Directions') {
                        System.debug('Record Type = ' + tm.Task__r.Case_Record_Type__c);
                        caseRec.Group_Exchange_Platform_Blue_Directions__c = 'Blue Directions for Large Business';
                        caseRec.Exchange_Lines_of_Business__c = 'Medical; Dental; Dearborn';
                        caseRec.Requested_By__c = opp.OwnerId;
                    }

                    // Private Exchange - External
                    if (tm.Task__r.Case_Record_Type__c == 'Private Exchange - External') {
                        System.debug('Record Type = ' + tm.Task__r.Case_Record_Type__c);
                        caseRec.Group_Exchange_Platform__c = 'Aon Hewitt Active Exchange';
                        caseRec.Exchange_Lines_of_Business__c = 'Medical; Dental; Dearborn';
                        caseRec.Requested_By__c = opp.OwnerId;
                    }



                    // UnderWriting
                    if (tm.Task__r.Case_Record_Type__c == 'UnderWriting') {
                        caseRec.Proposal_Due_Date__c = opp.CloseDate;
                        caseRec.Expected_Health_Contracts__c = opp.Expected_Health_Contracts__c;
                        caseRec.Expected_Dental_Contracts__c = opp.Expected_Dental_Contracts__c ;
                        caseRec.Total_Expected_Members__c = opp.Expected_Health_Members__c;

                        for ( OpportunityContactRole oppConRole : opp.OpportunityContactRoles) {
                            if (oppConRole.Role == 'Producer') {
                                if (caseRec.Producer__c == null || caseRec.Producer__c == '')
                                    caseRec.Producer__c = oppConRole.Contact.Name;
                                else
                                    caseRec.Producer__c += ',' + oppConRole.Contact.Name;
                            }
                            if (oppConRole.Role == 'Consultant')
                                caseRec.Consultant__c = oppConRole.Contact.Name;
                        }
                    }


                    /*
                    // Dental Underwriting
                    if(taskMapping.Task__r.Case_Record_Type__c == 'Dental Underwriting')
                    {

                       if(underwritingCaseRecord != null && underwritingCaseRecord.Id != null)
                           caseRec = createDentalUnderwriting(underwritingCaseRecord,caseRec);
                       caseRec.Requested_Effective_Date__c = opp.Requested_Effective_Date__c;
                       caseRec.Proposal_Due_Date__c = opp.CloseDate;
                       caseRec.Expected_Health_Contracts__c = opp.Expected_Health_Contracts__c;
                       caseRec.Expected_Dental_Contracts__c = opp.Expected_Dental_Contracts__c ;
                       caseRec.Total_Expected_Members__c = opp.Expected_Health_Members__c;
                       for( OpportunityContactRole oppConRole : opp.OpportunityContactRoles){
                            if(oppConRole.Role == 'Producer'){
                                if(caseRec.Producer__c == null || caseRec.Producer__c == '')
                                  caseRec.Producer__c = oppConRole.Contact.Name;
                                else
                                  caseRec.Producer__c += ','+ oppConRole.Contact.Name;
                            }
                            if(oppConRole.Role == 'Consultant')
                                caseRec.Consultant__c = oppConRole.Contact.Name;
                       }
                    }

                    */


                    // Cede
                    if (tm.Task__r.Case_Record_Type__c == 'Cede') {
                        caseRec.Ceded_From_ICL__c           = accountRecord.Ceded_From_ICL__c;
                        caseRec.Ceded_To_ACL__c             = accountRecord.Ceded_To_ACL__c;
                        caseRec.Requested_Effective_Date__c       = accountRecord.Effective_Date__c;
                        caseRec.Cede_End_Date__c           = accountRecord.Cede_End_Date__c;
                        caseRec.Funding_Type_Multiselect__c       = accountRecord.Funding_Type__c;
                        //caseRec.Active_Health_Contracts__c       = (accountRecord.Active_Health_Subscribers__c != null ? integer.valueOf(accountRecord.Active_Health_Subscribers__c) : 0 );
                        //caseRec.Active_Health_Members__c       = (accountRecord.Active_Health_Members__c != null ? integer.valueOf(accountRecord.Active_Health_Members__c) : 0 ) ;
                        caseRec.OwnerId                =  cedeTeamQueue;
                        caseRec.Account_Owner__c            = accountRecord.OwnerId;
                        //caseRec.Ceded_Market_Segment__c        = accountRecord.Market_Segment__c;
                        //system.debug('======here====='+caseRec.Active_Health_Contracts__c +'======'+caseRec.Active_Health_Members__c+'========'+caseRec.Account_Owner__c);
                    }


                } catch (Exception e) {
                    System.debug( 'Exception : ' + e.getMessage() );
                    CreateExceptionLog.insertErrorLog(e, null, null, null, 'Apex Class', 'Opportunity', null, 'playbookCaseCreationHandler.Createcaserecord()', 'High');
                }




                // ************************ Case Record creation end *************************

                casesToBeCreated.add(caseRec);
            }

        }


        System.debug('--------- case to be created ------>' + casesToBeCreated);
        if (casesToBeCreated.size() > 0)
            insert casesToBeCreated;






        return null;



    }
}