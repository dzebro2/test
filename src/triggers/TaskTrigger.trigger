trigger TaskTrigger on Task (after insert, after update,before insert,before update) {
    if(Test.isRunningTest() || (!Test.isRunningTest() && ConstantsController.CheckTriggerExecution(userinfo.getProfileId(), ConstantsController.TaskTriggerField))){
		
        if(trigger.isAfter){
            if(trigger.isInsert || trigger.isUpdate){
                TaskTriggerHandler.updateCaseStatus(trigger.new,trigger.newMap);
                TaskTriggerHandler.sendEmailAlertToTaskOwner(trigger.new,trigger.oldMap);
				TaskTriggerHandler.updateUserLastOppActivity(trigger.new);
            }
        }
    }
}