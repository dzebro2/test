public with sharing class HPS_MyTeamsRenewalsController {
    
    public List<MyTeamsRenewalsWrapper> myTeamsRenewalsList {get; set;}
    public Map<Id, Opportunity> mapOfOpportunityIdAndOpportunity = new Map<Id, Opportunity>();
    public Map<Id, OpportunityTeamMember> mapOfOpportunityIdAndOpportunityTeamMember = new Map<Id, OpportunityTeamMember>();
    public Map<String, Integer> mapOfOpportunityIdAndProjectedMembers = new Map<String, Integer>();
    private static integer userLevel = 0;
    public HPS_MyTeamsRenewalsController(){
        try{
            populateMyTeamsRenewals();
        }catch(Exception e){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage());
            ApexPages.addMessage(myMsg);
        }
    }
    private void populateMyTeamsRenewals(){
        try{
            MyTeamsRenewalsWrapper myTeamsRenewalsObj;
            myTeamsRenewalsList = new List<MyTeamsRenewalsWrapper>();
            Set<Id> opportunityIds = new Set<Id>();
            Set<Id>teamUserIds = new Set<Id>();
            
            Id renewalRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal').getRecordTypeId(); 
            
            for(User userObj : [    SELECT  Id 
                                    FROM    User 
                                    WHERE   ManagerId =:UserInfo.getUserId() 
                                    limit   :Limits.getLimitQueryRows() - Limits.getQueryRows()]){
                teamUserIds.add(userObj.Id);
            }
            //get all the users who are 2 level below the current login user
                  teamUserIds.addAll(ConstantsController.getAllSubordinateUsers(teamUserIds));
            for(OpportunityTeamMember opportunityTeamMemberObj : [  SELECT  OpportunityId 
                                                                    FROM    OpportunityTeamMember 
                                                                    WHERE   Opportunity.RecordTypeId =: renewalRecordTypeId and Opportunity.IsClosed = false
                                                                        AND	(UserId =: UserInfo.getUserId() OR UserId IN: teamUserIds) 
                                                                    limit   :Limits.getLimitQueryRows() - Limits.getQueryRows()]){
                opportunityIds.add(opportunityTeamMemberObj.OpportunityId);
            }
            
            for(Opportunity opportunityObj : [  SELECT  Id, Name, AccountId, Account.Name, CloseDate, StageName, Account.Current_Risk_Level__c, Expected_Health_Members__c  
                                                FROM    Opportunity 
                                                WHERE   RecordTypeId =: renewalRecordTypeId and IsClosed = false
                                                    AND ( 	OwnerId = :UserInfo.getUserId() OR Direct_Indirect_Manager_of_Owner__c = true )//(   OwnerId =: UserInfo.getUserId() OR  OwnerId IN: teamUserIds) 
                                                limit   :Limits.getLimitQueryRows() - Limits.getQueryRows()]){
                opportunityIds.add(opportunityObj.Id);
            }
            for(Opportunity opportunityObj : [  SELECT  Id, Name, AccountId, Account.Name, CloseDate, StageName, Account.Current_Risk_Level__c, Expected_Health_Members__c 
                                                FROM    Opportunity 
                                                WHERE   Id IN: opportunityIds and IsClosed = false
                                                limit   :Limits.getLimitQueryRows() - Limits.getQueryRows()]){
                if(!mapOfOpportunityIdAndOpportunity.containsKey(opportunityObj.Id)){
                    mapOfOpportunityIdAndOpportunity.put(opportunityObj.Id, opportunityObj);
                }
            }
            for(OpportunityTeamMember opportunityTeamMemberObj : [  SELECT  OpportunityId, UserId 
                                                                    FROM    OpportunityTeamMember 
                                                                    WHERE   OpportunityId IN: opportunityIds 
                                                                        AND TeamMemberRole = 'Account Executive' 
                                                                    limit   :Limits.getLimitQueryRows() - Limits.getQueryRows()]){
                mapOfOpportunityIdAndOpportunityTeamMember.put(opportunityTeamMemberObj.OpportunityId, opportunityTeamMemberObj);
            }
            for(AggregateResult aggregateResultObj : [  SELECT  SUM(Projected_Members__c) noOfProjectedMembers, Opportunity_Name__c opportunityName 
                                                        FROM    Opportunity_Product__c 
                                                        WHERE   Product__c != null 
                                                        GROUP BY Opportunity_Name__c 
                                                        limit   :Limits.getLimitQueryRows() - Limits.getQueryRows()]){
                if(!mapOfOpportunityIdAndProjectedMembers.containsKey(String.valueOf(aggregateResultObj.get('opportunityName')))){
                    mapOfOpportunityIdAndProjectedMembers.put(String.valueOf(aggregateResultObj.get('opportunityName')), Integer.valueOf(aggregateResultObj.get('noOfProjectedMembers')));
                }
            }
            for(Id opportunityId : opportunityIds){
                myTeamsRenewalsObj = new MyTeamsRenewalsWrapper();
                if(mapOfOpportunityIdAndOpportunity.containsKey(opportunityId)){
                    myTeamsRenewalsObj.opportunityObj = mapOfOpportunityIdAndOpportunity.get(opportunityId);
                }
                if(mapOfOpportunityIdAndOpportunityTeamMember.containsKey(opportunityId)){
                    myTeamsRenewalsObj.opportunityTeamMemberObj = mapOfOpportunityIdAndOpportunityTeamMember.get(opportunityId);
                }
                if(mapOfOpportunityIdAndProjectedMembers.containsKey(opportunityId)){
                    myTeamsRenewalsObj.projectedMembers = mapOfOpportunityIdAndProjectedMembers.get(opportunityId);
                }
                if(myTeamsRenewalsList.size()<10000)
                	myTeamsRenewalsList.add(myTeamsRenewalsObj);
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
    }catch(exception e){
        System.debug( 'Exception : ' +e.getMessage() );
        throw e;
    }
  }*/
    
    public class MyTeamsRenewalsWrapper {
        public Opportunity opportunityObj {get; set;}
        public OpportunityTeamMember opportunityTeamMemberObj {get; set;}
        public Integer projectedMembers {get; set;}
        
        public MyTeamsRenewalsWrapper() {
        
        }
    }
}