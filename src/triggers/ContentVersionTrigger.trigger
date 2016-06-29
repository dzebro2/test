trigger ContentVersionTrigger on ContentVersion (before insert,before update) {
    if(Test.isRunningTest() || (!Test.isRunningTest() && ConstantsController.CheckTriggerExecution(userinfo.getProfileId(), ConstantsController.ContentVersionTriggerField))){
        if(trigger.isBefore){
            if(trigger.isInsert || trigger.isBefore){
            	String rectypeId;
            	for(RecordType rt : [select Id from RecordType where SobjectType='ContentVersion' and DeveloperName ='Renewals']){
            		rectypeId = rt.Id;
            	}
                for(ContentVersion cv : trigger.new){
                	
                	if(cv.RecordTypeId == rectypeId)
                		if(((trigger.oldMap != null && trigger.oldMap.containsKey(cv.Id) && trigger.oldMap.get(cv.Id).Account__c == null &&
                			cv.Account__c != null) || 
                			(trigger.oldMap == null || !trigger.oldMap.containsKey(cv.Id))) && 
                			cv.Underwriter__c == null){
                		cv.Underwriter__c = userInfo.getUserId();
                	}
                }
            }
        }
    }
}