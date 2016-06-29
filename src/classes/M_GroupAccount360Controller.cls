public without sharing class M_GroupAccount360Controller {

    public Id accountId {get; set;}
    public String abbrvAccountId {get; set;}
    public Account accountObj {
        get {
            if (accountObj == null)
            {
                accountObj = new Account(); 
                try{
                accountObj = [  SELECT  Id, Name, Number_Of_Open_Opportunities__c, Total_Value_Of_Open_Opportunity__c, Industry, 
                                        Market_Segment__c, Current_Risk_Level__c, Company_Financial_Health__c, Open_Enrollment_Date__c, Total_Num_of_Potential_Subscribers__c,
                                        Renewal_Date__c, AnnualRevenue, BCBS_Enrolled_Members__c, Total_EES__c, Active_Health_Subscribers__c, Active_Health_Members__c,
                                        TickerSymbol, ShippingStreet, ShippingCity, ShippingCountry, ShippingState, ShippingPostalCode, ParentId, External_ID__c,
                                        NumberOfEmployees, CreatedDate, Website, OwnerId, Group_Total_Eligible_Members__c,of_BCBS_Enrolled_Subscribers__c, HCSC_Revenue__c,HCSC_Division__c, Open_Enrollment_End_Date__c, HCSC_Client_Since__c, Contract_End__c
                                FROM    Account 
                                WHERE   Id = :accountId];
              
            }catch(exception e){ 
                
                System.debug( 'Exception : ' +e.getMessage() );
                 ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage());
            ApexPages.addMessage(myMsg);
           }
            
         }   
         return accountObj ;
        } 
        set;
    }
    public Date nextActivityDate {get; set;}
    public Date lastActivityDate {get; set;}
    public Id strategyPlanId {get; set;}
    public String openActivitiesPrefix {get; set;}
    public Integer NoOfOpenItems {get; set;}
    public Report openActivitiesReportObj {get; set;}
    public Integer NoOfPastDueItems {get; set;}
    public Report pastDueActivitiesReportObj {get; set;}
    public Report openCasesByPriorityReportObj {get; set;}
    public List<AccountContactRole> accountContactRoleList {get; set;}
    public List<AccountTeamMember> accountTeamMemberList {get; set;}
    public List<Account_Team_Non_SF__c> accountTeamMemberNonSFList {get; set;}
    public String colChartData{get;set;}
    public Integer NoOfOpenCases {get; set;}
    public String billingStreet {get; set;}
    public String restBillingAddress {get; set;}
    public string pinCode{get;set;}
    public Id lgnaCaseRecordTypeId;
    
    public Id LastrenewalOppId  {get; set;}
    public Decimal penetration {get; set;}
    public Map<String, Integer> caseCountByPriority{get;set;}
    public M_GroupAccount360Controller(ApexPages.standardController stdController) {
        try{
            accountId = ApexPages.currentPage().getParameters().get('id');
            abbrvAccountId = String.valueOf(accountId);
            abbrvAccountId = abbrvAccountId.subString(0,15);
            NoOfOpenCases = 0;
            accountContactRoleList = new List<AccountContactRole>();
            accountTeamMemberList = new List<AccountTeamMember>();
            accountTeamMemberNonSFList = new List<Account_Team_Non_SF__c>();
            billingStreet = '';
            restBillingAddress = '';
            if (accountObj.Total_Num_of_Potential_Subscribers__c > 0){
                penetration = Integer.ValueOf(accountObj.Active_Health_Subscribers__c)/Integer.ValueOf(accountObj.Total_Num_of_Potential_Subscribers__c)*100;
                system.debug('### penetration ' + penetration );
            }
            //lgnaCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('LGNA - General Case').getRecordTypeId();
            for(RecordType rt : [select Id from RecordType where SobjectType = 'Case' and DeveloperName = :ConstantsController.LGNAGeneralCaseRecordTypeName]){
                lgnaCaseRecordTypeId = rt.Id;
            }
            if(accountObj.ShippingStreet !=null)
                billingStreet = accountObj.ShippingStreet;
            if(accountObj.ShippingCity !=null)
                restBillingAddress += ' '+accountObj.ShippingCity;
            if(accountObj.ShippingState !=null)
                restBillingAddress += ','+accountObj.ShippingState;
            if(accountObj.ShippingPostalCode !=null)
                pinCode = accountObj.ShippingPostalCode;
                
            for(Account accountObj : [SELECT Id, (SELECT Id, ActivityDate, Subject FROM OpenActivities where isClosed = False ORDER BY ActivityDate ASC NULLS LAST, LastModifiedDate DESC LIMIT 500) FROM Account WHERE Id =:accountId limit 1]){
                if(!accountObj.OpenActivities.isEmpty()){
                    nextActivityDate = accountObj.OpenActivities[0].ActivityDate;
                }
            }
            
            for(Account accountObj : [SELECT Id, (SELECT Id, Subject, ActivityDate FROM ActivityHistories ORDER BY ActivityDate DESC limit 100) FROM Account WHERE Id =:accountId limit 1]){
                if(!accountObj.ActivityHistories.isEmpty()){
                    lastActivityDate = accountObj.ActivityHistories[0].ActivityDate;
                }
            }
            caseCountByPriority = new Map<String, Integer>();
            colChartData='';
            Schema.DescribeFieldResult fieldResult  = Case.Priority.getDescribe();
            List<Schema.PicklistEntry> ple          = fieldResult.getPicklistValues();
                
            for( Schema.PicklistEntry f : ple)
            {
                caseCountByPriority.put(f.getLabel(), 0);
            }       
            
            AggregateResult[] groupedResults = [select Priority, count(Id) from Case Where IsClosed = false AND AccountId =:accountId AND RecordTypeId =:lgnaCaseRecordTypeId GROUP BY Priority ];
            for (AggregateResult ar : groupedResults)  {
                if(ar.get( 'Priority' ) != null && ar.get( 'expr0' ) != null){
                    caseCountByPriority.put( String.valueOf( ar.get( 'Priority' ) ), Integer.valueOf(ar.get( 'expr0' )));
                    NoOfOpenCases+= Integer.valueOf(ar.get( 'expr0' ));
                }
            }
            map<Integer, String> orderAndPriority = new Map<Integer, String>();
            orderAndPriority.put(1,'Low');
            orderAndPriority.put(2,'Medium');
            orderAndPriority.put(3,'High');
            orderAndPriority.put(4,'Critical');
            for(String casePriority :orderAndPriority.values()) {
                if(caseCountByPriority.containsKey(casePriority)){
                    if(casePriority == 'Low')
                        colChartData += '["'+ casePriority +'",'+ caseCountByPriority.get(casePriority) +',\'color:black\'],';
                    if(casePriority == 'Medium')
                        colChartData += '["'+ casePriority +'",'+ caseCountByPriority.get(casePriority) +',\'color:black\'],';
                    if(casePriority == 'High')
                        colChartData += '["'+ casePriority +'",'+ caseCountByPriority.get(casePriority) +',\'color:orange\'],';
                    if(casePriority == 'Critical')
                        colChartData += '["'+ casePriority +'",'+ caseCountByPriority.get(casePriority) +',\'color:#8B0000\'],';
                }
                
            }
            //colChartData =  JSON.serializePretty(createChartData(orderAndPriority,caseCountByPriority));
            colChartData = colChartData.removeEnd(',');
            
            if(!Test.isRunningTest())
                openCasesByPriorityReportObj = [SELECT Id FROM Report WHERE DeveloperName = :ConstantsController.Open_Cases_By_Priority LIMIT 1];
            
            Schema.DescribeSObjectResult r = Task.sObjectType.getDescribe();
            openActivitiesPrefix = r.getKeyPrefix();
            
            
            List<Strategic_Plan__c> strategicPlanList = [SELECT Id FROM Strategic_Plan__c WHERE Account_Name__c =:accountId and Active__c=true ORDER BY LastModifiedDate DESC LIMIT 1];
            
            List<opportunity> opp = [select id,IsWon from opportunity where  accountid = :accountId and recordtype.DeveloperName='Renewal' and IsWon=true  order by Lastmodifieddate limit 1];
            
            if(opp !=null && opp.size()>0){
                LastrenewalOppId = opp[0].id;
            }
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
            if(!Test.isRunningTest())
                openActivitiesReportObj = [SELECT Id FROM Report WHERE DeveloperName = :ConstantsController.Open_Activities_By_Account LIMIT 1];
            
            List<AggregateResult> pastDueActivitiesList = [SELECT Count(Id) noOfPastDueItems FROM Task WHERE IsClosed = false AND ActivityDate <: System.today() AND WhatId =:accountId];
            
            if(!pastDueActivitiesList.isEmpty()){
                for(AggregateResult aggregateResultObj : pastDueActivitiesList){
                    
                    NoOfPastDueItems = Integer.valueOf(aggregateResultObj.get('noOfPastDueItems'));
                }
            }
            if(NoOfPastDueItems == null)
                NoOfPastDueItems = 0;
                
            if(!Test.isRunningTest())
                pastDueActivitiesReportObj = [SELECT Id FROM Report WHERE DeveloperName = 'Past_Due_Activities_By_Account' LIMIT 1];
            
            accountContactRoleList = [SELECT Contact.Email, Contact.Phone, Contact.Name, Role, Contact.PhotoUrl, AccountId FROM AccountContactRole WHERE AccountId =:accountId];
            
            accountTeamMemberList = [SELECT TeamMemberRole, UserId, User.Name FROM AccountTeamMember WHERE AccountId=:accountId];
            accountTeamMemberNonSFList = [SELECT Member_Role__c, Account_Name__c, Team_Member_Name__c, Team_Member_Name__r.Name FROM Account_Team_Non_SF__c WHERE Account_Name__c =:accountId];
        }catch(Exception e){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage());
            ApexPages.addMessage(myMsg);
            System.debug( 'Exception : ' +e.getMessage() ); 
        }
    }
    public List<PieWedgeData> getPieData() {
        List<PieWedgeData> data = new List<PieWedgeData>();
        data.add(new PieWedgeData('Med Only ', 25,''));
        data.add(new PieWedgeData('Dearborn & Competitor', 3,''));
        data.add(new PieWedgeData('Uninsured', 5,''));
        data.add(new PieWedgeData('Competitor', 42,''));
        data.add(new PieWedgeData('MED & Dearborn', 25,''));
        return data;
    }
  /*  private list<ParentChartWrapper> createChartData(map<Integer,String> orderNumber,Map<String, Integer> caseCountByPriority){
        list<ParentChartWrapper> pcw = new list<ParentChartWrapper>();
        ParentChartWrapper temp = new ParentChartWrapper();
        temp.cols = new list<ChartColWrapper>();
        temp.rows = new list<InterMediaryClass>();
        temp.cols.add(new ChartColWrapper('casePriority','casePriority','string'));
        temp.cols.add(new ChartColWrapper('cases','cases','Integer'));
        list<InterMediaryClass> tempClist = new list<InterMediaryClass>();
        for(String casePriority :orderAndPriority.values()){
            InterMediaryClass tempObj = new InterMediaryClass();
            tempObj.c = new list<ChartColWrapper>();
            if(caseCountByPriority.containsKey(casePriority)){
                if(casePriority == 'Low'){
                     tempObj.c.add(new ChartRowWrapper('Low')) ;
                     tempObj.c.add(new ChartRowWrapper(caseCountByPriority.get(casePriority),'color:black')) ;
                }
                if(casePriority == 'Medium'){
                      tempObj.c.add(new ChartRowWrapper('Medium')) ;
                      tempObj.c.add(new ChartRowWrapper(caseCountByPriority.get(casePriority),'color:black')) ;
                }
                if(casePriority == 'High'){
                      tempObj.c.add(new ChartRowWrapper('High')) ;
                      tempObj.c.add(new ChartRowWrapper(caseCountByPriority.get(casePriority),'color:orange')) ;
                }
                if(casePriority == 'Critical'){
                     tempObj.c.add(new ChartRowWrapper('Critical')) ;
                     tempObj.c.add(new ChartRowWrapper(caseCountByPriority.get(casePriority),'color:#8B0000')) ;
                }
            }
            tempClist.add(tempObj);
        }
        temp.rows = tempClist;
        pcw.add(temp);
        return pcw;
    }
    public class ParentChartWrapper{
        public list<ChartColWrapper> cols{get;set;}
        public list<InterMediaryClass> rows{get;set;}
        public ParentChartWrapper(){
            
        }
    }
    public class InterMediaryClass{
        public list<ChartColWrapper> c{get;set;}
        public InterMediaryClass(){
            
        }
    }
    public Class ChartColWrapper{
        public string id{get;set;}
        public string label{get;set;}
        public string type{get;set;}
        public string role{get;set;}
        public ChartColWrapper(String uid,String l , String t){
            id = uid;
            label = l;
            type = t;
        }
        
    }
    public class ChartRowWrapper{
        public Object v{get;set;}
        public string p{get;set;}
        public ChartRowWrapper(Integer p,String st){
            v = p;
            p = st;
        }
        public ChartRowWrapper(String vname){
            v = vname;
        }
    }*/
     public class PieWedgeData {

        public String name {get; set;}
        public Integer data {get; set;}
        public String dummy {get; set;}
        
        public PieWedgeData(String name, Integer data, String dummy) {
            this.name = name;
            this.data = data;
            this.dummy=dummy;
        }
    }
}