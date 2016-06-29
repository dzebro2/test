public with sharing class HPS_MyTeamMetrics_NewController {
  public decimal medicalRecordsCount{get;set;}
  public decimal DentalRecordsCount{get;set;}
  public decimal numberOfSales {get; set;}
  public decimal numberOfSalesAncillaryProds {get; set;}
  public String OppotunityCloseRatio {get; set;}
  //public set<ID> userIds;
  private static integer userLevel = 0;
  public HPS_MyTeamMetrics_NewController(){
          Date CompareDate = Date.newInstance(Date.Today().year(),1,31);
          Decimal OppotunityCloseRatioDec;
          Integer NumberOfOpportunitiesWon = 0;
          medicalRecordsCount = 0;
          DentalRecordsCount = 0;
          numberOfSales = 0;
          numberOfSalesAncillaryProds = 0;
          //userIds = new Set<Id>();
          
          
          /*for(    User userObj :[ SELECT  Id 
                                    FROM    User 
                                    WHERE   ManagerId =:UserInfo.getUserId()
                                    limit   :Limits.getLimitQueryRows() - Limits.getQueryRows() ] ) {
                userIds.add( userObj.Id );
          }
          userIds.addAll(ConstantsController.getAllSubordinateUsers(userIds));
          userIds.add(UserInfo.getUserId());
          */
          Set<Id> AccountIdSet = new Set<Id>();
          List<Opportunity> OwnerOpportunityList = [    SELECT  id, AccountId, CloseDate,StageName, 
                                                                (   SELECT  id, Product__c, Product__r.Family 
                                                                    FROM    Opportunity_Products__r 
                                                                    WHERE   Product__r.Family = 'Ancillary and other' ) 
                                                        From    Opportunity 
                                                        WHERE   (   OwnerId = :UserInfo.getUserId() OR Direct_Indirect_Manager_of_Owner__c = true )//OwnerId =: UserInfo.getUserId() 
                                                            AND (StageName = 'Won' OR StageName = 'Lost')];

          for(Opportunity oppty : OwnerOpportunityList){
              if(oppty.StageName == 'Won'){
                  AccountIdSet.add(oppty.AccountId);
                  NumberOfOpportunitiesWon++; 
                  if(oppty.CloseDate > CompareDate){
                      numberOfSales++;
                  }
                  if(oppty.Opportunity_Products__r != null && oppty.Opportunity_Products__r.size() > 0)
                      numberOfSalesAncillaryProds++;
              }
          }
          list<Account> activeAccounts = [select id,Active_Health_Members__c,Active_Dental_Members__c,New_Active_Health_Members__c,New_Active_Dental_Members__c,X1_31_Account_Status__c,X1_31_Membership__c from Account Where Id IN: AccountIdSet and Status__c = 'Active' and Effective_Date__c >=: CompareDate];
          for(Account acc : activeAccounts){
             if(acc.New_Active_Health_Members__c != null )
                 medicalRecordsCount += acc.New_Active_Health_Members__c;
             if(acc.New_Active_Dental_Members__c != null )
                 DentalRecordsCount += acc.New_Active_Dental_Members__c;
          }
          if(NumberOfOpportunitiesWon > 0 ){
              OppotunityCloseRatioDec = integer.valueOf((NumberOfOpportunitiesWon/OwnerOpportunityList.size())*100);
              OppotunityCloseRatio = String.valueOf(OppotunityCloseRatioDec) + '%';
          }else{
              OppotunityCloseRatio = '0%';
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
}