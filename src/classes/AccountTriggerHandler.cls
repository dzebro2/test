/**************************************************************************************
  Apex Class Name     : AccountTriggerHandler
  Version             : 1.0
  Function            : This is a handler class for AccountTrigger. The methods in this class are used as utility methods for CaseTrigger
  Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------
*   Suyog Dongaonkar       11/20/2014                Original Version
*************************************************************************************/

public class AccountTriggerHandler {


    /**
	* @author Dan Zebrowski/Slalom
	* @description updates a Group Account's Region__c if it is blank 
	* @param newAccounts The new accounts to be updated
	*/
	public static void updateRegion( List<Account> newAccounts ){
		try {
            
			for ( Account acc : newAccounts ){
				if ( acc.RecordTypeId == Schema.SObjectType.Account.getRecordTypeInfosByName().get( Label.Group_Account ).getRecordTypeId()){
					
					if (acc.HCSC_Division__c != null && acc.Region__c == null){
						acc.Region__c = acc.HCSC_Division__c;
					}
				}
			}

        } catch ( Exception ex ) {
           
            CreateExceptionLog.insertErrorLog(ex, null, null, null, 'Apex Class', 'Account', 'AccountTrigger', 'AccountTriggerHandler.updateRegion()', 'High');
        }
	}


    /*  createProducerContact
    *   @description:   This method checks if the account record is of record type Producer Account and its type is Sub Producer. It inserts/updates the producer contact record
                        This method is used for the after insert scenario.
    *   @parameters     List<Account> newAccounts : accounts under current context.
    *   @return type    void
    */
    public static void createProducerContact( List<Account> newAccounts ) {
        try {
            Map<Id, Account> accountsUnderConsideration = new Map<Id, Account>();

            //check if the account record is of record type Producer Account and its type is Sub Producer.
            for ( Account acc : newAccounts ) {
                if ( acc.RecordTypeId == Schema.SObjectType.Account.getRecordTypeInfosByName().get( Label.Producer_Account ).getRecordTypeId()
                        && acc.Type == 'Sub Producer' ) {
                    accountsUnderConsideration.put( acc.Id, acc );
                }
            }

            //insert/update producer contact
            createContactRecords( accountsUnderConsideration );
        } catch ( Exception ex ) {
            for ( Account acc : newAccounts ) {
                acc.addError( Label.AnErrorHasOcurred + ' : ' + ex.getMessage() );
            }
            CreateExceptionLog.insertErrorLog(ex, null, null, null, 'Apex Class', 'Account', 'AccountTrigger', 'AccountTriggerHandler.createProducerContact()', 'High');
        }
    }

    /*  createProducerContact
    *   @description:   This method checks if the account record is of record type Producer Account and its type is Sub Producer. It inserts/updates the producer contact record
                        This method is used for the after updates scenario.
    *   @parameters     List<Account> newAccounts : new accounts under current context.
    *                   List<Account> oldAccounts : old accounts under current context.
    *   @return type    void
    */
    public static void createProducerContact( List<Account> oldAccounts, List<Account> newAccounts ) {
        try {
            Map<Id, Account> accountsUnderConsideration = new Map<Id, Account>();

            Account newAccount;
            Account oldAccount;
            for ( Integer index = 0; index < newAccounts.size(); index++ ) {

                newAccount = newAccounts[index];
                oldAccount = oldAccounts[index];

                //check if the account record is of record type Producer Account and its type is Sub Producer.
                //and if any of the fields has changed
                if ( newAccount.RecordTypeId == Schema.SObjectType.Account.getRecordTypeInfosByName().get( Label.Producer_Account ).getRecordTypeId()
                        && newAccount.Type == 'Sub Producer'
                        && ( newAccount.Name != oldAccount.Name
                             || newAccount.External_Id__c    != oldAccount.External_Id__c
                             || newAccount.Email__c          != oldAccount.Email__c
                             || newAccount.Phone             != oldAccount.Phone
                             || newAccount.Fax               != oldAccount.Fax
                             || newAccount.BillingStreet     != oldAccount.BillingStreet
                             || newAccount.BillingCity       != oldAccount.BillingCity
                             || newAccount.BillingState      != oldAccount.BillingState
                             || newAccount.BillingPostalCode != oldAccount.BillingPostalCode
                             || newAccount.BillingCountry    != oldAccount.BillingCountry ) ) {

                    accountsUnderConsideration.put( newAccount.Id, newAccount );
                }
            }

            //insert/update producer contact
            createContactRecords( accountsUnderConsideration );

        } catch ( Exception ex ) {
            for ( Account acc : newAccounts ) {
                acc.addError( Label.AnErrorHasOcurred + ' : ' + ex.getMessage() );
            }
            CreateExceptionLog.insertErrorLog(ex, null, null, null, 'Apex Class', 'Account', 'AccountTrigger', 'AccountTriggerHandler.createProducerContact()', 'High');
        }
    }

