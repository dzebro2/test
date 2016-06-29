/**************************************************************************************
  Apex Class Name     : UserTriggerHandler
  Version             : 1.0
  Function            : This is a handler class for UserTrigger. The methods in this class are used as utility methods for UserTrigger
  Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Mayuri Bhadane       05/12/2015               Original Version
*************************************************************************************/
public with sharing class UserTriggerHandler{ 

/*************************************************************************************************** 
         Method Name : AddUsertoPermissionset
         Requirement : REQ – 01389
                       Ability to limit delete permissions to system administrators and super users
        @description : This method is used for the before update scenario.
        @parameters  : List<user> newUser , Map<id,User> OldMap
        @return type :   void                        
 ***************************************************************************************************   */  
 
    public static void AddUsertoPermissionset( List<user> newUser , Map<id,User> OldMap ) {
        List<PermissionSetAssignment> psAssignmentInsert = new List<PermissionSetAssignment>();
        List<PermissionSetAssignment> psAssignmentDelete = new List<PermissionSetAssignment>();
        set<id> userIds = new set<id>(); 
        PermissionSetAssignment PArecord;
        try{
            PermissionSet superUserpermisionset= [SELECT id ,Name, PermissionsModifyAllData FROM PermissionSet WHERE Name = :system.label.Super_User_Permissions limit 1];
            
            
            for(USer newuserRec : newUser){
                User  Olduser =OldMap.get(newuserRec.id);
                if(Olduser.Is_Super_User__c != newuserRec.Is_Super_User__c && newuserRec.Is_Super_User__c==true ){
                    PArecord = new PermissionSetAssignment();
                    PArecord.AssigneeId = newuserRec.id;
                    PArecord.PermissionSetId = superUserpermisionset.id;
                    psAssignmentInsert.add(PArecord);                
                }else if(Olduser.Is_Super_User__c != newuserRec.Is_Super_User__c && newuserRec.Is_Super_User__c==false ){
                    userIds.add(newuserRec.id);
                }
            }        
            if(userIds.size()>0)
                psAssignmentDelete =[ SELECT Id, PermissionSetId FROM PermissionSetAssignment WHERE PermissionSetId=:superUserpermisionset.id and AssigneeId in : userIds limit :Limits.getLimitQueryRows() - Limits.getQueryRows()];  
            
            if(psAssignmentInsert.size()>0){
                insert psAssignmentInsert;
            }
            if(psAssignmentDelete.size()>0){
                Delete psAssignmentDelete;
            }
        }Catch(Exception e){
            System.debug( 'Exception : ' +e.getMessage() );
        }
    
    }
    public static void updateContactAssociatedFields(list<User> newUserList,map<Id,User> oldUserMap){
        try{
            map<String,User> userEmploymentNumbers = new map<String,User>();
            set<String> userWithChangedEmloymentNumberIds = new set<String>();
            set<String> userIds = new set<String>();
            list<Contact> updateContacts = new list<Contact>();
            String recordTypeId = '';
            for(RecordType rt : [Select Id from RecordType where SobjectType = 'Contact' and DeveloperName=: ConstantsController.ContactRecordType ]){
                recordTypeId = rt.Id;
            }
            for(User u : newUserList){
                if(oldUserMap != null && oldUserMap.containsKey(u.Id)){
                    if(oldUserMap.get(u.Id).EmployeeNumber != u.EmployeeNumber || oldUserMap.get(u.Id).IsActive != u.IsActive){
                        userWithChangedEmloymentNumberIds.add(u.Id);
                        if(u.EmployeeNumber != null){
                            //userEmploymentNumbers.put(u.EmployeeNumber,u);
                            userIds.add(u.Id);
                        }
                    }
                }
                else if(u.EmployeeNumber != null){
                    userIds.add(u.Id);
                    //userEmploymentNumbers.put(u.EmployeeNumber,u);
                    
                }
            }
            /*for(Contact con : [select Associated_User__c,Active_user__c,External_ID__c from Contact where (Associated_User__c = :userWithChangedEmloymentNumberIds Or External_ID__c = :userEmploymentNumbers.keySet()) and RecordTypeId = :recordTypeId]){
                if(userEmploymentNumbers.containsKey(con.External_ID__c)){
                    con.Associated_User__c = userEmploymentNumbers.get(con.External_ID__c).Id;
                    con.Active_user__c = userEmploymentNumbers.get(con.External_ID__c).IsActive;
                    updateContacts.add(con);
                }
                else{
                    con.Associated_User__c = null;
                    con.Active_user__c = false;
                    updateContacts.add(con);
                }
            }
            
            if(updateContacts.size()>0)
                update updateContacts;*/
                updateContactRecords(userWithChangedEmloymentNumberIds,userIds);
        }catch(Exception e){
            throw e;
        }
    }
    @future
    public static void updateContactRecords(set<String> userWithChangedEmloymentNumberIds,set<String> userIds){
        list<Contact> updateContacts = new list<Contact>();
        map<String,User> userEmploymentNumbers = new map<String,User>();
        for(User u : [select Id,EmployeeNumber from User where Id In :userIds]){
            userEmploymentNumbers.put(u.EmployeeNumber,u);
        }
        String recordTypeId = '';
            for(RecordType rt : [Select Id from RecordType where SobjectType = 'Contact' and DeveloperName=: ConstantsController.ContactRecordType ]){
                recordTypeId = rt.Id;
            }
        for(Contact con : [select Associated_User__c,Active_user__c,External_ID__c from Contact where (Associated_User__c = :userWithChangedEmloymentNumberIds Or External_ID__c = :userEmploymentNumbers.keySet()) and RecordTypeId = :recordTypeId]){
                if(userEmploymentNumbers.containsKey(con.External_ID__c)){
                    con.Associated_User__c = userEmploymentNumbers.get(con.External_ID__c).Id;
                    updateContacts.add(con);
                }
                else{
                    con.Associated_User__c = null;
                    updateContacts.add(con);
                }
            }
            
            if(updateContacts.size()>0)
                update updateContacts;
    }
  
}