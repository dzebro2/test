/**************************************************************************************
  Apex Trigger Name     : UserTrigger
  Version               : 1.0
  Function              : This trigger on User object is used to perform various operations on trigger events on User. 
  Modification Log      :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
*  Mayuri Bhadane       05/12/2015                Original Version
*************************************************************************************/
trigger UserTrigger on User (before update,after insert,after update) {
    if(Test.isRunningTest() || (!Test.isRunningTest() && ConstantsController.CheckTriggerExecution(userinfo.getProfileId(), ConstantsController.UserTriggerField))){
        if( trigger.isBefore && trigger.isUpdate ){
            UserTriggerHandler.AddUsertoPermissionset(trigger.new , trigger.oldmap);
        }
        if(trigger.isAfter && (trigger.isInsert || trigger.isupdate)){
            UserTriggerHandler.updateContactAssociatedFields(trigger.new,trigger.oldMap);
        }
    }
}