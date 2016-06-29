/**************************************************************************************
  Apex Class Name     : ContactTriggerHandler
  Version             : 1.0
  Function            : This is a handler class for the Contact trigger
  Modification Log    :

*************************************************************************************/
public class ContactTriggerHandler {
    public static void insertAccountContactRole(List<Contact> listOfContacts) {
        Set<Id> contactIds = new Set<Id>();
        Map<Id, list<AccountContactRole>> mapOfContactIdAndAccountContactRole = new Map<Id, list<AccountContactRole>>(); 
        AccountContactRole insertAccountContactRoleObj;
        List<AccountContactRole> listOfAccountContactRoleToBeInserted = new List<AccountContactRole>();
        List<AccountContactRole> listOfAccountContactRoleToBeUpdated = new List<AccountContactRole>();
        try{
        for(Contact contactObj : listOfContacts){
            contactIds.add(contactObj.Id);
        }
        for(AccountContactRole accountContactRoleObj : [SELECT ContactId, AccountId, Role, IsPrimary FROM AccountContactRole WHERE ContactId IN: contactIds]){
            if(!mapOfContactIdAndAccountContactRole.containsKey(accountContactRoleObj.ContactId))
                mapOfContactIdAndAccountContactRole.put(accountContactRoleObj.ContactId,new list<AccountContactRole>());
            mapOfContactIdAndAccountContactRole.get(accountContactRoleObj.ContactId).add( accountContactRoleObj);
        }
        for(Contact contactObj : listOfContacts){
            boolean contactAccountPresent = false;
            if(contactObj.Add_to_Buyer_Hierarchy__c == true){
                if(mapOfContactIdAndAccountContactRole.containsKey(contactObj.Id)){
                    for(AccountContactRole accountContactRoleObj : mapOfContactIdAndAccountContactRole.get(contactObj.Id)){
                        if(accountContactRoleObj.AccountId == contactObj.AccountId)
                            contactAccountPresent = true;
                        if(accountContactRoleObj.Role != contactObj.Buyer_Role__c){
                            accountContactRoleObj.Role = contactObj.Buyer_Role__c;
                            listOfAccountContactRoleToBeUpdated.add(accountContactRoleObj);
                        }
                    }
                }
                if(!contactAccountPresent){
                    insertAccountContactRoleObj = new AccountContactRole();
                    insertAccountContactRoleObj.ContactId = contactObj.Id;
                    insertAccountContactRoleObj.AccountId = contactObj.AccountId;
                    insertAccountContactRoleObj.Role = contactObj.Buyer_Role__c;
                    listOfAccountContactRoleToBeInserted.add(insertAccountContactRoleObj);
                }
                
                
             /*   if(!mapOfContactIdAndAccountContactRole.isEmpty() && mapOfContactIdAndAccountContactRole.containsKey(contactObj.Id)){
                    AccountContactRole accountContactRoleObj = mapOfContactIdAndAccountContactRole.get(contactObj.Id);
                    accountContactRoleObj.Role = contactObj.Buyer_Role__c;
                    listOfAccountContactRoleToBeUpdated.add(accountContactRoleObj);
                }
                else{
                    insertAccountContactRoleObj = new AccountContactRole();
                    insertAccountContactRoleObj.ContactId = contactObj.Id;
                    insertAccountContactRoleObj.AccountId = contactObj.AccountId;
                    insertAccountContactRoleObj.Role = contactObj.Buyer_Role__c;
                    listOfAccountContactRoleToBeInserted.add(insertAccountContactRoleObj);
                }*/
            }
        }
        if(!listOfAccountContactRoleToBeUpdated.isEmpty())
            update listOfAccountContactRoleToBeUpdated;
        if(!listOfAccountContactRoleToBeInserted.isEmpty())
            insert listOfAccountContactRoleToBeInserted;
       }catch(exception e){
       System.debug( 'Exception : ' +e.getMessage() );
       throw e;
       }     
    }
    
