public without sharing class HPS_MyProspectsController {

    public List<MyProspectsWrapper> myProspectsList {get; set;}
    public DateTime currentTimeStamp;
    public Map<Id, Account> mapOfAccountIdAndAccount;
    public Map<Id, OpenActivity> mapOfAccountIdAndNextActivity;
    public Map<Id, Strategic_Plan__c> mapOfAccountIdAndStrategyPlan;
    

    public HPS_MyProspectsController(){
        try{
            currentTimeStamp                = System.now();
            mapOfAccountIdAndAccount        = new Map<Id, Account>();
            mapOfAccountIdAndNextActivity   = new Map<Id, OpenActivity>();
            mapOfAccountIdAndStrategyPlan   = new Map<Id, Strategic_Plan__c>();
            populateMyProspects();
        }catch(Exception e){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage());
            ApexPages.addMessage(myMsg);
        }
    }
    
    private void populateMyProspects(){
        try{
            MyProspectsWrapper myProspectObj;
            myProspectsList         = new List<MyProspectsWrapper>();
            Set<Id> accountIds      = new Set<Id>();
            set<String> recordTypeIds = new set<String>();
            //Id prospectRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get( 'Prospect' ).getRecordTypeId();
            recordTypeIds.add(Schema.SObjectType.Account.getRecordTypeInfosByName().get( 'Prospect' ).getRecordTypeId());
            recordTypeIds.add(Schema.SObjectType.Account.getRecordTypeInfosByName().get( 'Prospect (Non BlueSTAR)' ).getRecordTypeId());
            for( AccountTeamMember accountTeamMemberObj :[  SELECT  AccountId 
                                                            FROM    AccountTeamMember 
                                                            WHERE   Account.RecordTypeId In: recordTypeIds
                                                                AND UserId =: UserInfo.getUserId() and Account.Status__c != 'Dormant'
                                                            limit   :Limits.getLimitQueryRows() - Limits.getQueryRows() ] ) {
                accountIds.add( accountTeamMemberObj.AccountId );
            }
            
            for( Account accountObj :[  SELECT  Id, Name, Status__c, Number_Of_Open_Opportunities__c 
                                        FROM    Account 
                                        WHERE   RecordTypeId In :recordTypeIds  
                                            AND OwnerId =: UserInfo.getUserId() and Status__c != 'Dormant'
                                        limit   :Limits.getLimitQueryRows() - Limits.getQueryRows() ] ) {
                accountIds.add( accountObj.Id );
            }
            
            for( Account accountObj :[  SELECT  Id, Name, Status__c, Number_Of_Open_Opportunities__c 
                                        FROM    Account 
                                        WHERE   Id IN: accountIds  and Status__c != 'Dormant'
                                        limit   :Limits.getLimitQueryRows() - Limits.getQueryRows() ] ) {
                if(!mapOfAccountIdAndAccount.containsKey(accountObj.Id)){
                    mapOfAccountIdAndAccount.put(accountObj.Id, accountObj);
                }
            }
            for(Account accountObj : [  SELECT  Id, (   SELECT  Id, ActivityDate, Subject 
                                                        FROM    OpenActivities 
                                                        ORDER BY ActivityDate ASC NULLS LAST, LastModifiedDate DESC 
                                                        LIMIT 500 ) 
                                        FROM    Account 
                                        WHERE   Id IN: accountIds  and Status__c != 'Dormant'
                                        limit   :Limits.getLimitQueryRows() - Limits.getQueryRows() ] ) {
                if( !accountObj.OpenActivities.isEmpty() ) {
                    mapOfAccountIdAndNextActivity.put( accountObj.Id, accountObj.OpenActivities[0] );
                }
            }
            
            for( Strategic_Plan__c strategyPlanObj : [  SELECT  Id, Account_Name__c, Name 
                                                        FROM    Strategic_Plan__c 
                                                        WHERE Account_Name__c IN: accountIds] ) {
                if(!mapOfAccountIdAndStrategyPlan.containsKey(strategyPlanObj.Account_Name__c)){
                    mapOfAccountIdAndStrategyPlan.put(strategyPlanObj.Account_Name__c, strategyPlanObj);
                }
            }
            for(Id accountId : accountIds){
                myProspectObj = new MyProspectsWrapper();
                if(mapOfAccountIdAndAccount.containsKey(accountId)){
                    myProspectObj.accountObj = mapOfAccountIdAndAccount.get(accountId);
                }
                if(mapOfAccountIdAndNextActivity.containsKey(accountId)){
                    myProspectObj.openActivityObj = mapOfAccountIdAndNextActivity.get(accountId);
                }
                if(mapOfAccountIdAndStrategyPlan.containsKey(accountId)){
                    myProspectObj.strategyPlanObj = mapOfAccountIdAndStrategyPlan.get(accountId);
                }
                if(myProspectsList.size()<10000)
                	myProspectsList.add(myProspectObj);
            }
        }catch(Exception e){
            System.debug( 'Exception : ' +e.getMessage() );
            throw e;
        }
    }
    public class MyProspectsWrapper {
        public Account accountObj {get; set;}
        public OpenActivity openActivityObj {get; set;}
        public Strategic_Plan__c strategyPlanObj {get; set;}
        
        public MyProspectsWrapper(){
        
        }
    }
}