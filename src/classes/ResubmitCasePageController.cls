public with sharing class ResubmitCasePageController {

    public Case thecase {get; set;}
    public String selectedRecordType {get; set;}

    public Opportunity opp;
    public String oppId;
    public String isNetwork;
    public String isPerformance;
    public String isProposal;
    public Boolean closedLostOpp;
    private Map<String, List<OpportunityTeamMember>> oppTeamMembers;
    private Map<String, List<Opportunity_Team_Non_SF__c>> oppTeamMembersNonSF;
    private Id pniOwnerId;
    private ApexPages.StandardController thecon;

    public ResubmitCasePageController(ApexPages.StandardController stdcon) {

        thecon = stdcon;
        oppId = apexpages.currentpage().getparameters().get('oid');
        isNetwork = apexpages.currentpage().getparameters().get('Network');
        isPerformance = apexpages.currentpage().getparameters().get('Performance');
        isProposal = apexpages.currentpage().getparameters().get('Proposal');
        Opportunity curr = [Select Id from Opportunity Where Id = :oppId limit 1];
        thecase = new Case();
        pniOwnerId = populatePNIOwnerId();
        opp = getOpportunityRecord(curr);
        oppTeamMembers = populateOpportunityTeamMembers();
        oppTeamMembersNonSF = populateOpportunityTeamMembersNonSF();

        populateCase();

    }

    private Id populatePNIOwnerId() {
        try {
            List<Group> queues = [  SELECT  Id
                                    FROM    Group
                                    where   Type = 'Queue'
                                                   and DeveloperName = 'Proposal_Delivery_Unit'
                                                           limit   1 ];
            if ( queues.size() > 0 ) {
                return queues[0].Id;
            }
        } catch (Exception e) {
            System.debug( 'Exception : ' + e.getMessage() );
            throw e;

        }
        return null;
    }

    private void populateCase() {


        thecase.AccountId                   = opp.AccountId;
        thecase.Opportunity_Name__c         = opp.Id;
        thecase.Status                      = 'New';
        thecase.Requested_Effective_Date__c = opp.Requested_Effective_Date__c;
        thecase.FSU_Location__c             = opp.FSU_Location__c;
        thecase.Other_FSU_Location__c       = opp.Other_FSU_Location__c;
        thecase.HCSC_Division__c            = opp.HCSC_Division__c;
        thecase.Funding_Type_Multiselect__c = getFundingType();  //opp.Account.Funding_Type__c;
        thecase.Premium_Type__c             = getPremiumType();
        thecase.Number_of_Subscribers__c    = opp.Account.of_BCBS_Enrolled_Subscribers__c;
        thecase.Sales_Executive__c          = opp.OwnerId;

        for (Producer_Association_For_Opportunity__c pao : opp.Producer_Association_For_Opportunity__r) {
            thecase.Consulting_Firm__c = pao.Producer_Consultant__c;
        }

        if (!oppTeamMembers.isEmpty()) {

            if (oppTeamMembers.containsKey('Account Executive')) {
                thecase.Account_Executive__c = oppTeamMembers.get('Account Executive')[0].UserId;
            }
        }

        if (!oppTeamMembersNonSF.isEmpty()) {
            if (oppTeamMembersNonSF.containsKey('Underwriter')) {
                thecase.Underwriter_Lookup__c = oppTeamMembersNonSF.get('Underwriter')[0].Opportunity_Team_Member__r.Name + ' (' + oppTeamMembersNonSF.get('Underwriter')[0].Opportunity_Team_Member__r.Email + ')';
            }
        }

        if ( pniOwnerId != null ) {
            thecase.OwnerId = UserInfo.getUserId() ;
        }



        thecase.Requested_By__c = UserInfo.getUserId();
        //thecase.Group_Status__c = getGroupStatus();  group status should be empty for Proposal, Network Information, Performance guarentee
        thecase.Group_Number_s__c = opp.Account.External_ID__c;
        thecase.Consulting_Firm__c = null;
        System.debug('health ' + opp.Expected_Health_Contracts__c);
        System.debug('dental ' + opp.Expected_Dental_Contracts__c);
        thecase.Expected_Health_Contracts__c = opp.Expected_Health_Contracts__c;
        thecase.Expected_Dental_Contracts__c = opp.Expected_Dental_Contracts__c;

        if (oppTeamMembers.containsKey('Underwriter')) {
            thecase.Underwriter_Lookup__c = oppTeamMembers.get('Underwriter')[0].UserId;
        }
        for (Producer_Association_For_Opportunity__c pao : opp.Producer_Association_For_Opportunity__r) {
            if (pao.Account_Record_Type__c == 'Consultant Account')
                thecase.Consulting_Firm__c = pao.Producer_Consultant__c;
            if (pao.Account_Record_Type__c == 'Producer Account')
                thecase.Producer_Account__c = pao.Producer_Consultant__c;
        }


        thecase.Requested_By__c = opp.OwnerId;

    }

    public String getFundingType() {

        String funding_type;
        try {

            for (Opportunity_Product__c op : [select id , Funding_type__c from Opportunity_Product__c where  Opportunity_Name__c = :oppId and Funding_type__c != null]) {
                System.debug('in for');
                if (funding_type == null) {
                    System.debug(op.Funding_Type__c);
                    funding_type = op.Funding_type__c;
                } else if (!funding_type.contains(op.Funding_type__c)) {
                    funding_type = funding_type + ';' + op.Funding_type__c;
                }
            }

        } catch (Exception e) {

            throw e;
        }

        return funding_type;
    }

    public String getPremiumType() {

        String premiumType  = '';
        try {
            for (Opportunity_Product__c op : [select id , Premium_Type__c from Opportunity_Product__c where  Opportunity_Name__c = :oppId and Premium_Type__c != null]) {
                if (premiumType == '') {
                    premiumType = op.Premium_Type__c;
                } else if (!premiumType.contains(op.Premium_Type__c)) {
                    premiumType = premiumType + ';' + op.Premium_Type__c;
                }
            }
        } catch (Exception e) {
            throw e;
        }
        return premiumType;
    }

    private Map<String, List<OpportunityTeamMember>> populateOpportunityTeamMembers() {

        Map<String, List<OpportunityTeamMember>> oppTeamMembersMap = new Map<String, List<OpportunityTeamMember>>();
        try {
            for ( OpportunityTeamMember otm : [   select  Id, TeamMemberRole, UserId, OpportunityId
                                                  from    OpportunityTeamMember
                                                  where   OpportunityId = :opp.Id
                                                          limit   :Limits.getLimitQueryRows() - Limits.getQueryRows() ] ) {

                if ( !oppTeamMembersMap.containsKey( otm.TeamMemberRole ) ) {
                    oppTeamMembersMap.put( otm.TeamMemberRole, new List<OpportunityTeamMember>() );
                }
                oppTeamMembersMap.get( otm.TeamMemberRole ).add( otm );
            }
        } catch (exception e) {
            System.debug( 'Exception : ' + e.getMessage() );
            throw e;
        }
        return oppTeamMembersMap;
    }

    private Map<String, List<Opportunity_Team_Non_SF__c>> populateOpportunityTeamMembersNonSF() {
        Map<String, List<Opportunity_Team_Non_SF__c>> oppTeamMembersNonSFMap = new Map<String, List<Opportunity_Team_Non_SF__c>>();
        try {
            for (Opportunity_Team_Non_SF__c oppTeamNonSF : [SELECT Id, Member_Role__c, Opportunity_Team_Member__c, Opportunity_Team_Member__r.Name, Opportunity_Team_Member__r.Email FROM Opportunity_Team_Non_SF__c WHERE Opportunity_Name__c = :opp.Id LIMIT :Limits.getLimitQueryRows() - Limits.getQueryRows() ] ) {

                if (!oppTeamMembersNonSFMap.containsKey(oppTeamNonSF.Member_Role__c)) {
                    List<Opportunity_Team_Non_SF__c> tempOppTeamNonSFList = new List<Opportunity_Team_Non_SF__c>();
                    tempOppTeamNonSFList.add(oppTeamNonSF);
                    oppTeamMembersNonSFMap.put(oppTeamNonSF.Member_Role__c, tempOppTeamNonSFList);
                } else {
                    oppTeamMembersNonSFMap.get(oppTeamNonSF.Member_Role__c).add(oppTeamNonSF);
                }
            }
        } catch (Exception e) {
            System.debug( 'Exception : ' + e.getMessage() );
            throw e;
        }
        return oppTeamMembersNonSFMap;
    }

    private Opportunity getOpportunityRecord(Opportunity o) {
        try {
            Opportunity oppRec =  [SELECT  Id, StageName, Playbook__c, Expected_Health_Members__c, createdDate, LastModifiedDate, AccountId, Account.RecordType.DeveloperName, Account.of_BCBS_Enrolled_Subscribers__c,
                                   Name, Requested_Effective_Date__c, Rate_End_Date__c, HCSC_Division__c, closeDate, FSU_Location__c, Other_FSU_Location__c, District__c,
                                   Account.External_ID__c, Account.Funding_Type__c, Account.Group_Anniversary_Date__c, ownerID, createdbyid, Expected_Health_Contracts__c, Expected_Dental_Contracts__c,
                                   (Select Id, OpportunityId, ContactId, Contact.Name , Role, IsPrimary From OpportunityContactRoles),
                                   (Select Opportunity__c, Producer_Consultant__c, Account_Record_Type__c from Producer_Association_For_Opportunity__r)
                                   FROM    Opportunity
                                   WHERE   Id = :o.Id
                                                limit   1];

            if ( oppRec.StageName == 'Lost' || oppRec.StageName == 'Declined' || oppRec.StageName == 'Cancelled' ) {
                closedLostOpp = true;
            }
            return oppRec;
        } catch (Exception e) {
            throw e;
            System.debug('excepted!');
            return new Opportunity();
        }
    }

    // Builds the record type picklist from the ResubmitActionNames__c custom setting
    public List<SelectOption> getItems() {

        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('-None-', '-None-'));
        if(this.isNetwork == '1')
            options.add(new SelectOption('Network Information', 'Network Information'));
        if(this.isPerformance == '1')
            options.add(new SelectOption('Performance Guarantee', 'Performance Guarantee'));
        if(this.isProposal == '1')
            options.add(new SelectOption('Proposal', 'Proposal'));

        return options;

    }
    
    public void setRecordType(){

        if(selectedRecordType != '-None-')
            thecase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get( selectedRecordType ).getRecordTypeId();
    }


    public PageReference save() {

        try {
            thecase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get( selectedRecordType ).getRecordTypeId();
            thecase.Subject = opp.Name + ' ' + selectedRecordType;
            insert thecase;
            return new PageReference('/' + oppId);
        } catch (Exception ex) {
            ApexPages.addMessages(ex);
        }
        return null;
    }

    public PageReference cancel() {

        return new PageReference('/' + oppId);
    }


}