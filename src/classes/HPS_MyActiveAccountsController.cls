/**************************************************************************************
  Apex Class Name     : HPS_MyActiveAccountsController
  Version             : 1.0
  Function            : This is a controller class for HPS_MyActiveAccounts Page for showing the information of current logged in user active accounts.
  Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------    
  Dinesh           :       March                    Original Version
  mayuri                   June                     Updated Code comments
*************************************************************************************/
public with sharing class HPS_MyActiveAccountsController 
{

    public List<MyActiveAccountsWrapper>    myActiveAccountsList  // List of Wrapper class stores Active account and Strategic plan
    {
        get; 
        set;
    }
    public Map<Id, Account>                 mapOfAccountIdAndAccount; // map of Id and its account
    public Map<Id, Strategic_Plan__c>       mapOfAccountIdAndStrategyPlan;  // Map of Account id and its related strategic plan
    
     /******************************************************************** 
    * Method Name    : HPS_MyActiveAccountsController
    *   @description :   controller of class.
    *   @parameters  :   none
    *   @return type :   none                     
    ***************************************************************/  
    public HPS_MyActiveAccountsController()
    {
        mapOfAccountIdAndAccount        = new Map<Id, Account>();
        mapOfAccountIdAndStrategyPlan   = new Map<Id, Strategic_Plan__c>();
        populateMyActiveAccounts();
    }
   
   
      /******************************************************************** 
    * Method Name    : PopulateMyActiveAccounts
    *   @description :   Method to populate active accounts on home page slider.
    *   @parameters  :   none
    *   @return type :   none                     
    ***************************************************************/  
 
    private void PopulateMyActiveAccounts()
    {
        MyActiveAccountsWrapper myActiveAccountObj;
        myActiveAccountsList    = new List<MyActiveAccountsWrapper>();
        Set<Id> accountIds      = new Set<Id>();
        set<Id> groupRecordTypeId = new set<Id>();
        // Query Record typeId  of Group Account
        for(RecordType rt : [select Id from RecordType where SobjectType = 'Account' and (DeveloperName =: ConstantsController.GroupAccountRecordType or DeveloperName = 'Group_Account_Non_BlueSTAR')])
        {
            groupRecordTypeId.add( rt.Id);
        }
        //Id groupRecordTypeId    = Schema.SObjectType.Account.getRecordTypeInfosByName().get( 'Group Account' ).getRecordTypeId();
        try{
           // Query Group Account Team member of logged in user
            for( AccountTeamMember accountTeamMemberObj :[  SELECT  AccountId 
                                                            FROM    AccountTeamMember 
                                                            WHERE   Account.RecordTypeId    In :groupRecordTypeId 
                                                                AND Account.Status__c       != :ConstantsController.ActiveAccountStatusMandatoryCriteria 
                                                                AND (UserId                  = :UserInfo.getUserId() )
                                                            limit   :Limits.getLimitQueryRows() - Limits.getQueryRows() ] ) 
            {
                accountIds.add( accountTeamMemberObj.AccountId );
            }
           
           //collect  All group Account ids of logged in user
            for( Account accountObj :[  SELECT  Id
                                        FROM    Account 
                                        WHERE   RecordTypeId   In :groupRecordTypeId 
                                            AND Status__c       != :ConstantsController.ActiveAccountStatusMandatoryCriteria 
                                            AND OwnerId         =: UserInfo.getUserId() 
                                        limit   :Limits.getLimitQueryRows() - Limits.getQueryRows() ] ) 
            {
                accountIds.add( accountObj.Id );
            }
            
            //Query All group Accounts of logged in user as well as his/her Team member  
            for( Account accountObj :[  SELECT  Id, Name, Status__c, Number_Of_Open_Opportunities__c, Renewal_Date__c, Active_Health_Members__c ,
                                        (Select Id, Account_Name__c, Name FROM    Strategic_Account_Plans__r )
                                        FROM    Account 
                                        WHERE   Id IN :accountIds 
                                        limit   :Limits.getLimitQueryRows() - Limits.getQueryRows() ] ) 
             {
                if( !mapOfAccountIdAndAccount.containsKey( accountObj.Id ) ) {
                    mapOfAccountIdAndAccount.put( accountObj.Id, accountObj );
                }
            //  Create map of Account name and is related strategic Map
                for(Strategic_Plan__c strategyPlanObj : accountObj.Strategic_Account_Plans__r){
                    if( !mapOfAccountIdAndStrategyPlan.containsKey( strategyPlanObj.Account_Name__c ) ) 
                    {
                        mapOfAccountIdAndStrategyPlan.put( strategyPlanObj.Account_Name__c, strategyPlanObj );
                    }
                }
            }
            
            /*for( Strategic_Plan__c strategyPlanObj :[   SELECT  Id, Account_Name__c, Name 
                                                        FROM    Strategic_Plan__c 
                                                        WHERE   Account_Name__c IN :accountIds 
                                                        limit   :Limits.getLimitQueryRows() - Limits.getQueryRows() ] ) 
            {
                
                if( !mapOfAccountIdAndStrategyPlan.containsKey( strategyPlanObj.Account_Name__c ) ) 
                {
                    mapOfAccountIdAndStrategyPlan.put( strategyPlanObj.Account_Name__c, strategyPlanObj );
                }
                
            }*/
          
          //  Create list of Wrapper Objecct which stores Active account object and its Strategic plan
            for( Id accountId :accountIds ) 
            {
                myActiveAccountObj = new MyActiveAccountsWrapper();
                if( mapOfAccountIdAndAccount.containsKey( accountId ) ) 
                {
                    myActiveAccountObj.accountObj = mapOfAccountIdAndAccount.get( accountId );
                }
                if( mapOfAccountIdAndStrategyPlan.containsKey( accountId ) ) 
                {
                    myActiveAccountObj.strategyPlanObj = mapOfAccountIdAndStrategyPlan.get( accountId );
                }
                if(myActiveAccountsList.size()<10000)
                	myActiveAccountsList.add( myActiveAccountObj );
             }
        }catch(Exception e)
          {
              System.debug( 'Exception : ' +e.getMessage() );
              ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, System.label.Error_Message + ' ' + e.getMessage() + '  ' + e.getStackTraceString() ) );
          }
    }
    
    // Wrap class of Account and Strategic Plan
    public class MyActiveAccountsWrapper 
    {
        public Account              accountObj      
        { 
            get; 
            set; 
        }
        public Strategic_Plan__c    strategyPlanObj 
        { 
            get; 
            set; 
        }
    }
}