    /*  createContactRecords
    *   @description:   This method creates or updates producer contact record related to the accounts under context.
                        It assumes that only one contact record exist for an account.
    *   @parameters     List<Account> newAccounts : accounts under current context.
    *   @return type    void
    */
    static void createContactRecords( Map<Id, Account> accountsUnderConsideration ) {
        //Create a map of account id and its respective contact record
        Map<Id, Contact> accountIdToContact = new Map<Id, Contact>();
        try {
            for ( Contact con : [ select  FirstName, LastName, Email, AccountId
                                  from    Contact
                                  where   AccountId IN :accountsUnderConsideration.keySet()
                                  order by CreatedDate DESC
                                  limit   :Limits.getLimitQueryRows() - Limits.getQueryRows() ] ) {
                if ( !accountIdToContact.containsKey( con.AccountId ) ) {
                    accountIdToContact.put( con.AccountId, con );
                }
            }

            //for each account, get its contact record if it exist or create a new record
            List<Contact> newContacts = new List<Contact>();
            Contact newContact;
            Account currentAccount;
            for ( Id accId : accountsUnderConsideration.keySet() ) {
                currentAccount = accountsUnderConsideration.get( accId );

                if ( accountIdToContact.containsKey( accId ) ) {
                    newContact = accountIdToContact.get( accId );
                } else {
                    newContact = new Contact();
                }

                newContact.LastName             = currentAccount.Name;
                newContact.External_Id__c       = currentAccount.External_Id__c;

                newContact.Email                = currentAccount.Email__c;
                newContact.Phone                = currentAccount.Phone;
                newContact.Fax                  = currentAccount.Fax;

                newContact.MailingStreet        = currentAccount.BillingStreet;
                newContact.MailingCity          = currentAccount.BillingCity;
                newContact.MailingState         = currentAccount.BillingState;
                newContact.MailingPostalCode    = currentAccount.BillingPostalCode;
                newContact.MailingCountry       = currentAccount.BillingCountry;


                newContact.RecordTypeId         = Schema.SObjectType.Contact.getRecordTypeInfosByName().get( Label.Producer_Contact ).getRecordTypeId();
                newContact.Type__c              = 'Producer';
                newContact.AccountId            = accId;

                newContacts.add( newContact );
            }

            upsert newContacts;
        } catch (Exception ex) {
            CreateExceptionLog.insertErrorLog(ex, null, null, null, 'Apex Class', 'Account', 'AccountTrigger', 'AccountTriggerHandler.createProducerContact()', 'High');
        }
    }
    public static void createChatterPost(List<Account> listOfNewAccounts) {
        Map<Id, Account> mapOfIdAndAccount = new Map<Id, Account>();
        Map<Id, Set<Id>> mapOfAccountIdAndUserId = new Map<Id, Set<Id>>();
        ConnectApi.MessageBodyInput messageInput;
        ConnectApi.FeedItemInput input;
        ConnectApi.MentionSegmentInput mentionSegment;
        ConnectApi.TextSegmentInput textSegment;
        ConnectApi.BatchInput batchInput;
        List<ConnectApi.BatchInput> batchInputs = new List<ConnectApi.BatchInput>();
        try {
            for (Account accountObj : listOfNewAccounts) {
                if (accountObj.Current_Risk_Level__c == ConstantsController.Risk_level_4 || accountObj.Current_Risk_Level__c == ConstantsController.Risk_level_5) {
                    mapOfIdAndAccount.put(accountObj.Id, accountObj);
                }
            }
            for (AccountTeamMember accountTeamMemberObj : [SELECT Id, AccountId, UserId FROM AccountTeamMember WHERE AccountId IN:mapOfIdAndAccount.keySet() AND TeamMemberRole = 'Account Executive']) {
                if (!mapOfAccountIdAndUserId.containsKey(accountTeamMemberObj.AccountId)) {
                    Set<Id> userIds = new Set<Id>();
                    userIds.add(accountTeamMemberObj.UserId);
                    mapOfAccountIdAndUserId.put(accountTeamMemberObj.AccountId, userIds);
                } else {
                    mapOfAccountIdAndUserId.get(accountTeamMemberObj.AccountId).add(accountTeamMemberObj.UserId);
                }
            }
            if (!mapOfIdAndAccount.isEmpty() && !mapOfAccountIdAndUserId.isEmpty()) {
                for (Id accountId : mapOfIdAndAccount.keySet()) {
                    if (mapOfAccountIdAndUserId.containsKey(accountId)) {
                        messageInput = new ConnectApi.MessageBodyInput();
                        messageInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
                        for (Id userId : mapOfAccountIdAndUserId.get(accountId)) {
                            mentionSegment = new ConnectApi.MentionSegmentInput();
                            mentionSegment.Id = userId;
                            messageInput.messageSegments.add(mentionSegment);
                        }
                        textSegment = new ConnectApi.TextSegmentInput();
                        textSegment.text = ' ' + mapOfIdAndAccount.get(accountId).Name + ' risk level has increased to ' + mapOfIdAndAccount.get(accountId).Current_Risk_Level__c;
                        messageInput.messageSegments.add(textSegment);
                        input = new ConnectApi.FeedItemInput();
                        input.subjectId = accountId;
                        input.body = messageInput;
                        batchInput = new ConnectApi.BatchInput(input);
                        batchInputs.add(batchInput);
                    }
                }
            }
            if (!Test.isRunningTest() )
                ConnectApi.ChatterFeeds.postFeedElementBatch(Network.getNetworkId(), batchInputs);
        } catch (Exception ex) {
            CreateExceptionLog.insertErrorLog(ex, null, null, null, 'Apex Class', 'Account', 'AccountTrigger', 'AccountTriggerHandler.createChatterPost()', 'High');
        }
    }
    public static void createChatterPost(List<Account> listOfOldAccounts, List<Account> listOfNewAccounts) {
        Map<Id, Account> mapOfIdAndAccount = new Map<Id, Account>();
        Map<Id, Set<Id>> mapOfAccountIdAndUserId = new Map<Id, Set<Id>>();
        ConnectApi.MessageBodyInput messageInput;
        ConnectApi.FeedItemInput input;
        ConnectApi.MentionSegmentInput mentionSegment;
        ConnectApi.TextSegmentInput textSegment;
        ConnectApi.BatchInput batchInput;
        List<ConnectApi.BatchInput> batchInputs = new List<ConnectApi.BatchInput>();

        Account oldAccount;
        Account newAccount;
        try {
            for (Integer index = 0; index < listOfNewAccounts.size(); index++) {
                newAccount = listOfNewAccounts[index];
                oldAccount = listOfOldAccounts[index];
                if ((newAccount.Current_Risk_Level__c != oldAccount.Current_Risk_Level__c) && (newAccount.Current_Risk_Level__c == ConstantsController.Risk_level_4 || newAccount.Current_Risk_Level__c == ConstantsController.Risk_level_5)) {
                    mapOfIdAndAccount.put(newAccount.Id, newAccount);
                }
            }
            for (AccountTeamMember accountTeamMemberObj : [SELECT Id, AccountId, UserId FROM AccountTeamMember WHERE AccountId IN:mapOfIdAndAccount.keySet() AND TeamMemberRole = :ConstantsController.AccountTeamMemberRole]) {
                if (!mapOfAccountIdAndUserId.containsKey(accountTeamMemberObj.AccountId)) {
                    Set<Id> userIds = new Set<Id>();
                    userIds.add(accountTeamMemberObj.UserId);
                    mapOfAccountIdAndUserId.put(accountTeamMemberObj.AccountId, userIds);
                } else {
                    mapOfAccountIdAndUserId.get(accountTeamMemberObj.AccountId).add(accountTeamMemberObj.UserId);
                }
            }
            if (!mapOfIdAndAccount.isEmpty() && !mapOfAccountIdAndUserId.isEmpty()) {
                for (Id accountId : mapOfIdAndAccount.keySet()) {
                    if (mapOfAccountIdAndUserId.containsKey(accountId)) {
                        messageInput = new ConnectApi.MessageBodyInput();
                        messageInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
                        for (Id userId : mapOfAccountIdAndUserId.get(accountId)) {
                            mentionSegment = new ConnectApi.MentionSegmentInput();
                            mentionSegment.Id = userId;
                            messageInput.messageSegments.add(mentionSegment);
                        }
                        textSegment = new ConnectApi.TextSegmentInput();
                        textSegment.text = ' ' + mapOfIdAndAccount.get(accountId).Name + ' risk level has increased to ' + mapOfIdAndAccount.get(accountId).Current_Risk_Level__c;
                        messageInput.messageSegments.add(textSegment);
                        input = new ConnectApi.FeedItemInput();
                        input.subjectId = accountId;
                        input.body = messageInput;
                        batchInput = new ConnectApi.BatchInput(input);
                        batchInputs.add(batchInput);
                    }
                }
            }
            if (!Test.isRunningTest() )
                ConnectApi.ChatterFeeds.postFeedElementBatch(Network.getNetworkId(), batchInputs);
        } catch (Exception ex) {
            CreateExceptionLog.insertErrorLog(ex, null, null, null, 'Apex Class', 'Account', 'AccountTrigger', 'AccountTriggerHandler.createChatterPost()', 'High');
        }
    }


