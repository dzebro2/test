/**************************************************************************************
  Apex Class Name     : Producer House Controller
  Version             : 1.0
  Function            : This is a controller class for ProducerHouse Page for showing the information of current logged in user tasks and events.
  Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------    
  Jermaine Lindsay    :       3.4.2016               Original Version
*************************************************************************************/
public with sharing class ProducerHouseController {

    public List<Contact> myContactList {get;set;}
    public List<Account> producerList {get;set;}
    public ID accountId;

    public ProducerHouseController(ApexPages.standardController stdController) {
        try{
            accountId = ApexPages.currentPage().getParameters().get('id');
            PopulateContacts(accountId);
        }catch(Exception e){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage());
            ApexPages.addMessage(myMsg);
        }
    }
   
    /******************************************************************** 
    * Method Name    : PopulateContacts
    *   @description :   Method to populate active Activities on home page slider.
    *   @parameters  :   none
    *   @return type :   none                     
    ***************************************************************/  
    private void PopulateContacts(Id accountId) {
        try{

            // Query Query for child producers
            producerList = [SELECT Id, Name, National_Producer_Number__c, Producer_Number__c, BillingStreet, BillingState, BillingPostalCode, BillingCity FROM Account WHERE Parent.Id = :accountId];
            Set<Id> producerIds = new Set<Id>();
            for(Account a:producerList)
            { 
                producerIds.add(a.id);
            } 

            myContactList = [SELECT Id, AccountId, Account.Name, Name, Email, Type__c, RecordType.Name FROM Contact WHERE AccountId IN: producerIds limit 1000];

        }catch(Exception e){
            throw e;
        }
    }
}