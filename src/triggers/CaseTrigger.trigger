/**************************************************************************************
  Apex Trigger Name     : CaseTrigger
  Version               : 1.0
  Function              : This trigger on CAse object is used to perform various operations on trigger events on Case.
  Modification Log      :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------
*   Suyog Dongaonkar       03/10/2014                Original Version
*************************************************************************************/
trigger CaseTrigger on Case (before insert, before update, after insert, after update , before delete) {

    if (Test.isRunningTest() || (!Test.isRunningTest() && ConstantsController.CheckTriggerExecution(userinfo.getProfileId(), ConstantsController.CaseTriggerField))) {
        //Before insert, check record editability and update case owner/Assigned to
        if ( trigger.isBefore && trigger.isInsert ) {
            CaseTriggerHandler.checkCaseEditability( trigger.new );
            CaseTriggerHandler.updateCaseOwnerByQueue( trigger.new );
            CaseTriggerHandler.updateAssignedToOnCase(trigger.new);
            CaseTriggerHandler.updateCaseOwnerByEmail(trigger.new, new map<Id, Case>());
            CaseTriggerHandler.manageCaseAccountLookups( trigger.new);
            CaseTriggerHandler.updateCustomContractFields(trigger.new);
            CaseTriggerHandlerLGNA.UpdateIntegrationAction(trigger.new , trigger.oldmap);
            CaseTriggerHandlerLGNA.changeIntegrationAction(trigger.new , 'Insert');
        }
        //Before update, check record editability and update case owner/Assigned to
        if ( trigger.isBefore && trigger.isUpdate ) {
            CaseTriggerHandler.checkCaseEditability( trigger.new, trigger.old );
            CaseTriggerHandler.updateCaseOwnerByQueue( trigger.new, trigger.old);
            CaseTriggerHandler.updateAssignedToOnCase( trigger.new, trigger.old);
            CaseTriggerHandlerLGNA.UpdateIntegrationAction(trigger.new , trigger.oldmap);
            //for(Case caseObj : trigger.new){
            //  if(caseObj.Initial_Email_To_Address__c != trigger.oldMap.get(caseObj.Id).Initial_Email_To_Address__c)
            CaseTriggerHandler.updateCaseOwnerByEmail(trigger.new, trigger.oldmap);
            //}

            CaseTriggerHandler.manageCaseAccountLookups( trigger.new );
            if (!CaseTriggerHandlerLGNA.restrictExecution )
                CaseTriggerHandlerLGNA.changeIntegrationAction(trigger.new , 'Update');

            //Check for the Carrier History Last 24 months data covered
            CaseTriggerHandlerLGNA.validateCarrierHistoryValidation(trigger.new, trigger.oldMap, trigger.newMap);

            CaseTriggerHandlerLGNA.AppendExternalIdWithCaseNumber(trigger.new , trigger.oldmap);
            CaseTriggerHandlerLGNA.updateUnderwritingDueDates(trigger.new, trigger.oldMap);
            CaseTriggerHandlerLGNA.validateOwnerChange(trigger.new , trigger.oldMap);
            CaseTriggerHandler.privateExchangeCheckSubCasesIfClosed(trigger.new, trigger.newMap, trigger.oldMap);
        }

        if ( trigger.isAfter && trigger.isInsert && !CaseTriggerHandlerLGNA.restrictExecution) {
            CaseTriggerHandler.createCaseOwnershipTrackingRecord( trigger.new );
            CaseTriggerHandlerLGNA.calloutHelperMethod(trigger.new , 'Insert');
        }

        if ( trigger.isAfter && trigger.isUpdate && !CaseTriggerHandlerLGNA.restrictExecution) {
            CaseTriggerHandler.createCaseOwnershipTrackingRecord( trigger.new, trigger.old );
            CaseTriggerHandlerLGNA.DeleteCasesWithCloseMArkedStatus(trigger.new);
            CaseTriggerHandlerLGNA.calloutHelperMethod(trigger.new , 'Update');
            CaseTriggerHandler.clonePrivateExchangeRecords(trigger.new, trigger.oldMap);
        }
        if ( trigger.isBefore && trigger.isDelete) {
            CaseTriggerHandlerLGNA.CascadeDeleteDetailsTrigger(trigger.old);
        }
        if ( trigger.isBefore && (trigger.isInsert || trigger.isUpdate) && !CaseTriggerHandlerLGNA.restrictExecution) {
            ESalesUtilityClass.UpdateCaseRecordESales(trigger.new);
            CaseTriggerHandler.updateTypeFieldOnCustomContract(trigger.new);
        }
        if ( trigger.isAfter && (trigger.isInsert || trigger.isUpdate) && !CaseTriggerHandlerLGNA.restrictExecution) {
            ESalesUtilityClass.GenerateXMLFile(trigger.new);
            CaseTriggerHandler.updateAccountNumberEsales(trigger.newMap, trigger.oldMap);
            CaseTriggerHandlerLGNA.SendChatterNotifications( trigger.newMap, trigger.oldMap );
        }
    }
}