    /* Method used to cancel all the Benefit Agreements, Group Section and Billing Profiles associated to the Account */
    public static void GS_BA_BP_Cancellation(Map<Id, Account> NewAccountMap, Map<Id, Account> OldAccountMap) {
        try {
            Set<Id> AccountIdSet = new Set<Id>();
            for (Account accRecord : NewAccountMap.values()) {
                if (OldAccountMap != null && OldAccountMap.keyset().contains(accRecord.Id)) {
                    if (OldAccountMap.get(accRecord.Id).Cancellation_Status__c != NewAccountMap.get(accRecord.Id).Cancellation_Status__c) {
                        AccountIdSet.add(accRecord.Id);
                    }
                }
            }
            if (AccountIdSet.size() > 0) {
                List<Benefit_Agreement__c> BenAgreeList = new list<Benefit_Agreement__c>();
                List<Group_Section__c> GroupSecList = new list<Group_Section__c>();
                List<Billing__c> BillPrfLis = new list<Billing__c>();
                for (Account acc : [select id, (select id , name, Cancellation_Status__c, Group_Account__r.Cancellation_Status__c from Benefit_Agreements__r where Cancellation_Status__c != 'Cancelled'),
                                    (select id , name, Cancellation_Status__c, Group_Account__r.Cancellation_Status__c from Group_Sections__r where Cancellation_Status__c != 'Cancelled'),
                                    (select id , name, Cancellation_Status__c, Group_Account__r.Cancellation_Status__c from Billing__r where Cancellation_Status__c != 'Cancelled' )
                                    from Account where Id In :AccountIdSet]) {
                    for (Benefit_Agreement__c BenAgree : acc.Benefit_Agreements__r) {
                        BenAgree.Cancellation_Status__c = BenAgree.Group_Account__r.Cancellation_Status__c;
                        BenAgreeList.add(BenAgree);
                    }
                    for (Group_Section__c GrpSec : acc.Group_Sections__r) {
                        GrpSec.Cancellation_Status__c = GrpSec.Group_Account__r.Cancellation_Status__c;
                        GroupSecList.add(GrpSec);
                    }
                    for (Billing__c  BillPrf : acc.Billing__r) {
                        BillPrf.Cancellation_Status__c = BillPrf.Group_Account__r.Cancellation_Status__c;
                        BillPrfLis.add(BillPrf);
                    }

                }
                update BenAgreeList;
                update GroupSecList;
                update BillPrfLis;
                //List<Benefit_Agreement__c> BenAgreeList = [select id ,name, Cancellation_Status__c, Group_Account__r.Cancellation_Status__c from Benefit_Agreement__c where Group_Account__c In: AccountIdSet and Cancellation_Status__c != 'Cancelled' limit: Limits.getLimitQueryRows() - Limits.getQueryRows()];
                //List<Group_Section__c> GroupSecList = [select id ,name, Cancellation_Status__c, Group_Account__r.Cancellation_Status__c from Group_Section__c where Group_Account__c In: AccountIdSet and Cancellation_Status__c != 'Cancelled' limit: Limits.getLimitQueryRows() - Limits.getQueryRows()];
                //List<Billing__c> BillPrfList = [select id ,name, Cancellation_Status__c, Group_Account__r.Cancellation_Status__c from Billing__c where Group_Account__c In: AccountIdSet and Cancellation_Status__c != 'Cancelled' limit: Limits.getLimitQueryRows() - Limits.getQueryRows()];
                /* if(BenAgreeList.size() > 0){
                     for(Benefit_Agreement__c BenAgree : BenAgreeList){
                         BenAgree.Cancellation_Status__c = BenAgree.Group_Account__r.Cancellation_Status__c;
                     }
                     update BenAgreeList;
                 }
                 if(GroupSecList.size() > 0){
                     for(Group_Section__c GrpSec : GroupSecList){
                         GrpSec.Cancellation_Status__c = GrpSec.Group_Account__r.Cancellation_Status__c;
                     }
                     update GroupSecList;
                 }
                 if(BillPrfList.size() > 0){
                     for(Billing__c  BillPrf : BillPrfList){
                         BillPrf.Cancellation_Status__c = BillPrf.Group_Account__r.Cancellation_Status__c;
                     }
                     update BillPrfList;
                 }*/
            }
        } catch (Exception ex) {
            system.debug('### ERROR : ' + ex.getMessage() + ' ' + ex.getStackTraceString());
            CreateExceptionLog.insertErrorLog(ex, null, null, null, 'Apex Class', 'Account', 'AccountTrigger', 'AccountTriggerHandler.GS_BA_BP_Cancellation()', 'High');
        }
    }

