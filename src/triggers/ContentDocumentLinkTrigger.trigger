trigger ContentDocumentLinkTrigger on ContentDocumentLink (after insert) {
	if(Test.isRunningTest() || (!Test.isRunningTest() && ConstantsController.CheckTriggerExecution(userinfo.getProfileId(), ConstantsController.ContentDocumentLinkTriggerField))){
		if(trigger.isAfter && trigger.isInsert)
	        ContentDocumentLinkTriggerHandler.UpdateContentDocumentFields(trigger.new);
	}
}