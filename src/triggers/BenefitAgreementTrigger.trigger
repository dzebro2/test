trigger BenefitAgreementTrigger on Benefit_Agreement__c (before Insert, after Insert, after Update, before Delete, after Delete) {
    
    if(Test.isRunningTest() || (ConstantsController.CheckTriggerExecution(userinfo.getProfileId(), ConstantsController.BenefitAgreementTriggerField) && !Test.isRunningTest())){
        
        Map<Id, Benefit_Agreement__c> BAMap = new  Map<Id, Benefit_Agreement__c>();

        if (trigger.isBefore && trigger.isInsert) {
            BenefitAgreementTriggerHandler.setBenefitAgreementRecType(trigger.new);
        }     
        else if (trigger.isAfter) {
            if (trigger.isDelete) {
                BenefitAgreementTriggerHandler.updateAccountFundingType(trigger.old);
            }
            else
                BenefitAgreementTriggerHandler.updateAccountFundingType(trigger.new);
        }        
    }

}