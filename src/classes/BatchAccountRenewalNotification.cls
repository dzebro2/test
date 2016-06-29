/**************************************************************************************
  Apex Class Name     : BatchAccountRenewalNotification
  Version             : 1.0
  Function            : This class is used to notify Account Owner when a renewal is approaching based on renewal date and advanced notification timeframe
  Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------               
* Deloitte           10/01/2015                Original Version
*************************************************************************************/
global class BatchAccountRenewalNotification implements Database.Batchable<sObject>{
	
	/*************************************************
     * Method name  : start
     * Description  : Start method queries all the records matching criteria and returns a Database.QueryLocator for it.
     * Return Type  : Database.QueryLocator
   	*************************************************/
	global Database.QueryLocator start( Database.BatchableContext BC ){
		
		Date taskActivityDate 					= Date.today() + 2;
		String accountRenewalTaskSubject 		= Label.Account_Renewal_Task_Subject;
		String cedeAccountRenewalTaskSubject 	= Label.Cede_Account_Renewal_Task_Subject;
		
		List<String> notificationEnabledProfiles = LGNAUtilityClass.populateNotificationEnabledProfiles( 'Account_Renewal_Tasks__c' );
		
		String query = '	select 	Id, OwnerId, Ceded__c, '
						+ ' 		( 	select 	id from OpenActivities '
						+ '				where 	IsTask = true ' 
						+ '					and ActivityDate = :taskActivityDate ' 
						+ '					and ( 	Subject = :accountRenewalTaskSubject ' 
						+ ' 					or 	Subject = :cedeAccountRenewalTaskSubject ) ) '
						+ ' from 	Account '
						+ ' where 	Renewal_Notification_Date__c = TODAY '
						+ ' 	and Status__c = \'Active\' '
						+ '		and Owner.Profile.Name IN :notificationEnabledProfiles '
						+ '		and Owner.isActive = true ';
		System.debug(query);
		return Database.getQueryLocator( query );
	}
	
	/*************************************************
     * Method name  : execute
     * Description  : This method gets account records in scope and creates a task record for it. Task record is created only if a task with same due date and same subject does not exist. 
     * Return Type  : void
   	*************************************************/
	global void execute(Database.BatchableContext BC, List<sObject> scope){
		List<Task> tasks = new List<Task>();
		String taskSubject = Label.Account_Renewal_Task_Subject;
		for( Account acct :(List<Account>)scope ) {
			 //if a task with same due date and same subject does not exist
			 if( acct.OpenActivities == null || acct.OpenActivities.size() == 0 ) {
				 taskSubject = Label.Account_Renewal_Task_Subject;
				 if( acct.Ceded__c ) {
				 	taskSubject = Label.Cede_Account_Renewal_Task_Subject;
				 }
				tasks.add( new Task(
						WhatId 			= acct.Id,
						OwnerId 		= acct.OwnerId,
						Subject 		= taskSubject,
						Priority		= 'Normal',
						Status 			= 'Not Started',
						Type 			= 'To Do',
						ActivityDate 	= Date.today() + 2
					) 
				);
			 }
		}
		
		if( tasks.size() > 0 ) {
			Database.DMLOptions dmlo 			= new Database.DMLOptions();
			dmlo.EmailHeader.triggerUserEmail 	= true;
			try {       
				database.insert( tasks, dmlo );
			} catch( Exception e ) {
				System.debug( 'Exception in Account Renewal Batch: ' + e.getMessage() );
			}
		}
	}
	
	/*************************************************
     * Method name  : finish
     * Description  : No finish method behaviour is identified yet. 
     * Return Type  : void
   	*************************************************/	
	global void finish(Database.BatchableContext BC){
	
	}
}