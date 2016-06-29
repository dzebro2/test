trigger ContactRelationshipTrigger on Contact_Relationship__c ( after insert, after update, after delete ) {
    if( Test.isRunningTest() 
    	|| ( !Test.isRunningTest() 
    		&& ConstantsController.CheckTriggerExecution( userinfo.getProfileId(), ConstantsController.ContactRelationshipTriggerField ) ) ) {
        
        if( trigger.isAfter ) {
            if( trigger.isInsert ) {
            	ContactRelationshipTriggerHandler.manageContactRelationships( trigger.new );
            }
            else if( trigger.isUpdate ) {
            	ContactRelationshipTriggerHandler.manageContactRelationshipsUpdate( trigger.newMap, trigger.oldMap );
            }
            else if( trigger.isDelete ) {
            	ContactRelationshipTriggerHandler.manageContactRelationshipsDelete( trigger.oldMap );
            }
        }
    }
}