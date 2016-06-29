/**************************************************************************************
  Apex Trigger Name     : CaseCommnetTrigger
  Version               : 1.0
  Function              : This trigger on CaseComment object is used to perform various operations on trigger events on CaseComment. 
  Modification Log      :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
*   Mayuri Bhadane        04/30/2015                Original Version
*************************************************************************************/
trigger CaseCommentTrigger on CaseComment (before insert, after insert , after delete) {
    if(Test.isRunningTest() || (!Test.isRunningTest() && ConstantsController.CheckTriggerExecution(userinfo.getProfileId(), ConstantsController.CaseComponentTriggerField))){
        
        if( trigger.isBefore && trigger.isInsert ){
            CaseCommentTriggerHandlerLGNA.ValidateCaseCommnetInsert(trigger.new);
        }   
        if( trigger.isafter && trigger.isInsert ) {
            CaseCommentTriggerHandlerLGNA.UpdateIntegrationActionObject(trigger.new);        
        }        
        
        if(Trigger.isDelete)
          CaseCommentTriggerHandlerLGNA.DeleteIntegrationActionObject(Trigger.old);
    }
}