    public static void CarryOverMemberValues(Map<Id, Account> AccountNewMap, Map<Id, Account> AccountOldMap) {
        if (AccountNewMap != null) {
            for (Id AccountId : AccountNewMap.keySet()) {
                //update trigger
                if (AccountNewMap.containsKey(AccountId) && AccountOldMap.containsKey(AccountId)) {
                    if (AccountNewMap.get(AccountId).Effective_Date__c != null && AccountNewMap.get(AccountId).Effective_Date__c != AccountOldMap.get(AccountId).Effective_Date__c) {
                        Integer numberOfDays = Date.daysInMonth(AccountNewMap.get(AccountId).Effective_Date__c.year(), AccountNewMap.get(AccountId).Effective_Date__c.month());
                        AccountNewMap.get(AccountId).Health_Dental_Members_Carry_Over_Date__c = Date.newInstance(AccountNewMap.get(AccountId).Effective_Date__c.year(), AccountNewMap.get(AccountId).Effective_Date__c.month(), numberOfDays);
                    }
                }

                //insert trigger
                else if (AccountNewMap.containsKey(AccountId) ) {
                    if (AccountNewMap.get(AccountId).Effective_Date__c != null) {
                        Integer numberOfDays = Date.daysInMonth(AccountNewMap.get(AccountId).Effective_Date__c.year(), AccountNewMap.get(AccountId).Effective_Date__c.month());
                        AccountNewMap.get(AccountId).Health_Dental_Members_Carry_Over_Date__c = Date.newInstance(AccountNewMap.get(AccountId).Effective_Date__c.year(), AccountNewMap.get(AccountId).Effective_Date__c.month(), numberOfDays);
                    }
                }
            }
        }
    }


