trigger AttachmentTrigger on Attachment (after insert, after delete,before insert) {
    if(Test.isRunningTest() || (!Test.isRunningTest() && ConstantsController.CheckTriggerExecution(userinfo.getProfileId(), ConstantsController.AttachmentTriggerField))){
        if(trigger.isbefore && trigger.isInsert)  
            AtttachmentHandler.validateCBSRStatusforAttachment(Trigger.new);
        if(trigger.isAfter && trigger.isInsert)
            AtttachmentHandler.UpdateIntegrationActionObject(Trigger.new);
        
        if(Trigger.isDelete)
            AtttachmentHandler.DeleteIntegrationActionObject(Trigger.old);
            
        if(trigger.isAfter && trigger.isInsert)
            AtttachmentHandler.validationForMIMETypes(trigger.new);
    }
}