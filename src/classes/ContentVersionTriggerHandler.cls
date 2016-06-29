public with sharing class ContentVersionTriggerHandler {
	public static void validateRenewalDate(list<ContentVersion> newContents,map<Id,ContentVersion> oldContentMap){
		for(ContentVersion cv : newContents){
			if(((oldContentMap != null && oldContentMap.containsKey(cv.Id) 
				&& oldContentMap.get(cv.Id).Actual_Renewal_Release_Date__c != cv.Actual_Renewal_Release_Date__c)
				|| (oldContentMap == null || !oldContentMap.containsKey(cv.Id) && cv.Actual_Renewal_Release_Date__c != null)) 
				&& ConstantsController.fireContentVersionValidation){
					cv.addError(Label.Actual_Renewal_Release_Date_Validation);
			}
		}
	}
}