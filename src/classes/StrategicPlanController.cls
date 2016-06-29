public with sharing class StrategicPlanController{
      

    public String contactRoleId{get;set;} 
    public String updatedRole{get;set;} 
    public String contactRoleNames{get;set;}
    public String checkJSCall{get;set;}
    public Integer accountContactRoleSize{get;set;}
    public Set<Id> contactIds;
    public String rtype{get;set;}
    
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
    public Id groupContactRecordTypeId;
    public Map<Id, AccountContactRole> mapOfContactIdAndAccountContactRole = new Map<Id, AccountContactRole>();
    public List<Contact> groupContactsToBeUpdated = new List<Contact>();
    public Map<Id, Contact> mapOfContactRoleIdAndContact = new Map<Id, Contact>();
    public String fullView {get; set;}
    public String blobValue{get;set;}
    
    
    public StrategicPlanController()
    {
        fullView = 'false';
        allBuyerHierarchyList = new List<Buyer_Hierarchy__c>();
        contactIds = new Set<Id>();
        contactIdAndTypeMap = new map<Id,String>();
        accountContactRoleList = new List<AccountContactRole>();
        strHTML = '';
        String strategicPlanId = ApexPages.currentPage().getParameters().get('Id');
        system.debug('========'+strategicPlanId);
        Id rId = [select RecordTypeId from Strategic_Plan__c where Id =:strategicPlanId limit 1][0].RecordTypeId;
        rType = [select DeveloperName from RecordType where Id =:rId][0].DeveloperName;
        accountId = [select Account_Name__c from Strategic_Plan__c where Id =:strategicPlanId limit 1][0].Account_Name__c ;
        groupContactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Group Contact').getRecordTypeId();
        fullView = ApexPages.currentPage().getParameters().get('fullView');
    }

    public StrategicPlanController(Apexpages.standardcontroller controller)
    {
        fullView = 'false';
        allBuyerHierarchyList = new List<Buyer_Hierarchy__c>();
        contactIds = new Set<Id>();
        contactIdAndTypeMap = new map<Id,String>();
        accountContactRoleList = new List<AccountContactRole>();
        strHTML = '';
        String strategicPlanId = ApexPages.currentPage().getParameters().get('Id');
        accountId = [select Account_Name__c from Strategic_Plan__c where Id =:strategicPlanId limit 1][0].Account_Name__c ;
        Id rId = [select RecordTypeId from Strategic_Plan__c where Id =:strategicPlanId limit 1][0].RecordTypeId;
        rType = [select DeveloperName from RecordType where Id =:rId][0].DeveloperName;
        system.debug('rtype@@@'+rtype);
        groupContactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Group Contact').getRecordTypeId();
        fullView = ApexPages.currentPage().getParameters().get('fullView');
    }
    
    
    

    

}