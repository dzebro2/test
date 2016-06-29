public with sharing class AccountCancellationClass {
        
        
        public String StringCancelDate {get;set;}
        public String CancelExplanation { get; set; }
        public String CancelReason { get; set; }
        public String CancelCode { get; set; }
        public Date CancelDate {get;set;}
        public List<selectOption> CancellationCodePicklist { get; set; }
        public List<SelectOption> CancellationReasonPicklist { get; set; }
        String previoscancellationstatus;
        public boolean displayBillingsection { get; set; }
        public String selectedValue { get; set; }
        public Id accountId;
        public List<Account> AccountRecord { get; set; }
        public List<Group_Section__c> GroupSectionList { get; set; }
        public List<Benefit_Agreement__c> BenefitAgreementList { get; set; }
        public String accountName { get; set; }
        public List<GroupSectionWrapper> grpSectionWrapperList { get; set; }
        public List<GroupSectionWrapper> selectedgrpSectionWrapperList { get; set; }
        public Set<id> grpSecIds { get; set; }
        public List<BenefitAgreementWrapper> BAWrapperList { get; set; }
        public List<BenefitAgreementWrapper> selectedBAWrapperList { get; set; }

        public List<BiilingProfileWrapper> BillingWrapperList { get; set; }
        public List<BiilingProfileWrapper> selectedBillingWrapperList { get; set; }
        public Set<id> BAIds { get; set; }
        
        public Group_Section__c Massgrpsec { get; set; }
        public Benefit_Agreement__c MassBArec { get; set; }
        public billing__c Massbilling { get; set; }
        Map<id, set<id>> ba_gs_map;
        Map<id, set<id>> ba_gs_mapGrpSec;
        Map<id, Group_Section__c> GsIdRecMap;
        Map<id, Benefit_Agreement__c> BAIdRecMap;
        public boolean completeCancellationSectionToggle { get; set; }
        public boolean benefitAgreementSectionToggle { get; set; }
        public boolean GroupSectionToggle { get; set; }
        public boolean showMessagepanel { get; set; }
        public String DisplayMessage { get; set; }
        public List<Billing__c> BillingProfileList { get; set; }
        public boolean hasEditAccess { get; set; }
        public String marketSegment { get; set; } //the market segment value from the current account record
        public String pageWarning { get; set; }
        public List<BenefitAgreementWrapper> RelatedBenefitAgreementWrapper;
        public List<GroupSectionWrapper> RelatedGroupSectionWrapper;
        Id ProdNonBluStarRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get(ConstantsController.HCSC_Non_BlueStar_Product).getRecordTypeId();
        public Set<Id> persistentGroupSectionIdSet {get;set;}

        /*Removed Variables*/
        /*
        public String AccountCancellationReason {get; set;}
        public Integer AccountCancellationMembers {get; set;}
        public String AccountCancellationExplaination {get; set;}
        public List<Group_Section__c> RelatedGroupSection {get; set;}
        */

        public void setRelatedBenefitAgreementWrapper(List<BenefitAgreementWrapper> tempListBene) {
                RelatedBenefitAgreementWrapper = tempListBene;
        }

        public List<BenefitAgreementWrapper> getRelatedBenefitAgreementWrapper() {
                try {
                        List<Benefit_Agreement__c> RelatedBenefitAgreement = getRelatedBenefitAgreement();
                        RelatedBenefitAgreementWrapper.clear();
                        for (Benefit_Agreement__c benAgree : RelatedBenefitAgreement) {
                                RelatedBenefitAgreementWrapper.add(new BenefitAgreementWrapper(true, benAgree));
                        }
                } catch(Exception ex) {
                        //CreateExceptionLog.insertErrorLog(ex, null, null, null, 'Apex Class', 'Account', null, 'AccountCancellationClass.getRelatedBenefitAgreementWrapper()','High');
                        system.debug('ERROR: ' + ex.getMessage() + '  ' + ex.getStackTraceString());
                }
                return RelatedBenefitAgreementWrapper;
        }

        public void setRelatedGroupSectionWrapper(List<GroupSectionWrapper> templist) {
                RelatedGroupSectionWrapper = templist;
        }

        public List<GroupSectionWrapper> getRelatedGroupSectionWrapper() {
                try {
                        List<Group_Section__c> RelatedGroupSections = getRelatedGroupSection();
                        RelatedGroupSectionWrapper.clear();
                        for (Group_Section__c grpSec : RelatedGroupSections) {
                                RelatedGroupSectionWrapper.add(new GroupSectionWrapper(true, grpSec));
                        }
                } Catch(Exception ex) {
                        //CreateExceptionLog.insertErrorLog(ex, null, null, null, 'Apex Class', 'Account', null, 'AccountCancellationClass.getGroupSectionWrapperList()','High');
                        system.debug('ERROR: ' + ex.getMessage() + '  ' + ex.getStackTraceString());
                }
                return RelatedGroupSectionWrapper;
        }

        public List<SelectOption> getItems() {
                List<SelectOption> options = new List<SelectOption> ();
                options.add(new SelectOption('Complete', 'Account Cancellation'));
                options.add(new SelectOption('Group', 'Group Sections Cancellation'));
                options.add(new SelectOption('Benefit', 'Benefit Agreements Cancellation'));
                options.add(new SelectOption('Billing', 'Billing Profile Cancellation'));
                return options;
        }

        public AccountCancellationClass(ApexPages.StandardController controller) {
                try {
                        accountId = ApexPages.currentPage().getParameters().get('id');
                        String selectedValue = ApexPages.currentPage().getParameters().get('selectedValue');
                        this.pageWarning = system.label.AccountCancellationHomeWarning;
                        UserRecordAccess userAccess = [SELECT RecordId, HasEditAccess FROM UserRecordAccess WHERE UserId = :UserInfo.getUserId() AND RecordId = :accountId limit 1] [0];
                        if (userAccess.HasEditAccess) {
                                hasEditAccess = true;
                                AccountRecord = new List<Account> ();
                                AccountRecord = [Select Requested_Cancellation_Date__c, Market_Segment__c, Cancellation_Code__c, Cancellation_Explanation__c, Cancellation_Reason__c,
                                                 name, id, Description, Status__c, Cancellation_Status__c
                                                 From Account
                                                 Where id = :accountId
                                                 limit 1];
                                accountName = AccountRecord[0].name;
                                marketSegment = AccountRecord[0].Market_Segment__c;
                                previoscancellationstatus = AccountRecord[0].Cancellation_Status__c;
                                grpSectionWrapperList = new List<GroupSectionWrapper> ();
                                selectedgrpSectionWrapperList = new List<GroupSectionWrapper> ();
                                grpSecIds = new Set<id> ();
                                BAWrapperList = new List<BenefitAgreementWrapper> ();
                                selectedBAWrapperList = new List<BenefitAgreementWrapper> ();
                                BAIds = new Set<id> ();
                                selectedBillingWrapperList = new List<BiilingProfileWrapper> ();
                                BillingWrapperList = new List<BiilingProfileWrapper> ();
                                Massgrpsec = new Group_Section__c();
                                MassBArec = new Benefit_Agreement__c();
                                ba_gs_map = new Map<id, set<id>> ();
                                ba_gs_mapGrpSec = new Map<id, set<id>> ();
                                GsIdRecMap = new Map<id, Group_Section__c> ();
                                BAIdRecMap = new Map<id, Benefit_Agreement__c> ();
                                RelatedGroupSectionWrapper = new List<GroupSectionWrapper> ();
                                RelatedBenefitAgreementWrapper = new List<BenefitAgreementWrapper> ();
                                Massbilling = new billing__c();
                                completeCancellationSectionToggle = true;
                                benefitAgreementSectionToggle = true;
                                GroupSectionToggle = true;
                                displayBillingsection = false;
                                showMessagepanel = false;

                                getBAWrapperList();

                                getGroupSectionWrapperList();

                                getBillingProfileWrapperList();

                                populatePicklistValues(selectedValue);

                        } else {
                                hasEditAccess = false;
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, system.label.InsufficientError));
                        }
                } catch(Exception ex) {
                        //CreateExceptionLog.insertErrorLog(ex, null, null, null, 'Apex Class', 'Account', null, 'AccountCancellationClass.getRelatedBenefitAgreementWrapper()','High');
                        system.debug('ERROR: ' + ex.getMessage() + '  ' + ex.getStackTraceString());
                }
        }

        public pageReference NavigateToSelectedPage() {
                accountId = ApexPages.currentPage().getParameters().get('id');
                PageReference pg = null;
                if (selectedValue == 'Group') {
                        pg = new pageReference('/apex/AccountCancellationGroupSection?Id=' + accountId);
                        ResetMassUpdateValues(new Group_Section__c());
                } else if (selectedValue == 'Complete') {
                        pg = new pageReference('/apex/AccountCompleteCancellation?Id=' + accountId);
                        ResetMassUpdateValues(new Account());
                } else if (selectedValue == 'Benefit') {
                        pg = new pageReference('/apex/AccountCancellationBenefitAgreement?Id=' + accountId);
                        ResetMassUpdateValues(new Benefit_Agreement__c());
                } else if (selectedValue == 'Billing') {
                        pg = new pageReference('/apex/billingProfileCancellation?Id=' + accountId);
                        ResetMassUpdateValues(new Billing__c());
                }
                if (pg != null) {
                    pg.getParameters().put('selectedValue', selectedValue);
                    pg.setRedirect(true);   
                }

                return pg;
        }

        /**
        * @developer: Alec Klein/Slalom LLC
        * @description: Populates picklist values based on the current selected page
        */
        public void populatePicklistValues(String currentSelectedValue){
            if (currentSelectedValue == 'Group') 
                ResetMassUpdateValues(new Group_Section__c());
            else if (currentSelectedValue == 'Complete') 
                ResetMassUpdateValues(new Account());
            else if (currentSelectedValue == 'Benefit') 
                ResetMassUpdateValues(new Benefit_Agreement__c());
            else if (currentSelectedValue == 'Billing') 
                ResetMassUpdateValues(new Billing__c());
        }

        public pageReference confirmcancellationAccount() {

                if (!checkIfAccountCanBeCancelled()) {
                        backcancellationAccount();
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Account_Cannot_Be_Cancelled));
                        return null;
                }

                Savepoint sp = Database.setSavepoint();

                try {
                        if (AccountRecord.size() > 0 && AccountRecord[0] != null) {
                                if (isSGAccount()) {
                                        AccountRecord[0].Cancellation_Status__c = 'Cancelled';
                                } else {
                                        AccountRecord[0].Cancellation_Status__c = 'Pending Approval';
                                }
                                update AccountRecord[0];

                                if (GroupSectionList != null && GroupSectionList.size() > 0) {
                                        update GroupSectionList;
                                }
                                if (BenefitAgreementList != null && BenefitAgreementList.size() > 0) {
                                        update BenefitAgreementList;
                                }
                                if (BillingProfileList != null && BillingProfileList.size() > 0) {
                                        update BillingProfileList;
                                }
                                if (!isSGAccount()) { //doesn't count SG account for the Approval process
                                        list<Approval.ProcessSubmitRequest> request = new list<Approval.ProcessSubmitRequest> ();
                                        Approval.ProcessSubmitRequest temp = new Approval.ProcessSubmitRequest();
                                        temp = new Approval.ProcessSubmitRequest();
                                        temp.setComments('Submitting for Approval');
                                        temp.setObjectId(AccountRecord[0].id);
                                        request.add(temp);
                                        list<Approval.ProcessResult> result = Approval.process(request, true);
                                }
                        }
                        PageReference pg = new pageReference('/' + accountId);
                        return pg;
                } catch(DMLException ex) {
                        //CreateExceptionLog.insertErrorLog(ex, null, null, null, 'Apex Class', 'Account', null, 'AccountCancellationClass.confirmcancellationAccount()','High');
                        AccountRecord[0].Cancellation_Status__c = previoscancellationstatus;
                        Database.rollback(sp);
                        backcancellationAccount();
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.UsersManagerNotAvailable));
                        system.debug('ERROR: ' + ex.getMessage() + '  ' + ex.getStackTraceString());
                }
                return null;
        }

        private Boolean checkIfAccountCanBeCancelled() {
                if ((AccountRecord[0].Cancellation_Status__c == ConstantsController.pendingApprovalStatus && !isSGAccount()) // SG account doesn't need to check approval process
                    || AccountRecord[0].Cancellation_Status__c == ConstantsController.cancelledStatus
                    || AccountRecord[0].Cancellation_Status__c == ConstantsController.submittedStatus
                    || AccountRecord[0].Cancellation_Status__c == ConstantsController.requestedCancellationStatus) {

                        return false;
                }
                return true;
        }

        public pageReference backcancellationAccount() {
                showMessagepanel = false;
                return null;
        }

        public pageReference DiplaycancellationAccountMessage() {
                showMessagepanel = true;
                DisplayMessage = 'Are you sure you want to cancel the entire account?';
                return null;
        }

        public pageReference cancel() {
                accountId = ApexPages.currentPage().getParameters().get('id');
                pageReference pg = new pageReference('/' + accountId);
                return pg;
        }

        public pageReference backToAccountHome() {
                accountId = ApexPages.currentPage().getParameters().get('id');
                pageReference pg = new pageReference('/apex/AccountCancellationHome?id=' + accountId);
                pg.setredirect(true);
                return pg;
        }

        public pageReference moveToAccountCompCancelReviewPg() {
                try {
                        accountId = ApexPages.currentPage().getParameters().get('id');

                        GroupSectionList = [SELECT Id, Cancellation_Explanation__c, Members_Cancelling__c, Cancellation_Reason__c, Requested_Cancellation_Date__c, Cancellation_Code__c,
                                            Section_Number__c, Name, Group_Account__c, Status__c, Cancellation_Status__c, Total_Active_Members__c, Total_Active_Subscribers__c, Group_Number__c
                                            FROM Group_Section__c
                                            WHERE Group_Account__c = :accountId
                                            and status__c = 'Active'
                                            and(Cancellation_Status__c != :ConstantsController.pendingApprovalStatus
                                                and Cancellation_Status__c != :ConstantsController.cancelledStatus
                                                and Cancellation_Status__c != :ConstantsController.submittedStatus
                                                and Cancellation_Status__c != :ConstantsController.requestedCancellationStatus)
                                            limit :Limits.getLimitQueryRows() - Limits.getQueryRows()];

                        BenefitAgreementList = [SELECT id, Status__c, Group_Account__c, Benefit_Agreement_Number__c, Cancellation_Explanation__c, Requested_Cancellation_Date__c, Cancellation_Code__c,
                                                Members_Cancelling__c, Cancellation_Reason__c, Name, Cancellation_Status__c
                                                FROM Benefit_Agreement__c
                                                WHERE Group_Account__c = :accountId
                                                and status__c = 'Active'
                                                and(Cancellation_Status__c != :ConstantsController.pendingApprovalStatus
                                                    and Cancellation_Status__c != :ConstantsController.cancelledStatus
                                                    and Cancellation_Status__c != :ConstantsController.submittedStatus
                                                    and Cancellation_Status__c != :ConstantsController.requestedCancellationStatus)
                                                and Product__r.RecordTypeId != :ProdNonBluStarRecordTypeId
                                                limit :Limits.getLimitQueryRows() - Limits.getQueryRows()];

                        BillingProfileList = [select id, name, Cancellation_Code__c, Requested_Cancellation_Date__c, Cancellation_Explanation__c, Cancellation_Reason__c,
                                              Cancellation_Submitted_Date__c, Status__c, Group_Account__c, Group_Account__r.name, Cancellation_Status__c from Billing__C
                                              WHERE Group_Account__c = :accountId
                                              and(Cancellation_Status__c != :ConstantsController.pendingApprovalStatus
                                                  and Cancellation_Status__c != :ConstantsController.cancelledStatus
                                                  and Cancellation_Status__c != :ConstantsController.submittedStatus
                                                  and Cancellation_Status__c != :ConstantsController.requestedCancellationStatus)
                                              limit :Limits.getLimitQueryRows() - Limits.getQueryRows()];

                        for (Group_Section__c GroupSec : GroupSectionList) {
                                GroupSec.Cancellation_Reason__c = AccountRecord[0].Cancellation_Reason__c;
                                GroupSec.Requested_Cancellation_Date__c = AccountRecord[0].Requested_Cancellation_Date__c;
                                GroupSec.Cancellation_Explanation__c = AccountRecord[0].Cancellation_Explanation__c;
                                GroupSec.Cancellation_Code__c = AccountRecord[0].Cancellation_Code__c;

                        }
                        for (Benefit_Agreement__c benAgree : BenefitAgreementList) {
                                benAgree.Cancellation_Reason__c = AccountRecord[0].Cancellation_Reason__c;
                                benAgree.Cancellation_Code__c = AccountRecord[0].Cancellation_Code__c;
                                benAgree.Cancellation_Explanation__c = AccountRecord[0].Cancellation_Explanation__c;
                                benAgree.Requested_Cancellation_Date__c = AccountRecord[0].Requested_Cancellation_Date__c;

                        }
                        for (Billing__c billPrf : BillingProfileList) {
                                billPrf.Cancellation_Reason__c = AccountRecord[0].Cancellation_Reason__c;
                                billPrf.Cancellation_Code__c = AccountRecord[0].Cancellation_Code__c;
                                billPrf.Cancellation_Explanation__c = AccountRecord[0].Cancellation_Explanation__c;
                                billPrf.Requested_Cancellation_Date__c = AccountRecord[0].Requested_Cancellation_Date__c;
                        }
                        completeCancellationSectionToggle = false;
                } catch(Exception ex) {
                        //CreateExceptionLog.insertErrorLog(ex, null, null, null, 'Apex Class', 'Account', null, 'AccountCancellationClass.moveToAccountCompCancelReviewPg()','High');
                        system.debug('ERROR: ' + ex.getMessage() + '  ' + ex.getStackTraceString());
                }
                return null;
        }

        public pageReference moveToAccountCompCancel() {
                completeCancellationSectionToggle = true;
                return null;
        }

        private boolean isSGAccount() {

                list<Market_Segment__c> sgsmList = [select id, name, value__c, type__c from market_segment__c where type__c = 'SG'];

                if (sgsmList != null && sgsmList.size() > 0 && marketSegment != null && marketSegment != '') {
                        for (Market_Segment__c sm : sgsmList) {
                                if (sm != null && sm.value__c.containsIgnoreCase(marketSegment)) {
                                        return true;
                                }
                        }

                }
                return false;
        }
        /*******************************************************************Group Section**********************************************************************************************/

        public List<Group_Section__c> getGroupSectionList() {
                List<Group_Section__c> grpSecList;
                try {
                        grpSecList = [select id, name, Cancellation_Status__c, Cancellation_Code__c, Cancellation_Date__c, Cancellation_Explanation__c, Cancellation_Reason__c,
                                      Requested_Cancellation_Date__c, Certs_Cancelling__c, Members_Cancelling__c, Section_Number__c, Status__c, Group_Account__c,
                                      Group_Account__r.name, Name__c, Total_Active_Members__c, Total_Active_Subscribers__c, Group_Number__c
                                      from Group_Section__c
                                      where Group_Account__c = :accountId
                                      and Status__c = 'Active'
                                      and(Cancellation_Status__c != :ConstantsController.pendingApprovalStatus
                                          and Cancellation_Status__c != :ConstantsController.cancelledStatus
                                          and Cancellation_Status__c != :ConstantsController.submittedStatus
                                          and Cancellation_Status__c != :ConstantsController.requestedCancellationStatus)
                                      limit :Limits.getLimitQueryRows() - Limits.getQueryRows()];

                } catch(Exception ex) {
                        //CreateExceptionLog.insertErrorLog(ex, null, null, null, 'Apex Class', 'Account', null, 'AccountCancellationClass.getGroupSectionList()','High');
                        system.debug('ERROR: ' + ex.getMessage() + '  ' + ex.getStackTraceString());
                        return null;
                }
                return grpSecList;
        }


        public void getGroupSectionWrapperList() {
                List<Group_Section__c> grpSecList = getGroupSectionList();

                try {
                        if (grpSecList != null && grpSecList.size() > 0) {
                                for (Group_Section__c gs : grpSecList) {
                                        if (gs.Cancellation_Status__c != ConstantsController.pendingApprovalStatus
                                            && gs.Cancellation_Status__c != ConstantsController.cancelledStatus
                                            && gs.Cancellation_Status__c != ConstantsController.submittedStatus
                                            && gs.Cancellation_Status__c != ConstantsController.requestedCancellationStatus) {

                                                grpSectionWrapperList.add(new GroupSectionWrapper(false, gs));
                                        }
                                }
                        }
                } catch(Exception ex) {
                        //CreateExceptionLog.insertErrorLog(ex, null, null, null, 'Apex Class', 'Account', null, 'AccountCancellationClass.getGroupSectionWrapperList()','High');
                        system.debug('ERROR: ' + ex.getMessage() + '  ' + ex.getStackTraceString());
                }

        }

        public List<GroupSectionWrapper> getSelectedGroupSectionWrapperList() {
                selectedgrpSectionWrapperList.clear();
                for (GroupSectionWrapper gsw : grpSectionWrapperList) {
                        if (gsw.entrySelected) {
                                selectedgrpSectionWrapperList.add(gsw);
                                grpSecIds.add(gsw.entry.id);
                                GsIdRecMap.put(gsw.entry.id, gsw.entry);
                        }
                }
                return selectedgrpSectionWrapperList;
        }

        public List<Benefit_Agreement__c> getRelatedBenefitAgreement() {
                Set<id> BAisds = new Set<id> ();
                Set<id> TempBAids = new Set<id> ();
                List<Benefit_Agreement__c> benAgreeList = new List<Benefit_Agreement__c> ();
                try {

                        for (BA_GS_Assignment__c ba_gs :[select id, Benefit_Agreement__c from BA_GS_Assignment__c where Group_Section__c in :grpSecIds and Benefit_Agreement__r.Status__c = 'Active']) {
                                TempBAids.add(ba_gs.Benefit_Agreement__c);
                        }

                        if (TempBAids.size() > 0)
                        for (BA_GS_Assignment__c ba_gs :[select id, Benefit_Agreement__c, Group_Section__c
                             from BA_GS_Assignment__c
                             where Benefit_Agreement__r.Status__c = 'Active' and Benefit_Agreement__c in :TempBAids
                             ]) {
                                if (ba_gs_map.get(ba_gs.Benefit_Agreement__c) == null) {
                                        Set<id> newIds = new Set<id> ();
                                        newIds.add(ba_gs.Group_Section__c);
                                        ba_gs_map.put(ba_gs.Benefit_Agreement__c, newIds);
                                } else {
                                        ba_gs_map.get(ba_gs.Benefit_Agreement__c).add(ba_gs.Group_Section__c);
                                }

                        }

                        if (ba_gs_map.size() > 0)
                        for (Id baid : ba_gs_map.keyset()) {
                                if (ba_gs_map.get(baid).size() == 1) {
                                        BAisds.add(baid);
                                } else if (ba_gs_map.get(baid).size() > 1) {
                                        if (grpSecIds.size() >= ba_gs_map.get(baid).size() && grpSecIds.containsAll(ba_gs_map.get(baid))) {
                                                BAisds.add(baid);
                                        }
                                }
                        }
                        if (BAisds.size() > 0)
                        benAgreeList = [select id, name, Benefit_Agreement_Number__c, Status__c, Cancellation_Date__c, Cancellation_Explanation__c, Cancellation_Reason__c,
                                        Members_Cancelling__c, Requested_Cancellation_Date__c, Cancellation_Code__c
                                        from Benefit_Agreement__c
                                        where id IN :BAisds
                                        and Status__c = 'Active'
                                        and(Cancellation_Status__c != :ConstantsController.pendingApprovalStatus
                                            and Cancellation_Status__c != :ConstantsController.cancelledStatus
                                            and Cancellation_Status__c != :ConstantsController.submittedStatus
                                            and Cancellation_Status__c != :ConstantsController.requestedCancellationStatus)
                                        and Product__r.RecordTypeId != :ProdNonBluStarRecordTypeId limit :
                                        Limits.getLimitQueryRows() - Limits.getQueryRows()];

                        List<id> ids = new List<id> ();
                        for (Benefit_Agreement__c benAgr : benAgreeList) {
                                ids.addall(ba_gs_map.get(benAgr.id));
                                if (ba_gs_map.get(benAgr.id) != null && GsIdRecMap.get(ids[0]) != null) {
                                        benAgr.Cancellation_Explanation__c = GsIdRecMap.get(ids[0]).Cancellation_Explanation__c;
                                        benAgr.Cancellation_Reason__c = GsIdRecMap.get(ids[0]).Cancellation_Reason__c;
                                        benAgr.Requested_Cancellation_Date__c = GsIdRecMap.get(ids[0]).Requested_Cancellation_Date__c;
                                        benAgr.Cancellation_Code__c = GsIdRecMap.get(ids[0]).Cancellation_Code__c;
                                }
                        }
                } catch(Exception ex) {
                        //CreateExceptionLog.insertErrorLog(ex, null, null, null, 'Apex Class', 'Account', null, 'AccountCancellationClass.getRelatedBenefitAgreement()','High');
                        system.debug('ERROR: ' + ex.getMessage() + '  ' + ex.getStackTraceString());
                }
                return benAgreeList;
        }

        public void MassUpdate() {
                Boolean SelctedFlag = false;
                try{
                        CancelDate = Date.parse(StringCancelDate);
                } catch (TypeException e) {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
                }

                for (GroupSectionWrapper gsw : grpSectionWrapperList) {
                        if (gsw.entrySelected) {
                                if (CancelExplanation != '') {
                                        gsw.entry.Cancellation_Explanation__c = CancelExplanation;
                                }
                                if (CancelReason != '') {
                                        gsw.entry.Cancellation_Reason__c = CancelReason;
                                }
                                if (CancelDate != null) {
                                        gsw.entry.Requested_Cancellation_Date__c = CancelDate;
                                }
                                if (CancelCode != '') {
                                        gsw.entry.Cancellation_Code__c = CancelCode;
                                }
                                SelctedFlag = true;
                        }
                }
                if (!SelctedFlag) {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, system.label.AccountCancellationClassError1));
                }
        }

        public pageReference FinishGroupSection() {
                List<Group_Section__c> updateGroupSection = new List<Group_Section__c> ();
                List<Benefit_Agreement__c> updatebenAgreeList = new List<Benefit_Agreement__c> ();
                Set<id> uniqueset = new Set<id> ();

                for (GroupSectionWrapper grpsec : selectedgrpSectionWrapperList) {
                        grpsec.entry.Cancellation_Status__c = 'Requested Cancellation';
                        if (uniqueset.size() == 0 || !uniqueset.contains(grpsec.entry.id)) {
                                updateGroupSection.add(grpsec.entry);
                                uniqueset.add(grpsec.entry.id);
                        }

                }
                system.debug('******selectedgrpSectionWrapperList' + selectedgrpSectionWrapperList);
                for (BenefitAgreementWrapper benAgrWrp : RelatedBenefitAgreementWrapper) {
                        if (benAgrWrp.entrySelected == true) {
                                benAgrWrp.entry.Cancellation_Status__c = 'Requested Cancellation';
                                updatebenAgreeList.add(benAgrWrp.entry);
                        }
                }

                try {
                        if (updateGroupSection.size() > 0)
                        update updateGroupSection;
                        if (updatebenAgreeList.size() > 0)
                        update updatebenAgreeList;
                        accountId = ApexPages.currentPage().getParameters().get('id');
                        pageReference pg = new pageReference('/' + accountId);
                        return pg;
                } catch(DMLException ex) {
                        //CreateExceptionLog.insertErrorLog(ex, null, null, null, 'Apex Class', 'Account', null, 'AccountCancellationClass.FinishGroupSection()','High');
                        system.debug('ERROR: ' + ex.getMessage() + '  ' + ex.getStackTraceString());
                        return null;
                }
        }

        public pageReference backToGroupSection() {
                accountId = ApexPages.currentPage().getParameters().get('id');
                selectedgrpSectionWrapperList.clear();
                ResetMassUpdateValues(new Group_Section__c());
                GroupSectionToggle = true;
                return null;
                //pageReference pg = new pageReference('/apex/AccountCancellationGroupSection?id='+accountId);
                //return pg;
        }

        public PageReference MoveTonextPage() {
                Boolean SelctedFlag = false;
                Boolean AllSelected = true;

                Pagereference p;
                Date TodayDate = system.Today();
                List<Group_Section__c> RequestedDateGSList = new List<Group_Section__c> ();
                List<String> activeGSList = new List<String> ();
                for (GroupSectionWrapper gsw : grpSectionWrapperList) {
                        if (gsw.entrySelected) {
                                SelctedFlag = true;
                                if (gsw.entry.Requested_Cancellation_Date__c != null && gsw.entry.Cancellation_Explanation__c != null && gsw.entry.Cancellation_Reason__c != null && gsw.entry.Cancellation_Code__c != null) {
                                        if (gsw.entry.Requested_Cancellation_Date__c != null) {
                                                if (gsw.entry.Requested_Cancellation_Date__c.daysBetween(TodayDate) > 60) {
                                                        RequestedDateGSList.add(gsw.entry);
                                                }
                                        }

                                        // Builds a List of any Group Sections with Active Members
                                        if (gsw.entry.Total_Active_Members__c > 0) {
                                                if (gsw.entry.Name__c != null)
                                                activeGSList.add(gsw.entry.Name__c);
                                                else
                                                activeGSList.add(gsw.entry.Name);
                                        }

                                } else {
                                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, system.label.AccountCancellationClassError2));
                                        ba_gs_mapGrpSec.clear();
                                        BAIds.clear();
                                        return null;
                                }
                        } else {
                                AllSelected = false;
                        }
                }
                if (!SelctedFlag) {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, system.label.AccountCancellationClassError1));
                        ba_gs_mapGrpSec.clear();
                        BAIds.clear();
                        return null;
                } else if (AllSelected) {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, system.label.AccountCancellationClassError5));
                        ba_gs_mapGrpSec.clear();
                        BAIds.clear();
                        return null;
                        // p  = new Pagereference('/apex/CancellationReviewPage');
                } else if (RequestedDateGSList.size() > 0) {
                        DisplayMessage = system.label.AccountCancellationClassError6;
                        /* for(Group_Section__c grpSec : RequestedDateGSList){
                          DisplayMessage += ' ' + grpSec.Name;
                          }*/
                        //ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, DisplayMessage));
                        showMessagepanel = true;
                        ba_gs_mapGrpSec.clear();
                        BAIds.clear();
                        return null;
                } else if (activeGSList.size() > 0) {

                        // Builds the error string of all Group Sections with Active Members that the user is attempting to cancel
                        String activeGS = '';
                        Integer gsSize = activeGSList.size();
                        for (Integer i = 0; i < gsSize; i++) {
                                if (i != 0)
                                activeGS = activeGS + ', ' + activeGSList[i];
                                else
                                activeGS = activeGS + ' ' + activeGSList[i];
                        }
                        ba_gs_mapGrpSec.clear();
                        BAIds.clear();
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, system.label.AccountCancellationClassError10 + activeGS));
                        return null;
                } else {
                        GroupSectionToggle = false;
                        return null;
                }
        }

        public pageReference HideMessagePanel() {
                showMessagepanel = false;
                GroupSectionToggle = false;
                return null;
        }

        /********************************************************************* Benefit Agreement ********************************************************************************************/


        public List<Benefit_Agreement__c> getBAList() {
                List<Benefit_Agreement__c> BAList;
                try {
                        BAList = [select id, name, Cancellation_Status__c, Cancellation_Date__c, Status__c, Group_Account__c,
                                  Group_Account__r.name, Benefit_Agreement_Number__c, Cancellation_Explanation__c,
                                  Cancellation_Reason__c, Members_Cancelling__c, Requested_Cancellation_Date__c, Cancellation_Code__c,
                                  (select Id, Group_Section__r.Total_Active_Members__c from BA_GS_Assignments__r)
                                  from Benefit_Agreement__c
                                  where Group_Account__c = :accountId
                                  and Status__c = 'Active'
                                  and(Cancellation_Status__c != :ConstantsController.pendingApprovalStatus
                                      and Cancellation_Status__c != :ConstantsController.cancelledStatus
                                      and Cancellation_Status__c != :ConstantsController.submittedStatus
                                      and Cancellation_Status__c != :ConstantsController.requestedCancellationStatus)
                                  and Product__r.RecordTypeId != :ProdNonBluStarRecordTypeId
                                  limit :Limits.getLimitQueryRows() - Limits.getQueryRows()];
                } catch(Exception ex) {
                        //CreateExceptionLog.insertErrorLog(ex, null, null, null, 'Apex Class', 'Account', null, 'AccountCancellationClass.getBAList()','High');
                        system.debug('ERROR: ' + ex.getMessage() + '  ' + ex.getStackTraceString());
                        return null;
                }
                return BAList;
        }

        public void getBAWrapperList() {
                List<Benefit_Agreement__c> BAList = getBAList();

                try {
                        if (BAList != null && BAList.size() > 0) {
                                for (Benefit_Agreement__c ba : BAList) {
                                        if (ba.Cancellation_Status__c != ConstantsController.pendingApprovalStatus
                                            && ba.Cancellation_Status__c != ConstantsController.cancelledStatus
                                            && ba.Cancellation_Status__c != ConstantsController.submittedStatus
                                            && ba.Cancellation_Status__c != ConstantsController.requestedCancellationStatus) {

                                                BAWrapperList.add(new BenefitAgreementWrapper(false, ba));
                                        }
                                }
                        }
                } catch(Exception ex) {
                        //CreateExceptionLog.insertErrorLog(ex, null, null, null, 'Apex Class', 'Account', null, 'AccountCancellationClass.getBAWrapperList()','High');
                        system.debug('ERROR: ' + ex.getMessage() + '  ' + ex.getStackTraceString());
                }

        }

        public List<BenefitAgreementWrapper> getSelectedBAWrapperList() {
                selectedBAWrapperList.clear();
                for (BenefitAgreementWrapper gsw : BAWrapperList) {
                        if (gsw.entrySelected) {
                                selectedBAWrapperList.add(gsw);
                                BAIds.add(gsw.entry.id);
                                BAIdRecMap.put(gsw.entry.id, gsw.entry);
                        }
                }
                return selectedBAWrapperList;
        }

        public List<Group_Section__c> getRelatedGroupSection() {
            return buildRelatedGroupSectionList(false);
        }
    
        public List<Group_Section__c> getAllRelatedGroupSection() {
            return buildRelatedGroupSectionList(true);
        }
    
        private List<Group_Section__c> buildRelatedGroupSectionList(Boolean ignoreMultipleRelatedBAs){
            Set<id> ba_gs_set = new Set<id>();
            Set<id> TempGSids = new Set<id>();
            List<Group_Section__c> GroupSEcList = new List<Group_Section__c>();
            try {
                for (BA_GS_Assignment__c ba_gs : [select id, Group_Section__c from BA_GS_Assignment__c where Benefit_Agreement__c in: BAIds and Group_Section__r.Status__c = 'Active' ]) {
                    TempGSids.add(ba_gs.Group_Section__c);
                }
                if (TempGSids.size() > 0)
                    for (BA_GS_Assignment__c ba_gs : [select id, Benefit_Agreement__c, Group_Section__c from BA_GS_Assignment__c where Group_Section__c in: TempGSids ]) {
                        if (ba_gs_mapGrpSec.get(ba_gs.Group_Section__c) == null) {
                            Set<id> newIds = new Set<id>();
                            newIds.add(ba_gs.Benefit_Agreement__c);
                            ba_gs_mapGrpSec.put(ba_gs.Group_Section__c, newIds);
                        } else {
                            ba_gs_mapGrpSec.get(ba_gs.Group_Section__c).add(ba_gs.Benefit_Agreement__c);
                        }
    
                    }
                if (ba_gs_mapGrpSec.size() > 0)
                    for (Id gsid : ba_gs_mapGrpSec.keyset()) {
                        if (ignoreMultipleRelatedBAs){
                            ba_gs_set.add(gsid);
                        } else if (ba_gs_mapGrpSec.get(gsid).size() == 1) {
                            ba_gs_set.add(gsid);
                        } else if (ba_gs_mapGrpSec.get(gsid).size() > 1) {
                            if (BAIds.size() > ba_gs_mapGrpSec.get(gsid).size() &&  BAIds.containsAll(ba_gs_mapGrpSec.get(gsid))) {
                                ba_gs_set.add(gsid);
                            }
                        }
                    }
    
                if (ba_gs_set.size() > 0)
                    GroupSEcList = [    select  id , name , Cancellation_Code__c, Cancellation_Date__c, Cancellation_Explanation__c, Cancellation_Reason__c,
                                        Cancellation_Status__c, Requested_Cancellation_Date__c, Certs_Cancelling__c, Members_Cancelling__c , Section_Number__c ,
                                        Status__c, Group_Account__c, Group_Account__r.name, Name__c, Total_Active_Members__c, Total_Active_Subscribers__c, Group_Number__c
                                        from    Group_Section__c
                                        where   id          IN :ba_gs_set
                                        and Status__c   = 'Active'
                                                          and (   Cancellation_Status__c != :ConstantsController.pendingApprovalStatus
                                                                  and Cancellation_Status__c != :ConstantsController.cancelledStatus
                                                                  and Cancellation_Status__c != :ConstantsController.submittedStatus
                                                                  and Cancellation_Status__c != :ConstantsController.requestedCancellationStatus)
                                                          limit: Limits.getLimitQueryRows() - Limits.getQueryRows()];
                List<id> ids = new List<id>();
                for (Group_Section__c grpSec : GroupSEcList) {
                    ids.addall(ba_gs_mapGrpSec.get(grpSec.id));
                    if (ba_gs_mapGrpSec.get(grpSec.id) != null && BaIdRecMap.get(ids[0]) != null) {
                        grpSec.Cancellation_Explanation__c = BaIdRecMap.get(ids[0]).Cancellation_Explanation__c;
                        grpSec.Cancellation_Reason__c      = BaIdRecMap.get(ids[0]).Cancellation_Reason__c;
                        grpSec.Requested_Cancellation_Date__c = BaIdRecMap.get(ids[0]).Requested_Cancellation_Date__c;
                        grpSec.Cancellation_Code__c  = BaIdRecMap.get(ids[0]).Cancellation_Code__c;
                    }
                }
            } catch (Exception ex) {
                //CreateExceptionLog.insertErrorLog(ex, null, null, null, 'Apex Class', 'Account', null, 'AccountCancellationClass.getRelatedGroupSection()','High');
                system.debug('ERROR: ' + ex.getMessage() + '  ' + ex.getStackTraceString());
            }
            return GroupSEcList;
        }      

        public pageReference MassUpdateBenefitAgree() {
                Boolean SelctedFlag = false;

                for (BenefitAgreementWrapper gsw : BAWrapperList) {
                        if (gsw.entrySelected) {
                                if (CancelExplanation != '') {
                                        gsw.entry.Cancellation_Explanation__c = CancelExplanation;
                                }
                                if (CancelReason != '') {
                                        gsw.entry.Cancellation_Reason__c = CancelReason;
                                }
                                if (Date.parse(StringCancelDate) != null) {
                                        gsw.entry.Requested_Cancellation_Date__c = Date.parse(StringCancelDate);
                                }
                                if (CancelCode != '') {
                                        gsw.entry.Cancellation_Code__c = CancelCode;
                                }

                                SelctedFlag = true;
                        }
                }
                if (!SelctedFlag) {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, system.label.AccountCancellationClassError1));
                }
                return null;
        }

        public pageReference FinishBenefitAgreeCancel() {
                List<Benefit_Agreement__c> benefitAgreementList = new List<Benefit_Agreement__c> ();
                List<Group_Section__c> UpdateRelatedGroupSection = new List<Group_Section__c> ();
                List<id> ids = new List<id> ();
                if (benefitAgreementList != null)
                for (BenefitAgreementWrapper benAgrWrp : SelectedBAWrapperList) {
                        benAgrWrp.entry.Cancellation_Status__c = 'Requested Cancellation';
                        benefitAgreementList.add(benAgrWrp.entry);
                }
                for (GroupSectionWrapper grpSec : RelatedGroupSectionWrapper) {
                        if (grpSec.entrySelected == true) {
                                grpSec.entry.Cancellation_Status__c = 'Requested Cancellation';
                                UpdateRelatedGroupSection.add(grpSec.entry);
                        }
                }

                try {
                        if (benefitAgreementList != null && benefitAgreementList.size() > 0)
                        update benefitAgreementList;
                        if (UpdateRelatedGroupSection != null && UpdateRelatedGroupSection.size() > 0)
                        update UpdateRelatedGroupSection;
                        pageReference pg = new pageReference('/' + accountId);
                        return pg;
                } catch(DMLException ex) {
                        //CreateExceptionLog.insertErrorLog(ex, null, null, null, 'Apex Class', 'Account', null, 'AccountCancellationClass.FinishBenefitAgreeCancel()','High');
                        system.debug('ERROR: ' + ex.getMessage() + '  ' + ex.getStackTraceString());
                        return null;
                }
        }

        public pageReference backToBenefitAgreementCan() {
                accountId = ApexPages.currentPage().getParameters().get('id');
                selectedBAWrapperList.clear();
                ResetMassUpdateValues(new Benefit_Agreement__c());
                benefitAgreementSectionToggle = true;
                return null;
                /*
                  pageReference pg = new pageReference('/apex/AccountCancellationBenefitAgreement?id='+accountId);
                  return pg;
                 */
        }

        public PageReference MoveTonextBenefitAgreePage() {

                Pagereference p;
                Boolean SelctedFlag = false;
                Boolean AllSelected = true;
                Date TodayDate = system.Today();
                List<Benefit_Agreement__c> RequestedDateBAList = new List<Benefit_Agreement__c> ();
                getSelectedBAWrapperList();

               
                List<Group_Section__c> relatedGSList = getAllRelatedGroupSection();
                
                Map<Id, Benefit_Agreement__c> activeBAWithActiveGS;
                Set<Id> currBAs = new Set<Id> ();

                // Loops through the Group Sections related to the Benefit Agreements and grabs all the BAs Ids
                // that have Group Sections with active members
                for (Integer i = 0; i < relatedGSList.size(); i++) {
                        if (relatedGSList[i].Total_Active_Members__c > 0) {
                                currBAs.addAll(ba_gs_mapGrpSec.get(relatedGSList[i].Id));
                        }
                }

                // Grabs the Benefit Agreements from the Ids gathered above
                if (!currBAs.isEmpty()) {
                        activeBAWithActiveGS = new Map<Id, Benefit_Agreement__c> ([Select Id, Name from Benefit_Agreement__c where Id in :currBAs limit :Limits.getLimitQueryRows() - Limits.getQueryRows()]);
                }

                String errorBAs = '';
                for (BenefitAgreementWrapper gsw : BAWrapperList) {
                        if (gsw.entrySelected) {

                                Benefit_Agreement__c currBA;

                                if (activeBAWithActiveGS != null)
                                currBA = activeBAWithActiveGS.get(gsw.entry.Id);
                                // Builds the error string with the names of Benefit Agreements that have related Group Sections with Active Members
                                if (currBA != null)
                                errorBAs = errorBAs + currBA.Name + '  ';

                                SelctedFlag = true;
                                if (gsw.entry.Requested_Cancellation_Date__c != null && gsw.entry.Cancellation_Explanation__c != null && gsw.entry.Cancellation_Reason__c != null && gsw.entry.Cancellation_Code__c != null) {
                                        if (gsw.entry.Requested_Cancellation_Date__c != null) {
                                                if (gsw.entry.Requested_Cancellation_Date__c.daysBetween(TodayDate) > 60) {
                                                        RequestedDateBAList.add(gsw.entry);
                                                }
                                        }

                                } else {
                                        ba_gs_mapGrpSec.clear();
                                        BAIds.clear();
                                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, system.label.AccountCancellationClassError2));
                                        return null;
                                }
                        } else {
                                AllSelected = false;
                        }
                }
                if (!SelctedFlag) {
                        ba_gs_mapGrpSec.clear();
                        BAIds.clear();
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, system.label.AccountCancellationClassError1));
                        return null;
                } else if (AllSelected) {
                        ba_gs_mapGrpSec.clear();
                        BAIds.clear();
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, system.label.AccountCancellationClassError4));
                        return null;
                        // p  = new Pagereference('/apex/CancellationReviewPage');
                } else if (RequestedDateBAList.size() > 0) {
                        DisplayMessage = system.label.AccountCancellationClassError7;
                        /*for(Benefit_Agreement__c BenAg : RequestedDateBAList){
                          DisplayMessage += ' ' + BenAg.Name;
                          }*/
                        //ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, DisplayMessage));
                        ba_gs_mapGrpSec.clear();
                        BAIds.clear();
                        showMessagepanel = true;
                        return null;
                } else if (errorBAs != '') {
                        ba_gs_mapGrpSec.clear();
                        BAIds.clear();
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, system.label.AccountCancellationClassError9 + errorBAs));
                        return null;
                }
                else {
                        benefitAgreementSectionToggle = false;
                        return null;
                }
                /*
                  if(p!=null)
                  p.setRedirect(false);
                  return p;
                 */
        }

        public pageReference HideMessagePanelBA() {
                showMessagepanel = false;
                benefitAgreementSectionToggle = false;
                return null;
        }

        /*******************************************************************Billing Section**********************************************************************************************/

        public List<Billing__c> getBillingList() {
                List<Billing__c> billingList;
                try {
                        billingList = [select id, name, Cancellation_Code__c, Requested_Cancellation_Date__c, Cancellation_Explanation__c, Cancellation_Reason__c,
                                       Cancellation_Submitted_Date__c, Status__c, Group_Account__c, Group_Account__r.name, Cancellation_Status__c, External_ID__c
                                       from Billing__C
                                       where Group_Account__c = :accountId
                                       and(Cancellation_Status__c != :ConstantsController.pendingApprovalStatus
                                           and Cancellation_Status__c != :ConstantsController.cancelledStatus
                                           and Cancellation_Status__c != :ConstantsController.submittedStatus
                                           and Cancellation_Status__c != :ConstantsController.requestedCancellationStatus)
                                       limit :Limits.getLimitQueryRows() - Limits.getQueryRows()];

                } catch(Exception ex) {
                        //CreateExceptionLog.insertErrorLog(ex, null, null, null, 'Apex Class', 'Account', null, 'AccountCancellationClass.getBillingList()','High');
                        system.debug('ERROR: ' + ex.getMessage() + '  ' + ex.getStackTraceString());
                        return null;
                }
                return billingList;
        }


        public void getBillingProfileWrapperList() {
                List<Billing__c> bpList = getBillingList();

                try {
                        if (bpList != null && bpList.size() > 0) {
                                for (Billing__c billing : bpList) {
                                        BillingWrapperList.add(new BiilingProfileWrapper(false, billing));
                                }
                        }
                } catch(Exception ex) {
                        //CreateExceptionLog.insertErrorLog(ex, null, null, null, 'Apex Class', 'Account', null, 'AccountCancellationClass.getBillingProfileWrapperList()','High');
                        system.debug('ERROR: ' + ex.getMessage() + '  ' + ex.getStackTraceString());
                }

        }

        public List<BiilingProfileWrapper> getSeelectedBillingWrapperList() {
                SelectedBillingWrapperList.clear();
                for (BiilingProfileWrapper gsw : BillingWrapperList) {
                        if (gsw.entrySelected) {
                                SelectedBillingWrapperList.add(gsw);
                        }
                }
                return SelectedBillingWrapperList;
        }

        public pageReference MassUpdateBilling() {
                Boolean SelctedFlag = false;

                for (BiilingProfileWrapper gsw : BillingWrapperList) {
                        if (gsw.entrySelected) {
                                if (CancelExplanation != '') {
                                        gsw.entry.Cancellation_Explanation__c = CancelExplanation;
                                }
                                if (CancelReason != '') {
                                        gsw.entry.Cancellation_Reason__c = CancelReason;
                                }
                                if (Date.parse(StringCancelDate) != null) {
                                        gsw.entry.Requested_Cancellation_Date__c = Date.parse(StringCancelDate);
                                }
                                if (CancelCode != '') {
                                        gsw.entry.Cancellation_Code__c = CancelCode;
                                }

                                SelctedFlag = true;
                        }
                }
                if (!SelctedFlag) {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, system.label.AccountCancellationClassError1));
                }
                return null;
        }

        public pageReference showselectedBillingProf() {
                Boolean SelctedFlag = false;
                Boolean AllSelected = true;
                Date TodayDate = system.Today();
                List<billing__C> billingList = new List<billing__C> ();
                List<billing__c> RequestedDateBPList = new List<billing__c> ();
                getSeelectedBillingWrapperList();
                for (BiilingProfileWrapper gsw : BillingWrapperList) {
                        if (gsw.entrySelected) {
                                SelctedFlag = true;
                                if (gsw.entry.Requested_Cancellation_Date__c != null && gsw.entry.Cancellation_Explanation__c != null && gsw.entry.Cancellation_Reason__c != null && gsw.entry.Cancellation_Code__c != null) {
                                        if (gsw.entry.Requested_Cancellation_Date__c != null) {
                                                if (gsw.entry.Requested_Cancellation_Date__c.daysBetween(TodayDate) > 60) {
                                                        RequestedDateBPList.add(gsw.entry);
                                                }
                                        }
                                } else {
                                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, system.label.AccountCancellationClassError2));
                                        return null;
                                }
                        } else {
                                AllSelected = false;
                        }
                }
                
                if (!SelctedFlag) {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, system.label.AccountCancellationClassError1));
                        return null;
                } else if (AllSelected) {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, system.label.AccountCancellationClassError3));
                        return null;
                        // p  = new Pagereference('/apex/CancellationReviewPage');
                } else if (RequestedDateBPList.size() > 0) {
                        DisplayMessage = system.label.AccountCancellationClassError8;
                        /*for(billing__C Bill : billingList){
                          DisplayMessage += ' ' + Bill.Name;
                          }*/
                        //ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, DisplayMessage));
                        showMessagepanel = true;
                        return null;
                } else {
                        displayBillingsection = true;
                        return null;
                }
        }
        public pageReference backTobillingsection() {
                ResetMassUpdateValues(new Billing__c());
                SelectedBillingWrapperList.clear();
                displayBillingsection = false;
                return null;
        }

        public pageReference FinishBillingProfileCancel() {
                List<billing__C> billingList = new List<billing__c> ();
                List<id> ids = new List<id> ();
                if (billingList != null)
                for (BiilingProfileWrapper gsw : selectedBillingWrapperList) {
                        gsw.entry.Cancellation_Status__c = 'Requested Cancellation';
                        billingList.add(gsw.entry);
                }

                try {
                        if (billingList != null && billingList.size() > 0)
                        update billingList;

                        pageReference pg = new pageReference('/' + accountId);
                        return pg;
                } catch(DMLException ex) {
                        //CreateExceptionLog.insertErrorLog(ex, null, null, null, 'Apex Class', 'Account', null, 'AccountCancellationClass.FinishBillingProfileCancel()','High');
                        system.debug('ERROR: ' + ex.getMessage() + '  ' + ex.getStackTraceString());
                        return null;
                }
        }

        public pageReference HideMessagePanelBP() {
                showMessagepanel = false;
                displayBillingsection = true;
                return null;
        }



        public static list<SelectOption> getPicklistValues(SObject obj, String fld) {
                list<SelectOption> options = new list<SelectOption> ();
                // Get the object type of the SObject.
                Schema.sObjectType objType = obj.getSObjectType();
                // Describe the SObject using its object type.
                Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
                // Get a map of fields for the SObject
                map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();
                // Get the list of picklist values for this field.
                list<Schema.PicklistEntry> values = fieldMap.get(fld).getDescribe().getPickListValues();
                // Add these values to the selectoption list.
                for (Schema.PicklistEntry a : values) {
                        options.add(new SelectOption(a.getLabel(), a.getValue()));
                }
                return options;
        }

        public void ResetMassUpdateValues(SObject objInstance) {
                CancellationCodePicklist = getPicklistValues(objInstance, 'Cancellation_Code__c');
                CancellationReasonPicklist = getPicklistValues(objInstance, 'Cancellation_Reason__c');
                CancelExplanation = '';
                CancelCode = '';
                StringCancelDate = '';
                CancelReason = '';
        }


        /*********************************************Wrapper class section*****************************************************************************************/
        public class BiilingProfileWrapper {
                public Boolean entrySelected { get; set; }
                public Billing__c entry { get; set; }
                public BiilingProfileWrapper(Boolean b, Billing__c e) {
                        entrySelected = b;
                        entry = e;
                }
        }
        public class GroupSectionWrapper {
                public Boolean entrySelected { get; set; }
                public Group_Section__c entry { get; set; }
                public GroupSectionWrapper(Boolean b, Group_Section__c e) {
                        entrySelected = b;
                        entry = e;
                }
        }

        public class BenefitAgreementWrapper {
                public Boolean entrySelected { get; set; }
                public Benefit_Agreement__c entry { get; set; }
                public Decimal totalActiveGroupSectionMembers {get;set;}
                public BenefitAgreementWrapper(Boolean b, Benefit_Agreement__c e) {
                        totalActiveGroupSectionMembers = 0;
                        for(BA_GS_Assignment__c bags: e.BA_GS_Assignments__r){
                            totalActiveGroupSectionMembers += bags.Group_Section__r.Total_Active_Members__c;
                        }
                        entrySelected = b;
                        entry = e;
                }
        }

}