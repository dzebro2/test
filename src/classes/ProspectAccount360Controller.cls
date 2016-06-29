/**************************************************************************************
  Apex Class Name     : ProspectAccount360Controller
  Version             : 1.0
  Function            : This is a controller  class for the ProspectAccount360 page
  Modification Log    :

*************************************************************************************/
public with sharing class ProspectAccount360Controller 
{

    
    public Id accountId {get; set;}
    public String abbrvAccountId {get; set;}
    public Account accountObj 
    {
        get 
        {
            if (accountObj == null)
            {
                accountObj = new Account();
                accountObj = [  SELECT  Id, Name, Number_Of_Open_Opportunities__c, Total_Value_Of_Open_Opportunity__c, Industry, HCSC_Division__c, Status__c,
                                        Market_Segment__c, Current_Risk_Level__c, Company_Financial_Health__c, Open_Enrollment_Date__c, 
                                        Renewal_Date__c, AnnualRevenue, Market_Capitalization__c, Net_Income__c, BCBS_Enrolled_Members__c, Group_Total_Eligible_Members__c, Total_EES__c,
                                        TickerSymbol, ShippingStreet, ShippingCity, ShippingCountry, ShippingState, ShippingPostalCode, ParentId, External_ID__c,
                                        NumberOfEmployees, CreatedDate, Website, OwnerId, Projected_Health_Members__c, Projected_Health_Contracts__c, credit_rating__c 
                                FROM    Account 
                                WHERE   Id = :accountId];
                
            }
            return accountObj;  
        } 
        set;
    }
    public Id strategyPlanId {get; set;}
    public List<Opportunity> listOfOpenOpportunities {get; set;}
    public String openActivitiesPrefix {get; set;}
    public Integer NoOfOpenItems {get; set;}
    public Report openActivitiesReportObj {get; set;}
    public Integer NoOfPastDueItems {get; set;}
    public Report pastDueActivitiesReportObj {get; set;}
    public List<AccountContactRole> accountContactRoleList {get; set;}
    public List<AccountTeamMember> accountTeamMemberList {get; set;}
    public List<Account_Team_Non_SF__c> accountTeamMemberNonSFList {get; set;}
    public String billingStreet {get; set;}
    public String restBillingAddress {get; set;}
    public String zipCode{get;set;}
    public list<TeamMemberWrapper> teamMembersList{get;set;}
    public ProspectAccount360Controller(ApexPages.standardController stdController) 
    {
        try
        {
            accountId = ApexPages.currentPage().getParameters().get('id');
            abbrvAccountId = String.valueOf(accountId);
            abbrvAccountId = abbrvAccountId.subString(0,15);
            NoOfOpenItems = 0;
            NoOfPastDueItems = 0;
            accountContactRoleList = new List<AccountContactRole>();
            accountTeamMemberList = new List<AccountTeamMember>();
            accountTeamMemberNonSFList = new List<Account_Team_Non_SF__c>();
            billingStreet = '';
            restBillingAddress = '';
            teamMembersList = new list<TeamMemberWrapper>();
            if(accountObj.ShippingStreet !=null)
                billingStreet = accountObj.ShippingStreet;
            if(accountObj.ShippingCity !=null)
                restBillingAddress += ' '+accountObj.ShippingCity;
            if(accountObj.ShippingState !=null)
                restBillingAddress += ','+accountObj.ShippingState;
            if(accountObj.ShippingPostalCode !=null)
                zipCode = ' '+accountObj.ShippingPostalCode;
                
            listOfOpenOpportunities = [SELECT Id, Name, CloseDate FROM Opportunity WHERE AccountId =:accountId AND Isclosed=false order by CloseDate ASC];
            
            Schema.DescribeSObjectResult r = Task.sObjectType.getDescribe();
            openActivitiesPrefix = r.getKeyPrefix();
            
            
            
            List<Strategic_Plan__c> strategicPlanList = [SELECT Id FROM Strategic_Plan__c WHERE Account_Name__c =:accountId and Active__c=true ORDER BY LastModifiedDate DESC LIMIT 1];
            
            if(!strategicPlanList.isEmpty()){
                strategyPlanId = strategicPlanList[0].Id;
            }
            
            List<Account> listOfAccountsWithOpenEvents = [SELECT (SELECT Id, isClosed, IsTask FROM OpenActivities ORDER BY ActivityDate ASC NULLS LAST, LastModifiedDate DESC LIMIT 500) FROM Account WHERE Id=:accountId LIMIT 1];
            AggregateResult[]  numberOfOpenTasks = [    select  count(Id) tasks
                                                        from    Task
                                                        where   isClosed = False
                                                            and accountId=:accountId
                                                            and IsRecurrence = false
                                                        ];
            
            NoOfOpenItems = 0;
            for(Account accountObj : listOfAccountsWithOpenEvents){
                for( OpenActivity openAct :accountObj.OpenActivities ) {
                    if( !openAct.isClosed && !openAct.IsTask ) {
                        NoOfOpenItems++;
                    }
                }
            }
            
            for(AggregateResult aggr :numberOfOpenTasks) {
                NoOfOpenItems += Integer.valueOf(aggr.get('tasks'));
            }
            
            if(!Test.isRunningTest()){
                list<Report> reports = [select Id from Report where DeveloperName = 'Open_Activities_By_Account'];
                if(reports.size()>0)
                    openActivitiesReportObj = reports[0];
                else
                    openActivitiesReportObj = new Report();
                reports = [select Id from Report where DeveloperName = 'Past_Due_Activities_By_Account'];
                if(reports.size()>0)
                    pastDueActivitiesReportObj = reports[0];
                else
                    pastDueActivitiesReportObj = new Report();
            }
            List<AggregateResult> pastDueActivitiesList = [SELECT Count(Id) noOfPastDueItems FROM Task WHERE IsClosed = false AND ActivityDate <: System.today() AND AccountId =:accountId];
            
            if(!pastDueActivitiesList.isEmpty()){
                for(AggregateResult aggregateResultObj : pastDueActivitiesList){
                    NoOfPastDueItems = Integer.valueOf(aggregateResultObj.get('noOfPastDueItems'));
                }
            }
            if(NoOfPastDueItems == null)
                NoOfPastDueItems = 0;
            
            
            accountContactRoleList = [SELECT Contact.Email, Contact.Phone, Contact.Name, Role, Contact.PhotoUrl, AccountId FROM AccountContactRole WHERE AccountId =:accountId];
           /* set<String> teamMemberRoles = new set<String>();
            set<String> customSettingRecordTypes = new set<String>();
            for(Team_Member_360Views__c atm : Team_Member_360Views__c.getAll().values()){
            	customSettingRecordTypes = new set<String>();
            	if(atm.Account_Record_Types__c != null)
            		customSettingRecordTypes.addAll(atm.Account_Record_Types__c.split(','));
            	if(atm.Account__c && customSettingRecordTypes.size()>0 && (customSettingRecordTypes.contains('Group_Prospect_Account')))
            		teamMemberRoles.add(atm.Name);
            }*/
            list<AccountTeamMember> tempList1 = [SELECT TeamMemberRole, UserId, User.Name FROM AccountTeamMember WHERE AccountId=:accountId ];
            list<Account_Team_Non_SF__c> tempList2 = [SELECT Member_Role__c, Account_Name__c, Team_Member_Name__c, Team_Member_Name__r.Name FROM Account_Team_Non_SF__c WHERE Account_Name__c =:accountId];
            for(Team_Member_360Views__c atm : [select Team_Role_Name__c,Sort_Order__c from Team_Member_360Views__c 
            									where Account_Record_Types__c = 'Group_Prospect_Account' 
            									order By Sort_Order__c]){
            	for(AccountTeamMember temp : tempList1){
            		if(atm.Team_Role_Name__c == temp.TeamMemberRole){
            			accountTeamMemberList.add(temp);
            			teamMembersList.add(new TeamMemberWrapper(atm.Team_Role_Name__c,temp.User.Name,temp.UserId));
            		}
            	}
            	for(Account_Team_Non_SF__c temp : tempList2){
            		if(atm.Team_Role_Name__c == temp.Member_Role__c){
            			accountTeamMemberNonSFList.add(temp);
            			teamMembersList.add(new TeamMemberWrapper(atm.Team_Role_Name__c,temp.Team_Member_Name__r.Name,temp.Team_Member_Name__c));
            		}
            	}
            }
            
            //accountTeamMemberList = [SELECT TeamMemberRole, UserId, User.Name FROM AccountTeamMember WHERE AccountId=:accountId];
           /* for(AccountTeamMember atm : [SELECT TeamMemberRole, UserId, User.Name FROM AccountTeamMember WHERE AccountId=:accountId]){
            	if(teamMemberRoles.contains(atm.TeamMemberRole))
            		accountTeamMemberList.add(atm);
            }
            //accountTeamMemberNonSFList = [SELECT Member_Role__c, Account_Name__c, Team_Member_Name__c, Team_Member_Name__r.Name FROM Account_Team_Non_SF__c WHERE Account_Name__c =:accountId];
        	for(Account_Team_Non_SF__c atm : [SELECT Member_Role__c, Account_Name__c, Team_Member_Name__c, Team_Member_Name__r.Name FROM Account_Team_Non_SF__c WHERE Account_Name__c =:accountId]){
            	if(teamMemberRoles.contains(atm.Member_Role__c))
            		accountTeamMemberNonSFList.add(atm);
            }*/
        }catch(Exception e){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage());
            ApexPages.addMessage(myMsg);
        }
    }
    public class TeamMemberWrapper{
		public string teamRoleName{get;set;}
		public string teamMemberName{get;set;}
		public string teamMemberId{get;set;}
		public TeamMemberWrapper(string teamRole,String memberName,String memberId){
			teamRoleName 		= teamRole;
			teamMemberName		= memberName;
			teamMemberId		= memberId;
		}
	}

}