    public static void ValidateProducerContact(List<Contact> listOfContacts) {
        Id ProducerRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Producer Contact').getRecordTypeId();
        Id ConsultantRecordTypeId =Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Consultant Contact').getRecordTypeId();
        map<id,list<Contact>> AccountcontactMap = new map<id,List<Contact>>();
        map<id,Account> AccountMap = new map<id,Account>();
        set<id> accountIds = new set<id>();
       try{
        FOR( Contact cont : listOfContacts ){
            if(cont.RecordTypeId==ProducerRecordTypeId){
                accountIds.add(cont.Accountid);
            }
        }
        if(accountIds.size()>0){
            for( Contact cont : [select id,Accountid,RecordTypeId from contact where Accountid  in :accountIds ] ){
                if(cont.RecordTypeId==ProducerRecordTypeId){
                    if(AccountcontactMap.get(cont.Accountid)==null){
                        List<Contact> newcont = new List<Contact>();
                        newcont.add(cont);
                        AccountcontactMap.put(cont.Accountid,newcont);   
                    }else{
                        AccountcontactMap.get(cont.Accountid).add(cont);
                    }
                }    
            }
        }
        if(AccountcontactMap.size()>0){
            for(Account acc : [select id ,type , recordtype.name from account where id in : AccountcontactMap.keyset()]){
                AccountMap.put(acc.id,acc);
            }
             FOR( Contact cont : listOfContacts ){
                 if(cont.RecordTypeId==ProducerRecordTypeId && AccountcontactMap.containsKey(cont.Accountid) && AccountMap.containsKey(cont.Accountid)  && AccountcontactMap.get(cont.Accountid).size()>0 && AccountMap.get(cont.Accountid).type == 'Sub Producer'){
                     cont.adderror(System.Label.Sub_Producer_Validation) ;
                 } 
             }
        }
        }catch( Exception e ) {
            System.debug( 'Exception : ' +e.getMessage() );
            throw e;
            
        }    
    }
    
    public static void PopulateAssociatedUserLookup(list<Contact> newContacts,map<Id,Contact> oldContactsMap){
        try{
            set<String> externalIds = new set<String>();
            String recordTypeId = '';
            map<String,User> matchingUserIds = new map<String,User>();
            for(RecordType rt : [Select Id from RecordType where SobjectType = 'Contact' and DeveloperName=: ConstantsController.ContactRecordType ]){
                recordTypeId = rt.Id;
            }
            for(Contact con : newContacts){
                if(oldContactsMap == null){
                    if(recordTypeId == con.RecordTypeId && con.External_ID__c != null){
                        externalIds.add(con.External_ID__c);
                    }
                }
                else if(oldContactsMap.containsKey(con.Id)){
                    if(recordTypeId == con.RecordTypeId && con.External_ID__c != null && (con.External_ID__c != oldContactsMap.get(con.Id).External_ID__c || con.Associated_User__c != oldContactsMap.get(con.Id).Associated_User__c)){
                        externalIds.add(con.External_ID__c);
                    }
                }
            }
            for(User u : [Select Id,Employee_Number__c,IsActive from User where Employee_Number__c In :externalIds]){
                matchingUserIds.put(u.Employee_Number__c,u);
            }
            for(Contact con :newContacts){
                if(matchingUserIds.containsKey(con.External_ID__c)){
                    con.Associated_User__c = matchingUserIds.get(con.External_ID__c).Id;
                }
            }
            
        }
        catch(Exception e){
            throw e;
        }
    }
    
