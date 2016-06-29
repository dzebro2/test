trigger OpportunityTrigger on Opportunity (before insert, after insert, before update, after update) {
    if (Test.isRunningTest() || (!Test.isRunningTest() && ConstantsController.CheckTriggerExecution(userinfo.getProfileId(), ConstantsController.OpportunityTriggerField))) {
        try {

            if (Trigger.isInsert || Trigger.isUpdate) {
                OpportunityTriggerHelper.updateUserOpporuntityActivity(Trigger.new);
            }

            if ( trigger.isBefore ) {
                if ( trigger.isInsert ) {
                    OpportunityTriggerHelper.selectDefaultPlaybook( trigger.new );
                    //Method to populate fields on new opportunity creation with related account field values
                    OpportunityTriggerHelper.PopulateFieldsFromAccount(trigger.new);
                }

                if (trigger.isUpdate) {
                    // Method to check if parent account has an underwriter, and adds an error if it does not
                    OpportunityTriggerHelper.CheckAccountTeamForUnderwriter(trigger.new, trigger.newMap, trigger.oldMap);
                }
            }


            if (Trigger.isAfter) {

                if (Trigger.isInsert) {

                    //Method call to filter and create related playbook records - stage,substage and task mapping records associated to the opportunity
                    OpportunityTriggerHelper.filterForCreatePlaybookRecords(trigger.new);
                    //Metehod call to pre populate Renewal Opportunities with Existing Products
                    OpportunityTriggerHelper.PopulateRenewalProducts(trigger.new);
                } else if (Trigger.isUpdate) {
                    //Method call to filter and create related playbook records when playbook is added to opp - stage,substage and task mapping records associated to the opportunity
                    OpportunityTriggerHelper.filterForCreatePlaybookRecords(trigger.newMap, trigger.oldMap);
                }
                if (Trigger.isInsert || Trigger.isUpdate) {
                    OpportunityTriggerHelper.CreateBAForNonBlueStarProducts(trigger.newMap);
                    OpportunityTriggerHelper.SendChatterNotifications(trigger.newMap, trigger.oldMap);
                }
            }
        } catch (Exception e) {
            for (Opportunity oppIterator : trigger.new) {
                oppIterator.addError(System.Label.UnexpectedError);
            }
        }
    }
}