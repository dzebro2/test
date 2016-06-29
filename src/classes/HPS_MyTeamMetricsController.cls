/**************************************************************************************
  Apex Class Name     : HPS_MyTeamMetricsController
  Version             : 1.0
  Function            : This is a controller class for HPS_MyTeamMetrics Page for showing the information of current logged in user teams metrics.
  Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
**/
public with sharing class HPS_MyTeamMetricsController 
{
    public decimal medicalRecordsCount{get;set;}
    public decimal DentalRecordsCount{get;set;}
    public String persistency{get;set;}
    public String retention{get;set;}
    public string renewalWinRate{get;set;}
    //public set<ID> userIds;
     private static integer userLevel = 0;
    public HPS_MyTeamMetricsController()
    {
        /*userIds = new Set<Id>();
        
        for(    User userObj :[ SELECT  Id 
                                FROM    User 
                                WHERE   ManagerId =:UserInfo.getUserId()
                                limit   :Limits.getLimitQueryRows() - Limits.getQueryRows() ] ) 
        {
            userIds.add( userObj.Id );
        }
        
        userIds.addAll(ConstantsController.getAllSubordinateUsers(userIds));
        userIds.add(UserInfo.getUserId());*/
        CreateData();
        
    }
    /*public static Set<ID> getRoleSubordinateUsers() {
        try{
            // get requested user's role
            Id roleId = [select UserRoleId from User where Id = :userInfo.getUserId()].UserRoleId;
            // get all of the roles underneath the user
            Set<Id> allSubRoleIds = getAllSubRoleIds(new Set<ID>{roleId});
            system.debug('==subroles=='+allSubRoleIds);
            // get all of the ids for the users in those roles
            Map<Id,User> users = new Map<Id, User>([Select Id, Name From User where 
              UserRoleId IN :allSubRoleIds]);
            // return the ids as a set so you can do what you want with them
            return users.keySet();
        }catch(Exception e){
            System.debug( 'Exception : ' +e.getMessage() );
            throw e;
        }
    }
  
    private static Set<ID> getAllSubRoleIds(Set<ID> roleIds) {
        try{
            ++userLevel;
            Set<ID> currentRoleIds = new Set<ID>();
        
            // get all of the roles underneath the passed roles
            for(UserRole userRole :[select Id from UserRole where ParentRoleId 
              IN :roleIds AND ParentRoleID != null])
            currentRoleIds.add(userRole.Id);
            system.debug('level==='+ userLevel);
            // go fetch some more rolls!
            if(currentRoleIds.size() > 0 && userLevel <=1)
              currentRoleIds.addAll(getAllSubRoleIds(currentRoleIds));
        
            return currentRoleIds;
        }catch(Exception e){
            System.debug( 'Exception : ' +e.getMessage() );
            throw e;
        }
     }*/
     private void CreateData()
     {
       try
       {
        list<Account> activeAccounts = [	select 	id,Active_Health_Members__c,Account_Persistency__c,Active_Dental_Members__c,X1_31_Account_Status__c,X1_31_Membership__c 
        									from 	Account 
        									Where 	( 	OwnerId = :UserInfo.getUserId() OR Direct_Indirect_Manager_of_Owner__c = true )//OwnerId In: userIds 
        										and Status__c = 'Active'];
        medicalRecordsCount=DentalRecordsCount= 0;
        decimal throughOutActiveAccountsMembersCount = 0;
        decimal activeAccountOn31Members = 0;
        decimal activeAccountTodayandOn31 = 0;
        list<Account> prevActiveAccounts = [	select 	Id,X1_31_Membership__c,Account_Persistency__c 
        										from 	Account 
        										where 	(	X1_31_Account_Status__c = 'Active' 
        													Or X1_31_Account_Status__c = 'active') 
    													and ( 	OwnerId = :UserInfo.getUserId() OR Direct_Indirect_Manager_of_Owner__c = true )//OwnerId In: userIds 
    										];
        
        for(Account acc : activeAccounts)
        {
             if(acc.Active_Health_Members__c != null )
                medicalRecordsCount += acc.Active_Health_Members__c;
             if(acc.Active_Dental_Members__c != null )
                DentalRecordsCount += acc.Active_Dental_Members__c;
             if((acc.X1_31_Account_Status__c == 'Active' || acc.X1_31_Account_Status__c == 'active') &&  acc.Account_Persistency__c != null)
             {
                throughOutActiveAccountsMembersCount += acc.Account_Persistency__c;
                
                ++activeAccountTodayandOn31; 
             }
        }
        
        for(Account acc : prevActiveAccounts)
        {
            if(acc.X1_31_Membership__c != null )
                activeAccountOn31Members +=     acc.X1_31_Membership__c;
        }
        decimal persistencyPercentage,retentionPercentage,totalClosedOpps,winPercentage;
        if(activeAccountTodayandOn31 != 0)
            persistencyPercentage = integer.valueOf((throughOutActiveAccountsMembersCount/activeAccountTodayandOn31));
        else
            persistencyPercentage = 0;
        persistency = (persistencyPercentage >100 ? 100+' %' : persistencyPercentage+' %');
        if(prevActiveAccounts.size() != 0)
            retentionPercentage = integer.valueOf((activeAccountTodayandOn31/prevActiveAccounts.size())*100);
        else
            retentionPercentage = 0;
        retention = retentionPercentage + ' %';
        
        Date checkDate = ConstantsController.hpsPerformanceMetricDateRequired;
        decimal wonOpps = 0;
        totalClosedOpps = 0;
        for(Opportunity opp : [	select 	id,IsWon 
        						from 	opportunity 
        						where 	( 	OwnerId = :UserInfo.getUserId() OR Direct_Indirect_Manager_of_Owner__c = true )//OwnerId In: userIds 
        							and RecordType.DeveloperName = 'Renewal' 
        							and IsClosed = true 
        							and Date_Closed__c > :checkDate ] )
        {
            if(opp.Iswon)
                ++wonOpps;
            ++totalClosedOpps;
        }
        if(totalClosedOpps != 0)
            winPercentage = integer.valueOf((wonOpps/totalClosedOpps)*100);
        else 
            winPercentage = 0;
        renewalWinRate = winPercentage + ' %';
      }catch(Exception e)
      {
          
          ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage());
            ApexPages.addMessage(myMsg);
      }
    }
}