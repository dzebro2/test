/**************************************************************************************
  Apex Class Name     : RenewalOpportunity360ViewController
  Version             : 1.0
  Function            : This is a controller  class for the RenewalOpportunity360 page
  Modification Log    :

*************************************************************************************/
public without sharing class RenewalOpportunity360ViewController {
    
    public Id opportunityId {get; set;}
    public Opportunity opportunityObj {
        get {
            if (opportunityObj == null)
            {
                opportunityObj = new Opportunity();
                opportunityObj = [SELECT Id, IsWon, AccountId, OwnerId, Type,StageName, CloseDate, Expected_Decision_Date__c, ExpectedRevenue, Account.Name FROM Opportunity WHERE Id = :opportunityId];
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
   
    public Id strategyPlanId {get; set;}
    public Id lastRenewalId {get; set;}
    public String openActivitiesPrefix {get; set;}
    public Integer NoOfOpenItems {get; set;}
    public Report openActivitiesReportObj {get; set;}
    public Integer NoOfPastDueItems {get; set;}
    public Report pastDueActivitiesReportObj {get; set;}
    
    public Integer productsIncluded {get; set;}
    public Integer projectedRevenue {get; set;}
    public List<Opportunity_Product__c> listOfOpportunityProducts {get; set;}
    public List<OpportunityContactRole> opportunityContactRoleList {get; set;}
    public List<OpportunityTeamMember> opportunityTeamMemberList {get; set;}
    public List<Opportunity_Team_Non_SF__c> opportunityTeamMemberNonSFList {get; set;}
    public list<TeamMemberWrapper> teamMembersList{get;set;}
    public RenewalOpportunity360ViewController(ApexPages.standardController stdController) {
        try{
            billingStreet = '';
            restBillingAddress = '';
            productsIncluded = 0;
            projectedRevenue = 0;
            
            opportunityId = ApexPages.currentPage().getParameters().get('id');
            
            accountId = opportunityObj.AccountId;
            abbrvAccountId = String.valueOf(accountId);
            abbrvAccountId = abbrvAccountId.subString(0,15);
            
            abbrvOpportunityId = String.valueOf(opportunityId);
            abbrvOpportunityId = abbrvOpportunityId.subString(0,15);
            
            NoOfOpenItems = 0;
            NoOfPastDueItems = 0;
            
            listOfOpportunityProducts = new List<Opportunity_Product__c>();
            opportunityContactRoleList = new List<OpportunityContactRole>();
            opportunityTeamMemberList = new List<OpportunityTeamMember>();
            opportunityTeamMemberNonSFList = new List<Opportunity_Team_Non_SF__c>();
            teamMembersList = new list<TeamMemberWrapper>();
            Schema.DescribeSObjectResult r = Task.sObjectType.getDescribe();
            openActivitiesPrefix = r.getKeyPrefix();
            
            accountObj = [SELECT Id, Name, ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, Website, ParentId, Industry, External_ID__c, Market_Segment__c, NumberOfEmployees, Effective_Date__c, Open_Enrollment_Date__c, CreatedDate, TickerSymbol, HCSC_Client_Since__c, Contract_End__c, Open_Enrollment_End_Date__c FROM Account WHERE Id=:accountId];
            
            if(accountObj.ShippingStreet !=null)
                billingStreet = accountObj.ShippingStreet;
            if(accountObj.ShippingCity !=null)
                restBillingAddress += ' '+accountObj.ShippingCity;
            if(accountObj.ShippingState !=null)
                restBillingAddress += ','+accountObj.ShippingState;
            if(accountObj.ShippingPostalCode !=null)
                restBillingAddress += ' '+accountObj.ShippingPostalCode;
            
            
            List<Strategic_Plan__c> strategicPlanList = [SELECT Id FROM Strategic_Plan__c WHERE Account_Name__c =:accountId and Active__c=true ORDER BY LastModifiedDate DESC LIMIT 1];
            
            if(!strategicPlanList.isEmpty()){
                strategyPlanId = strategicPlanList[0].Id;
            }
            
            Id renewalRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal').getRecordTypeId();
            
            List<Opportunity> lastRenewalOpportunityList = [SELECT Id FROM Opportunity WHERE AccountId =:accountId AND Id !=: opportunityId AND RecordTypeId =:renewalRecordTypeId ORDER By CreatedDate DESC LIMIT 1];
            
            if(!lastRenewalOpportunityList.isEmpty()){
                lastRenewalId = lastRenewalOpportunityList[0].Id;
            }
            
            
            List<Opportunity> listOfOpportunitiesWithOpenActivities = [SELECT (SELECT Id, isClosed, IsTask FROM OpenActivities ORDER BY ActivityDate ASC NULLS LAST, LastModifiedDate DESC LIMIT 500) FROM Opportunity WHERE Id=:opportunityId LIMIT 1];
            
            AggregateResult[]  numberOfOpenTasks = [    select  count(Id) tasks
                                                        from    Task
                                                        where   isClosed = False
                                                            and WhatId =:opportunityId
                                                            and IsRecurrence = false
                                                        ];
            
            NoOfOpenItems = 0;
            for(Opportunity oppObj : listOfOpportunitiesWithOpenActivities){
                for( OpenActivity openAct :oppObj.OpenActivities ) {
                    if( !openAct.isClosed && !openAct.IsTask ) {
                        NoOfOpenItems++;
                    }
                }
            }
            
            for(AggregateResult aggr :numberOfOpenTasks) {
                NoOfOpenItems += Integer.valueOf(aggr.get('tasks'));
            }
            
            if(!Test.isRunningTest()){
                list<Report> reports = [select Id from Report where DeveloperName =:ConstantsController.OpenActivitiesReport];
                if(reports.size()>0)
                    openActivitiesReportObj = reports[0];
                else
                    openActivitiesReportObj = new Report();
                reports = [select Id from Report where DeveloperName = :ConstantsController.PastDueActivitiesReport];
                if(reports.size()>0)
                    pastDueActivitiesReportObj = reports[0];
                else
                    pastDueActivitiesReportObj = new Report();
            }
            
            List<AggregateResult> pastDueActivitiesList = [SELECT Count(Id) noOfPastDueItems FROM Task WHERE IsClosed = false AND ActivityDate <: System.today() AND WhatId =:opportunityId];
            
            if(!pastDueActivitiesList.isEmpty()){
                for(AggregateResult aggregateResultObj : pastDueActivitiesList){
                    NoOfPastDueItems = Integer.valueOf(aggregateResultObj.get('noOfPastDueItems'));
                }
            }
            if(NoOfPastDueItems == null)
                NoOfPastDueItems = 0;
            
            
            
            List<AggregateResult> productsList = [SELECT Count(Id) noOfProducts FROM Opportunity_Product__c WHERE Opportunity_Name__c =:opportunityId AND Product__c !=null];
            
            if(!productsList.isEmpty()){
                for(AggregateResult aggregateResultObj : productsList){
                    productsIncluded = Integer.valueOf(aggregateResultObj.get('noOfProducts'));
                }
            }
            if(productsIncluded == null)
                productsIncluded = 0;
                
            listOfOpportunityProducts = [SELECT Id, Product__c, Product__r.Name, Product__r.Simplified_Product__c, Projected_Members__c, Win_Probability__c FROM Opportunity_Product__c WHERE Opportunity_Name__c =:opportunityId];
            
            opportunityContactRoleList = [SELECT Contact.Email, Contact.Phone, Contact.Name, Contact.PhotoUrl, Role, OpportunityId FROM OpportunityContactRole WHERE OpportunityId =:opportunityId];
            
            /*set<String> teamMemberRoles = new set<String>();
            set<String> customSettingRecordTypes = new set<String>();
            for(Team_Member_360Views__c atm : Team_Member_360Views__c.getAll().values()){
                customSettingRecordTypes = new set<String>();
                if(atm.Opportunity_Record_Type__c != null)
                    customSettingRecordTypes.addAll(atm.Opportunity_Record_Type__c.split(','));
                if( atm.Opportunity__c && customSettingRecordTypes.size()>0 && customSettingRecordTypes.contains('Renewal'))
                    teamMemberRoles.add(atm.Name);
            }
           
            
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
            list<OpportunityTeamMember> tempList1 = [SELECT TeamMemberRole, UserId, User.Name FROM OpportunityTeamMember WHERE OpportunityId=:opportunityId];
            list<Opportunity_Team_Non_SF__c> tempList2 = [SELECT Member_Role__c, Opportunity_Name__c, Opportunity_Team_Member__c, Opportunity_Team_Member__r.Name FROM Opportunity_Team_Non_SF__c WHERE Opportunity_Name__c =:opportunityId];
            for(Team_Member_360Views__c atm : [select Team_Role_Name__c,Sort_Order__c from Team_Member_360Views__c 
                                                where Opportunity_Record_Type__c = 'Renewal' 
                                                order By Sort_Order__c]){
                for(OpportunityTeamMember temp : tempList1){
                    if(atm.Team_Role_Name__c == temp.TeamMemberRole){
                        opportunityTeamMemberList.add(temp);
                        teamMembersList.add(new TeamMemberWrapper(atm.Team_Role_Name__c,temp.User.Name,temp.UserId));
                    }
                }
                for(Opportunity_Team_Non_SF__c temp : tempList2){
                    if(atm.Team_Role_Name__c == temp.Member_Role__c){
                        opportunityTeamMemberNonSFList.add(temp);
                        teamMembersList.add(new TeamMemberWrapper(atm.Team_Role_Name__c,temp.Opportunity_Team_Member__r.Name,temp.Opportunity_Team_Member__c));
                    }
                }
            }
        }catch(Exception e){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage());
            ApexPages.addMessage(myMsg);
            System.debug( 'Exception : ' +e.getMessage() );
        } 
    }
    public class TeamMemberWrapper{
        public string teamRoleName{get;set;}
        public string teamMemberName{get;set;}
        public string teamMemberId{get;set;}
        public TeamMemberWrapper(string teamRole,String memberName,String memberId){
            teamRoleName        = teamRole;
            teamMemberName      = memberName;
            teamMemberId        = memberId;
        }
    }
}