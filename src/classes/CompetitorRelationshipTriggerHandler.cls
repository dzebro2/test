/**************************************************************************************
  Apex Class Name     : CompetitorRelationshipTriggerHandler
  Version             : 1.0
  Function            : This is a handler Class for the CompetitorRelationshipTrigger 
  Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Nitin Paliwal           09/15/2015                Original Version
*************************************************************************************/
public with sharing class CompetitorRelationshipTriggerHandler{
    /*************************************************
     * Method name  : updateSlicedAccountDetails
     * Description  : Static method to update the sliced field of the Account while inserting/updating carrier relationship
     * Return Type  : Void
   *************************************************/
    public static void updateSlicedAccountDetails(list<Competitor_Relationship__c> newList, map<Id,Competitor_Relationship__c > oldMap,list<Competitor_Relationship__c > oldList){
        list<Account> updateAccounts = new list<Account>();
        set<String> accountIds = new set<String>();
        string carrierRecordTypeId;
        //query the record type of carrier 
        for(RecordType rt : [select Id from RecordType where SobjectType = 'Competitor_Relationship__c' and DeveloperName ='Carrier'])
        {
            carrierRecordTypeId = rt.Id;
        }
        //get the account records ids to be update
        if(newList != null){
            for(Competitor_Relationship__c cr : newList){
                if(cr.RecordTypeId == carrierRecordTypeId ){
                    if(oldMap != null && oldMap.containsKey(cr.Id) ){
                        accountIds.add(cr.Group_Account__c);
                        accountIds.add(oldMap.get(cr.Id).Group_Account__c);
                    }
                    else if(oldMap == null || !(oldMap.containsKey(cr.Id))){
                        accountIds.add(cr.Group_Account__c);
                    }
                }
            }
        }
        if(oldList != null){
            for(Competitor_Relationship__c cr : oldList){
                if(cr.RecordTypeId == carrierRecordTypeId && cr.Sliced__c == true && cr.Status__c == 'Active'){
                    accountIds.add(cr.Group_Account__c);
                }
            }
        }
        //query on the account records and in the inner query find out if there is any carrier which is active and sliced set as true
        for(Account acc : [select Sliced__c,Carve_Out__c,Id,(select Id,Sliced_with__c,Carve_Out__c from Competitor_Relationships1__r where (Sliced_with__c = true or Carve_Out__c = true) and Status__c = 'Active' and RecordtypeId =:carrierRecordTypeId) from account where Id In :accountIds]){
            boolean sliced = false;
            boolean carved = false;
            boolean ischanged = false;
            for(Competitor_Relationship__c cr : acc.Competitor_Relationships1__r){
                if(cr.Carve_Out__c)
                    carved = true;
                if(cr.Sliced_with__c)
                    sliced = true;
            }
            
            if(sliced && !acc.Sliced__c){
                acc.Sliced__c = true;
               ischanged = true;
            }
            else if(!sliced && acc.Sliced__c){
                acc.Sliced__c = false;
                ischanged = true;
            }
            
            if(carved && !acc.Carve_Out__c){
                acc.Carve_Out__c = true;
                 ischanged = true;
            }
            else if(!carved && acc.Carve_Out__c){
                acc.Carve_Out__c = false;
                ischanged = true;
            }
            if(ischanged)
                updateAccounts.add(acc);
        }
        //update the account records
        if(updateAccounts.size() >0)
            update updateAccounts;
    }
}