   /******************************************************************** 
    *    Method Name : DisableTheUsersLogin
    *   @description :   This method checks disable/enable the user login based on the internal contact status
    *   @parameters  :   set<String> userIds
    *   @return type :   none                     
    ***************************************************************/  
    private static void DisableTheUsersLogin(set<String> userIds,map<String,boolean> userStatus){
        try{
            list<UserLogin> users = new list<UserLogin>();
            set<String> activeUserIds = new set<String>();
            for(User u :[select Id from User where Id In :userIds and IsActive = true]){
                activeUserIds.add(u.Id);
            }
            for(UserLogin ul : [select IsFrozen,UserId from UserLogin where UserId In :activeUserIds]){
                if(userStatus.containsKey(ul.UserId)){
                    ul.IsFrozen = userStatus.get(ul.UserId);
                    users.add(ul);
                }
            }
           /* if(users.size()>0)
                update users;*/
        }catch(Exception e){
            throw e;
        }
        
    }
    /******************************************************************** 
    *    Method Name : updateTheUsersDetails
    *   @description :   This method checks to update the user details depending on the Internal contact update op 
    *   @parameters  :   list<Contact> newContacts,map<Id,Contact> oldContactsMap
    *   @return type :   none                     
    ***************************************************************/  
    public static void updateTheUsersDetails(list<Contact> newContacts,map<Id,Contact> oldContactsMap){
        try{
            list<UserLogin> users = new list<UserLogin>();
            set<String> userIds = new set<String>();
            set<String> contactLanIds = new set<String>();
            map<String,boolean> userInactive = new map<String,boolean>();
            String recordTypeId = '';
            for(RecordType rt : [Select Id from RecordType where SobjectType = 'Contact' and DeveloperName=: ConstantsController.ContactRecordType ]){
                recordTypeId = rt.Id;
            }
            for(Contact con : newContacts){
                /*if(oldContactsMap.get(con.Id).In_Active__c != con.In_Active__c && con.RecordTypeId == recordTypeId){
                    userIds.add(con.Associated_User__c);
                    userInactive.put(con.Associated_User__c,con.In_Active__c);
                }*/
                if(oldContactsMap.get(con.Id).Status__c != con.Status__c && con.Status__c == 'Terminated' && con.RecordTypeId == recordTypeId){
                    userIds.add(con.Associated_User__c);
                    userInactive.put(con.Associated_User__c,true);
                }
                if(con.RecordTypeId == recordTypeId && con.External_ID__c != null){
                    contactLanIds.add(con.External_ID__c);
                }
            }
            if(userIds.size()>0)
                DisableTheUsersLogin(userIds,userInactive);
            if(contactLanIds.size()>0)
                updateTheUserManagers(contactLanIds,newContacts);
        }catch(Exception e){
            throw e;
        }
    }
    /******************************************************************** 
    *    Method Name : updateTheUserManagers
    *   @description :   This method updated the user Manager Id depending on the internal user ReportsTo id
    *   @parameters  :   set<String> contactLanIds,list<Contact> newContacts
    *   @return type :   none                     
    ***************************************************************/  
    private  static void updateTheUserManagers(set<String> contactLanIds,list<Contact> newContacts){
        try{
            map<String,User> usersMap = new map<String,User>();
            list<User> updateUsersList = new list<User>();
            map<String,Contact> contactsMap = new map<String,Contact>();
            for(Contact con : [select ReportsTo.External_ID__c,External_ID__c,Title,Phone,Department from Contact where External_ID__c in :contactLanIds]){
                contactsMap.put(con.External_ID__c,con);
                if(con.ReportsTo.External_ID__c != null)
                    contactLanIds.add(con.ReportsTo.External_ID__c);
            }
            for(User u : [select Id,ManagerId,Employee_Number__c,title,Department,Phone,IsActive from User where Employee_Number__c In :contactLanIds]){
                usersMap.put(u.Employee_Number__c,u);
            }
            for(Contact con : contactsMap.values()){
                if(con.ReportsTo.External_ID__c != null && con.External_ID__c != null && usersMap.containsKey(con.External_ID__c) 
                    && usersMap.containsKey(con.ReportsTo.External_ID__c) 
                    && usersMap.get(con.External_ID__c).ManagerId != usersMap.get(con.ReportsTo.External_ID__c).Id){
                    
                    if(usersMap.get(con.ReportsTo.External_ID__c).IsActive )
                        usersMap.get(con.External_ID__c).ManagerId = usersMap.get(con.ReportsTo.External_ID__c).Id;
                    if(usersMap.get(con.External_ID__c).Title != con.Title && con.Title != null)
                        usersMap.get(con.External_ID__c).Title = con.Title;
                    if(usersMap.get(con.External_ID__c).Phone != con.Phone && con.Phone != null)
                        usersMap.get(con.External_ID__c).Phone = con.Phone;
                    if(usersMap.get(con.External_ID__c).Department != con.Department && con.Department != null)
                        usersMap.get(con.External_ID__c).Department = con.Department;
                    updateUsersList.add(usersMap.get(con.External_ID__c));
                }
                else if(usersMap.containsKey(con.External_ID__c)){
                    boolean isUpdated = false;
                    if(usersMap.get(con.External_ID__c).Title != con.Title && con.Title != null){
                        usersMap.get(con.External_ID__c).Title = con.Title;
                        isUpdated = true;
                    }
                    if(usersMap.get(con.External_ID__c).Phone != con.Phone && con.Phone != null){
                        usersMap.get(con.External_ID__c).Phone = con.Phone;
                        isUpdated = true;
                    }
                    if(usersMap.get(con.External_ID__c).Department != con.Department && con.Department != null){
                        usersMap.get(con.External_ID__c).Department = con.Department;
                        isUpdated = true;
                    }
                    if(isUpdated)
                        updateUsersList.add(usersMap.get(con.External_ID__c));
                }
            }
            if(updateUsersList.size()>0)
                update updateUsersList;
        }catch(Exception e){
            throw e;
        }
    }
    /******************************************************************** 
    *    Method Name : checkForDeletionValidation
    *   @description :   This method checks whether the contact can be deleted or not 
    *   @parameters  :   List<Contact> oldContacts
    *   @return type :   none                     
    ***************************************************************/  
     
    public static void checkForDeletionValidation(list<Contact> oldContacts){
        try{
            Ignore_Validations__c mc = Ignore_Validations__c.getInstance(UserInfo.getProfileId());
            set<String> migrationSourceValues = new set<String>();
            if(System.label.ContactValidationMigrationValue3 != null){
                migrationSourceValues.addAll(System.label.ContactValidationMigrationValue3.split(','));
                if(migrationSourceValues.size() > 0 && (mc==null || (mc!=null && !mc.Ignore_Validation__c))){
                    for(Contact con : oldContacts){
                        if(con.Migration_Source__c != null && migrationSourceValues.contains(con.Migration_Source__c)){
                            con.addError(System.label.ContactDeleteValidationMessage);
                        }
                    }
                }
            }
        }catch(Exception e){
            for(Contact con : oldContacts){
                con.addError(System.label.AnErrorHasOcurred);
            }
        }
    }
    
    
    
}