/**************************************************************************************
  Apex Class Name     : HPS_MyMetricsController
  Version             : 1.0
  Function            : This class is used for showing the performance of the logged in used on the home page slider
  Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
**/
public with sharing class HPS_MyMetricsController {
    public decimal medicalRecordsCount{get;set;}
    public decimal DentalRecordsCount{get;set;}
    public String persistency{get;set;}
    public String retention{get;set;}
    public string renewalWinRate{get;set;}
    public HPS_MyMetricsController()
    {
       try
       {
        
        //get the list of the Logged in users active account
        list<Account> activeAccounts = [select id,Active_Health_Members__c,Account_Persistency__c,Active_Dental_Members__c,X1_31_Account_Status__c,X1_31_Membership__c from Account Where OwnerId =: UserInfo.getUserId() and Status__c = 'Active' ];
        medicalRecordsCount=DentalRecordsCount= 0;
        decimal throughOutActiveAccountsMembersCount = 0;
        decimal activeAccountOn31Members = 0;
        decimal activeAccountTodayandOn31 = 0;
        
        //get the list of the logged in user accounts which were active previously as well
        list<Account> prevActiveAccounts = [select Id,X1_31_Membership__c,Account_Persistency__c from Account where (X1_31_Account_Status__c = 'Active' Or X1_31_Account_Status__c = 'active') and OwnerId =: UserInfo.getUserId() ];
        
        for(Account acc : activeAccounts)
        {
            //sum the Active health members
             if(acc.Active_Health_Members__c != null  )
                medicalRecordsCount += acc.Active_Health_Members__c;
            //sum the Active Dental members
             if(acc.Active_Dental_Members__c != null )
                DentalRecordsCount += acc.Active_Dental_Members__c;
                
             //get the sum of active health members which were active previously as well and as of now   
             if((acc.X1_31_Account_Status__c == 'Active' || acc.X1_31_Account_Status__c == 'active') ){
                throughOutActiveAccountsMembersCount += acc.Account_Persistency__c;
                
                ++activeAccountTodayandOn31; 
             }
        }
        
        //get the sum of active health members from account which were previously active
        for(Account acc : prevActiveAccounts)
        {
            if(acc.X1_31_Membership__c != null )
                activeAccountOn31Members +=     acc.X1_31_Membership__c;
        }
        decimal persistencyPercentage,retentionPercentage,totalClosedOpps,winPercentage;
        
        //calculate persistency
        if(activeAccountTodayandOn31 != 0)
            persistencyPercentage = integer.valueOf((throughOutActiveAccountsMembersCount/activeAccountTodayandOn31));
        else
            persistencyPercentage = 0;
        persistency = (persistencyPercentage >100 ? 100+' %' : persistencyPercentage+' %');
        
        //calculate retention
        if(prevActiveAccounts.size() != 0)
            retentionPercentage = integer.valueOf((activeAccountTodayandOn31/prevActiveAccounts.size())*100);
        else
            retentionPercentage = 0;
        retention = retentionPercentage + ' %';
        
        Date checkDate = constantsController.hpsPerformanceMetricDateRequired;
        decimal wonOpps = 0;
        totalClosedOpps = 0;
        //get the renewal opportunity win rate
        for(Opportunity opp : [select id,IsWon from opportunity where OwnerId =:UserInfo.getUserId() and RecordType.DeveloperName = :constantsController.hpsPerformanceMetricRecordTypeRequired 
                                and IsClosed = true and Date_Closed__c > :checkDate])
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
          System.debug( 'Exception : ' +e.getMessage() );
          ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage());
          ApexPages.addMessage(myMsg);
      }
    }
}