    /*************************************************************************************************************************************
    *  ReatainPreviousOwnersAccess
    *   @description:  Method is used to retain previous owner's access in acount team if present
    *   @parameters     List<Account> AccountList, Map<Id,Account> AccountOldMap
    *   @return type    void
    *******************************************************************************************************************************************/

    public static void ReatainPreviousOwnersAccess(List<Account> AccountList, Map<Id, Account> AccountOldMap) {
        Set<Id> userId = new Set<Id>();
        List<AccountTeamMember> insertList = new List<AccountTeamMember>();
        List<AccountTeamMember> DeleteList = new List<AccountTeamMember>();
        List<AccountShare> share = new List<AccountShare>();
        Map<Id , Id> accountUserMap = new Map<Id , Id>();
        Map<Id , Id> accountShareUserMap = new Map<Id , Id>();
        Map<Id , Id> accountSharerecordMap = new Map<Id , Id>();
        for (Account acc : AccountList) {
            if (AccountOldMap.get(acc.Id).ownerid != acc.ownerid) {
                accountUserMap.put(acc.id, AccountOldMap.get(acc.id).ownerid);
                userId.add(AccountOldMap.get(acc.id).ownerid);
            }
        }

        //get accountshare record if it exist for user and account
        for (AccountShare accountShare : [select id, AccountId, UserOrGroupId from AccountShare where accountid in : accountUserMap.keyset()]) {
            if (accountShare.UserOrGroupId == accountUserMap.get(accountShare.AccountId) ) {
                accountSharerecordMap.put(accountShare.AccountId, accountShare.id);
            }
        }
        //create share record list for previous owner to give full access

        for (AccountTeamMember accTeam : [select id , accountid, userid , AccountAccessLevel from AccountTeamMember where accountid in : accountUserMap.keyset()]) {
            if (accTeam.userid == accountUserMap.get(accTeam.AccountId)) {
                AccountShare accountShare = new AccountShare();
                accountShare.AccountId = accTeam.AccountId;
                accountShare.UserOrGroupId = accTeam.userid;

                if (accountShareRecordMap.containskey(accTeam.AccountId)  ) {
                    accountShare.id = accountShareRecordMap.get(accTeam.AccountId);
                    accountShare.AccountAccessLevel = 'Edit' ;

                } else {
                    accountShare.AccountAccessLevel = 'Edit' ;
                    accountShare.OpportunityAccessLevel = 'Edit' ;
                    accountShare.caseAccessLevel = 'Edit' ;

                }
                share.add(accountShare);
            }
        }
        system.debug('share*' + share);
        if (share.size() > 0) {
            upsert share;
        }
    }

