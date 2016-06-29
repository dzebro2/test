trigger SecureInformationTrigger on Secure_Information__c (after insert, after update,before Insert,before update) {
 	if(Test.isRunningTest() || (!Test.isRunningTest() && ConstantsController.CheckTriggerExecution(userinfo.getProfileId(), ConstantsController.SecureInformationTriggerFIeld))){
     
     if(trigger.isAfter && (trigger.isInsert || trigger.isUpdate)){
        SecureAttachmentTriggerHandler.shareSecureAttachmentRecords(trigger.new,trigger.oldMap);
      }
      if(trigger.isBefore && (trigger.isInsert || trigger.isUpdate)){
      	SecureAttachmentTriggerHandler.prepopulateAccountValue(trigger.new,trigger.oldMap);
      	SecureAttachmentTriggerHandler.checkforSecurityIssues(trigger.new);
      }
 	}
}