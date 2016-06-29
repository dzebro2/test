public with sharing class HPS_MyTeamsActiveAccountsController {

    public List<MyTeamsActiveAccountsWrapper> myTeamsActiveAccountsList {get; set;}
    public Map<Id, Account>             mapOfAccountIdAndAccount;
    public Map<Id, AccountTeamMember>   mapOfAccountIdAndAccountTeamMember;
    public Map<Id, Strategic_Plan__c>   mapOfAccountIdAndStrategyPlan;
    private static integer userLevel = 0;
    public HPS_MyTeamsActiveAccountsController(){

        mapOfAccountIdAndAccount            = new Map<Id, Account>();
        mapOfAccountIdAndAccountTeamMember  = new Map<Id, AccountTeamMember>();
        mapOfAccountIdAndStrategyPlan       = new Map<Id, Strategic_Plan__c>();
        

        populateMyTeamsActiveAccounts();
    }
    


    private void populateMyTeamsActiveAccounts(){
        MyTeamsActiveAccountsWrapper myTeamsActiveAccountObj;
        myTeamsActiveAccountsList   = new List<MyTeamsActiveAccountsWrapper>();
        Set<Id> accountIds          = new Set<Id>();
        Set<Id>teamUserIds          = new Set<Id>();
        set<Id> recordTypeIds       = new set<Id>();

        try{
        //Id groupRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get( 'Group Account' ).getRecordTypeId();
        recordTypeIds.add(Schema.SObjectType.Account.getRecordTypeInfosByName().get( 'Group Account' ).getRecordTypeId());
        recordTypeIds.add(Schema.SObjectType.Account.getRecordTypeInfosByName().get( 'Group Account (Non BlueSTAR)' ).getRecordTypeId());
        for(    User userObj :[ SELECT  Id 
                                FROM    User 
                                WHERE   ManagerId =:UserInfo.getUserId()
                                limit   :Limits.getLimitQueryRows() - Limits.getQueryRows() ] ) {
            teamUserIds.add( userObj.Id );
        }
        
        teamUserIds.addAll(ConstantsController.getAllSubordinateUsers(teamUserIds));
        
        for( AccountTeamMember accountTeamMemberObj :[  SELECT  AccountId 
                                                        FROM    AccountTeamMember 
                                                        WHERE   Account.RecordTypeId In:recordTypeIds
                                                            AND Account.Status__c       != 'Cancelled'  
                                                            AND ( UserId =: UserInfo.getUserId() OR UserId IN:teamUserIds )
                                                        limit   :Limits.getLimitQueryRows() - Limits.getQueryRows() ] ) {
            accountIds.add( accountTeamMemberObj.AccountId );
        }
        for( Account accountObj :[  SELECT  Id, Name, Status__c, Number_Of_Open_Opportunities__c, Renewal_Date__c, Active_Health_Members__c 
                                    FROM    Account 
                                    WHERE   RecordTypeId In:recordTypeIds
                                        AND Account.Status__c       != 'Cancelled'  
                                        AND (   OwnerId = :UserInfo.getUserId() OR Direct_Indirect_Manager_of_Owner__c = true )//( OwnerId =: UserInfo.getUserId() OR OwnerId IN: teamUserIds)
                                    limit   :Limits.getLimitQueryRows() - Limits.getQueryRows() ] ) {

            accountIds.add( accountObj.Id );
        }
        
        for( Account accountObj :[  SELECT  Id, Name, Status__c, Number_Of_Open_Opportunities__c, Renewal_Date__c, Active_Health_Members__c 
                                    FROM    Account 
                                    WHERE   Id IN: accountIds
                                    limit   :Limits.getLimitQueryRows() - Limits.getQueryRows() ] ) {

            if( !mapOfAccountIdAndAccount.containsKey( accountObj.Id ) ) {
                mapOfAccountIdAndAccount.put( accountObj.Id, accountObj );
            }
        }
        
        for( AccountTeamMember accountTeamMemberObj :[  SELECT  AccountId, UserId 
                                                        FROM    AccountTeamMember 
                                                        WHERE AccountId IN: accountIds 
                                                            AND TeamMemberRole = 'Account Executive'
                                                        limit   :Limits.getLimitQueryRows() - Limits.getQueryRows() ] ) {
            mapOfAccountIdAndAccountTeamMember.put( accountTeamMemberObj.AccountId, accountTeamMemberObj );
        }
        
        for( Strategic_Plan__c strategyPlanObj :[   SELECT  Id, Account_Name__c, Name 
                                                    FROM    Strategic_Plan__c 
                                                    WHERE   Account_Name__c IN: accountIds 
                                                        AND Active__c = true
                                                    limit   :Limits.getLimitQueryRows() - Limits.getQueryRows() ] ) {

            if( !mapOfAccountIdAndStrategyPlan.containsKey( strategyPlanObj.Account_Name__c ) ) {
                mapOfAccountIdAndStrategyPlan.put( strategyPlanObj.Account_Name__c, strategyPlanObj );
            }
        }
        
        for( Id accountId : accountIds ) {
            myTeamsActiveAccountObj = new MyTeamsActiveAccountsWrapper();
            if( mapOfAccountIdAndAccount.containsKey( accountId ) ) {
                myTeamsActiveAccountObj.accountObj = mapOfAccountIdAndAccount.get( accountId );
            }
            if( mapOfAccountIdAndAccountTeamMember.containsKey( accountId ) ) {
                myTeamsActiveAccountObj.accountTeamMemberObj = mapOfAccountIdAndAccountTeamMember.get( accountId );
            }
            if( mapOfAccountIdAndStrategyPlan.containsKey( accountId ) ) {
                myTeamsActiveAccountObj.strategyPlanObj = mapOfAccountIdAndStrategyPlan.get( accountId );

            }
            if(myTeamsActiveAccountsList.size()<10000)
            	myTeamsActiveAccountsList.add( myTeamsActiveAccountObj );
        }
      }catch(Exception e){
          System.debug( 'Exception : ' +e.getMessage() );
      }
    }
    
   /* public static Set<ID> getRoleSubordinateUsers() {
        Map<Id,User> users;
        try{
        // get requested user's role
        Id roleId = [select UserRoleId from User where Id = :userInfo.getUserId()].UserRoleId;
        // get all of the roles underneath the user
        Set<Id> allSubRoleIds = getAllSubRoleIds(new Set<ID>{roleId});
        system.debug('==subroles=='+allSubRoleIds);
        // get all of the ids for the users in those roles
         users= new Map<Id, User>([Select Id, Name From User where 
          UserRoleId IN :allSubRoleIds]);
        // return the ids as a set so you can do what you want with them
        return users.keySet();
        }catch(Exception e){
            
            System.debug( 'Exception : ' +e.getMessage() );
            return null;
        }
        

  }
  
  private static Set<ID> getAllSubRoleIds(Set<ID> roleIds) {
    
    ++userLevel;
    Set<ID> currentRoleIds = new Set<ID>();
  try{
    // get all of the roles underneath the passed roles
    for(UserRole userRole :[select Id from UserRole where ParentRoleId 
      IN :roleIds AND ParentRoleID != null])
    currentRoleIds.add(userRole.Id);
    system.debug('level==='+ userLevel);
    // go fetch some more rolls!
    if(currentRoleIds.size() > 0 && userLevel <=1)
      currentRoleIds.addAll(getAllSubRoleIds(currentRoleIds));
    }catch(Exception e){
        System.debug( 'Exception : ' +e.getMessage() );
    } 
    return currentRoleIds;

  }*/
    
    public class MyTeamsActiveAccountsWrapper {
        public Account accountObj {get; set;}
        public AccountTeamMember accountTeamMemberObj {get; set;}
        public Strategic_Plan__c strategyPlanObj {get; set;}
        
    }
}