	public class AccountExecWrapper {
		public Map<String, Id> accExNameToacctId = new Map<String, Id>();
		public Map<String, Id> underwriterNamesToacctId = new Map<String, Id>();
		public List<String> accExName = new List<String>();
		public List<String> underwriterNames = new List<String>();
	}

    /**
    * @description		 Handles calling addAE2AndUnderwriterToAccountTeam for inserts
    * @param newAccounts The new accounts being inserted
    */
    public static void addAE2AndUnderwriterOnInsert( List<Account> newAccounts) {

		AccountExecWrapper accountExWrapper = new AccountExecWrapper();
        
		for (Account acc : newAccounts) {
			if (acc.Account_Cluster_Name__c != null) {
				accountExWrapper.accExName.add(acc.Account_Cluster_Name__c);
				accountExWrapper.accExNameToacctId.put(acc.Account_Cluster_Name__c, acc.Id);
			}
			if (acc.Account_Executive_2__c != null) {
				accountExWrapper.accExName.add(acc.Account_Executive_2__c);
				accountExWrapper.accExNameToacctId.put(acc.Account_Executive_2__c, acc.Id);
			}
			if (acc.Underwriter_User_ID__c != null) {
				accountExWrapper.underwriterNAmes.add(Acc.Underwriter_User_ID__c);
				accountExWrapper.underwriterNamesToacctId.put(acc.Underwriter_User_ID__c, acc.Id);
			}

		}

		addAE2AndUnderwriterToAccountTeam(accountExWrapper);

    }

