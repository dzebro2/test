public with sharing class EventTriggerHandler { 
	
	/**
	* @description Updates the field Last_Opp_Activity_Date__c on the current User to the current time.
	*			   Used for tracking the last time a User created/edited Opportunity Events.
	* @param newEvents The list of Events in Trigger.new
	*/
	public static void updateUserLastOppActivity(List<Event> newEvents){
		
		try 
		{	       
			// Finds current User 
			Id currUserId = UserInfo.getUserId();
			User currUser = [Select Id, Last_Opp_Activity_Date__c from User Where Id = :currUserId limit 1];

			// Builds list of Object Ids that newEvents are related to
			Set<Id> whatIds = new Set<Id>();
			for (Event e : newEvents){
				whatIds.add(e.WhatId);
			}
		
			// Queries for Opportunities that any Event in newEvents is related to
			Map<Id, Opportunity> m = new Map<Id, Opportunity>([Select Id, Name From Opportunity Where Id in :whatIds]); 
			
			// Looks through newEvents to find any related objects that are Opportunities.
			// If any are found, update the current User's Last_Opp_Activity_Date__c to the current time.
			for (Event currEvent : newEvents){
				Opportunity o = m.get(currEvent.WhatId);
			
				if (o != null){
					currUser.Last_Opp_Activity_Date__c = System.now();
				}
			}

			update currUser;
		}
		catch (Exception  e)
		{
			System.debug('Exception ' + e.getMessage());
			
		}
		
	}
}