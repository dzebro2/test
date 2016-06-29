public class NPNTriggerHandler {

    
    /******************************************************************** 
    * Method Name    :   reparentProducers
    *   @description :   Re-parents producers to the house account with the newly created NPN.
    *   @parameters  :   Map<Id, National_Producer_Number__c>
    *   @return type :   none                     
    ***************************************************************/  
    public static void reparentProducers(Map<Id, National_Producer_Number__c> npnMap) {
        
        Id recTypeProducer = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Producer Account').getRecordTypeId();
        Id producerHouse;
        List<String> npnStringList = new List<String>();
        List<Account> candidateAccts = new List<Account>();
        List<Account> updateAccts = new List<Account>();
        Map<String, Id> npnLookup = new Map<String, Id>();

        if(npnMap != null && npnMap.size() > 0){
        	Set<Id> npnIdSet = npnMap.keySet();

        	for(Id npnId : npnIdSet){
 	       		npnStringList.add(npnMap.get(npnId).NPN__c);
 	       		npnLookup.put(npnMap.get(npnId).NPN__c, npnMap.get(npnId).House_Account__c);
        	}

        	candidateAccts = [SELECT ParentId, National_Producer_Number__c FROM Account where RecordTypeId =: recTypeProducer AND National_Producer_Number__c IN: npnStringList];

        	for(Account a : candidateAccts){
 	       		
 	       		producerHouse = npnLookup.get(a.National_Producer_Number__c);

        		if(a.ParentId != producerHouse){
        			a.ParentId = producerHouse; 
 	       			updateAccts.add(a);
 	       		}
        	}

        	update updateAccts;
        }
    }


    /******************************************************************** 
    * Method Name    :   checkIfProducersWithNPN
    *   @description :   Checks if there are Accounts tied to an NPN prevent deletion if so.
    *   @parameters  :   Map<Id, National_Producer_Number__c>
    *   @return type :   none                     
    ***************************************************************/  
    public static void checkIfProducersWithNPN(Map<Id, National_Producer_Number__c> npnMap) {
        
        Id recTypeProducer = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Producer Account').getRecordTypeId();
        List<String> npnStringList = new List<String>();
        List<Account> candidateAccts = new List<Account>();
        Map<String, Id> reverseNPNMap = new Map<String, Id>();
        Id foundId;

        if(npnMap != null && npnMap.size() > 0){
        	Set<Id> npnIdSet = npnMap.keySet();

        	for(Id npnId : npnIdSet){
 	       		npnStringList.add(npnMap.get(npnId).NPN__c);
 	       		reverseNPNMap.put(npnMap.get(npnId).NPN__c, npnId);
        	}

        	candidateAccts = [SELECT National_Producer_Number__c FROM Account where RecordTypeId =: recTypeProducer AND National_Producer_Number__c IN: npnStringList];
        	for(Account a : candidateAccts){
        		foundId = reverseNPNMap.get(a.National_Producer_Number__c);
        		npnMap.get(foundId).addError(Label.NPN_Delete_not_allowed);
        	}
        }
    }

    
    /******************************************************************** 
    * Method Name    :   updateNPNProducerCount
    *   @description :   Updates the count on the prodcer list
    *   @parameters  :   Map<Id, National_Producer_Number__c>
    *   @return type :   List<National_Producer_Number__c>                     
    ***************************************************************/  
    public static List<National_Producer_Number__c> updateNPNProducerCount(List<National_Producer_Number__c> npnList) {
        
        Id recTypeProducer = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Producer Account').getRecordTypeId();
        List<String> npnStringList = new List<String>();
        List<Account> candidateAccts = new List<Account>();
        Map<String, Id> reverseNPNMap = new Map<String, Id>();
        Map<Id, National_Producer_Number__c> npnMap = new Map<Id, National_Producer_Number__c>();
        Id foundId;

        if(npnList != null && npnList.size() > 0){
        	Set<Id> npnIdSet;

        	for(National_Producer_Number__c npn : npnList){
 	       		npnStringList.add(npn.NPN__c);
 	       		reverseNPNMap.put(npn.NPN__c, npn.Id);
 	       		npn.Producer_Count__c = 0;
 	       		npnMap.put(npn.Id, npn);
        	}
        	
        	candidateAccts = [SELECT National_Producer_Number__c FROM Account where RecordTypeId =: recTypeProducer AND National_Producer_Number__c IN: npnStringList];

        	for(Account a : candidateAccts){
        		foundId = reverseNPNMap.get(a.National_Producer_Number__c);
        		npnMap.get(foundId).Producer_Count__c += 1;
        	}

	       	for(National_Producer_Number__c n : npnList){
	       		n.Producer_Count__c = npnMap.get(n.Id).Producer_Count__c;
	       	}
        }

        return npnList;

    }
}