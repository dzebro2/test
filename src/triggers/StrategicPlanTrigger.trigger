trigger StrategicPlanTrigger on Strategic_Plan__c (before update, before insert) {

    if(trigger.isBefore ) {
        if (trigger.isUpdate)
            StrategicPlanTriggerHandler.validateRecordChange(trigger.newMap, trigger.oldMap);

        if (trigger.isInsert)
            StrategicPlanTriggerHandler.resetFieldsForClonedSP(trigger.new);
    }
}