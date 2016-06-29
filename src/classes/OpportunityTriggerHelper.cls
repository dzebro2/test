public with sharing class OpportunityTriggerHelper {
    /** final variables ***/
    static final String ENTRY_SEPARATOR = ',';
    static final String KEY_SEPARATOR = '__';
    static final String OPP_PROD_OPPORTUNITY_FIELD = 'opportunity__c';
    static final String OPP_PROD_PRODFAMILY_FIELD = 'family';
    static final String OPP_PROD_RECORD_TYPE_FIELD = 'recType';



    public static void updateUserOpporuntityActivity(List<Opportunity> newOpps) {

        Id currUserId = UserInfo.getUserId();
        User currUser = [Select Id, Last_Opp_Activity_Date__c from User Where Id = :currUserId limit 1];
        currUser.Last_Opp_Activity_Date__c = System.now();
        update currUser;
    }

    /**
    * @developer: Abhinav Gadepalli/Deloitte Consulting
    * @description: Method to filter the opportunities for which the playbook records(stage mapping, sub stage mapping and task mapping)
    *               records have to be created. This method is overloaded as there is another method takes an extra param(old trigger map)
    *                to filter the opp records to return records where playbook has been added.
    * @usage: OpportunityTriggerHelper
    *
    */
    public static void filterForCreatePlaybookRecords(List<Opportunity> newOpportunitiesList) {
        List<Opportunity> oppList = new List<Opportunity>();
        if (!recursiveHelper.hascreatedPlaybookRecs()) {
            for (Opportunity opp : newOpportunitiesList) {
                if (opp.Playbook__c != null) {
                    oppList.add(opp);
                }
            }
        }
        if (oppList.size() <> 0) {
            createRecordsForPlaybook(oppList);
            RecursiveHelper.setCreatedPlaybookRecs();
        }
    }

    /**
    * @developer: Abhinav Gadepalli/Deloitte Consulting
    * @description: Method to filter the opportunities for which the playbook records(stage mapping, sub stage mapping and task mapping)
    *                records have to be created. This method is overloaded as the method takes an extra param(old trigger map)
    *                to filter the opp records to return records where playbook has been added.
    * @usage: OpportunityTriggerHelper
    *
    */
    public static void filterForCreatePlaybookRecords(Map<Id, Opportunity> newOpportunititesMap, Map<Id, Opportunity> oldOpportunitiesMap) {
        List<Opportunity> oppList = new List<Opportunity>();
        if (!recursiveHelper.hascreatedPlaybookRecs()) {
            for (Id oppId : newOpportunititesMap.keySet()) {
                if (newOpportunititesMap.get(oppId).Playbook__c <> oldOpportunitiesMap.get(oppId).Playbook__c) {
                    oppList.add(newOpportunititesMap.get(oppId));
                }
            }
        }
        if (oppList.size() <> 0) {
            createRecordsForPlaybook(oppList);
            RecursiveHelper.setCreatedPlaybookRecs();
        }
    }

    /**
    * @description: Method to create the playbook stage, substage and task mapping records when a playbook is added to an opportunity.
    * @usage:       OpportunityTriggerHelper
    *
    */
    public static void createRecordsForPlaybook(List<Opportunity> listOppsForPlaybook) {

        Map<Id, List<Opportunity>> mapOppsByPbId = new Map<Id, List<Opportunity>>();
        Set<Id> setStageIds = new Set<Id>();
        Map<String, Stage_Mapping__c> mapSMByKey = new Map<String, Stage_Mapping__c>();
        Set<Id> setSubstageIds = new Set<Id>();
        Map<String, Substage_Mapping1__c> mapSSMByKey = new Map<String, Substage_Mapping1__c>();
        List<Task_Mapping__c> listTM = new List<Task_Mapping__c>();

        List<Opportunity> listOpps;
        try {
            for (Opportunity opp : listOppsForPlaybook) {
                if (!mapOppsByPbId.containsKey(opp.Playbook__c)) {
                    listOpps = new List<Opportunity>();
                    listOpps.add(opp);
                    mapOppsByPbId.put(opp.Playbook__c, listOpps);
                } else mapOppsByPbId.get(opp.Playbook__c).add(opp);
            }
            Stage_Mapping__c sm;
            for (Playbook__c pb : [SELECT Id, (SELECT Id FROM Stages__r ORDER BY Stage_Sort_Order__c)
                                   FROM Playbook__c WHERE Id IN: mapOppsByPbId.keySet()]) {
                for (Stage__c s : pb.Stages__r)
                    setStageIds.add(s.Id);
                if (mapOppsByPbId.containsKey(pb.Id)) {
                    for (Opportunity opp : mapOppsByPbId.get(pb.Id)) {
                        for (Stage__c s : pb.Stages__r) {
                            sm = new Stage_Mapping__c();
                            sm.Opportunity__c = opp.Id;
                            sm.Playbook__c = pb.Id;
                            sm.Stage__c = s.Id;
                            String key1 = sm.Opportunity__c + '-' + sm.Playbook__c + '-' + sm.Stage__c;
                            mapSMByKey.put(key1, sm);
                        }
                    }
                }
            }

            if (!mapSMByKey.values().isEmpty()) {
                insert mapSMByKey.values();
            }

            Substage_Mapping1__c ssm;
            for (Stage__c s : [SELECT Id, Playbook__c, (SELECT Id, Stage__r.Stage_Sort_Order__c, Substage_Sort_Order__c FROM Substages__r ORDER BY Substage_Sort_Order__c)
                               FROM Stage__c WHERE Id IN: setStageIds]) {
                for (Substage__c ss : s.Substages__r) {
                    setSubstageIds.add(ss.Id);
                    if (mapOppsByPbId.containsKey(s.Playbook__c)) {
                        for (Opportunity o : mapOppsByPbId.get(s.Playbook__c)) {
                            String key2 = o.Id + '-' + s.Playbook__c + '-' + s.Id;
                            if (mapSMByKey.containsKey(key2)) {
                                ssm = new Substage_Mapping1__c();
                                ssm.Substage__c = ss.Id;
                                ssm.Stage_Mapping__c = mapSMByKey.get(key2).Id;
                                if ( ss.Stage__r.Stage_Sort_Order__c == 1 && ss.Substage_Sort_Order__c == 1 ) {
                                    ssm.Started__c          = true;
                                    ssm.Start_DateTime__c   = DateTime.now();
                                }
                                String key3 = key2 + '-' + ssm.Substage__c;
                                mapSSMByKey.put(key3, ssm);
                            }
                        }
                    }
                }
            }

            if (!mapSSMByKey.values().isEmpty()) {
                insert mapSSMByKey.values();
            }
            Task_Mapping__c tm;
            for (Substage__c ss : [SELECT Id, Stage__r.Playbook__c, Stage__c, (SELECT Id FROM Tasks__r ORDER BY Task_Sort_Order__c)
                                   FROM Substage__c WHERE Id IN: setSubstageIds]) {
                for (Task__c t : ss.Tasks__r) {
                    if (mapOppsByPbId.containsKey(ss.Stage__r.Playbook__c)) {
                        for (Opportunity o : mapOppsByPbId.get(ss.Stage__r.Playbook__c)) {
                            String key4 = o.Id + '-' + ss.Stage__r.Playbook__c + '-' + ss.Stage__c + '-' + ss.Id;
                            if (mapSSMByKey.containsKey(key4)) {
                                tm = new Task_Mapping__c();
                                tm.Task__c = t.Id;
                                tm.Substage_Mapping__c = mapSSMByKey.get(key4).Id;
                                listTM.add(tm);
                            }
                        }
                    }
                }
            }

            if (!listTM.isEmpty()) {
                insert listTM;
            }
        } catch (Exception e) {
            CreateExceptionLog.insertErrorLog(e, null, null, null, 'Apex Class', 'Opportunty', null, 'OpportunityTriggerHelper', 'High');
            System.debug( 'Exception : ' + e.getMessage() );
        }
    }


    public static void selectDefaultPlaybook( List<Opportunity> newOpportunities ) {
        Playbook_Settings__c playbookSettings = Playbook_Settings__c.getOrgDefaults();

        Map<String, Id> playbookNameIdMap = new Map<String, Id>();

        for ( Playbook__c plbk : [    select  Id, Name
                                      from    Playbook__c
                                      where   ( Name = :playbookSettings.New_Sale_Default_Playbook__c
                                                or  Name = :playbookSettings.Renewal_Default_Playbook__c )
                                      And Active__c = true
                                              limit   2] ) {
            playbookNameIdMap.put( plbk.Name, plbk.Id );
        }

        Map<ID, RecordType> rt_Map = New Map<ID, RecordType>([Select ID, DeveloperName From RecordType Where sObjectType = 'Opportunity']);

        try {
            for ( Opportunity opp : newOpportunities ) {

                if ( rt_Map.containsKey( opp.RecordTypeId ) && opp.Playbook__c == null ) {
                    if ( rt_Map.get( opp.RecordTypeId ).DeveloperName == 'New_Sale' ) {
                        opp.Playbook__c = playbookNameIdMap.get( playbookSettings.New_Sale_Default_Playbook__c );

                    } else if ( rt_Map.get( opp.RecordTypeId ).DeveloperName == 'Renewal' ) {
                        opp.Playbook__c = playbookNameIdMap.get( playbookSettings.Renewal_Default_Playbook__c );
                    }
                }
            }
        } catch (Exception e) {
            System.debug( 'Error: ' + e.getMessage() );
            CreateExceptionLog.insertErrorLog(e, null, null, null, 'Apex Class', 'Opportunty', null, 'OpportunityTriggerHelper', 'High');
        }

    }
    /**************************************************************************************
      Apex Methos Name    : CreateBAForNonBlueStarProducts
      Version             : 2.0
      Function            : This method creates a benefit agreement from won opportunities that are related to a given account.  These
                            benefit agreements are only created for HCSC Non BlueStar Products that are won for the account

    *************************************************************************************/
    public static void CreateBAForNonBlueStarProducts(Map<Id, Opportunity> OpportunityMap) {
        Set<Id> OpportunityIdSet = new Set<Id>();
        Set<Id> ProductIdSet = new Set<Id>();
        Id BANonBluStarRecordTypeId ;
        BANonBluStarRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get(Label.HCSCNonBlueStar).getRecordTypeId();
        List<Benefit_Agreement__c> BAList = new List<Benefit_Agreement__c>();
        Benefit_Agreement__c BARecord;
        try {
            for (Opportunity oppty : OpportunityMap.values()) {
                if (oppty.IsWon == true) {
                    OpportunityIdSet.add(oppty.Id);
                }
            }

            List<Opportunity_Product__c> OpptyLineItemList = [SELECT Id, Product__c, Opportunity_Name__r.AccountId, Product__r.RecordtypeId FROM Opportunity_Product__c WHERE Opportunity_Name__c IN: OpportunityIdSet AND Product__r.RecordtypeId = :BANonBluStarRecordTypeId];
            for (Opportunity_Product__c opptyLit : OpptyLineItemList) {
                BARecord = new Benefit_Agreement__c();
                BARecord.Product__c = opptyLit.Product__c;
                BARecord.Group_Account__c = opptyLit.Opportunity_Name__r.AccountId;
                BAList.add(BARecord);
            }
            insert BAList;
        } catch (Exception ex) {
            System.debug('#####' + Label.Error + ex.getMessage() + ex.getStackTraceString());
            CreateExceptionLog.insertErrorLog(ex, null, null, null, 'Apex Class', 'Opportunty', null, 'OpportunityTriggerHelper', 'High');
        }
    }
    /********************************************************************
    *    Method Name :   SendChatterNotifications
    *   @description :   This method  will post chatter on case owner when the Opportunity is won/lost/Declined
    *   @parameters  :   map<Id,Case> newCasesMap,map<Id,Case> oldCasesMap
    *   @return type :   none
    ***************************************************************/
    public static void SendChatterNotifications(map<Id, Opportunity> newOpportunitiesMap, map<Id, Opportunity> oldOpportunitiesMap) {
        try {

            set<String> changedOppIds               = new set<String>();
            set<String> CedeuserIds                 = new set<String>();
            set<String> userIds                     = new set<String>();
            set<String> userChatterPosted           = new set<String>();
            list<FeedItem> feedItems                = new list<FeedItem>();
            boolean isCededChatterPosted            = false;
            set<String> accIds                      = new set<String>();
            for (Opportunity opp : newOpportunitiesMap.values()) {
                if (((oldOpportunitiesMap != null && oldOpportunitiesMap.containsKey(opp.Id) && oldOpportunitiesMap.get(opp.Id).stageName != opp.stagename)
                        || (oldOpportunitiesMap == null || !oldOpportunitiesMap.containsKey(opp.Id)))
                        && (constantsController.OpportunityStagesConsideredForChatterPost.contains(opp.stagename))) {
                    changedOppIds.add(opp.Id);
                    if (opp.stagename == 'Won')
                        accIds.add(opp.AccountId);
                }
            }
            for (GroupMember gm : [select UserOrGroupId  from GroupMember where Group.developerName = 'Cede_Team' and Group.type = 'Queue']) {
                CedeuserIds.add(gm.UserOrGroupId);
            }
            for (Account acc : [select Id, RecordType.DeveloperName, Ceded__c, Name from Account where Id In:accIds and Ceded__c = true]) {
                system.debug('====' + acc.RecordType.DeveloperName);
                if (acc.RecordType.DeveloperName == 'Group_Prospect_Account' || acc.RecordType.DeveloperName == 'Prospect_Non_BlueSTAR') {
                    string chatterMessage   = Label.OpporuntiyUpdatePostToChatterMessageCedeCase.replace('<<AccountName>>', acc.name).replace('<<UpdatedOpportunityStage>>', 'Won');
                    //feedItems.addAll(ConstantsController.sendChattertoTeams(CedeuserIds,chatterMessage,'',''));
                    for (String userId : CedeuserIds) {
                        system.debug('=========' + userId);
                        FeedItem post = new FeedItem();
                        post.ParentId =  userId;
                        post.Body = chatterMessage;
                        feedItems.add(post);
                    }
                    isCededChatterPosted = true;
                }
            }
            for (Case caseRec : [select Account.name, Account.Ceded__c, OwnerId, RecordType.Developername, CaseNumber, Opportunity_Name__c, Opportunity_Name__r.Name, Opportunity_Name__r.StageName
                                 from Case where Opportunity_Name__c In :changedOppIds and
                                 (RecordType.Developername In : ConstantsController.caseRecordTypePermissibleWhenOppUpdatedChatter)]) {
                string caseLinkId                   = URL.getSalesforceBaseUrl().toExternalForm() + '/' + caseRec.Opportunity_Name__c;
                string caseTitle                    = caseRec.Opportunity_Name__r.Name;
                string chatterMessage               = Label.OpporuntiyUpdatePostToChatterMessage.replace('<<AccountName>>', caseRec.Account.name).replace('<<UpdatedOpportunityStage>>', caseRec.Opportunity_Name__r.StageName);
                if (caseRec.RecordType.Developername != 'Cede') {
                    userIds                         = new set<String>();
                    userIds.add(caseRec.OwnerId);
                    if (!userChatterPosted.contains(caseRec.OwnerId)) {
                        feedItems.addAll(ConstantsController.sendChattertoTeams(userIds, chatterMessage, caseLinkId, caseTitle));
                        userChatterPosted.add(caseRec.OwnerId);
                    }
                } else {
                    if (!isCededChatterPosted && caseRec.Account.Ceded__c) {
                        chatterMessage              = Label.OpporuntiyUpdatePostToChatterMessageCedeCase.replace('<<AccountName>>', caseRec.Account.name).replace('<<UpdatedOpportunityStage>>', caseRec.Opportunity_Name__r.StageName);
                        feedItems.addAll(ConstantsController.sendChattertoTeams(CedeuserIds, chatterMessage, caseLinkId, caseTitle));
                        isCededChatterPosted = true;
                    }
                }
            }
            if (feedItems.size() > 0)
                insert feedItems;

        } catch (Exception e) {
            CreateExceptionLog.insertErrorLog(e, null, null , null, 'SendChatterNotifications', 'Opportunity', 'OpportunityTrigger', 'OpportunityTriggerHelper.SendChatterNotifications', 'High');

        }
    }

    /**
    * @developer: Alec Klein, Sana Fatima, Dan Zebrowski/Slalom LLC
    * @description: Method to populate certain fields on the Opportunity object based on the values of the Account
    *               record in the lookup.
    * @usage: OpportunityTriggerHelper
    *
    */
    public static void PopulateFieldsFromAccount(List<Opportunity> newOpportunities) {
        try {
            Set<Id> oppAccountIds = new Set<Id>();
            for (Opportunity opp : newOpportunities) {
                if (opp.AccountId != null)
                    oppAccountIds.add(opp.AccountId);
            }
            Map<ID, Account> oppAccountMap = new Map<ID, Account>([SELECT Id, Active_Dental_Members__c, Active_Dental_Subscribers__c,
                    Active_Health_Members__c, Active_Health_Subscribers__c, HCSC_Division__c, Market_Segment__c, Cluster__c, Region__c, District__c FROM Account WHERE Id IN :oppAccountIds]);

            for (Opportunity opp : newOpportunities) {
                if (opp.AccountId != null) {
                    Account acc = oppAccountMap.get(opp.AccountId);
                    Map<ID, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.Opportunity.getRecordTypeInfosById();
                    String recordTypeName = rtMap.get(opp.RecordTypeId).getName();

                    if (acc.HCSC_Division__c != null) {
                        opp.HCSC_Division__c = acc.HCSC_Division__c;
                    }
                    if (acc.Market_Segment__c != null) {
                        opp.Account_Market_Segment__c = acc.Market_Segment__c;
                    }
                    if (acc.Cluster__c != null) {
                        opp.Clusters__c = acc.Cluster__c;
                    }
                    if (acc.Region__c != null) {
                        opp.Region__c = acc.Region__c;
                    }
                    if (acc.District__c != null) {
                        opp.District__c = acc.District__c;
                    }

                    if (recordTypeName == 'Renewal') {
                        if (acc.Active_Dental_Members__c != null)
                            opp.Expected_Dental_Members__c = acc.Active_Dental_Members__c;
                        if (acc.Active_Dental_Subscribers__c != null)
                            opp.Expected_Dental_Contracts__c = acc.Active_Dental_Subscribers__c;
                        if (acc.Active_Health_Members__c != null)
                            opp.Expected_Health_Members__c = acc.Active_Health_Members__c;
                        if (acc.Active_Health_Subscribers__c != null)
                            opp.Expected_Health_Contracts__c = acc.Active_Health_Subscribers__c;
                    }
                }
            }
        } catch (Exception e) {
            System.debug( 'Exception : ' + e.getMessage());
        }
    }
    /**
    * @developer: Nick Serafin/Slalom LLC
    * @description: Method to pre-populate products on Renewal Opportunities from active BenefitAgreements
    *               on the related account
    * @usage: OpportunityTriggerHelper
    *
    */

    public static void PopulateRenewalProducts(List<Opportunity> newOpportunities) {

        try {
            String Cancelled = Label.Cancelled;
            String Active = Label.Active;
            String Won = Label.WonP;
            List<Opportunity> opp = new List<Opportunity>();
            List<Benefit_Agreement__c> benagr = new List<Benefit_Agreement__c>();
            Set<Id> oppAccountIds = new Set<Id>();
            Id oppId;

            for (Opportunity op : newOpportunities) {
                if (op.AccountId != null) {
                    oppAccountIds.add(op.AccountId);
                }
                oppId = op.Id;
            }

            Id renewalRecordTypeId;
            Id newSaleRecordTypeId;
            newSaleRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(Label.ProductTypeN).getRecordTypeId();
            renewalRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(Label.ProductTypeR).getRecordTypeId();
            
            opp = [SELECT Id, RecordTypeId, HCSC_Division__c, AccountId FROM Opportunity WHERE Id = :oppId];            
                        

            benagr = [SELECT Product__c,Product__r.Product_Type__c, Product__r.HCSC_State__c, Product__r.Simplified_Product__c, Funding_type__c,(select Group_Section__r.Total_Dental_Active_Members__c,
                                                                        Group_Section__r.Total_Healthcare_Active_Members__c, Group_Section__r.Total_Active_Subscribers__c 
                                                                        from BA_GS_Assignments__r where Group_Section__r.Status__c = :Active), 
                                                                        Premium_Type__c FROM Benefit_Agreement__c WHERE Status__c = :Active AND Group_Account__c IN :oppAccountIds AND Effective_Date__c < :System.today()
                           and(Cancellation_Status__c != :Cancelled and Status__c != :Cancelled)
                           ORDER BY Product__r.Product_Type__c ASC limit :Limits.getLimitQueryRows() - Limits.getQueryRows()];
                                   

            Map<String, List<Benefit_Agreement__c>> bagrMap = new Map<String, List<Benefit_Agreement__c>>();
            for (Benefit_Agreement__c b : benagr) {
                List<Benefit_Agreement__c> be = new List<Benefit_Agreement__c>();

                if (bagrMap.containsKey(b.Product__r.Simplified_Product__c)) {
                    be = bagrMap.get(b.Product__r.Simplified_Product__c);
                }

                be.add(b);
                bagrMap.put(b.Product__r.Simplified_Product__c, be);
            }

            Map<String, Set<String>> fundMap = new Map<String, Set<String>>();
            for (Benefit_Agreement__c b : benagr) {
                Set<String> ba = new Set<String>();

                if (fundMap.containsKey(b.Product__r.Simplified_Product__c)) {
                    ba = fundMap.get(b.Product__r.Simplified_Product__c);
                }

                ba.add(b.Funding_Type__c);
                fundMap.put(b.Product__r.Simplified_Product__c, ba);
            }

            List<String> prods = new List<String>();
            for (String b : bagrMap.keySet()) {
                String product = bagrMap.get(b)[0].Product__r.Simplified_Product__c;
                prods.add(product);
            }

            Map<String, List<Product2>> prodMap = new Map<String, List<Product2>>();

            List<Product2> prod = new List<Product2>();
            prod = [SELECT Id, Name FROM Product2 WHERE NotSimple__c = false AND Name IN :prods AND HCSC_State__c = :opp[0].HCSC_Division__c];

            for (Product2 p : prod) {
                List<Product2> Nprod = new List<Product2>();
                Nprod.add(p);
                prodMap.put(p.Name, Nprod);
            }

            List<Opportunity_Product__c> NewProductList = new List<Opportunity_Product__c>();

            decimal memberCountACAP;
            decimal memberCountPREM;
            decimal memberCountASO;
            decimal memberCountCOST;
            decimal memberCountMPP;
            decimal memberCountPAR;
            decimal memberCountSERV;

			decimal memberCountACAPContracts;
            decimal memberCountPREMContracts;
            decimal memberCountASOContracts;
            decimal memberCountCOSTContracts;
            decimal memberCountMPPContracts;
            decimal memberCountPARContracts;
            decimal memberCountSERVContracts;
            
            for(Opportunity opps : newOpportunities){

                if(opps.AccountId != NULL){ 

                    if(opps.RecordTypeId == renewalRecordTypeId){                                   
                    
                        for (String b : bagrMap.keySet())
                        {       
                         
                            List<Benefit_Agreement__c> ba = new List<Benefit_Agreement__c>();
                            ba = bagrMap.get(b);
                            memberCountACAP = 0;                            
                            memberCountPREM = 0;
                            memberCountASO = 0;
                            memberCountCOST = 0;
                            memberCountMPP = 0;
                            memberCountPAR = 0;
                            memberCountSERV = 0;

                            memberCountACAPContracts = 0;                           
                            memberCountPREMContracts = 0;
                            memberCountASOContracts = 0;
                            memberCountCOSTContracts = 0;
                            memberCountMPPContracts = 0;
                            memberCountPARContracts = 0;
                            memberCountSERVContracts = 0;

                            for (Benefit_Agreement__c ab : ba)
                            {
                              if(ab.Funding_Type__c == Label.ACAP){
                                for(BA_GS_Assignment__c bagsAgrrement : ab.BA_GS_Assignments__r){   
                                                
                                    if(ab.Product__r.Product_Type__c == Label.ProductTypeM){                    
                                        if(bagsAgrrement.Group_Section__r.Total_Healthcare_Active_Members__c !=null)
                                            memberCountACAP += bagsAgrrement.Group_Section__r.Total_Healthcare_Active_Members__c;
                                    }
                                    else if(ab.Product__r.Product_Type__c == Label.ProductTypeD){
                                        if(bagsAgrrement.Group_Section__r.Total_Dental_Active_Members__c !=null)
                                            memberCountACAP += bagsAgrrement.Group_Section__r.Total_Dental_Active_Members__c;
                                    } 
                                }
                                for(BA_GS_Assignment__c bagsAgrrement : ab.BA_GS_Assignments__r){
                                    if (ab.Product__r.Product_Type__c == Label.ProductTypeM){
                                                if(bagsAgrrement.Group_Section__r.Total_Active_Subscribers__c !=null)
                                                    memberCountACAPContracts += bagsAgrrement.Group_Section__r.Total_Active_Subscribers__c;
                                    }
                                    else if (ab.Product__r.Product_Type__c == Label.ProductTypeD){
                                                if(bagsAgrrement.Group_Section__r.Total_Active_Subscribers__c !=null)
                                                    memberCountACAPContracts += bagsAgrrement.Group_Section__r.Total_Active_Subscribers__c;
                                    }
                                    
                                }
                                                                                                                                
                              } else if (ab.Funding_Type__c == Label.PREM){
                                for(BA_GS_Assignment__c bagsAgrrement : ab.BA_GS_Assignments__r){   
                                                
                                    if(ab.Product__r.Product_Type__c == Label.ProductTypeM){                    
                                        if(bagsAgrrement.Group_Section__r.Total_Healthcare_Active_Members__c !=null)
                                            memberCountPREM += bagsAgrrement.Group_Section__r.Total_Healthcare_Active_Members__c;
                                    }
                                    else if(ab.Product__r.Product_Type__c == Label.ProductTypeD){
                                        if(bagsAgrrement.Group_Section__r.Total_Dental_Active_Members__c !=null)
                                            memberCountPREM += bagsAgrrement.Group_Section__r.Total_Dental_Active_Members__c;
                                    }
                                }
                                for(BA_GS_Assignment__c bagsAgrrement : ab.BA_GS_Assignments__r){
                                    if (ab.Product__r.Product_Type__c == Label.ProductTypeM){
                                                if(bagsAgrrement.Group_Section__r.Total_Active_Subscribers__c !=null)
                                                    memberCountPREMContracts += bagsAgrrement.Group_Section__r.Total_Active_Subscribers__c;
                                    }
                                    else if (ab.Product__r.Product_Type__c == Label.ProductTypeD){
                                                if(bagsAgrrement.Group_Section__r.Total_Active_Subscribers__c !=null)
                                                    memberCountPREMContracts += bagsAgrrement.Group_Section__r.Total_Active_Subscribers__c;
                                    }
                                }           
                              } else if (ab.Funding_Type__c == Label.ASO){
                                for(BA_GS_Assignment__c bagsAgrrement : ab.BA_GS_Assignments__r){   
                                                
                                    if(ab.Product__r.Product_Type__c == Label.ProductTypeM){                    
                                        if(bagsAgrrement.Group_Section__r.Total_Healthcare_Active_Members__c !=null)
                                            memberCountASO += bagsAgrrement.Group_Section__r.Total_Healthcare_Active_Members__c;
                                    }
                                    else if(ab.Product__r.Product_Type__c == Label.ProductTypeD){
                                        if(bagsAgrrement.Group_Section__r.Total_Dental_Active_Members__c !=null)
                                            memberCountASo += bagsAgrrement.Group_Section__r.Total_Dental_Active_Members__c;
                                    }
                                }
                                for(BA_GS_Assignment__c bagsAgrrement : ab.BA_GS_Assignments__r){
                                    if (ab.Product__r.Product_Type__c == Label.ProductTypeM){
                                                if(bagsAgrrement.Group_Section__r.Total_Active_Subscribers__c !=null)
                                                    memberCountASOContracts += bagsAgrrement.Group_Section__r.Total_Active_Subscribers__c;
                                    }
                                    else if (ab.Product__r.Product_Type__c == Label.ProductTypeD){
                                                if(bagsAgrrement.Group_Section__r.Total_Active_Subscribers__c !=null)
                                                    memberCountASOContracts += bagsAgrrement.Group_Section__r.Total_Active_Subscribers__c;
                                    }
                                }                                       
                            } else if (ab.Funding_Type__c == Label.COST){
                                for(BA_GS_Assignment__c bagsAgrrement : ab.BA_GS_Assignments__r){   
                                                
                                    if(ab.Product__r.Product_Type__c == Label.ProductTypeM){                    
                                        if(bagsAgrrement.Group_Section__r.Total_Healthcare_Active_Members__c !=null)
                                            memberCountCOST += bagsAgrrement.Group_Section__r.Total_Healthcare_Active_Members__c;
                                    }
                                    else if(ab.Product__r.Product_Type__c == Label.ProductTypeD){
                                        if(bagsAgrrement.Group_Section__r.Total_Dental_Active_Members__c !=null)
                                            memberCountCOST += bagsAgrrement.Group_Section__r.Total_Dental_Active_Members__c;
                                    }
                                }
                                for(BA_GS_Assignment__c bagsAgrrement : ab.BA_GS_Assignments__r){
                                    if (ab.Product__r.Product_Type__c == Label.ProductTypeM){
                                                if(bagsAgrrement.Group_Section__r.Total_Active_Subscribers__c !=null)
                                                    memberCountCOSTContracts += bagsAgrrement.Group_Section__r.Total_Active_Subscribers__c;
                                    }
                                    else if (ab.Product__r.Product_Type__c == Label.ProductTypeD){
                                                if(bagsAgrrement.Group_Section__r.Total_Active_Subscribers__c !=null)
                                                    memberCountCOSTContracts += bagsAgrrement.Group_Section__r.Total_Active_Subscribers__c;
                                    }
                                }           
                        } else if (ab.Funding_Type__c == Label.MPP){
                                for(BA_GS_Assignment__c bagsAgrrement : ab.BA_GS_Assignments__r){   
                                                
                                    if(ab.Product__r.Product_Type__c == Label.ProductTypeM){                    
                                        if(bagsAgrrement.Group_Section__r.Total_Healthcare_Active_Members__c !=null)
                                            memberCountMPP += bagsAgrrement.Group_Section__r.Total_Healthcare_Active_Members__c;
                                    }
                                    else if(ab.Product__r.Product_Type__c == Label.ProductTypeD){
                                        if(bagsAgrrement.Group_Section__r.Total_Dental_Active_Members__c !=null)
                                            memberCountMPP += bagsAgrrement.Group_Section__r.Total_Dental_Active_Members__c;
                                    }
                                }
                                for(BA_GS_Assignment__c bagsAgrrement : ab.BA_GS_Assignments__r){   
                                    if (ab.Product__r.Product_Type__c == Label.ProductTypeM){
                                                if(bagsAgrrement.Group_Section__r.Total_Active_Subscribers__c !=null)
                                                    memberCountMPPContracts += bagsAgrrement.Group_Section__r.Total_Active_Subscribers__c;
                                    }
                                    else if (ab.Product__r.Product_Type__c == Label.ProductTypeD){
                                                if(bagsAgrrement.Group_Section__r.Total_Active_Subscribers__c !=null)
                                                    memberCountMPPContracts += bagsAgrrement.Group_Section__r.Total_Active_Subscribers__c;
                                    }
                                }
                        } else if (ab.Funding_Type__c == Label.PAR){
                                for(BA_GS_Assignment__c bagsAgrrement : ab.BA_GS_Assignments__r){   
                                                
                                    if(ab.Product__r.Product_Type__c == Label.ProductTypeM){                    
                                        if(bagsAgrrement.Group_Section__r.Total_Healthcare_Active_Members__c !=null)
                                            memberCountPAR += bagsAgrrement.Group_Section__r.Total_Healthcare_Active_Members__c;
                                    }
                                    else if(ab.Product__r.Product_Type__c == Label.ProductTypeD){
                                        if(bagsAgrrement.Group_Section__r.Total_Dental_Active_Members__c !=null)
                                            memberCountPAR += bagsAgrrement.Group_Section__r.Total_Dental_Active_Members__c;
                                    }
                                }
                                for(BA_GS_Assignment__c bagsAgrrement : ab.BA_GS_Assignments__r){   
                                    if (ab.Product__r.Product_Type__c == Label.ProductTypeM){
                                                if(bagsAgrrement.Group_Section__r.Total_Active_Subscribers__c !=null)
                                                    memberCountPARContracts += bagsAgrrement.Group_Section__r.Total_Active_Subscribers__c;
                                    }
                                    else if (ab.Product__r.Product_Type__c == Label.ProductTypeD){
                                                if(bagsAgrrement.Group_Section__r.Total_Active_Subscribers__c !=null)
                                                    memberCountPARContracts += bagsAgrrement.Group_Section__r.Total_Active_Subscribers__c;
                                    }
                                }
                        }else {
                                for(BA_GS_Assignment__c bagsAgrrement : ab.BA_GS_Assignments__r){   
                                                
                                    if(ab.Product__r.Product_Type__c == Label.ProductTypeM){                    
                                        if(bagsAgrrement.Group_Section__r.Total_Healthcare_Active_Members__c !=null)
                                            memberCountSERV += bagsAgrrement.Group_Section__r.Total_Healthcare_Active_Members__c;
                                    }
                                    else if(ab.Product__r.Product_Type__c == Label.ProductTypeD){
                                        if(bagsAgrrement.Group_Section__r.Total_Dental_Active_Members__c !=null)
                                            memberCountSERV += bagsAgrrement.Group_Section__r.Total_Dental_Active_Members__c;
                                    }
                                }
                                for(BA_GS_Assignment__c bagsAgrrement : ab.BA_GS_Assignments__r){
                                    if (ab.Product__r.Product_Type__c == Label.ProductTypeM){
                                                if(bagsAgrrement.Group_Section__r.Total_Active_Subscribers__c !=null)
                                                    memberCountSERVContracts += bagsAgrrement.Group_Section__r.Total_Active_Subscribers__c;
                                    }
                                    else if (ab.Product__r.Product_Type__c == Label.ProductTypeD){
                                                if(bagsAgrrement.Group_Section__r.Total_Active_Subscribers__c !=null)
                                                    memberCountSERVContracts += bagsAgrrement.Group_Section__r.Total_Active_Subscribers__c;
                                    }
                                }
                        }
                    }                   
                            for (String f : fundMap.get(b)) {

                                Opportunity_Product__c o = new Opportunity_Product__c();
                                o.State__c = opps.HCSC_Division__c;
                                o.Opportunity_Name__c = opps.Id;
                                 if(prodMap.get(b) == null){
                                    o.Product__c = bagrMap.get(b)[0].Product__c;
                                } else {
                                	o.Product__c = prodMap.get(b)[0].Id;
                                }
                                if (f == Label.ACAP) {
                                    o.Projected_Members__c = memberCountACAP;
                                } else if (f == Label.PREM) {
                                    o.Projected_Members__c = memberCountPREM;
                                }  else if (f == Label.ASO) {
                                    o.Projected_Members__c = memberCountASO;
                                }  else if (f == Label.COST) {
                                    o.Projected_Members__c = memberCountCOST;
                                }  else if (f == Label.MPP) {
                                    o.Projected_Members__c = memberCountMPP;
                                }  else if (f == Label.PAR) {
                                    o.Projected_Members__c = memberCountPAR;
                                }  else {
                                    o.Projected_Members__c = memberCountSERV;
                                }

								if(f == Label.ACAP){                               
                                    o.Projected_Contracts__c = memberCountACAPContracts;
                                } else if(f == Label.PREM){
                                    o.Projected_Contracts__c = memberCountPREMContracts;
                                }  else if(f == Label.ASO){
                                    o.Projected_Contracts__c = memberCountASOContracts;
                                }  else if(f == Label.COST){
                                    o.Projected_Contracts__c = memberCountCOSTContracts;
                                }  else if(f == Label.MPP){
                                    o.Projected_Contracts__c = memberCountMPPContracts;
                                }  else if(f == Label.PAR){
                                    o.Projected_Contracts__c = memberCountPARContracts;
                                }  else {
                                    o.Projected_Contracts__c = memberCountSERVContracts;
                                }
                              
                                o.Status__c = Label.Progress;
                                o.Product_Type__c = Label.ProductTypeR;
                                o.Win_Probability__c = opps.Probability;
                                o.Funding_Type__c = f;
                                o.Premium_Type__c = bagrMap.get(b)[0].Premium_Type__c;
                                o.Upsell__c = Label.NoneP;
                                o.Category__c = bagrMap.get(b)[0].Product__r.Product_Type__c;
                                NewProductList.add(o);

                            }
                        }

                    }
                }
            }
            insert NewProductList;

        } catch (Exception e) {
            System.debug( Label.Exception + e.getMessage());
        }
    }


    /**
    * @developer: Ralph Tariga/Slalom LLC
    * @description: Method to check if Opportunity's parent account has an Underwriter in Account Team
    *               if not, an error is thrown
    * @usage: Used in a before update trigger
    *
    */
    public static void CheckAccountTeamForUnderwriter(List<Opportunity> opps, map<Id, Opportunity> newMap, map<Id, Opportunity> oldMap) {
        try {
            Set<Id> accIds = new Set<Id>();
            List<RenewalOpportunityStages__c> stages = RenewalOpportunityStages__c.getAll().values();
            Set<String> stagesIncluded = new Set<String>();
            for (RenewalOpportunityStages__c stage : stages) {
                stagesIncluded.add(stage.Stage_to_Check__c);
            }

            for (Opportunity opp : opps) {
                if (stagesIncluded.contains(opp.StageName) && oldMap.get(opp.Id).StageName != opp.StageName) {
                    accIds.add(opp.AccountId);
                }
            }

            if (accIds.size() > 0) {
                Set<Id> accUnderWriterExists = new Set<Id>();
                List<AccountTeamMember> accTMs = [SELECT TeamMemberRole, AccountId FROM AccountTeamMember WHERE AccountId IN :accIds AND TeamMemberRole = :Label.AccountUnderwriterRole];
                for (AccountTeamMember accTM : accTMs) {
                    accUnderWriterExists.add(accTM.AccountId);
                }

                for (Opportunity opp : opps) {
                    if (accUnderWriterExists.contains(opp.AccountId) == false) {
                        newMap.get(opp.Id).addError(Label.OppNoAccountUnderwriterErrorMessage);
                        break;
                    }
                }
            }
        } catch (Exception e) {
            System.debug( 'Exception : ' + e.getMessage());
        }
    }

}