trigger IntegrationStaTrigger on Integration_Status__c (before insert ,after insert){
    if(Test.isRunningTest() || (!Test.isRunningTest() && ConstantsController.CheckTriggerExecution(userinfo.getProfileId(), ConstantsController.IntegrationStatusTriggerField))){
        if(Trigger.isInsert && Trigger.isbefore){
             IntegrationStatusTriggerHandler.updateIntegrationAction(Trigger.new);
        } 
        if(Trigger.isInsert && Trigger.isafter){
             IntegrationStatusTriggerHandler.calloutHelperMethod(Trigger.new);
        }    
    }
}