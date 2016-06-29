trigger EventTrigger on Event (before insert ,after insert, after update,before update,before delete)  { 
	
	if(Test.isRunningTest() || (!Test.isRunningTest() && ConstantsController.CheckTriggerExecution(userinfo.getProfileId(), ConstantsController.TaskTriggerField))){
		
		if (Trigger.isAfter){
			if(Trigger.isInsert || Trigger.isUpdate){
				EventTriggerHandler.updateUserLastOppActivity(Trigger.new);
			}
		}
	}
}