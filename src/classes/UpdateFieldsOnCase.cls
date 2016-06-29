/***********************************************************************************************************
  Apex Class Name     : UpdateFieldsOnCase
  Version             : 1.0
  Function            : This class is used to update the Case Fields and send Email to 
                        Queue Members/Owner's Manager based on the Inbound Email Subject 
  Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
*   Dinesh Talreja          02/10/2014                Original Version
************************************************************************************************************/

global class UpdateFieldsOnCase implements Messaging.InboundEmailHandler 
{
    
    public String ParseSubject;
    public List<String> SplitSubjectByColon = new List<String>();
    public String RecordId;
    public String UpdateValue;
    public String EmailTemplateDeveloperName;
    public String UserOrQueueId;
    public set<Id> UserIds;
    public set<String> EmailIds;
    public List<Contact> InsertedContacts;
    
    /*  handleInboundEmail
    *   @description:   This method is used to update the Case Fields and send Email to 
                        Queue Members/Owner's Manager based on the Inbound Email Subject
                        
    *   @parameters     Messaging.InboundEmail email, Messaging.InboundEnvelope envelope
    *   @return type    Messaging.InboundEmailResult                     
    */   
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) 
    {
    
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        
        //Store the Email Subject
        ParseSubject = email.Subject;
        if(ParseSubject !=null && ParseSubject !='')
        {
            //Check if the Sub String of Subject contains Priority Field
            if(ParseSubject.subString(8,16) == System.Label.Priority_Field)
            {
                //Split the Email Subject by colon
                SplitSubjectByColon = ParseSubject.split(':',-1);
                if(!SplitSubjectByColon.isEmpty())
                {
                    //Store the Case Record Id
                    RecordId = SplitSubjectByColon[3];
                    RecordId = RecordId.trim();
                    
                    //Store the value of Priority Field to be updated on Case Record
                    UpdateValue = SplitSubjectByColon[2];
                    UpdateValue = UpdateValue = UpdateValue.replace('?','');
                    UpdateValue = UpdateValue.replace('?','');
                    
                    //If the value of Priority Field to be updated on Case Record contains "One Up" String
                    if(UpdateValue.contains(System.Label.One_Up))
                    {
                        Case caseObj = [SELECT 	Id, Execute_Rule__c, Priority 
                        				FROM 	Case 
                        				WHERE 	Id=:RecordId 
                        				limit   :Limits.getLimitQueryRows() - Limits.getQueryRows()];
                        
                        //Check if the existing Priority field value on Case Record is "Low"
                        if(caseObj.Priority == StaticVariablesUtility.casePriorityLow )
                            //Update the new Priority field value on Case Record as "Medium"
                            caseObj.Priority = StaticVariablesUtility.casePriorityMedium;
                        
                        //Check if the existing Priority field value on Case Record is "Medium"
                        else if(caseObj.Priority == StaticVariablesUtility.casePriorityMedium)
                            //Update the new Priority field value on Case Record as "High"
                            caseObj.Priority = StaticVariablesUtility.casePriorityHigh;
                            
                        //Check if the existing Priority field value on Case Record is "High"
                        else if(caseObj.Priority == StaticVariablesUtility.casePriorityHigh)
                            //Update the new Priority field value on Case Record as "Critical"
                            caseObj.Priority = StaticVariablesUtility.casePriorityCritical;
                        
                        caseObj.Execute_Rule__c = true;
                        update caseObj;
                    }   
                    else
                    {                   
                        Case caseObj = [SELECT 	Id, Execute_Rule__c, Status, Priority 
                        				FROM 	Case 
                        				WHERE 	Id=:RecordId 
                        				limit   :Limits.getLimitQueryRows() - Limits.getQueryRows()];
                        
                        caseObj.Priority = UpdateValue;
                        /*if(caseObj.Status == 'In-Progress'){
                            caseObj.Execute_Rule__c = true;
                        }
                        else{
                            caseObj.Execute_Rule__c = false;
                        } */   
                        update caseObj;
                    }
                }
            }
            //Check if the Sub String of Subject contains Status Field
            else if(ParseSubject.subString(8,14) == System.Label.Status_Field)
            {
                //Split the Email Subject by colon
                SplitSubjectByColon = ParseSubject.split(':',-1);
                if(!SplitSubjectByColon.isEmpty())
                {
                    //Store the Case Record Id
                    RecordId = SplitSubjectByColon[3];
                    RecordId = RecordId.trim();
                    
                    //Store the value of Status Field to be updated on Case Record
                    UpdateValue = SplitSubjectByColon[2];
                    UpdateValue = UpdateValue.replace('?','');
                    UpdateValue = UpdateValue.replace('?','');
                    
                    Case caseObj = [SELECT 	Id, Execute_Rule__c, Status 
                    				FROM 	Case 
                    				WHERE 	Id=:RecordId 
                    				limit   :Limits.getLimitQueryRows() - Limits.getQueryRows()];
                    
                    caseObj.Status = UpdateValue;
                    //caseObj.Execute_Rule__c = true;
                    update caseObj;
                }
            }
            //Check if the Sub String of Subject contains Mail
            else if(ParseSubject.subString(0,4) == System.Label.Mail)
            {
                //Split the Email Subject by colon
                SplitSubjectByColon = ParseSubject.split(':',-1);
                if(!SplitSubjectByColon.isEmpty())
                { 
                    //Store the Case Record Id
                    RecordId = SplitSubjectByColon[2];
                    RecordId = RecordId.trim();
                    
                    //Store the Email Template Id to be used to send Email
                    EmailTemplateDeveloperName = SplitSubjectByColon[3];
                    EmailTemplateDeveloperName = EmailTemplateDeveloperName.trim();
                    
                    //Store the User/Queue Id to send Email
                    UserOrQueueId = SplitSubjectByColon[1];
                    UserOrQueueId = UserOrQueueId.trim();
                    
                    //If the UserOrQueueId starts with "005"
                    if(UserOrQueueId.startsWith(System.Label.UserId_Prefix))
                    {
                        //Query the User record based on Suer Id
                        User userObj = [SELECT 	Id, ManagerId 
                        				FROM 	User 
                        				WHERE 	Id=:UserOrQueueId 
                        				limit   :Limits.getLimitQueryRows() - Limits.getQueryRows()];
                        if(userObj.ManagerId !=null)
                        {
                            Id ManagerId = userObj.ManagerId;
                            //Query the User's/Owner's Manager based on ManagerId
                            User managerUserObj = [	SELECT 	Email 
                            						FROM 	User 
                            						WHERE 	Id =:ManagerId 
                            						limit   :Limits.getLimitQueryRows() - Limits.getQueryRows()];
                            
                            //Create a dummy Contact record with Managerr Email
                            Contact con = new Contact();
                            con.FirstName = 'Test';
                            con.LastName = 'Contact';
                            con.Email = managerUserObj.Email;
                            insert con;
                            
                            //Send Email to Owner's Manager with the specified Email Template and Case Record Id
                            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                            mail.setTemplateId([select 	Id 
                            					from 	EmailTemplate 
                            					where 	DeveloperName =:EmailTemplateDeveloperName 
                            					limit 	1 ].Id);
                            mail.setTargetObjectId(con.Id);
                            mail.setWhatId(RecordId);
                            Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
                            
                            //Delete the dummy contact
                            delete con;
                        }
                    }
                    //If the UserOrQueueId starts with "00G"
                    else if(UserOrQueueId.startsWith(System.Label.GroupId_Prefix))
                    {
                        UserIds = new set<Id>();
                        EmailIds = new set<String>();
                        InsertedContacts = new List<Contact>();
                        Integer i=1;
                        List<Messaging.SingleEmailMessage> listOfEmailMessage = new List<Messaging.SingleEmailMessage>();
                        
                        //Store the Group Members associated to Group
                        for(GroupMember groupMemberObj : [	SELECT 	UserOrGroupId 
                        									FROM 	GroupMember 
                        									WHERE 	GroupId =:UserOrQueueId 
                        									limit   :Limits.getLimitQueryRows() - Limits.getQueryRows()])
                            UserIds.add(groupMemberObj.UserOrGroupId);
                        //Store the Email Id of the Group Members
                        for(User userObj : [SELECT 	Id, Email 
                        					FROM 	User 
                        					WHERE 	Id IN:UserIds 
                        					limit   :Limits.getLimitQueryRows() - Limits.getQueryRows()])
                            EmailIds.add(userObj.Email);
                        
                        //Create a Dummy Contact for each Group Members Email Address
                        for(String str : EmailIds)
                        {
                            Contact con = new Contact();
                            con.FirstName = 'Test';
                            con.LastName = 'Contact' + i;
                            con.Email = str;
                            InsertedContacts.add(con);
                        }
                        if(!InsertedContacts.isEmpty())
                            insert InsertedContacts;
                        
                        for(Contact contactObj : InsertedContacts)
                        {
                            //Store the Email messages in a list
                            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                            mail.setTemplateId([select 	Id 
                            					from 	EmailTemplate 
                            					where 	DeveloperName =:EmailTemplateDeveloperName 
                            					limit 	1].Id );
                            mail.setTargetObjectId(contactObj.Id);
                            mail.setWhatId(RecordId);
                            listOfEmailMessage.add(mail);
                            i++;
                        }
                        
                        //Send Email to Group Members with the specified Email Template and Case Record Id
                        Messaging.SendEmailResult [] r = Messaging.sendEmail(listOfEmailMessage);
                        
                        //Delete the Dummy Contacts
                        if(!InsertedContacts.isEmpty())
                            delete InsertedContacts;
                    }
                }
            }
        }
        return result;
    }
}