public with sharing class BuyerHierarchyOnAccountController {
    public Account acc {
        get {
            if (acc == null)
            {
                acc = new Account();
                acc = [Select Id, Name From account where Id = :ApexPages.currentPage().getParameters().get('id')  ];
            }
            return acc ;
        } 
        set;
    }    

    public String contactRoleId{get;set;} 
    public String updatedRole{get;set;} 
    public String contactRoleNames{get;set;}
    public String checkJSCall{get;set;}
    public Id reportsToWeb{get;set;} 
    public Boolean changeSentimentApex{get;set;}
    public Integer accountContactRoleSize{get;set;}
    public Set<Id> contactIds;
    
    public List<AccountContactRole> accountContactRoleList {get;set;}
    public List<Buyer_Hierarchy__c> allBuyerHierarchyList {get;set;}
    
    public Map<string,string> mapContNameConId = new map<string,string>();
    public Map<Id,String> contactIdAndTypeMap {get;set;}
    public Map<Id,Task> contactIdAndTaskMap = new map<Id,Task>();
    public Map<Id,Event> contactIdAndEventMap = new map<Id,Event>();
    public List<Buyer_Hierarchy__c> buyerHierarchyList = new List<Buyer_Hierarchy__c>();
    public Map<String,Buyer_Hierarchy__c> mapContactBuyerHierarchy = new Map<String,Buyer_Hierarchy__c> ();

    
    private static JSONGenerator gen {get; set;}
    public Map<String,list<Buyer_Hierarchy__c>> parentContactNameAndBuyerHierarchyMap = new Map<String,list<Buyer_Hierarchy__c>>();
    public String strHTML{get;set;}
    private Integer intIndent = 0;
    public Id accountId;
    public Map<Id, Buyer_Hierarchy__c> mapOfRoleIdAndBuyerHierarchy = new Map<Id, Buyer_Hierarchy__c>();
    public Map<Id, AccountContactRole> mapOfRoleIdAndAccountContactRole = new Map<Id, AccountContactRole>();
    public BuyerHierarchyWrapper buyerHierarchyWrapperObj;
    public List<BuyerHierarchyWrapper> buyerHierarchyWrapperList {get; set;}
    public Id groupContactRecordTypeId;
    public Map<Id, AccountContactRole> mapOfContactIdAndAccountContactRole = new Map<Id, AccountContactRole>();
    public List<Contact> groupContactsToBeUpdated = new List<Contact>();
    public Map<Id, Contact> mapOfContactRoleIdAndContact = new Map<Id, Contact>();
    public String fullView {get; set;}
    public String blobValue{get;set;}
    
    public pageReference saveasAttachment(){
            String accId = accountId;
            String Accountid15Digit = accId.substring(0, 15);
            String imageName = 'Strategic Plan - '+Accountid15Digit ;
                
            list<Attachment> attachments = [select id from Attachment where name = :imageName  and ParentId =:ApexPages.currentPage().getParameters().get('spId')];
            delete attachments;
            if(blobValue != '' && blobValue  != null){
                Blob blobData = Blob.valueOf(blobValue.split(',')[1]);
                
                Attachment att = new Attachment();
                att.body = EncodingUtil.base64Decode(blobValue.split(',')[1]);
                
                att.ParentId = ApexPages.currentPage().getParameters().get('spId');
                att.Name = 'Strategic Plan - '+Accountid15Digit ;
                att.ContentType = 'image/jpg';
                if(!accountContactRoleList.isEmpty())
                    insert att;
            }
            PageReference pg = new PageReference('/apex/Create_Buyer_Heirarchy_Attachment?Id='+strategicPlanId);
            pg.setRedirect(true);
            return pg;
    }
    public string strategicPlanId{get;set;}
    public BuyerHierarchyOnAccountController() 
    {
        fullView = 'false';
        allBuyerHierarchyList = new List<Buyer_Hierarchy__c>();
        contactIds = new Set<Id>();
        contactIdAndTypeMap = new map<Id,String>();
        accountContactRoleList = new List<AccountContactRole>();
        strHTML = '';
        accountId = ApexPages.currentPage().getParameters().get('id');
        strategicPlanId = '';
        strategicPlanId = ApexPages.currentPage().getParameters().get('spId');
        buyerHierarchyWrapperList = new List<BuyerHierarchyWrapper>();
        groupContactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Group Contact').getRecordTypeId();
        fullView = ApexPages.currentPage().getParameters().get('fullView');
    }

    public BuyerHierarchyOnAccountController(Apexpages.standardcontroller controller)
    {
        fullView = 'false';
        allBuyerHierarchyList = new List<Buyer_Hierarchy__c>();
        contactIds = new Set<Id>();
        contactIdAndTypeMap = new map<Id,String>();
        accountContactRoleList = new List<AccountContactRole>();
        strHTML = '';
        accountId = ApexPages.currentPage().getParameters().get('id');
        strategicPlanId = '';
        strategicPlanId = ApexPages.currentPage().getParameters().get('spId');
        
        system.debug('========='+strategicPlanId );
        buyerHierarchyWrapperList = new List<BuyerHierarchyWrapper>();
        groupContactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Group Contact').getRecordTypeId();
        fullView = ApexPages.currentPage().getParameters().get('fullView');
    }
    public PageReference fetchBuyerHierarchyData()
    {
        try{
        accountContactRoleList = [SELECT ContactId, Role, Contact.RecordTypeId, Contact.HCSC_Sentiment__c, AccountId, Contact.Name FROM AccountContactRole WHERE AccountId =:accountId  limit   :Limits.getLimitQueryRows() - Limits.getQueryRows() ];
        accountContactRoleSize = accountContactRoleList.size();
        if(accountContactRoleList.isEmpty())
        {
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Buyer Hierarchy cannot be generated as there are no contact roles associated to this Account'));
        }
    
        else
        {
            contactRoleNames = '';
            buyerHierarchyList = [SELECT Contact_Role_Id__c, Contact__r.Account.Name, Contact_Role__c, Account__c, Contact__c, Contact__r.Name, Contact__r.LastActivityDate, Role__c, Contact__r.ReportsTo.Name FROM Buyer_Hierarchy__c WHERE Account__c =:accountId   limit   :Limits.getLimitQueryRows() - Limits.getQueryRows() ];
            
            List<Buyer_Hierarchy__c> tempBuyerHierarchyList = new List<Buyer_Hierarchy__c>();
            
            for(Buyer_Hierarchy__c buyerHierarchyObj: buyerHierarchyList)
            {
                if(!mapContactBuyerHierarchy.containskey(buyerHierarchyObj.Contact_Role_Id__c))
                {
                    mapContactBuyerHierarchy.put(buyerHierarchyObj.Contact_Role_Id__c, buyerHierarchyObj);
                }
            }
            
            for(Buyer_Hierarchy__c buyerHierarchyObj:mapContactBuyerHierarchy.values())
            {
                buyerHierarchyObj.Active__c = false;
            }

            for(AccountContactRole accountContactRoleObj: accountContactRoleList)
            {
                if(mapContactBuyerHierarchy.containskey(accountContactRoleObj.Id))
                {
                    mapContactBuyerHierarchy.get(accountContactRoleObj.Id).Active__c = true;
                    if(accountContactRoleObj.Contact.RecordTypeId == groupContactRecordTypeId && accountContactRoleObj.Contact.HCSC_Sentiment__c !=null)
                        mapContactBuyerHierarchy.get(accountContactRoleObj.Id).Role__c = accountContactRoleObj.Contact.HCSC_Sentiment__c;
                    else
                        mapContactBuyerHierarchy.get(accountContactRoleObj.Id).Role__c = 'Unknown';
                }
                else
                {
                    Buyer_Hierarchy__c buyerHierarchyObj = new Buyer_Hierarchy__c();
                    buyerHierarchyObj.Contact_Role_Id__c = accountContactRoleObj.Id;
                    buyerHierarchyObj.Contact_Role__c = accountContactRoleObj.Role;
                    buyerHierarchyObj.Contact__c = accountContactRoleObj.ContactId;
                    buyerHierarchyObj.Account__c = accountContactRoleObj.AccountId;
                    if(accountContactRoleObj.Contact.RecordTypeId == groupContactRecordTypeId && accountContactRoleObj.Contact.HCSC_Sentiment__c !=null)
                        buyerHierarchyObj.Role__c = accountContactRoleObj.Contact.HCSC_Sentiment__c;
                    else
                        buyerHierarchyObj.Role__c = 'Unknown';
                    buyerHierarchyObj.active__c = true;   
                    mapContactBuyerHierarchy.put(buyerHierarchyObj.Contact_Role_Id__c,buyerHierarchyObj);
                }
            }
            
            tempBuyerHierarchyList = mapContactBuyerHierarchy.values();
            upsert tempBuyerHierarchyList;
            
            buyerHierarchyList.clear();
            
            for(String tempRole:mapContactBuyerHierarchy.keyset())
            {
                if(mapContactBuyerHierarchy.get(tempRole).Active__c == true)
                {
                    buyerHierarchyList.add(mapContactBuyerHierarchy.get(tempRole));
                }
                
            }
            
            allBuyerHierarchyList = [SELECT Contact_Role_Id__c, Contact__r.Account.Name, Contact_Role__c, Account__c, Contact__c, Active__c, Contact__r.Name, Contact__r.LastActivityDate, Role__c, Contact__r.ReportsTo.Name, Contact__r.Title FROM Buyer_Hierarchy__c WHERE Account__c =:accountId AND Active__c = true  limit :Limits.getLimitQueryRows() - Limits.getQueryRows() ];  

            for(Buyer_Hierarchy__c buyerHierarchyObj : allBuyerHierarchyList){
                contactIds.add(buyerHierarchyObj.Contact__c);
                mapOfRoleIdAndBuyerHierarchy.put(buyerHierarchyObj.Contact_Role_Id__c, buyerHierarchyObj);
            }
            Map<Id, Contact> mapOfIdAndContact = new Map<Id, Contact>([SELECT Id, Add_to_Buyer_Hierarchy__c, Buyer_Role__c, HCSC_Sentiment__c FROM Contact WHERE Id IN:contactIds limit :Limits.getLimitQueryRows() - Limits.getQueryRows()]);
            
            for(AccountContactRole accountContactRoleObj : [SELECT Id, Role, AccountId, ContactId, Contact.RecordTypeId, IsPrimary FROM AccountContactRole WHERE Id IN:mapOfRoleIdAndBuyerHierarchy.keySet()  limit   :Limits.getLimitQueryRows() - Limits.getQueryRows() ]){
                mapOfRoleIdAndAccountContactRole.put(accountContactRoleObj.Id, accountContactRoleObj);
                if(accountContactRoleObj.Contact.RecordTypeId == groupContactRecordTypeId){
                    mapOfContactIdAndAccountContactRole.put(accountContactRoleObj.ContactId, accountContactRoleObj);
                    mapOfContactRoleIdAndContact.put(accountContactRoleObj.Id, mapOfIdAndContact.get(accountContactRoleObj.contactId));
                }
            }
            if(!mapOfIdAndContact.isEmpty() && !mapOfContactIdAndAccountContactRole.isEmpty()){
                for(Id contactId : mapOfIdAndContact.keySet()){
                    if(mapOfContactIdAndAccountContactRole.containsKey(contactId)){
                        Contact groupContactObj = mapOfIdAndContact.get(contactId);
                        AccountContactRole groupAccountContactRoleObj = mapOfContactIdAndAccountContactRole.get(contactId);
                        if(groupContactObj.Add_to_Buyer_Hierarchy__c == false || groupContactObj.Buyer_Role__c !=groupAccountContactRoleObj.Role){
                            groupContactObj.Add_to_Buyer_Hierarchy__c = true;
                            groupContactObj.Buyer_Role__c = groupAccountContactRoleObj.Role;
                            if(!mapOfRoleIdAndBuyerHierarchy.isEmpty() && mapOfRoleIdAndBuyerHierarchy.containsKey(groupAccountContactRoleObj.Id))
                                groupContactObj.HCSC_Sentiment__c = mapOfRoleIdAndBuyerHierarchy.get(groupAccountContactRoleObj.Id).Role__c;
                            groupContactsToBeUpdated.add(groupContactObj);
                        }
                    }
                }
            }
            for(Id contactRoleId : mapOfRoleIdAndBuyerHierarchy.keySet()){
                buyerHierarchyWrapperObj = new BuyerHierarchyWrapper();
                buyerHierarchyWrapperObj.buyerHierarchyObj = mapOfRoleIdAndBuyerHierarchy.get(contactRoleId);
                if(!mapOfRoleIdAndAccountContactRole.isEmpty() && mapOfRoleIdAndAccountContactRole.containsKey(contactRoleId)){
                    buyerHierarchyWrapperObj.roleName = mapOfRoleIdAndAccountContactRole.get(contactRoleId).Role;
                }
                buyerHierarchyWrapperList.add(buyerHierarchyWrapperObj);
            }
            for (AccountContactRole accountContactRoleObj: accountContactRoleList){
                contactRoleNames += accountContactRoleObj.Contact.Name;
            }   
            for(Task taskObj : [SELECT Id, Type, whoId, LastModifiedDate FROM Task WHERE whoId IN:contactIds AND whatId =:accountId ORDER BY LastModifiedDate DESC LIMIT 1]){
                contactIdAndTaskMap.put(taskObj.whoId,taskObj);
            }
            for(Event eventObj : [SELECT Id, Type, whoId, LastModifiedDate FROM Event WHERE whoId IN:contactIds AND whatID =: accountId ORDER BY LastModifiedDate DESC LIMIT 1]){
                contactIdAndEventMap.put(eventObj.whoId,eventObj);
            }
                
            for(Id contactId : contactIds){
                if(contactIdAndTaskMap.containsKey(contactId) && contactIdAndEventMap.containsKey(contactId)){
                    if(contactIdAndTaskMap.get(contactId).LastModifiedDate > contactIdAndEventMap.get(contactId).LastModifiedDate){
                        contactIdAndTypeMap.put(contactId,contactIdAndTaskMap.get(contactId).Type);
                    }
                    else if(contactIdAndTaskMap.get(contactId).LastModifiedDate < contactIdAndEventMap.get(contactId).LastModifiedDate){
                        contactIdAndTypeMap.put(contactId,contactIdAndEventMap.get(contactId).Type);
                    }
                }
                else if(contactIdAndTaskMap.containsKey(contactId) && !contactIdAndEventMap.containsKey(contactId)){
                    contactIdAndTypeMap.put(contactId,contactIdAndTaskMap.get(contactId).Type);
                }
                else if(!contactIdAndTaskMap.containsKey(contactId) && contactIdAndEventMap.containsKey(contactId)){
                    contactIdAndTypeMap.put(contactId,contactIdAndEventMap.get(contactId).Type);
                }
                else if(!contactIdAndTaskMap.containsKey(contactId) && !contactIdAndEventMap.containsKey(contactId)){
                    contactIdAndTypeMap.put(contactId,'No Activity');
                }
            }
            system.debug('========'+contactRoleId+'==='+changeSentimentApex+'====='+mapOfContactRoleIdAndContact.keyset());
            if(contactRoleId !=null)
            {   
                if(!mapOfContactRoleIdAndContact.isEmpty()){
                    if(mapOfContactRoleIdAndContact.containsKey(contactRoleId)){
                        Contact groupContactObj = mapOfContactRoleIdAndContact.get(contactRoleId);


                        if (changeSentimentApex){
                            groupContactObj.HCSC_Sentiment__c = updatedRole;    
                        }else{

                             groupContactObj.ReportsToId = reportsToWeb;  
                        }
                         if (changeSentimentApex==false && reportsToWeb==null){
                             groupContactObj.HCSC_Sentiment__c = updatedRole; 
                        }

                            try{
                                update groupContactObj;
                            }
                            catch(Exception exp){
                                 ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Relationship might already exists!'));
                                 return null;
                            }
                        
                      //For mobile connections dont delete
                        
                        
                    }
                }
                mapContactBuyerHierarchy.get(contactRoleId).Role__c = updatedRole;
                upsert buyerHierarchyList;
            }
            system.debug('=====Con===='+groupContactsToBeUpdated);
            if(!groupContactsToBeUpdated.isEmpty()){
                update groupContactsToBeUpdated;
                groupContactsToBeUpdated.clear();
            }
            buildBuyerHierarchy();
        }
    
        if(checkJSCall=='active')
        {
            Id accountId = ApexPages.currentPage().getParameters().get('id');
            PageReference pageRef = new PageReference('/apex/BuyerHierarchyOnAccount?id='+accountId);
            pageRef.setRedirect(true);
            return pageRef;
        }else if(checkJSCall=='activeMobile'){
            Id accountId = ApexPages.currentPage().getParameters().get('id');
            PageReference pageRef = new PageReference('/apex/M_BuyerHierarchyOnAccount?id='+accountId);
            pageRef.setRedirect(true);
            return pageRef;
        }
        else
            return null;
            
      }catch(Exception ex){
           CreateExceptionLog.insertErrorLog(ex, null, null, null, 'Apex Class', 'Account', null, 'BuyerHierarchyOnAccountController.fetchBuyerHierarchyData()','High'); 
          return null;
      }      
    }
    public PageReference buildBuyerHierarchy()
    {
        List<Buyer_Hierarchy__c> rootNodeList = new List<Buyer_Hierarchy__c>();
        try{
        for (Buyer_Hierarchy__c buyerHierarchyObj: allBuyerHierarchyList)
        {
            if(buyerHierarchyObj.Contact__r.ReportsTo.Name == null)
            {
                
                rootNodeList.add(buyerHierarchyObj);              
            }
            else
            {
                if(!parentContactNameAndBuyerHierarchyMap.containskey(buyerHierarchyObj.Contact__r.ReportsTo.Name))
                {
                    List<Buyer_Hierarchy__c> tempBuyerHierarchyList = new List<Buyer_Hierarchy__c>();                  
                    tempBuyerHierarchyList.add(buyerHierarchyObj);
                    parentContactNameAndBuyerHierarchyMap.put(buyerHierarchyObj.Contact__r.ReportsTo.Name,tempBuyerHierarchyList);                  
                }
                else
                {
                    List<Buyer_Hierarchy__c> tempBuyerHierarchyList = new List<Buyer_Hierarchy__c>();
                    tempBuyerHierarchyList = parentContactNameAndBuyerHierarchyMap.get(buyerHierarchyObj.Contact__r.ReportsTo.Name);
                    tempBuyerHierarchyList.add(buyerHierarchyObj);
                    parentContactNameAndBuyerHierarchyMap.put(buyerHierarchyObj.Contact__r.ReportsTo.Name,tempBuyerHierarchyList);                  
                }
            }           
        }

        if(!rootNodeList.isEmpty()){ 
            for(Buyer_Hierarchy__c buyerHierarchyObj: rootNodeList)
            {
                createNode(buyerHierarchyObj);
                getTreeJSON(buyerHierarchyObj);
            }
        }
        }catch(Exception ex){
            CreateExceptionLog.insertErrorLog(ex, null, null, null, 'Apex Class', 'Account', null, 'BuyerHierarchyOnAccountController.buildBuyerHierarchy()','High'); 
        }
        return null;
    }
    private RoleNodeWrapper createNode(Buyer_Hierarchy__c buyerHierarchyObj) 
    {
        RoleNodeWrapper roleNodeWrapperObj = new RoleNodeWrapper();
        try{
        List<Buyer_Hierarchy__c> tempBHList = new List<Buyer_Hierarchy__c>();
        roleNodeWrapperObj.myId = buyerHierarchyObj.Contact__c;
        roleNodeWrapperObj.myName = buyerHierarchyObj.Contact__r.Name;
        system.debug('===Name=='+buyerHierarchyObj.Contact__r.Name+'===='+buyerHierarchyObj.Contact__c);  
        roleNodeWrapperObj.myContactRole = buyerHierarchyObj.Contact_Role__c;
        roleNodeWrapperObj.myBuyerRole = buyerHierarchyObj.Role__c;
        
        if(parentContactNameAndBuyerHierarchyMap.containsKey(buyerHierarchyObj.Contact__r.Name))
        {
            roleNodeWrapperObj.hasChildren = true;
            roleNodeWrapperObj.isLeafNode = false;
            List<RoleNodeWrapper> roleNodeWrapperList = new List<RoleNodeWrapper>();
            for (Buyer_Hierarchy__c tempBuyerHierarchyObj : parentContactNameAndBuyerHierarchyMap.get(buyerHierarchyObj.Contact__r.Name)) 
            {
                roleNodeWrapperList.add(createNode(tempBuyerHierarchyObj));
            }           
            roleNodeWrapperObj.myChildNodes = roleNodeWrapperList;
        }
        else 
        {
            roleNodeWrapperObj.isLeafNode = true;
            roleNodeWrapperObj.hasChildren = false;
        }
        return roleNodeWrapperObj;
        }catch(exception ex){
         CreateExceptionLog.insertErrorLog(ex, null, null, null, 'Apex Class', 'Account', null, 'BuyerHierarchyOnAccountController.createNode()','High'); 
         return null;
        }
        
    }
    
    public String getTreeJSON(Buyer_Hierarchy__c buyerHierarchyObj) 
    {   
        try{
        gen = JSON.createGenerator(true);
        RoleNodeWrapper node = createNode(buyerHierarchyObj);
        gen.writeStartArray();
        convertNodeToJSON(node);
        gen.writeEndArray();
        string tempJsonstring = gen.getAsString();
        convertNodeToHTML(node);
        return tempJsonstring;
        }catch(Exception e){
         return null;
        }
    }
    private void convertNodeToJSON(RoleNodeWrapper roleNodeWrapperObj)
    {
        try{
        gen.writeStartObject();
        gen.writeStringField('title', roleNodeWrapperObj.myName);
        gen.writeStringField('key', roleNodeWrapperObj.myId);
        gen.writeBooleanField('unselectable', false);
        gen.writeBooleanField('expand', true);
        gen.writeBooleanField('isFolder', true);
        
            if (roleNodeWrapperObj.hasChildren)
            {
                gen.writeFieldName('children');
                gen.writeStartArray();
                   
                if (roleNodeWrapperObj.hasChildren)
                {
                    for (RoleNodeWrapper node : roleNodeWrapperObj.myChildNodes)
                    {
                        convertNodeToJSON(node);
                    }
                }
                gen.writeEndArray();
            }
        gen.writeEndObject();
        }catch(Exception e){}
    }
    private void convertNodeToHTML(RoleNodeWrapper roleNodeWrapperObj)
    {
        try{
        if (roleNodeWrapperObj.hasChildren)
        {
            strHTML += '<div data-role="collapsible">';
            intIndent = intIndent + 5;
             
            strHTML += '<h2>' + roleNodeWrapperObj.myName + ' - ' + roleNodeWrapperObj.myContactRole + ' - ' + roleNodeWrapperObj.myBuyerRole + '</h2>' + '<div data-role="listview" style="margin-left:' + (intIndent*2)+ 'px;width:'+ (100-intIndent) +'%">' ;                
            for (RoleNodeWrapper childNode : roleNodeWrapperObj.myChildNodes)
            {                           
                convertNodeToHTML(childNode);
            }
            strHTML = strHTML + '</div></div>';
            intIndent = intIndent - 5;
        }
        else
        {           
            strHTML = strHTML + '<div data-role="button" data-corners="false" style="margin-left:' + (intIndent*2)+ 'px;width:'+ (100-intIndent) +'%">' + roleNodeWrapperObj.myName + ' - ' + roleNodeWrapperObj.myContactRole + ' - ' + roleNodeWrapperObj.myBuyerRole +  '</div>';
        } 
        }catch(Exception e){}  
    }
    public class RoleNodeWrapper {

        public Id myId {get; set;}
        public String myName {get; set;}
        public String myContactRole {get; set;}
        public String myBuyerRole {get; set;}
        public Boolean hasChildren {get; set;}
        public Boolean isLeafNode {get; set;}
        public List<RoleNodeWrapper> myChildNodes {get; set;}
  
        public RoleNodeWrapper(){
            hasChildren = false;
        }
    }
    public class BuyerHierarchyWrapper {
        public Buyer_Hierarchy__c buyerHierarchyObj {get; set;}
        public String roleName {get; set;}
        
        public BuyerHierarchyWrapper(){
        
        }
    }
    

    

}