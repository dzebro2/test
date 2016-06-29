/**************************************************************************************
  Apex Class Name     : Opportunity360ViewController
  Version             : 1.0
  Function            : This is a controller class for Opportunity360 view page
  Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------
  Dinesh           :       March                    Original Version

*************************************************************************************/
public without sharing class Opportunity360ViewController {

    public Id opportunityId {get; set;}
    public Opportunity opportunityObj {
        get
        {
            if (opportunityObj == null) {
                opportunityObj = new Opportunity();
                opportunityObj = [SELECT Id, AccountId, Account.Name, StageName, OwnerId, CloseDate, Probability, Expected_Decision_Date__c, Bull_s_Eye__c FROM Opportunity WHERE Id = :opportunityId];
            }
            return opportunityObj;
        }
        set;
    }
    public Id accountId {get; set;}
    public String abbrvOpportunityId {get; set;}
    public String abbrvAccountId {get; set;}
    public Account accountObj {get; set;}
    public String billingStreet {get; set;}
    public String restBillingAddress {get; set;}
    public String zipCode {get; set;}
    public Decimal totalRevenue {get; set;}
    public Decimal NetIncome {get; set;}
    public Decimal MrktCapital {get; set;}


    public  Integer noOfOpportunityProducts {get; set;}
    public List<Opportunity_Product__c> listOfOpportunityProducts {get; set;}

    public String openActivitiesPrefix {get; set;}
    public Integer NoOfOpenItems {get; set;}
    public Report openActivitiesReportObj {get; set;}
    public Integer NoOfPastDueItems {get; set;}
    public Report pastDueActivitiesReportObj {get; set;}
    public List<OpportunityContactRole> opportunityContactRoleList {get; set;}
    public List<OpportunityTeamMember> opportunityTeamMemberList {get; set;}
    public List<Opportunity_Team_Non_SF__c> opportunityTeamMemberNonSFList {get; set;}
    public list<TeamMemberWrapper> teamMembersList {get; set;}
    public Opportunity360ViewController(ApexPages.standardController stdController) {
        try {
            billingStreet = '';
            restBillingAddress = '';
            totalRevenue = 0;
            noOfOpportunityProducts = 0;

            listOfOpportunityProducts = new List<Opportunity_Product__c>();
            opportunityId = stdController.getId();
            accountId = opportunityObj.AccountId;
            abbrvAccountId = String.valueOf(accountId);
            abbrvAccountId = abbrvAccountId.subString(0, 15);
            teamMembersList = new list<TeamMemberWrapper>();
            NoOfOpenItems = 0;
            NoOfPastDueItems = 0;
            opportunityContactRoleList = new List<OpportunityContactRole>();
            opportunityTeamMemberList = new List<OpportunityTeamMember>();
            opportunityTeamMemberNonSFList = new List<Opportunity_Team_Non_SF__c>();

            abbrvOpportunityId = String.valueOf(opportunityId);
            abbrvOpportunityId = abbrvOpportunityId.subString(0, 15);


            accountObj = [SELECT Id, Market_Capitalization__c, Net_Income__c, Name, ParentId, Market_Segment__c, Number_Of_Open_Opportunities__c, NumberOfEmployees, ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, Website, Industry, HCSC_Revenue__c, AnnualRevenue, HCSC_Division__c, External_ID__c, TickerSymbol, Credit_Rating__c FROM Account WHERE Id = :accountId];

            if (accountObj.AnnualRevenue != null)
                totalRevenue = accountObj.AnnualRevenue;

            if (accountObj.Net_Income__c != null)
                NetIncome = accountObj.Net_Income__c;

            if (accountObj.Market_Capitalization__c != null)
                MrktCapital = accountObj.Market_Capitalization__c;

            if (accountObj.ShippingStreet != null)
                billingStreet = accountObj.ShippingStreet;
            if (accountObj.ShippingCity != null)
                restBillingAddress += ' ' + accountObj.ShippingCity;
            if (accountObj.ShippingState != null)
                restBillingAddress += ',' + accountObj.ShippingState;
            if (accountObj.ShippingPostalCode != null)
                zipCode = ' ' + accountObj.ShippingPostalCode;


            Schema.DescribeSObjectResult r = Task.sObjectType.getDescribe();
            openActivitiesPrefix = r.getKeyPrefix();

            List<Opportunity> listOfOpportunitiesWithOpenActivities = [SELECT (SELECT Id, isClosed, IsTask FROM OpenActivities ORDER BY ActivityDate ASC NULLS LAST, LastModifiedDate DESC LIMIT 500) FROM Opportunity WHERE Id = :opportunityId LIMIT 1];

            AggregateResult[]  numberOfOpenTasks = [    select  count(Id) tasks
                                                   from    Task
                                                   where   isClosed = False
                                                           and WhatId = :opportunityId
                                                                   and IsRecurrence = false
                                                   ];

            NoOfOpenItems = 0;
            for (Opportunity oppObj : listOfOpportunitiesWithOpenActivities) {
                for ( OpenActivity openAct : oppObj.OpenActivities ) {
                    if ( !openAct.isClosed && !openAct.IsTask ) {
                        NoOfOpenItems++;
                    }
                }
            }

            for (AggregateResult aggr : numberOfOpenTasks) {
                NoOfOpenItems += Integer.valueOf(aggr.get('tasks'));
            }

            if (!Test.isRunningTest()) {
                //openActivitiesReportObj = [SELECT Id FROM Report WHERE DeveloperName = 'Open_Activities_By_Opportunity' LIMIT 1];
                //pastDueActivitiesReportObj = [SELECT Id FROM Report WHERE DeveloperName = 'Past_Due_Activities_By_Opportunity' LIMIT 1];

                list<Report> reports = [SELECT Id FROM Report WHERE DeveloperName = :ConstantsController.OpenActivitiesReport];
                if (reports.size() > 0)
                    openActivitiesReportObj = reports[0];
                else
                    openActivitiesReportObj = new Report();

                reports = [SELECT Id FROM Report WHERE DeveloperName = :ConstantsController.PastDueActivitiesReport];
                if (reports.size() > 0)
                    pastDueActivitiesReportObj = reports[0];
                else
                    pastDueActivitiesReportObj = new Report();

            }
            List<AggregateResult> pastDueActivitiesList = [SELECT Count(Id) noOfPastDueItems FROM Task WHERE IsClosed = false AND ActivityDate < : System.today() AND WhatId = :opportunityId];

            if (!pastDueActivitiesList.isEmpty()) {
                for (AggregateResult aggregateResultObj : pastDueActivitiesList) {
                    NoOfPastDueItems = Integer.valueOf(aggregateResultObj.get('noOfPastDueItems'));
                }
            }
            if (NoOfPastDueItems == null)
                NoOfPastDueItems = 0;

            if (!Test.isRunningTest())


                listOfOpportunityProducts = [SELECT Id, Product__c, Product__r.Name, Product__r.Simplified_Product__c, Projected_Members__c, Win_Probability__c FROM Opportunity_Product__c WHERE Opportunity_Name__c = :opportunityId];

            noOfOpportunityProducts = listOfOpportunityProducts.size();
            /* set<String> teamMemberRoles = new set<String>();
             set<String> customSettingRecordTypes = new set<String>();
             for(Team_Member_360Views__c atm : Team_Member_360Views__c.getAll().values()){
                 customSettingRecordTypes = new set<String>();
                 if(atm.Opportunity_Record_Type__c != null)
                     customSettingRecordTypes.addAll(atm.Opportunity_Record_Type__c.split(','));
                 if( atm.Opportunity__c && customSettingRecordTypes.size()>0 && customSettingRecordTypes.contains('New_Sale'))
                     teamMemberRoles.add(atm.Name);
             }
             system.debug('=========='+teamMemberRoles);
             opportunityContactRoleList = [SELECT Contact.Email, Contact.Phone, Contact.Name, Contact.PhotoUrl, Role, OpportunityId FROM OpportunityContactRole WHERE OpportunityId =:opportunityId];

             //opportunityTeamMemberList = [SELECT TeamMemberRole, UserId, User.Name FROM OpportunityTeamMember WHERE OpportunityId=:opportunityId];
             for(OpportunityTeamMember otm : [SELECT TeamMemberRole, UserId, User.Name FROM OpportunityTeamMember WHERE OpportunityId=:opportunityId]){
                 if(teamMemberRoles.contains(otm.TeamMemberRole))
                     opportunityTeamMemberList.add(otm);
             }
             //opportunityTeamMemberNonSFList = [SELECT Member_Role__c, Opportunity_Name__c, Opportunity_Team_Member__c, Opportunity_Team_Member__r.Name FROM Opportunity_Team_Non_SF__c WHERE Opportunity_Name__c =:opportunityId];
             for(Opportunity_Team_Non_SF__c otms : [SELECT Member_Role__c, Opportunity_Name__c, Opportunity_Team_Member__c, Opportunity_Team_Member__r.Name FROM Opportunity_Team_Non_SF__c WHERE Opportunity_Name__c =:opportunityId]){
                 if(teamMemberRoles.contains(otms.Member_Role__c))
                     opportunityTeamMemberNonSFList.add(otms);
             }*/
            list<OpportunityTeamMember> tempList1 = [SELECT TeamMemberRole, UserId, User.Name FROM OpportunityTeamMember WHERE OpportunityId = :opportunityId];
            list<Opportunity_Team_Non_SF__c> tempList2 = [SELECT Member_Role__c, Opportunity_Name__c, Opportunity_Team_Member__c, Opportunity_Team_Member__r.Name FROM Opportunity_Team_Non_SF__c WHERE Opportunity_Name__c = :opportunityId];
            for (Team_Member_360Views__c atm : [select Team_Role_Name__c, Sort_Order__c from Team_Member_360Views__c
                                                where Opportunity_Record_Type__c = 'New_Sale'
                                                        order By Sort_Order__c]) {
                for (OpportunityTeamMember temp : tempList1) {
                    if (atm.Team_Role_Name__c == temp.TeamMemberRole) {
                        opportunityTeamMemberList.add(temp);
                        teamMembersList.add(new TeamMemberWrapper(atm.Team_Role_Name__c, temp.User.Name, temp.UserId));
                    }
                }
                for (Opportunity_Team_Non_SF__c temp : tempList2) {
                    if (atm.Team_Role_Name__c == temp.Member_Role__c) {
                        opportunityTeamMemberNonSFList.add(temp);
                        teamMembersList.add(new TeamMemberWrapper(atm.Team_Role_Name__c, temp.Opportunity_Team_Member__r.Name, temp.Opportunity_Team_Member__c));
                    }
                }
            }
        } catch (Exception e) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage());
            ApexPages.addMessage(myMsg);
            System.debug( 'Exception : ' + e.getMessage() );
        }
    }
    public class TeamMemberWrapper {
        public string teamRoleName {get; set;}
        public string teamMemberName {get; set;}
        public string teamMemberId {get; set;}
        public TeamMemberWrapper(string teamRole, String memberName, String memberId) {
            teamRoleName        = teamRole;
            teamMemberName      = memberName;
            teamMemberId        = memberId;
        }
    }
}