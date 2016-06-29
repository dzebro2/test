public with sharing class HPS_MyTeamsProspectsController {

    public List<MyTeamsProspectsWrapper> myTeamsProspectsList {get; set;}
    public Map<Id, Account> mapOfAccountIdAndAccount = new Map<Id, Account>();
    public Map<Id, AccountTeamMember> mapOfAccountIdAndAccountTeamMember = new Map<Id, AccountTeamMember>();
    public Map<Id, Strategic_Plan__c> mapOfAccountIdAndStrategyPlan = new Map<Id, Strategic_Plan__c>();
    private static integer userLevel = 0;
    public HPS_MyTeamsProspectsController(){
        try{
            populateMyTeamsProspects();
        }catch(Exception e){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage());
            ApexPages.addMessage(myMsg);
        }
    }
    private void populateMyTeamsProspects(){
        try{
            MyTeamsProspectsWrapper myTeamsProspectObj;
            myTeamsProspectsList = new List<MyTeamsProspectsWrapper>();
            Set<Id> accountIds = new Set<Id>();
            Set<Id>teamUserIds = new Set<Id>();
            set<String> recordTypeIds = new set<String>();
            //Id prospectRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
            recordTypeIds.add(Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId());
            recordTypeIds.add(Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect (Non BlueSTAR)').getRecordTypeId());
            for(User userObj : [    SELECT  Id 
                                    FROM    User 
                                    WHERE   ManagerId =:UserInfo.getUserId() 
                                    limit   :Limits.getLimitQueryRows() - Limits.getQueryRows()]){
                teamUserIds.add(userObj.Id);
            }
            
            //get all the users who are 2 level below the current login user
            teamUserIds.addAll(ConstantsController.getAllSubordinateUsers(teamUserIds));
            
            for(AccountTeamMember accountTeamMemberObj : [  SELECT  AccountId 
                                                            FROM    AccountTeamMember 
                                                            WHERE   Account.RecordTypeId In :recordTypeIds
                                                                AND (   UserId =: UserInfo.getUserId() OR  UserId IN: teamUserIds) 
                                                                    and Account.Status__c != 'Dormant' 
                                                            limit   :Limits.getLimitQueryRows() - Limits.getQueryRows()]){
                accountIds.add(accountTeamMemberObj.AccountId);
            }
            
            for(Account accountObj : [  SELECT  Id, Name, Status__c, Number_Of_Open_Opportunities__c 
                                        FROM    Account 
                                        WHERE   RecordTypeId In :recordTypeIds
                                            AND (   OwnerId = :UserInfo.getUserId() OR Direct_Indirect_Manager_of_Owner__c = true )//(   OwnerId =: UserInfo.getUserId() OR  OwnerId IN: teamUserIds) 
                                                and Status__c != 'Dormant' 
                                        limit   :Limits.getLimitQueryRows() - Limits.getQueryRows()]){
                accountIds.add(accountObj.Id);
            }
            
            for(Account accountObj : [  SELECT  Id, Name, Status__c, Number_Of_Open_Opportunities__c 
                                        FROM    Account 
                                        WHERE   Id IN: accountIds and Status__c != 'Dormant' 
                                        limit   :Limits.getLimitQueryRows() - Limits.getQueryRows()]){
                if(!mapOfAccountIdAndAccount.containsKey(accountObj.Id)){
                    mapOfAccountIdAndAccount.put(accountObj.Id, accountObj);
                }
            }
            
            for(AccountTeamMember accountTeamMemberObj : [  SELECT  AccountId, UserId 
                                                            FROM    AccountTeamMember 
                                                            WHERE   AccountId IN: accountIds 
                                                                AND TeamMemberRole = 'Sales Executive' and Account.Status__c != 'Dormant' 
                                                            limit   :Limits.getLimitQueryRows() - Limits.getQueryRows()]){
                mapOfAccountIdAndAccountTeamMember.put(accountTeamMemberObj.AccountId, accountTeamMemberObj);
            }
            
            for(Strategic_Plan__c strategyPlanObj : [   SELECT  Id, Account_Name__c, Name 
                                                        FROM    Strategic_Plan__c 
                                                        WHERE   Account_Name__c IN: accountIds 
                                                            AND Active__c = true 
                                                        limit   :Limits.getLimitQueryRows() - Limits.getQueryRows()]){
                mapOfAccountIdAndStrategyPlan.put(strategyPlanObj.Account_Name__c, strategyPlanObj);
            }
            for(Id accountId : accountIds){
                myTeamsProspectObj = new MyTeamsProspectsWrapper();
                if(mapOfAccountIdAndAccount.containsKey(accountId)){
                    myTeamsProspectObj.accountObj = mapOfAccountIdAndAccount.get(accountId);
                }
                if(mapOfAccountIdAndAccountTeamMember.containsKey(accountId)){
                    myTeamsProspectObj.accountTeamMemberObj = mapOfAccountIdAndAccountTeamMember.get(accountId);
                }
                if(mapOfAccountIdAndStrategyPlan.containsKey(accountId)){
                    myTeamsProspectObj.strategyPlanObj = mapOfAccountIdAndStrategyPlan.get(accountId);
                }
                if(myTeamsProspectsList.size()<10000)
                	myTeamsProspectsList.add(myTeamsProspectObj);
            }
        }catch(Exception e){
            System.debug( 'Exception : ' +e.getMessage() );
            throw e;
        }
    }
    
   /* public static Set<ID> getRoleSubordinateUsers() {
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
            return null;
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
    
    public class MyTeamsProspectsWrapper {
        public Account accountObj {get; set;}
        public AccountTeamMember accountTeamMemberObj {get; set;}
        public Strategic_Plan__c strategyPlanObj {get; set;}
        
        public MyTeamsProspectsWrapper(){
        
        }
    }
}