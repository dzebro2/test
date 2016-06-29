/**************************************************************************************
  Apex Trigger Name     : CompetitorRelationshipTrigger 
  Version               : 1.0
  Function              : This trigger on Competitor_Relationship__c object is used to perform various operations on trigger events on Competitor_Relationship__c . 
  Modification Log      :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
*  Nitin Paliwal       15/09/2015                Original Version
*/
trigger CompetitorRelationshipTrigger on Competitor_Relationship__c (after insert,after update,after delete) {
	if(Test.isRunningTest() || (!Test.isRunningTest() && ConstantsController.CheckTriggerExecution(userinfo.getProfileId(), ConstantsController.CompetitorRelationshipTriggerFIeld))){
	    if(trigger.isAfter){
	        if(trigger.isinsert || trigger.isUpdate || trigger.isdelete){
	            CompetitorRelationshipTriggerHandler.updateSlicedAccountDetails(trigger.new,trigger.oldmap,trigger.old);
	        }
	    }
	}
}