	/**
	* @description		 Handles calling addAE2AndUnderwriterToAccountTeam for updates
	* @param newAccounts The accounts after update
	* @param oldAccounts The accounts before update
	*/
	public static void addAE2AndUnderwriterOnUpdate( List<Account> newAccounts, Map<Id, Account> oldAccounts ){
		
        AccountExecWrapper accountExWrapper = new AccountExecWrapper();
		for (Account acc : newAccounts){
			Account oldAccount = oldAccounts.get(acc.Id);
			if (acc.Account_Cluster_Name__c != null && acc.Account_Cluster_Name__c != oldAccount.Account_Cluster_Name__c){
				accountExWrapper.accExName.add(acc.Account_Cluster_Name__c);
				accountExWrapper.accExNameToacctId.put(acc.Account_Cluster_Name__c, acc.Id);
			}

			if (acc.Account_Executive_2__c != null && acc.Account_Executive_2__c != oldAccount.Account_Executive_2__c) {
				accountExWrapper.accExName.add(acc.Account_Executive_2__c);
				accountExWrapper.accExNameToacctId.put(acc.Account_Executive_2__c, acc.Id);
			}

			if (acc.Underwriter_User_ID__c != null && acc.Underwriter_User_ID__c != oldAccount.Underwriter_User_ID__c){
				accountExWrapper.underwriterNames.add(acc.Underwriter_User_ID__c);
				accountExWrapper.underwriterNAmesToacctId.put(acc.Underwriter_User_ID__c, acc.Id);
			}
		}

		addAE2AndUnderwriterToAccountTeam(accountExWrapper);
	}

	/**
	* @description		 Adds users to the Account Team as Account Executive or Underwriter
						 depending on if the corresponding fields were filled out on the Account
	* @param newAccounts The accounts after update or the new accounts being inserted
	* @param oldAccounts The accounts before update, if in an update trigger, otherwise an empty Map
	*/
	private static void addAE2AndUnderwriterToAccountTeam(AccountExecWrapper accountExWrapper){
		
		String EDIT_ACCESS = 'Edit';
		String ACCOUNT_EXEC_ROLE = 'Account Executive';
		String UNDERWRITER_ROLE = 'Underwriter';

		String teamMemberRole;

		List<AccountTeamMember> members = new list<AccountTeamMember>();
        List<AccountShare> sharingRules = new list<AccountShare>();
		
		try {
		
			List<User> users = [SELECT Id, Name, Lan_Id__c, isActive FROM User where (name in :accountExWrapper.accExName OR Lan_Id__c in :accountExWrapper.underwriterNames) AND isActive = True];

			if (!users.isEmpty()) {
				for (User u : users) {

					//add users to account owner team
					Id acctExAcctId = accountExWrapper.accExNameToacctId.get(u.Name);
					Id underwriterAcctId = accountExWrapper.underwriterNamesToacctId.get(u.Lan_Id__c);
					Id acctId;
					if (acctExAcctId != null) {
						teamMemberRole = ACCOUNT_EXEC_ROLE;
						acctId = acctExAcctId;
					} else {
						teamMemberRole = UNDERWRITER_ROLE;
						acctId = underwriterAcctId;
					}
					if (acctId != null) {
						members.add(New AccountTeamMember(AccountId = acctId, TeamMemberRole = teamMemberRole, UserId = u.id));
						sharingRules.add(new AccountShare(AccountAccessLevel = EDIT_ACCESS, OpportunityAccessLevel = EDIT_ACCESS, CaseAccessLevel = EDIT_ACCESS, UserOrGroupId = u.id, AccountId = acctId));
					}
				}
				insert members;
				insert sharingRules;
			}
		} catch (Exception ex) {
			CreateExceptionLog.insertErrorLog(ex, null, null, null, 'Apex Class', 'Account', 'AccountTrigger', 'AccountTriggerHandler.AddAE2ToAccountTeam', 'High');
		}
	}


