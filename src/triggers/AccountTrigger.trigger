/**************************************************************************************
  Apex Trigger Name     : AccountTrigger
  Version               : 1.0
  Function              : This trigger on Acount object is used to perform various operations on trigger events on Account.
  Modification Log      :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------
*   Suyog Dongaonkar       21/11/2014                Original Version
*/

trigger AccountTrigger on Account (after insert, after update, before update, before insert) {
  if (Test.isRunningTest() || (!Test.isRunningTest() && ConstantsController.CheckTriggerExecution(userinfo.getProfileId(), ConstantsController.AccountTriggerField))) {
    if (trigger.isBefore) {
		
      AccountTriggerHandler.CarryOverMemberValues(trigger.newMap, trigger.oldMap);
      

      AccountTriggerHandler.validateUniqueNPN(trigger.new);
	  AccountTriggerHandler.updateRegion(trigger.new);
    }

    if ( trigger.isAfter ) {
      AccountTriggerHandler.updateProducerParent(trigger.newMap, trigger.oldMap);
      AccountTriggerHandler.GS_BA_BP_Cancellation(trigger.newMap, trigger.oldMap);

      if ( trigger.isInsert ) {
        AccountTriggerHandler.createProducerContact( trigger.new );
        AccountTriggerHandler.createChatterPost(trigger.new);
        AccountTriggerHandler.addAE2AndUnderwriterOnInsert( trigger.new );

      } else if ( trigger.isUpdate ) {
        AccountTriggerHandler.createProducerContact( trigger.old, trigger.new );
        AccountTriggerHandler.createChatterPost(trigger.old, trigger.new);
        AccountTriggerHandler.addAE2AndUnderwriterOnUpdate( trigger.new, trigger.oldMap );
        // reatain the
        AccountTriggerHandler.ReatainPreviousOwnersAccess(trigger.new, trigger.oldMap);
      }
    }
  }
}