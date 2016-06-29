trigger ContactTrigger on Contact (before insert ,after insert, after update,before update,before delete) {
   // try{
        if(Trigger.isAfter && (Trigger.isinsert || Trigger.isUpdate))
            ContactTriggerHandler.insertAccountContactRole(trigger.new);
        
        if(Trigger.isbefore && Trigger.isinsert)
            ContactTriggerHandler.ValidateProducerContact(trigger.new);
   /* }  No need of Exception Here. ContactTrigger Handler Has Exception Handling
    catch(Exception e){
        for(Contact contactIterator: trigger.new){
            contactIterator.addError(System.Label.UnexpectedError);
        }
    }*/
    
    if(trigger.isBefore && trigger.isInsert){
    	ContactTriggerHandler.populateAssociatedUserLookup(trigger.new,trigger.oldMap);
    }
    if(trigger.isBefore && trigger.isUpdate){
    	ContactTriggerHandler.populateAssociatedUserLookup(trigger.new,trigger.oldMap);
    }
    if(trigger.isAfter && trigger.isUpdate){
    	//ContactTriggerHandler.disableTheUsersLogin(trigger.new,trigger.oldMap);
        ContactTriggerHandler.updateTheUsersDetails(trigger.new,trigger.oldMap);
    }
    //Check whether the contact can be deleted or not
    if(trigger.isbefore && trigger.isDelete){
    	ContactTriggerHandler.checkForDeletionValidation(trigger.old);
    }
}