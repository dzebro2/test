trigger CaseOwnerShipTracking on Case_Ownership_Tracking__c (before update) {
    if(Test.isRunningTest() || (!Test.isRunningTest() && ConstantsController.CheckTriggerExecution(userinfo.getProfileId(), ConstantsController.CaseOwnershipTriggerField))){
        if(trigger.isupdate && trigger.isbefore){
            BusinessHours defaultBusinessHours = ConstantsController.defaultBusinessHours;
            integer workingHours;
            for(LGNA_Constants__c temp : LGNA_Constants__c.getAll().values()){
                    if(temp.name == 'Default'){
                        workingHours = ( Integer )temp.Total_Working_Hours_per_Day__c;
                    }
                }
            if(workingHours == null)
                workingHours = 9;
            for(Case_Ownership_Tracking__c cot : trigger.new){
                if(cot.End__c != trigger.oldMap.get(cot.Id).End__c && cot.End__c != null && cot.Start__c != null)
                    cot.Days_Outstanding_Number__c = LGNAUtilityClass.getDifferenceBetweenDays(defaultBusinessHours.Id,(cot.Start__c),(cot.End__c),workingHours);
                else if(cot.End__c == null)
                    cot.Days_Outstanding_Number__c = 0;
            }
        }
    }
}