    //Update the Producer's parent to the appropriate house account based on NPN
    public static void updateProducerParent(Map<Id, Account> AccountNewMap, Map<Id, Account> AccountOldMap) {
        Account curAcct;
        Map<String, National_Producer_Number__c> npnMap = new Map<String, National_Producer_Number__c>();
        Map<Id, Account> producerAccountMap = new Map<Id, Account>();
        List<String> npnValues = new List<String>();
        List<Account> updateAcctList = new List<Account>();
        List<National_Producer_Number__c> npnList;
        National_Producer_Number__c existingNPN;
        National_Producer_Number__c newNPN;

        String oldValue;
        String newValue;

        if (AccountNewMap != null) {
            //Add the National Producer Numbers from the accounts that we're adding to a list to check if already there

            for (Id AccountId : AccountNewMap.KeySet()) {
                //Only doing the following for Producer Accounts
                if (AccountNewMap.get(AccountId).RecordTypeId ==
                        Schema.SObjectType.Account.getRecordTypeInfosByName().get( Label.Producer_Account ).getRecordTypeId()) {

                    if (AccountOldMap != null )
                        oldValue = AccountOldMap.get(AccountId).National_Producer_Number__c;
                    if (AccountNewMap != null )
                        newValue = AccountNewMap.get(AccountId).National_Producer_Number__c;

                    producerAccountMap.put(AccountId, AccountNewMap.get(AccountId));

                    //if NPN on AccountNewMap is blank then it could be a delete so add NPN if exists in AccountOldMap
                    if ( (newValue == '' || newValue == null) && (oldValue != '' && oldValue != null) ) {
                        npnValues.add(oldValue);
                    } else
                        npnValues.add(newValue);

                    //If NPN is being changed on the account then both the counts for both the old and the new will need to be updated.
                    if ( (oldValue != null && newValue != null) && (newValue.length() > 0 && oldValue.length() > 0)
                            && (oldValue.equals(newValue) == false ) ) {
                        npnValues.add(oldValue);
                    }
                }
            }

            npnList = [SELECT House_Account__c, NPN__c FROM National_Producer_Number__c where NPN__c IN: npnValues];

            for (National_Producer_Number__c n : npnList) {
                npnMap.put(n.NPN__c, n);
            }

            for (Id AccountId : producerAccountMap.keySet()) {
                curAcct = producerAccountMap.get(AccountId);

                //Only create this NPN if its not already there.. then add to the map so it doesn't get created again
                if ( (curAcct.National_Producer_Number__c != null && curAcct.National_Producer_Number__c != '') &&
                        npnMap.containsKey(curAcct.National_Producer_Number__c) == false && curAcct.ParentId != null) {
                    newNPN = insertNewNPN(curAcct.ParentId, curAcct.National_Producer_Number__c);
                    npnMap.put(newNPN.Id, newNPN);
                    npnList.add(newNPN);
                }
            }

            update updateAcctList;

            //Update the Producer Count of all the related NPNs
            npnList = NPNTriggerHandler.updateNPNProducerCount(npnList);
            update npnList;
        }
    }

    //Update the Producer House NPN List if a child producer is associated with the house
    public static National_Producer_Number__c insertNewNPN(Id houseId, String npnValue) {
        National_Producer_Number__c newNPN = new National_Producer_Number__c(House_Account__c = houseId, NPN__c = npnValue );
        insert newNPN;
        return newNPN;
    }



    //Checks that an NPN is not already is use on another house account, don't allow save
    public static void validateUniqueNPN(List<Account> accountList) {

        Map<String, National_Producer_Number__c> npnMap = new Map<String, National_Producer_Number__c>();
        List<Account> producerAccountList = new List<Account>();
        List<Account> updateAcctList = new List<Account>();
        List<String> npnValues = new List<String>();
        National_Producer_Number__c existingNPN;

        if (accountList != null) {
            for (Account a : accountList) {
                //Only doing the following for Accounts where a National Producer Number is specified
                if (a.National_Producer_Number__c != null ) {
                    producerAccountList.add(a);
                    npnValues.add(a.National_Producer_Number__c);
                }
            }

            List<National_Producer_Number__c> npnList = [SELECT House_Account__c, NPN__c, House_Account__r.Name FROM National_Producer_Number__c where NPN__c IN: npnValues];

            for (National_Producer_Number__c npn : npnList) {
                npnMap.put(npn.NPN__c, npn);
            }

            for (Account a : producerAccountList) {
                //If the NPN is associated with another Producer House then trigger error... don't allow update
                if (npnMap.containsKey(a.National_Producer_Number__c) == true && a.ParentId != null
                        && a.ParentId != npnMap.get(a.National_Producer_Number__c).House_Account__c) {
                    //add error
                    existingNPN = npnMap.get(a.National_Producer_Number__c);
                    a.addError('Error : ' +  Label.NPN_Already_Assigned_To_A_Producer_House + ' '
                               + existingNPN.House_Account__r.Name  );
                } else {
                    //Only update the parent id based on NPN if needed..
                    existingNPN = npnMap.get(a.National_Producer_Number__c);
                    if (existingNPN != null && a.ParentId != existingNPN.House_Account__c) {
                        a.ParentId = existingNPN.House_Account__c;
                    }
                }
            }
        }
    }

}