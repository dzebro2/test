/**************************************************************************************
  Apex Class Name     : TaskTriggerHandler
  Version             : 1.0
  Function            : This is a handler class for the task trigger
  Modification Log    :

*************************************************************************************/
public with sharing class TaskTriggerHandler {
	/******************************************************************** 
    * Method Name    : updateCaseStatus
    *   @description : This method updates the UnderWriting Case Status when a new Task of Type "Need Additional Information" is created
    *   @parameters  : list<Task> newTasklist,map<Id,Task> newTaskMap
    *   @return type :void  
    *   Requirement Number : REQ - 02209               
    ***************************************************************/
    public static void updateCaseStatus(list<Task> newlist,map<Id,Task> newMap){
        set<String> caseIds = new set<String>();
        for(Task t : newlist){
            if(t.whatId != null){
                if(string.valueOf(t.whatId).subString(0,3) == Case.sobjecttype.getDescribe().getKeyPrefix() && t.Type == ConstantsController.TaskTypeForUpdatingCaseStatus ){
                    caseIds.add(t.whatId);
                }
            }
        }
        map<String,Case> caseRecords = new map<String,Case>( [	select 	Id,Status,
        																( 	select 	Id,Status 
        																	from 	Tasks 
        																	where 	(Status != 'Completed' and Status != 'Deferred')
        																		and Type = :ConstantsController.TaskTypeForUpdatingCaseStatus) 
        														from 	Case 
        														where 	Id =:caseIds 
        															and (	RecordType.DeveloperName =: ConstantsController.UnderwritingCaseRecordType 
        																or 	RecordType.DeveloperName =:ConstantsController.DentalUnderwritingCaseRecordTypeDeveloperName ) 
        														limit: 	Limits.getLimitQueryRows() - Limits.getQueryRows() ] );
        list<Case> updatedCaseStatus = new list<Case>();
        for(Task t : newList){
            if(t.Type == ConstantsController.TaskTypeForUpdatingCaseStatus){
                if(t.Status != 'Completed' && t.Status != 'Deferred' && caseRecords.containsKey(t.whatId)){
                    if(caseRecords.get(t.whatId).Status != ConstantsController.updatedCaseStatus){
                        caseRecords.get(t.whatId).Status = ConstantsController.updatedCaseStatus;
                        updatedCaseStatus.add(caseRecords.get(t.whatId));
                    }
                }
                else if((t.Status == 'Completed' || t.Status == 'Deferred')&& caseRecords.containsKey(t.whatId)){
                    if (caseRecords.get(t.whatId).Tasks.size() == 0 && caseRecords.get(t.whatId).Status != 'Closed' && caseRecords.get(t.whatId).Status != 'In Progress')
                        caseRecords.get(t.whatId).Status = 'In Progress';
                        updatedCaseStatus.add(caseRecords.get(t.whatId));
                }
            }
        }
        Database.SaveResult[] srList;
        try{
            if(updatedCaseStatus.size() > 0){
               ConstantsController.shouldCarrierHistoryValidationFire = false;
               srList = database.update(updatedCaseStatus,false);
               for(Integer i=0;i<srList.size();i++){
                    Database.SaveResult s = srList[i];
                    Case origRecord = updatedCaseStatus[i];
                    if (!s.isSuccess()) {
                        for(Task t : newlist){
                            if(t.whatId == origRecord.Id){
                                t.addError(System.label.AnErrorHasOcurred);
                            }
                        }
                     } 
                }
            }    
        }catch(Exception e){
            throw e;
        }
    }

	/**
	* @description Updates the field Last_Opp_Activity_Date__c on the current User to the current time.
	*			   Used for tracking the last time a User created/edited Opportunity Tasks.
	* @param newTasks The list of Tasks in Trigger.new
	*/
	public static void updateUserLastOppActivity(List<Task> newTasks){
		
		try 
		{	        
			// Finds current User
			Id currUserId = UserInfo.getUserId();
			User currUser = [Select Id, Last_Opp_Activity_Date__c from User Where Id = :currUserId limit 1];
			
			// Builds list of Object Ids that newTasks are related to
			Set<Id> whatIds = new Set<Id>();
			for (Task newt : newTasks){
			
				whatIds.add(newt.WhatId);
			}
		
			// Queries for Opportunities that any Task in newTasks is related to
			Map<Id, Opportunity> m = new Map<Id, Opportunity>([Select Id, Name From Opportunity Where Id in :whatIds]); 

			// Looks through newTasks to find any related objects that are Opportunities.
			// If any are found, update the current User's Last_Opp_Activity_Date__c to the current time.
			for (Task t : newTasks){
				Opportunity o = m.get(t.WhatId);
			
				if (o != null){
					currUser.Last_Opp_Activity_Date__c = System.now();
				}
			}
			update currUser;
		}
		catch (Exception e){
			System.debug('Exception ' + e.getMessage());
		}
	}

 /******************************************************************** 
    * Method Name    : sendEmailAlertToTaskOwner
    *   @description : This method updates the will send an email alert to taskowner when the task status is set as completed
    *   @parameters  : list<Task> newTasklist,map<Id,Task> oldTaskMap
    *   @return type :void  
    *   Requirement Number : REQ - 02523               
    ***************************************************************/
    public static void sendEmailAlertToTaskOwner(list<Task> newlist,map<Id,Task> oldMap){
        try{
	        if( !ConstantsController.isTaskCompletionEmailSent ) {
		        set<String> caseIds 		= new set<String>();
		        set<String> closedTaskIds 	= new set<String>();
		        set<String> createdUserIds  = new set<String>();
		        for( Task t :newlist ){
		            if( t.whatId != null ) {
		                if(	 ( ( 	oldMap != null && oldMap.containsKey( t.Id ) && t.status != oldMap.get( t.Id ).status ) 
								|| ( oldMap == null || !oldMap.containsKey( t.Id ) ) ) 
							&& t.status == 'Completed' ) {
		                    if(string.valueOf( t.whatId ).subString( 0, 3 ) == Case.sobjecttype.getDescribe().getKeyPrefix())
		                    	caseIds.add( t.whatId );
		                    closedTaskIds.add( t.Id ); // this set will be used to validate the task id
		                	createdUserIds.add(t.CreatedById);
		                }
		            }
		        }
		        set<String> allowedProfileNames = new set<String>();
		        for(Task_Closed_Mail_User_Profiles__c temp : Task_Closed_Mail_User_Profiles__c.getAll().values()){
		        	allowedProfileNames.add(temp.Name);
		        }
		        map<String,Case> caseRecords = new map<String,Case>(	[	select 	Id, Status, OwnerId
	    																	from 	Case 
	    																	where 	Id =:caseIds 
	    																		and (	RecordType.DeveloperName = :ConstantsController.UnderwritingCaseRecordType 
	    																			Or 	RecordType.DeveloperName = :ConstantsController.DentalUnderwritingCaseRecordTypeDeveloperName ) 
																			limit: 	Limits.getLimitQueryRows() - Limits.getQueryRows() ] );
		        
		        map<Id,User> createdUsersMap = new Map<Id,User>([select Profile.Name, Id from User where Id In :createdUserIds]);
		        
		        list<Messaging.SingleEmailMessage> sendEmails = new list<Messaging.SingleEmailMessage>();
		        EmailTemplate et = [	select 	Id 
		        						from 	EmailTemplate 
		        						where 	DeveloperName ='Case_Task_Complete_VF_Template'
		        						limit	1 ];
		       	Case caseRec;
		        for( Task t :newList ) {
		            
		            if( closedTaskIds.contains( t.Id )  && t.OwnerId != t.createdbyId && createdUsersMap.containsKey( t.createdbyId ) 
		            		&& allowedProfileNames.contains(createdUsersMap.get( t.createdbyId ).Profile.name) /*createdUsersMap.get( t.createdbyId ).Profile.name == 'Underwriting'*/ ) {
		            	system.debug('inside---');
		            	Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
						mail.setTemplateId(et.Id);
						mail.setTargetObjectId(t.CreatedById);
						mail.setWhatId(t.Id); 
						mail.setSaveAsActivity(false); 
						sendEmails.add(mail);
		            }
		            else if( closedTaskIds.contains( t.Id ) && caseRecords.containsKey( t.WhatId ) ) {
		            	caseRec = caseRecords.get( t.WhatId );
		            	
		            	Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
						mail.setTemplateId( et.Id );
						mail.setTargetObjectId( caseRec.OwnerId );
						mail.setWhatId( t.Id ); 
						mail.setSaveAsActivity( false ); 
						sendEmails.add( mail );
		            }
		        }

		        if( sendEmails.size() > 0 ) {
		        	Messaging.sendEmail( sendEmails );
		        	ConstantsController.isTaskCompletionEmailSent = true;
		        }
	        }
        }catch(Exception e){
            System.debug( 'Exception: ' + e.getMessage() );
        }
    }
}