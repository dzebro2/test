/**************************************************************************************
  Apex Class Name     : CaseTriggerHandler
  Version             : 1.0
  Function            : This is a handler class for CaseTrigger. The methods in this class are used as utility methods for CaseTrigger
  Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------
*   Suyog Dongaonkar       03/10/2014                Original Version
*************************************************************************************/
public with sharing class CaseTriggerHandler {

    public static Boolean isUpdateFromCode = false;

    /*  isSuperUser
    *   @description:   This method checks if the current user is a super user.
    *   @parameters     N/A
    *   @return type    Boolean
    */


    /*  validateCarrierHistoryValidation
    *   @description:   This method checks if the carrier history is covering the 24 months duration.
    *   @parameters     N/A
    *   @return type    none
    */

    public static void validateCarrierHistoryValidation(list<Case> newCases, map<Id, Case> oldCasesMap, map<Id, Case> newCasesMap) {}



    public static Boolean isSuperUser() {
        try {
            return ConstantsController.LoggedInUserInfo.Is_Super_User__c;
            /*return [    select  Id, Is_Super_User__c
                        from    User
                        where   Id = :UserInfo.getUserId()
                        limit   1].Is_Super_User__c;*/
        } catch ( Exception e ) {
            System.debug( 'Exception : ' + e.getMessage() );
            return false;
        }
    }

    /*  checkCaseEditability
    *   @description:   This method checks if the case is editableby current user.
                        This method is used for the before insert scenario.
    *   @parameters     List<Case> newCases : Cases under current context.
    *   @return type    void
    */
    public static void checkCaseEditability( List<Case> newCases ) {
        try {
            Case newCase;
            for ( Integer index = 0; index < newCases.size(); index++ ) {
                newCase = newCases[index];
                //If the fields are being updated via code, do not add an error
                if ( CaseTriggerHandler.isUpdateFromCode == false ) {
                    if ( newCase.Assigned_To__c != null && !CaseTriggerHandler.isSuperUser() ) {
                        newCase.addError( Label.Assigned_To_Edit_Not_Allowed );
                    }
                }
            }
        } catch ( Exception e ) {
            System.debug( 'Exception : ' + e.getMessage() );
        }
    }

    /*  checkCaseEditability
    *   @description:   This method checks if the case is editableby current user.
                        This method is used for the before update scenario.
    *   @parameters     List<Case> newCases : Cases under current context.
                        List<Case> oldCases : Old values of the cases under context.
    *   @return type    void
    */
    public static void checkCaseEditability( List<Case> newCases, List<Case> oldCases ) {
        try {
            Case newCase;
            Case oldCase;
            Set<id> userIds = new  Set<id>();
            Map<id, id> UserManagerMAp = new  Map<id, id>();
            //User loggedinUser = [select id ,profile.name from User where id = :UserInfo.getUserId()] ;
            User loggedinUser = ConstantsController.LoggedInUserInfo;
            Map<String, Restricted_SG_Profiles__c> Restricted_SG_Profiles  = Restricted_SG_Profiles__c.getAll();
            for ( Integer index = 0; index < newCases.size(); index++ ) {
                newCase = newCases[index];
                userIds.add(newCase.OwnerId);
            }
            if (newCases.size() > 0) {
                for ( user userrec : [Select Id, Name, managerid from User where Id = : newCase.OwnerId]) {
                    UserManagerMAp.put(userrec.id, userrec.managerid);
                }
                for ( Integer index = 0; index < newCases.size(); index++ ) {
                    newCase = newCases[index];
                    oldCase = oldCases[index];
                    if ( CaseTriggerHandler.isUpdateFromCode == false ) {
                        if ( !CaseTriggerHandler.isSuperUser() ) {
                            //Added owner and owner's manger in condition as a part of requiremnt no :REQ-1444
                            if ( newCase.OwnerId != oldCase.OwnerId ) {

                                if (Restricted_SG_Profiles.containskey(loggedinUser.profile.name) || (!Restricted_SG_Profiles.containskey(loggedinUser.profile.name) &&  newCase.OwnerId != UserInfo.getUserId() && UserManagerMAp.get(newCase.OwnerId) != UserInfo.getUserId()  ) && newCase.recordtype.DeveloperName == Label.Small_Group_Case_Recordtype ) {
                                    newCase.addError( Label.Owner_Edit_Not_Allowed );
                                }
                            } else if ( newCase.Assigned_To__c != oldCase.Assigned_To__c && !CaseTriggerHandler.isSuperUser() ) {
                                newCase.addError( Label.Assigned_To_Edit_Not_Allowed );
                            }
                        }
                    }
                }
            }
        } catch ( Exception e ) {
            System.debug( 'Exception : ' + e.getMessage() );
        }
    }

    /*  updateCaseOwnerByQueue
    *   @description:   This method updates the assigned to and owner id of a record when a case is being assigned to partner queues.
                        This method is used for the before insert scenario.
    *   @parameters     List<Case> newCases : Cases under current context.
    *   @return type    void
    */
    public static void updateCaseOwnerByQueue( List<Case> newCases ) {
        try {
            Set<Id> smallGroupCaseRecordTypeIds = ConstantsController.populateSmallGroupCaseRecordTypeIds();
            Map<String, Id> QueueNameAndIdMap = new Map<String, Id>();
            Map<String, String> AssignedPartnerAndQueueNameMap = new Map<String, String>();
            List<Case_Partner_Queues__c> listPartnerQueues = Case_Partner_Queues__c.getAll().values();
            //Get all the queues
            /*for(Group GroupObj : [SELECT Id, Name FROM Group where Type = 'Queue' limit   :Limits.getLimitQueryRows() - Limits.getQueryRows() ]){
                QueueNameAndIdMap.put(GroupObj.Name, GroupObj.Id);
            }*/
            for (Group GroupObj : ConstantsController.groups) {
                QueueNameAndIdMap.put(GroupObj.Name, GroupObj.Id);
            }
            //Get all the applicable queues from custom setting
            for ( Case_Partner_Queues__c casePartnerQueueObj : listPartnerQueues ) {
                AssignedPartnerAndQueueNameMap.put(casePartnerQueueObj.Assigned_Partner__c, casePartnerQueueObj.Queue__c);
            }
            if ( !AssignedPartnerAndQueueNameMap.isEmpty() && !QueueNameAndIdMap.isEmpty() ) {
                for (Case caseObj : newCases) {
                    //if the case is assigned to a partner at the time of case creation
                    if ( smallGroupCaseRecordTypeIds.contains( caseObj.RecordTypeId )
                            && caseObj.Assigned_Partner__c != null &&
                            AssignedPartnerAndQueueNameMap.containsKey(caseObj.Assigned_Partner__c) &&
                            AssignedPartnerAndQueueNameMap.get(caseObj.Assigned_Partner__c) != null) {

                        String queueName = AssignedPartnerAndQueueNameMap.get(caseObj.Assigned_Partner__c);
                        if (QueueNameAndIdMap.containsKey(queueName)) {
                            /*//if the original owner is a queue, update the "Assigned To" to the current user
                            if( caseObj.Assigned_To__c == null && Schema.Group.SObjectType == caseObj.OwnerId.getSobjectType() ) {
                                caseObj.Assigned_To__c = UserInfo.getUserId();
                            }
                            //if the original owner is a user, update the "Assigned To" to that user
                            else if( caseObj.Assigned_To__c == null && Schema.User.SObjectType == caseObj.OwnerId.getSobjectType() ) {
                                caseObj.Assigned_To__c = caseObj.OwnerId;
                            }*/
                            caseObj.OwnerId = QueueNameAndIdMap.get(queueName);
                            isUpdateFromCode = true;
                        }
                    }
                }
            }
        } catch ( Exception e ) {
            System.debug( 'Exception : ' + e.getMessage() );
        }
    }

    /*  updateCaseOwnerByQueue
    *   @description:   This method updates the assigned to and owner id of a record when a case is being assigned to partner queues.
                        This method is used for the before update scenario.
    *   @parameters     List<Case> oldCases : Old values of the cases under context.
    *   @parameters     List<Case> newCases : Cases under current context.
                        List<Case> oldCases : Old values of the cases under context.
    *   @return type    void
    */
    public static void updateCaseOwnerByQueue( List<Case> newCases, List<Case> oldCases ) {
        try {
            Set<Id> smallGroupCaseRecordTypeIds = ConstantsController.populateSmallGroupCaseRecordTypeIds();

            Map<String, Id> QueueNameAndIdMap = new Map<String, Id>();
            Map<String, String> AssignedPartnerAndQueueNameMap = new Map<String, String>();
            List<Case_Partner_Queues__c> listPartnerQueues = Case_Partner_Queues__c.getAll().values();
            //Get all the queues
            /*for(Group GroupObj : [SELECT Id, Name FROM Group where Type = 'Queue' limit   :Limits.getLimitQueryRows() - Limits.getQueryRows() ]){
                QueueNameAndIdMap.put(GroupObj.Name, GroupObj.Id);
            }*/
            for (Group GroupObj : ConstantsController.groups) {
                QueueNameAndIdMap.put(GroupObj.Name, GroupObj.Id);
            }
            //Get all the applicable queues from custom setting
            for ( Case_Partner_Queues__c casePartnerQueueObj : listPartnerQueues ) {
                AssignedPartnerAndQueueNameMap.put(casePartnerQueueObj.Assigned_Partner__c, casePartnerQueueObj.Queue__c);
            }
            if ( !AssignedPartnerAndQueueNameMap.isEmpty() && !QueueNameAndIdMap.isEmpty() ) {
                Case newCase;
                Case oldCase;
                for (Integer index = 0; index < newCases.size(); index++ ) {
                    newCase = newCases[index];
                    oldCase = oldCases[index];
                    System.debug( ' smallGroupCaseRecordTypeIds==' + smallGroupCaseRecordTypeIds.contains( newCase.RecordTypeId ) );
                    if ( smallGroupCaseRecordTypeIds.contains( newCase.RecordTypeId ) ) {
                        //if the case is assigned to a partner or a partner is changed
                        if ( newCase.Assigned_Partner__c != null &&
                                newCase.Assigned_Partner__c != oldCase.Assigned_Partner__c &&
                                AssignedPartnerAndQueueNameMap.containsKey(newCase.Assigned_Partner__c) &&
                                AssignedPartnerAndQueueNameMap.get(newCase.Assigned_Partner__c) != null) {

                            String queueName = AssignedPartnerAndQueueNameMap.get(newCase.Assigned_Partner__c);
                            if (QueueNameAndIdMap.containsKey(queueName)) {
                                /*//if the original owner is a queue, update the "Assigned To" to the current user
                                if(  newCase.Assigned_To__c == null && Schema.Group.SObjectType == newCase.OwnerId.getSobjectType() ) {
                                    newCase.Assigned_To__c = UserInfo.getUserId();
                                }
                                //if the original owner is a user, update the "Assigned To" to that user
                                else if(  newCase.Assigned_To__c == null && Schema.User.SObjectType == newCase.OwnerId.getSobjectType() ) {
                                    newCase.Assigned_To__c = newCase.OwnerId;
                                }*/
                                newCase.OwnerId = QueueNameAndIdMap.get(queueName);
                                isUpdateFromCode = true;
                            }
                        }
                        //If the case is taken back from the partner, change owner to the Assigned To user.
                        else if ( newCase.Assigned_Partner__c != oldCase.Assigned_Partner__c &&
                                  newCase.Assigned_Partner__c == null ) {
                            if ( newCase.Assigned_To__c != null ) {
                                newCase.OwnerId = newCase.Assigned_To__c;
                                isUpdateFromCode = true;
                            } else if ( newCase.Assigned_To__c == null ) {
                                newCase.OwnerId = UserInfo.getUserId();
                                isUpdateFromCode = true;
                            }
                        }
                    }
                }
            }
        } catch ( Exception e ) {
            System.debug( 'Exception : ' + e.getMessage() );
        }
    }

    /*  manageCaseAccountLookups
    *   @description:   This method updates the account lookups on case object based on the various conditions.
                        Account Name and Producer Account lookups are filled in based on the contact type.
    *   @parameters     List<Case> oldCases : Old values of the cases under context.
    *   @parameters     List<Case> newCases : Cases under current context.
    *   @return type    void
    */
    public static void manageCaseAccountLookups( List<Case> newCases ) {
        try {
            Set<Id> contactIds = new Set<Id>();
            Set<Id> accountIds = new Set<Id>();

            for ( Case caseRec : newCases ) {
                contactIds.add( caseRec.ContactId );
                accountIds.add( caseRec.AccountId );
                accountIds.add( caseRec.Producer_Account__c );
            }

            Map<Id, Contact> contacts = new Map<Id, Contact>(
                [   select  Id, AccountId
                    from    Contact
                    where   Id IN :contactIds
                    limit   :Limits.getLimitQueryRows() - Limits.getQueryRows() ]
            );

            for ( Contact contactRec : contacts.values() ) {
                accountIds.add( contactRec.AccountId );
            }

            Map<Id, Account> accounts = new Map<Id, Account>(
                [   select  Id, RecordType.Name
                    from    Account
                    where   Id IN :accountIds
                    limit   :Limits.getLimitQueryRows() - Limits.getQueryRows() ]
            );

            Account accountRec;
            Account contactsAccount;
            for ( Case caseRec : newCases ) {

                //If both account lookups are blank
                if ( String.isBlank( caseRec.AccountId ) && String.isBlank( caseRec.Producer_Account__c ) ) {
                    if (     String.isNotBlank( caseRec.ContactId )
                             &&  contacts.containsKey( caseRec.ContactId )
                             &&  accounts.containsKey( contacts.get( caseRec.ContactId ).AccountId ) ) {

                        accountRec = accounts.get( contacts.get( caseRec.ContactId ).AccountId );

                        if ( accountRec.RecordType.Name == Label.Producer_Account ) {
                            caseRec.AccountId           = Id.valueOf(System.Label.Default_Account);
                            caseRec.Producer_Account__c = accountRec.Id;
                        } else if ( accountRec.RecordType.Name == Label.Group_Account ) {
                            caseRec.AccountId           = accountRec.Id;
                            caseRec.Producer_Account__c = null;
                        }
                    }
                }

                //if account name on case is filled in and producer acc is blank
                if ( String.isNotBlank( caseRec.AccountId ) && String.isBlank( caseRec.Producer_Account__c ) ) {
                    if ( accounts.containsKey( caseRec.AccountId ) ) {

                        accountRec = accounts.get( caseRec.AccountId );

                        if ( accountRec.RecordType.Name == Label.Producer_Account ) {
                            caseRec.AccountId           = Id.valueOf(System.Label.Default_Account);
                            caseRec.Producer_Account__c = accountRec.Id;
                        } else if ( accountRec.RecordType.Name == Label.Group_Account ) {
                            caseRec.AccountId           = accountRec.Id;

                            if (     String.isNotBlank( caseRec.ContactId )
                                     &&  contacts.containsKey( caseRec.ContactId )
                                     &&  accounts.containsKey( contacts.get( caseRec.ContactId ).AccountId ) ) {

                                contactsAccount = accounts.get( contacts.get( caseRec.ContactId ).AccountId );

                                if ( contactsAccount.Id != accountRec.Id && contactsAccount.RecordType.Name == Label.Producer_Account ) {
                                    caseRec.Producer_Account__c = contactsAccount.Id;
                                }
                            }
                        }
                    }
                }

                //if account name is blank and producer name is filled
                if ( String.isBlank( caseRec.AccountId ) && String.isNotBlank( caseRec.Producer_Account__c ) ) {
                    if ( accounts.containsKey( caseRec.Producer_Account__c ) ) {

                        accountRec = accounts.get( caseRec.Producer_Account__c );

                        if ( accountRec.RecordType.Name == Label.Producer_Account ) {
                            if (     String.isNotBlank( caseRec.ContactId )
                                     &&  contacts.containsKey( caseRec.ContactId )
                                     &&  accounts.containsKey( contacts.get( caseRec.ContactId ).AccountId ) ) {

                                contactsAccount = accounts.get( contacts.get( caseRec.ContactId ).AccountId );

                                if ( contactsAccount.Id != accountRec.Id && contactsAccount.RecordType.Name == Label.Group_Account ) {
                                    caseRec.AccountId           = contactsAccount.Id;
                                } else {
                                    caseRec.AccountId           = Id.valueOf(System.Label.Default_Account);
                                }
                            }

                        } else if ( accountRec.RecordType.Name == Label.Group_Account ) {
                            caseRec.AccountId           = accountRec.Id;
                            caseRec.Producer_Account__c = null;
                        }
                    }
                }

                //If both account lookups are not blank
                if ( String.isNotBlank( caseRec.AccountId ) && String.isNotBlank( caseRec.Producer_Account__c ) ) {
                    if (     String.isNotBlank( caseRec.ContactId )
                             &&  contacts.containsKey( caseRec.ContactId )
                             &&  accounts.containsKey( contacts.get( caseRec.ContactId ).AccountId ) ) {

                        contactsAccount = accounts.get( contacts.get( caseRec.ContactId ).AccountId );

                        if ( contactsAccount.RecordType.Name == Label.Producer_Account ) {
                            caseRec.Producer_Account__c = contactsAccount.Id;
                        } else if ( contactsAccount.RecordType.Name == Label.Group_Account ) {
                            caseRec.AccountId           = contactsAccount.Id;
                        }
                    }

                    //Validate record types
                    if ( accounts.containsKey( caseRec.Producer_Account__c ) ) {
                        accountRec = accounts.get( caseRec.Producer_Account__c );
                        if ( accountRec.RecordType.Name == Label.Group_Account ) {
                            caseRec.Producer_Account__c           = null;
                        }
                    }

                    if ( accounts.containsKey( caseRec.AccountId ) ) {
                        accountRec = accounts.get( caseRec.AccountId );
                        if ( accountRec.RecordType.Name == Label.Producer_Account ) {
                            caseRec.AccountId           = Id.valueOf(System.Label.Default_Account);
                        }
                    }
                }
            }
        } catch ( Exception e ) {
            System.debug( 'Exception : ' + e.getMessage() );
        }
    }



    /*  updateCaseOwnerByEmail
    *   @description:   This method changes the Case Owner by Queue based on Initial Email Address
                        This method is used for the before insert scenario.
    *   @parameters     List<Case> newCases : Cases under current context.
    *   @return type    void
    */
    public static void updateCaseOwnerByEmail(List<Case> newCases, map<Id, Case> oldCaseMap) {
        try {
            Map<String, String> emailAndQueueMap = new Map<String, String>();
            Map<String, Id> groupNameAndId = new Map<String, Id>();
            Map<String, String>emailAndStateMap = new Map<String, String>();

            Map<String, Email_To_Case_Queues__c> emailToCaseQueuesMap = Email_To_Case_Queues__c.getAll();

            for (Email_To_Case_Queues__c emailToCaseQueueObj : emailToCaseQueuesMap.values()) {
                emailAndQueueMap.put(emailToCaseQueueObj.Email__c, emailToCaseQueueObj.Queue_Name__c);
                emailAndStateMap.put(emailToCaseQueueObj.Email__c, emailToCaseQueueObj.State__c);
            }
            for (Group groupObj : [SELECT Id, Name FROM Group WHERE Name IN:emailAndQueueMap.values() limit   :Limits.getLimitQueryRows() - Limits.getQueryRows() ]) {
                groupNameAndId.put(groupObj.Name, groupObj.Id);
            }
            for (Case caseObj : newCases) {
                if (caseObj.Initial_Email_To_Address__c != null && caseObj.Initial_Email_To_Address__c != '') {
                    if (oldCaseMap.containsKey(caseObj.Id) && caseObj.Initial_Email_To_Address__c != oldCaseMap.get(caseObj.Id).Initial_Email_To_Address__c) {

                        if (!emailAndQueueMap.isEmpty() && !groupNameAndId.isEmpty()) {
                            for ( String emailAddress : emailAndQueueMap.keySet() ) {
                                if ( caseObj.Initial_Email_To_Address__c.contains( emailAddress ) ) {
                                    String queueName = emailAndQueueMap.get(emailAddress);
                                    if (groupNameAndId.containsKey(queueName) && groupNameAndId.get(queueName) != null) {
                                        caseObj.OwnerId = groupNameAndId.get(queueName);
                                        caseObj.Plan_State__c = emailAndStateMap.get(emailAddress);
                                        isUpdateFromCode = true;
                                    }
                                }
                            }
                        }
                    }
                }
            }
        } catch ( Exception e ) {
            System.debug( 'Exception : ' + e.getMessage() );
        }
    }

    /*  createCaseOwnershipTrackingRecord
    *   @description:   This method creates case ownership tracking records for Case object. This method is used in after insert trigger.
    *   @parameters     List<Case> newCases : Cases under current context.
    *   @return type    void
    */
    public static void createCaseOwnershipTrackingRecord( List<Case> newCases ) {
        try {
            Map<Id, String> queueIdAndNameMap = new Map<Id, String>();
            //Get all the queues
            /*for(Group GroupObj : [  SELECT  Id, Name
                                    FROM    Group
                                    where   Type = 'Queue'
                                    limit   :Limits.getLimitQueryRows() - Limits.getQueryRows() ]){
                queueIdAndNameMap.put( GroupObj.Id, GroupObj.Name );
            } */
            for (Group GroupObj : ConstantsController.groups) {
                queueIdAndNameMap.put( GroupObj.Id, GroupObj.Name );
            }

            List<Case_Ownership_Tracking__c> ownershipTrackings = new List<Case_Ownership_Tracking__c>();
            set<String> allowedRecordTypeNames = new set<String>();
            for (CaseOwnerShip_Record_Creation_Settings__c crc : CaseOwnerShip_Record_Creation_Settings__c.getAll().values()) {
                if (crc.Create_CaseOwnership_Record__c)
                    allowedRecordTypeNames.add(crc.Name);
            }
            for ( Case caseRec : [select Id, status, OwnerId, Owner.UserRole.Name, RecordType.DeveloperName, Owner.Profile.Name from Case where Id In :newCases ] ) {
                Case_Ownership_Tracking__c cot = new Case_Ownership_Tracking__c();
                cot.Case__c     = caseRec.Id;
                cot.Start__c    = System.now();
                if (allowedRecordTypeNames.contains(caseRec.RecordType.DeveloperName))
                    cot.Case_Status__c = caseRec.Status;
                //if the original owner is a queue, update the "Queue" field
                if ( Schema.Group.SObjectType == caseRec.OwnerId.getSobjectType() ) {
                    cot.Queue__c = queueIdAndNameMap.get( caseRec.OwnerId );
                }
                //if the original owner is a user, update the "User" field
                else if ( Schema.User.SObjectType == caseRec.OwnerId.getSobjectType() ) {
                    cot.User__c = caseRec.OwnerId;
                    if (allowedRecordTypeNames.contains(caseRec.RecordType.DeveloperName)) {
                        cot.User_Role__c = caseRec.Owner.UserRole.Name;
                        cot.User_Profile__c = caseRec.Owner.Profile.Name;
                    }
                }
                ownershipTrackings.add( cot );
            }
            if ( ownershipTrackings.size() > 0 ) {
                insert ownershipTrackings;
            }
        } catch ( Exception e ) {
            System.debug( 'Exception : ' + e.getMessage() );
        }
    }

    /*  createCaseOwnershipTrackingRecord
    *   @description:   This method creates case ownership tracking records for Case object. This method also updates end time in previous case ownership record.
    *                   This method is used in after update trigger.
    *   @parameters     List<Case> newCases : Cases under current context.
    *   @return type    void
    */
    public static void createCaseOwnershipTrackingRecord( List<Case> newCases, List<Case> oldCases ) {
        try {
            Map<Id, String> queueIdAndNameMap = new Map<Id, String>();
            //Get all the queues
            /*for(Group GroupObj : [  SELECT  Id, Name
                                    FROM    Group
                                    where   Type = 'Queue'
                                    limit   :Limits.getLimitQueryRows() - Limits.getQueryRows() ]){
                queueIdAndNameMap.put( GroupObj.Id, GroupObj.Name );
            }*/
            for (Group GroupObj : ConstantsController.groups) {
                queueIdAndNameMap.put( GroupObj.Id, GroupObj.Name );
            }
            Integer workingHours;
            /*BusinessHours defaultBusinessHours = [    SELECT  IsActive, Id
                                                FROM    BusinessHours
                                                where   IsActive= true
                                                    and IsDefault = true
                                                limit   1 ];    */
            BusinessHours defaultBusinessHours = ConstantsController.defaultBusinessHours;
            /*List<LGNA_Constants__c> lgnaConstants = [ select  Total_Working_Hours_per_Day__c
                                                        from    LGNA_Constants__c
                                                        limit   1 ];
            if( lgnaConstants.size() > 0 ) {
                workingHours = ( Integer )lgnaConstants[0].Total_Working_Hours_per_Day__c;
            }
            else {
                workingHours = 9;
            }*/
            for (LGNA_Constants__c temp : LGNA_Constants__c.getAll().values()) {
                if (temp.name == 'Default') {
                    workingHours = ( Integer )temp.Total_Working_Hours_per_Day__c;
                }
            }
            if (workingHours == null)
                workingHours = 9;
            List<Case_Ownership_Tracking__c> ownershipTrackings = new List<Case_Ownership_Tracking__c>();
            Case newCase;
            Case oldCase;
            Set<Id> caseIdsUnderContext = new Set<Id>();
            set<String> allowedRecordTypeNames = new set<String>();
            set<String> allowedRecordTypeIds    = new set<String>();
            for (CaseOwnerShip_Record_Creation_Settings__c crc : CaseOwnerShip_Record_Creation_Settings__c.getAll().values()) {
                if (crc.Create_CaseOwnership_Record__c)
                    allowedRecordTypeNames.add(crc.Name);
            }
            for (RecordType rt : [select Id from RecordType where DeveloperName In :allowedRecordTypeNames and SobjectType = 'Case']) {
                allowedRecordTypeIds.add(rt.Id);
            }
            for ( Integer index = 0; index < newCases.size(); index++ ) {
                if ( ( newCases[index].OwnerId != oldCases[index].OwnerId )
                        || ( newCases[index].IsClosed != oldCases[index].IsClosed )) {

                    caseIdsUnderContext.add( newCases[index].Id );
                } else if (allowedRecordTypeIds.contains(newCases[index].RecordTypeId) && newCases[index].Status != oldCases[index].Status) {
                    caseIdsUnderContext.add( newCases[index].Id );
                }
            }

            List<Case> casesUnderContext = [    select  Id, Subject, Status, RecordTypeId, IsClosed, OwnerId, Owner.UserRole.Name, Owner.Profile.Name,
                                                (select  Id, Start__c, End__c, Case__r.Id from Case_Ownership_Tracking__r where   End__c = null order by CreatedDate DESC )
                                                from    Case
                                                where   Id IN :caseIdsUnderContext
                                                limit   :Limits.getLimitQueryRows() - Limits.getQueryRows()  ];

            /* Map<Id, List<Case_Ownership_Tracking__c>> caseToOwnershipTrackingRecords = new Map<Id, List<Case_Ownership_Tracking__c>>();

             for( Case_Ownership_Tracking__c ownershipTracking :[    select  Id, End__c, Case__r.Id
                                                                     from    Case_Ownership_Tracking__c
                                                                     where   End__c = null
                                                                     order by CreatedDate DESC
                                                                     limit   :Limits.getLimitQueryRows() - Limits.getQueryRows() ])
             {
                 if( !caseToOwnershipTrackingRecords.containsKey( ownershipTracking.Case__r.Id ) ) {
                      caseToOwnershipTrackingRecords.put( ownershipTracking.Case__r.Id, new List<Case_Ownership_Tracking__c>() );
                 }
                 caseToOwnershipTrackingRecords.get( ownershipTracking.Case__r.Id ).add( ownershipTracking );
             }*/

            List<Case_Ownership_Tracking__c> caseOwnershipTrackings = new List<Case_Ownership_Tracking__c>();

            for ( Case caseRec : casesUnderContext ) {
                /* if( caseToOwnershipTrackingRecords.containsKey( caseRec.Id )  ) {

                     caseOwnershipTrackings =  caseToOwnershipTrackingRecords.get( caseRec.Id ) ;

                     if( caseOwnershipTrackings != null && caseOwnershipTrackings.size() > 0 ) {
                         for( Case_Ownership_Tracking__c cot : caseOwnershipTrackings ) {
                             cot.End__c = System.now();
                             ownershipTrackings.add( cot );
                         }
                     }
                 }*/
                for (Case_Ownership_Tracking__c cot : caseRec.Case_Ownership_Tracking__r) {
                    cot.End__c = System.now();

                    ownershipTrackings.add( cot );
                }

                if ( !caseRec.IsClosed ) {
                    Case_Ownership_Tracking__c cot = new Case_Ownership_Tracking__c();
                    cot.Case__c     = caseRec.Id;
                    cot.Start__c    = System.now();
                    if (allowedRecordTypeIds.contains(caseRec.RecordTypeId))
                        cot.Case_Status__c = caseRec.Status;
                    //if the original owner is a queue, update the "Queue" field
                    if ( Schema.Group.SObjectType == caseRec.OwnerId.getSobjectType() ) {
                        cot.Queue__c = queueIdAndNameMap.get( caseRec.OwnerId );
                    }
                    //if the original owner is a user, update the "User" field
                    else if ( Schema.User.SObjectType == caseRec.OwnerId.getSobjectType() ) {
                        cot.User__c = caseRec.OwnerId;
                        if (allowedRecordTypeIds.contains(caseRec.RecordTypeId)) {
                            cot.User_Role__c = caseRec.Owner.UserRole.Name;
                            cot.User_Profile__c = caseRec.Owner.Profile.Name;
                        }
                    }
                    ownershipTrackings.add( cot );
                }
            }

            if ( ownershipTrackings.size() > 0 && ConstantsController.shouldContinueWithOwnerCreation) {
                ConstantsController.shouldContinueWithOwnerCreation = false;
                upsert ownershipTrackings;
            }
        } catch ( Exception e ) {
            System.debug( 'Exception : ' + e.getMessage() );
        }
    }

    /*  updateAssignedToOnCase
    *   @description:   This method updates the assigned to of a record when a case is being taken from Case Queues Page.
    *                    This method is used for the before update scenario.
    *   @parameters     List<Case> newCases : Cases under current context.
    *                    List<Case> oldCases : Old values of the cases under context.
    *   @return type    void
    */
    public static void updateAssignedToOnCase( List<Case> newCases, List<Case> oldCases ) {
        try {
            Case newCase;
            Case oldCase;
            Map<String, Boolean> QueueNameAndUpdateMap = new Map<String, Boolean>();
            Set<String> QueueNames = new Set<String>();
            Map<Id, String> QueueNameAndIdMap = new Map<Id, String>();

            List<Queue_Names__c> listOfQueueNames = Queue_Names__c.getAll().values();
            for ( Queue_Names__c queueNameObj : listOfQueueNames ) {
                QueueNameAndUpdateMap.put( queueNameObj.Name, queueNameObj.Update__c );
                QueueNames.add( queueNameObj.Name );
            }
            for ( Group groupObj : [ SELECT Id, Name FROM Group WHERE Name IN :QueueNames limit :Limits.getLimitQueryRows() - Limits.getQueryRows() ] ) {
                QueueNameAndIdMap.put( groupObj.Id, groupObj.Name );
            }

            for ( Integer index = 0; index < newCases.size(); index++ ) {
                newCase = newCases[ index ];
                oldCase = oldCases[ index ];
                //if the case is assigned to a partner or a partner is changed
                if ( newCase.OwnerId != oldCase.OwnerId ) {

                    //if the Old owner is a queue and the new Owner is a user then update the "Assigned To" to the new owner
                    if ( Schema.Group.SObjectType == oldCase.OwnerId.getSobjectType() && Schema.User.SObjectType == newCase.OwnerId.getSobjectType() ) {
                        if ( QueueNameAndIdMap.containsKey( oldCase.OwnerId ) ) {
                            if (  QueueNameAndUpdateMap.containsKey( QueueNameAndIdMap.get( oldCase.OwnerId ) ) && QueueNameAndUpdateMap.get( QueueNameAndIdMap.get( oldCase.OwnerId ) ) )

                                newCase.Assigned_To__c = newCase.OwnerId;
                        }
                        /*else if( newCase.Assigned_To__c == null ) {
                            newCase.Assigned_To__c = UserInfo.getUserId();
                        }*/
                    }
                    /*
                    //if assigned to is null AND
                    //if the Old owner is a user and the new Owner is a user OR
                    //if the Old owner is a user and the new Owner is a queue
                    // then update the "Assigned To" to the old owner
                    else if(    newCase.Assigned_To__c == null
                                && ( ( Schema.User.SObjectType == oldCase.OwnerId.getSobjectType() && Schema.User.SObjectType == newCase.OwnerId.getSobjectType() )
                                || ( Schema.User.SObjectType == oldCase.OwnerId.getSobjectType() && Schema.Group.SObjectType == newCase.OwnerId.getSobjectType() &&  newCase.SuppliedEmail == null  ) ) ) {

                        newCase.Assigned_To__c = oldCase.OwnerId;
                    }

                    //if assigned to is null AND
                    //if the Old owner is a queue and the new Owner is also a queue then update the "Assigned To" to the current user
                    else if(    newCase.Assigned_To__c == null
                                && Schema.Group.SObjectType == oldCase.OwnerId.getSobjectType() && Schema.Group.SObjectType == newCase.OwnerId.getSobjectType() ) {

                        newCase.Assigned_To__c = UserInfo.getUserId();
                    }*/
                }
            }
        } catch ( Exception e ) {
            System.debug( 'Exception : ' + e.getMessage() );
        }
    }
    /*  updateAssignedToOnCase
    *   @description:   This method updates the assigned to of a record when a case is being manually created.
                        This method is used for the before insert scenario.
    *   @parameters     List<Case> newCases : Cases under current context.

    *   @return type    void
    */
    public static void updateAssignedToOnCase(List<Case> newCases) {
        try {
            Case newCase;
            for ( Integer index = 0; index < newCases.size(); index++ ) {
                newCase = newCases[index];
                //in email to case scenario, do not update the assigned to
                if ( newCase.SuppliedEmail == null && newCase.Origin != 'Email' ) {
                    //if new case owner is a user
                    if ( Schema.User.SObjectType == newCase.OwnerId.getSobjectType() ) {
                        newCase.Assigned_To__c = newCase.OwnerId;
                    }

                }
            }
        } catch ( Exception e ) {
            System.debug( 'Exception : ' + e.getMessage() );
        }
    }

    /*  updateAssignedToOnCase
    *   @description:   This method carry overs Account Number Esales from Case to its associated Account
                        This method is used for the after insert/update scenario.
    *   @parameters     Map<Id,Case> CaseNewMap : Cases new Map Map<Id,Case> CaseOldMap : Cases old map

    *   @return type    void
    */
    public static void updateAccountNumberEsales(Map<Id, Case> CaseNewMap, Map<Id, Case> CaseOldMap) {
        try {
            Id CaseRecordTypeMidMarket = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Mid-Market Underwriting').getRecordTypeId();
            Set<Id> AccountIdSet = new Set<Id>();
            List<Case> CaseList = new List<Case>();
            List<Account> AccountUpdateList = new List<Account>();
            for (Case cs : CaseNewMap.values()) {
                if (cs.RecordTypeId == CaseRecordTypeMidMarket && cs.Account_Number_eSales__c != null && cs.Account_Number_eSales__c != CaseOldMap.get(cs.Id).Account_Number_eSales__c) {
                    AccountIdSet.add(cs.AccountId);
                    CaseList.add(cs);
                }
            }
            Map<Id, Account> AccountMap = new Map<Id, Account>([SELECT Id, External_ID__c FROM Account where Id IN: AccountIdSet limit :Limits.getLimitQueryRows() - Limits.getQueryRows()]);
            for (Case cs : CaseList) {
                if (AccountMap.get(cs.AccountId).External_ID__c == null) {
                    AccountMap.get(cs.AccountId).External_ID__c = cs.Account_Number_eSales__c;
                    AccountUpdateList.add(AccountMap.get(cs.AccountId));
                }
            }
            if (AccountUpdateList.size() > 0) {
                update AccountUpdateList;
            }
        } catch (Exception ex) {
            system.debug('##### ERROR: ' + ex.getMessage() + ' ' + ex.getStackTraceString());
        }
    }

    /*  updateCustomContractFields
    *   @description:   Fill in the Account Executive, Account Executive Phone, Requestor, Requestor Number,
                        and State fields based on the Parent Account and Case creator information

    *   @parameters     List<Case> newCases : Cases under current context.

    *   @return type    void
    */
    public static void updateCustomContractFields(List<Case> newCases) {
        try {
            List<Case> customContracts = new List<Case>();
            Set<Id> customContractsAccIds = new Set<Id>();
            for (Case curCase : newCases) {
                if (curCase.RecordTypeId == Schema.SObjectType.Case.getRecordTypeInfosByName().get('Custom Contracts').getRecordTypeId()) {
                    customContracts.add(curCase);
                    if (curCase.AccountId != NULL) {
                        customContractsAccIds.add(curCase.AccountId);
                    }
                }
            }

            List<Account> customContractAccs = [SELECT Id, Name, OwnerId, HCSC_Division__c FROM Account WHERE Id IN:customContractsAccIds];
            Map<Id, Account> customContractAccsMap = new Map<Id, Account>();
            for (Account acc : customContractAccs) {
                customContractAccsMap.put(acc.Id, acc);
            }

            Set<Id> accOwnerIds = new Set<Id>();
            for (Account acc : customContractAccs) {
                accOwnerIds.add(acc.OwnerId);
            }
            List<User> customContractAccExec = [SELECT Id, Phone FROM User WHERE Id IN:accOwnerIds];
            Map<Id, User> accExec = new Map<Id, User>();
            for (User person : customContractAccExec) {
                accExec.put(person.Id, person);
            }

            /*Set<Id> createdByIds = new Set<Id>();
            for (Case curCase : customContracts) {
                createdByIds.add(curCase.CreatedById);
            }
            List<User> customContractRequestor = [SELECT Id, Phone FROM User WHERE Id IN:createdByIds];
            Map<Id, User> requestor = new Map<Id, User>();
            for (User person : customContractRequestor) {
                requestor.put(person.Id, person);
            } */

            User curUser = [SELECT Id, Phone FROM User WHERE Id = :UserInfo.getUserId()];

            for (Case curCase : newCases) {
                if (curCase.RecordTypeId == Schema.SObjectType.Case.getRecordTypeInfosByName().get('Custom Contracts').getRecordTypeId()) {
                    curCase.Requestor_Name__c = UserInfo.getUserId();
                    curCase.Requestor_Phone__c = curUser.Phone;
                    if (curCase.AccountId != NULL) {
                        Id curOwnerId = (customContractAccsMap.get(curCase.AccountId)).OwnerId;
                        curCase.Account_Executive__c = curOwnerId;
                        curCase.Account_Executive_Phone__c = (accExec.get(curOwnerId)).Phone;
                        curCase.State__c = (customContractAccsMap.get(curCase.AccountId)).HCSC_Division__c;
                    }
                }
            }
        } catch (Exception e) {
            System.debug('Exception : ' + e.getMessage());
        }
    }

    /*  clonePrivateExchangeRecords
    *   @description:   Creates Private Exchange Sub Cases

    *   @parameters     List<Case> updatedCases : Cases that were updated.
                        map<Id, Case> oldCaseMap : Contains the state of the Cases before updated

    *   @return type    void

	*	@author			Ralph Tariga/Slalom LLC
	*	@updated by		Alec Klein/Slalom LLc
    */
    public static void clonePrivateExchangeRecords(List<Case> updatedCases, map<Id, Case> oldCaseMap) {
        Map<Id, Schema.RecordTypeInfo> recTypeMap = Case.sObjectType.getDescribe().getRecordTypeInfosById();

        List<List<Case>> blueDirectionsCases = new List<List<Case>>();
        Schema.DescribeFieldResult exchangeLinesofBusiness = Case.Exchange_Lines_of_Business__c.getDescribe();
        List<Schema.PicklistEntry> exchangeLinesofBusinessChoices = exchangeLinesofBusiness.getPicklistValues();
        for (Integer i = 0; i < exchangeLinesofBusinessChoices.size(); i++) {
            blueDirectionsCases.add(new List<Case>());
        }

        List<List<Case>> externalCases = new List<List<Case>>();
        Schema.DescribeFieldResult exchangePlatform = Case.Group_Exchange_Platform__c.getDescribe();
        List<Schema.PicklistEntry> exchangePlatformChoices = exchangePlatform.getPicklistValues();
        for (Integer i = 0; i < exchangePlatformChoices.size(); i++) {
            externalCases.add(new List<Case>());
        }

        for (Case curCase : updatedCases) {
            if (curCase.Status == Label.CaseStatusInProgress && oldCaseMap.get(curCase.Id).Status == Label.CaseStatusNew && curCase.Exchange_Sub_Case__c != true) {
                String recTypeName = recTypeMap.get(curCase.recordTypeID).getName();
                if (recTypeMap.get(curCase.recordTypeID).getName().containsIgnoreCase(Label.CaseRecordTypePrivateExchangeBlueDirections)) {
                    for (Integer i = 0; i < exchangeLinesofBusinessChoices.size(); i++) {
                        if (curCase.Exchange_Lines_of_Business__c.contains(exchangeLinesofBusinessChoices[i].getValue())) {
                            blueDirectionsCases[i].add(curCase);
                        }
                    }
                } else if (recTypeMap.get(curCase.recordTypeID).getName().containsIgnoreCase(Label.CaseRecordTypePrivateExchangeExternal)) {
                    for (Integer i = 0; i < exchangePlatformChoices.size(); i++) {
                        if (curCase.Group_Exchange_Platform__c.contains(exchangePlatformChoices[i].getValue())) {
                            externalCases[i].add(curCase);
                        }
                    }
                }
            }
        }

        List<Case> masterList = new List<Case>();

        for (Integer i = 0; i < blueDirectionsCases.size(); i++) {
            if (blueDirectionsCases[i].size() > 0) {
                List<Case> blueDirectionsClones = new List<Case>();
                for (Case curCase : blueDirectionsCases[i]) {
                    Case cloneCase = curCase.clone(false, true);
                    cloneCase.ParentId = curCase.Id;
                    blueDirectionsClones.add(cloneCase);
                }
                for (Case curCase : blueDirectionsClones) {
                    curCase.Exchange_Lines_of_Business__c = exchangeLinesofBusinessChoices[i].getValue();
                    curCase.Exchange_Sub_Case__c = true;
                    curCase.Assigned_To__c = null;
                }
                masterList.addAll(blueDirectionsClones);
            }
        }

        for (Integer i = 0; i < externalCases.size(); i++) {
            if (externalCases[i].size() > 0) {
                List<Case> externalClones = new List<Case>();
                for (Case curCase : externalCases[i]) {
                    Case cloneCase = curCase.clone(false, true);
                    cloneCase.ParentId = curCase.Id;
                    externalClones.add(cloneCase);
                }
                for (Case curCase : externalClones) {
                    curCase.Group_Exchange_Platform__c = exchangePlatformChoices[i].getValue();
                    curCase.Exchange_Sub_Case__c = true;
                    curCase.Assigned_To__c = null;
                }
                masterList.addAll(externalClones);
            }
        }

        if (masterList.size() > 0) {
            insert masterList;
        }
    }

    /*  privateExchangeCheckSubCasesIfClosed
    *   @description:   Check if all the Sub Cases of a Parent Case are closed

    *   @parameters     List<Case> casesToUpdate      : Cases to be updated still containing original values.
                        map<Id, Case> updatedCasesMap : Contains the updated Case values

    *   @return type    void

	*	@author			Ralph Tariga/Slalom LLC
	*	@updated by		Alec Klein/Slalom LLc
    */
    public static void privateExchangeCheckSubCasesIfClosed(List<Case> casesToUpdate, map<Id, Case> newMap, map<Id, Case> oldMap) {
        List<Case> casesToCheck = new List<Case>();
        for (Case parent : casesToUpdate) {
            if (parent.Status == Label.CaseStatusClosed && oldMap.get(parent.Id).Status == Label.CaseStatusInProgress) {
                casesToCheck.add(parent);
            }
        }

        if (casesToCheck.size() > 0) {
            List<Case> curCases = [SELECT Id, Status, (SELECT Status FROM Cases) FROM Case WHERE Id IN :casesToCheck];
            for (Case curCase : curCases) {
                for (Case sub : curCase.Cases) {
                    if (sub.Status != Label.CaseStatusClosed) {
                        newMap.get(curCase.Id).addError(Label.CaseSubcaseErrorMsg1);
                        break;
                    }
                }
            }
        }
    }
    
    /*  updateTypeFieldOnCustomContract
	*	@developer:		Alec Klein/Slalom, LLC
	*	@date:			4/1/2016
    *   @description:   Fill the Type (Category) picklist with the selected value from the Type__c picklist
    *   @parameters     List<Case> newCases : Cases under current context.
    *   @return type    void
    */
	public static void updateTypeFieldOnCustomContract(List<Case> newCases){
        try{
            for(Case curCase : newCases){
                if (curCase.RecordTypeId == Schema.SObjectType.Case.getRecordTypeInfosByName().get('Custom Contracts').getRecordTypeId())
					curCase.Type = curCase.Type__c;
			}
        } catch(Exception e){
			System.debug('Exception : ' + e.getMessage());
		}
    }
}