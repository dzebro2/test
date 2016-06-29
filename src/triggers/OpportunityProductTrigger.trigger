trigger OpportunityProductTrigger on Opportunity_Product__c (before insert, before update)  { 
	if (Test.isRunningTest() || (!Test.isRunningTest() && ConstantsController.CheckTriggerExecution(userinfo.getProfileId(), ConstantsController.AccountTriggerField))) {
		
		if (trigger.isAfter){

			/**if(trigger.isInsert ){
				
				Map<Id, Opportunity_Product__c> lostOppProds = new Map<Id, Opportunity_Product__c>([Select Status__c, Product_Stage__c, Id, Name, Product__r.Non_Medical_Compensation__c from Opportunity_Product__c where Id in :Trigger.new and Product__r.Non_Medical_Compensation__c = True and Status__c = 'Won']);
		
				for ( Opportunity_Product__c opp : Trigger.new){
			
					Opportunity_Product__c currProduct = lostOppProds.get(opp.Id);
					System.debug(currProduct);
					if (currProduct != null)
						opp.Product_Stage__c = 'Closed Won';
				}	
			}	**/
		}
	}
}