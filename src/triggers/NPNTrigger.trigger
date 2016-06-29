trigger NPNTrigger on National_Producer_Number__c (before insert, before delete, before update, after insert,  after update, after delete) {
	if (Test.isRunningTest() || (!Test.isRunningTest() )) {

    	if(trigger.isBefore ){
    		
    		NPNTriggerHandler.updateNPNProducerCount(trigger.new);

    		if(trigger.isDelete){
    			NPNTriggerHandler.checkIfProducersWithNPN(trigger.oldMap);
    		}
    	}

    	if(trigger.isAfter){
   	 		if(trigger.isInsert){
    			NPNTriggerHandler.reparentProducers(trigger.newMap);
    		}
    	}
    }
}