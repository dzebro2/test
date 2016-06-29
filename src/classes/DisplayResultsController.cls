/***********************************************************************************************************
  Apex Class Name     : DisplayResultsController
  Version             : 1.0
  Function            : This class is used to display the Account/Contact records based on Search criteria 
  Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
*   Dinesh Talreja          26/09/2014                Original Version
************************************************************************************************************/


public with sharing class DisplayResultsController{
    
    public String accountName;
    public String accountID;
    public String accountType {get; set;}
    
    public String contactName;
    public String contactID;
    public String contactPhone;
    public String contactEmail;
    public String contactType {get; set;}
    
    
    public String soql;
    //List<Account> ListOfAccounts {get;set;}
    //List<Contact> ListOfContacts{get;set;}
    
    public List<Account> filteredAccounts {get;set;}
    public List<Contact> filteredContacts {get;set;}

    public boolean DisplayAccountInformation {get;set;}
    public boolean DisplayContactInformation {get;set;}
    public String NoAccountRecords {get;set;}
    public String NoContactRecords {get;set;}
    public String RefineSearch {get;set;}
    public String searchCriteria;
    public Integer counter;
    
    
    /*  DisplayResultsController
    *   Initilization
    */
    
    public DisplayResultsController(){
    	//Calculate query rows limit
    	Integer queryLimit = Limits.getLimitQueryRows() - Limits.getQueryRows() ;
        counter = 0;
        DisplayAccountInformation = false;
        DisplayContactInformation = false;
        
        //To store the search criteria
        searchCriteria = Apexpages.currentPage().getParameters().get( StaticVariablesUtility.searchQueryString );
        
        //Check if the search criteria is Account
        if(searchCriteria == System.Label.Search_Criteria_Account){
        
            List<Account> ListOfAccounts = new List<Account>();
            filteredAccounts = new List<Account>();
            
            //Store the Account Name parameter passed from URL.
            accountName = Apexpages.currentPage().getParameters().get( StaticVariablesUtility.accountNameQueryString );
            //Store the Account ID parameter passed from URL.
            accountID = Apexpages.currentPage().getParameters().get( StaticVariablesUtility.accountIDQueryString );
            //Store the Account Type parameter passed from URL.
            accountType = Apexpages.currentPage().getParameters().get( StaticVariablesUtility.accountTypeQueryString );
            
            soql = 'SELECT ';
            
            //Based on the Account Type, construct the Dynamic SOQL Query
            if(accountType == System.Label.Producer_Account){
                //Iterate over Producer Account Field set
                for( Schema.FieldSetMember f :SObjectType.Account.FieldSets.SearchFields.getFields() ) {
                    soql += f.getFieldPath() + ', ';
                }
            }
            
            //Based on the Account Type, construct the Dynamic SOQL Query
            if(accountType == System.Label.Group_Account){
                //Iterate over Group Account Field set
                for( Schema.FieldSetMember f :SObjectType.Account.FieldSets.SearchFields_GroupAccount.getFields() ) {
                    soql += f.getFieldPath() + ', ';
                }
            }
            
            soql +=' Id, Name FROM Account WHERE  Name != null';
        
            //Based on Search Filters passed, add the Filters conditions in WHERE clause of Dynamic SOQL
            if(accountName !=null && accountName !='')
                soql += ' AND Name LIKE \'%'+String.escapeSingleQuotes(accountName)+'%\'';
            if(accountID !=null && accountID !='')
                soql += ' AND External_Id__c LIKE \'%'+String.escapeSingleQuotes(accountID)+'%\'';
            if(accountType !=null && accountType !='')
                soql += ' AND RecordType.Name LIKE \'%'+String.escapeSingleQuotes(accountType)+'%\'';
                
            soql +=  ' limit :queryLimit';
                	

            ListOfAccounts = Database.query(soql);
            
            //Recalculate limit
            queryLimit = Limits.getLimitQueryRows() - Limits.getQueryRows() ;
            
            if(!ListOfAccounts.isEmpty()){
                //If the Records returned is greater than 1000, display the Refine Search message and the show the first 1000 records on UI.
                if(ListOfAccounts.size() > Integer.valueOf(System.Label.Record_Display_Limit))
                    RefineSearch = System.Label.Refine_Search;
                    
                for(Account acc : ListOfAccounts){
                    if(counter < Integer.valueOf(System.Label.Record_Display_Limit)){
                        filteredAccounts.add(acc);
                        counter++;
                    }
                }
            }
            if(!filteredAccounts.isEmpty())
                DisplayAccountInformation = true;
            else
                //Display No Results Found message, if the Search criteria did not return any Account records
                NoAccountRecords = System.Label.No_Results_Found;
        }
        
        //Check if the search criteria is Contact
        else if(searchCriteria == System.Label.Search_Criteria_Contact){
            
            List<Contact> ListOfContacts = new List<Contact>();
            filteredContacts = new List<Contact>();
            
            //Store the Contact Name parameter passed from URL.
            contactName = Apexpages.currentPage().getParameters().get( StaticVariablesUtility.contactNameQueryString );
            //Store the Contact ID parameter passed from URL.
            contactID = Apexpages.currentPage().getParameters().get( StaticVariablesUtility.contactIDQueryString );
            //Store the Contact Phone parameter passed from URL.
            contactPhone = Apexpages.currentPage().getParameters().get( StaticVariablesUtility.contactPhoneQueryString );
            //Store the Contact Email parameter passed from URL.
            contactEmail = Apexpages.currentPage().getParameters().get( StaticVariablesUtility.contactEmailQueryString );
            //Store the Contact Type parameter passed from URL.
            contactType = Apexpages.currentPage().getParameters().get( StaticVariablesUtility.contactTypeQueryString );
            
            soql = 'SELECT ';
            
            //Based on the Contact Type, construct the Dynamic SOQL Query
            if(contactType == System.Label.Producer_Contact){
                //Iterate over Producer Contact Field set
                for( Schema.FieldSetMember f :SObjectType.Contact.FieldSets.SearchFields.getFields() ) {
                    soql += f.getFieldPath() + ', ';
                }
            }
            
            if(contactType == System.Label.Group_Contact){
                //Iterate over Group Contact Field set
                for( Schema.FieldSetMember f :SObjectType.Contact.FieldSets.SearchFields_GroupContact.getFields() ) {
                    soql += f.getFieldPath() + ', ';
                }
            }
            
            soql +=' Id, Name, Account.Name FROM Contact WHERE  Name != null';
         
            //Based on Search Filters passed, add the Filters conditions in WHERE clause of Dynamic SOQL
            if(contactName !=null && contactName !='')
                soql += ' AND Name LIKE \'%'+String.escapeSingleQuotes(contactName)+'%\'';
            if(contactID !=null && contactID !='')
                soql += ' AND External_Id__c LIKE \'%'+String.escapeSingleQuotes(contactID)+'%\'';
            if(contactPhone !=null && contactPhone !='')
                soql += ' AND Phone LIKE \'%'+String.escapeSingleQuotes(contactPhone)+'%\'';
            if(contactEmail !=null && contactEmail !='')
                soql += ' AND Email LIKE \'%'+String.escapeSingleQuotes(contactEmail)+'%\'';
            if(contactType !=null && contactType !='')
                soql += ' AND RecordType.Name LIKE \''+String.escapeSingleQuotes(contactType)+'%\'';
            
            soql +=  ' limit :queryLimit';
            
            ListOfContacts = Database.query(soql);
            
            if(!ListOfContacts.isEmpty()){
                //If the Records returned is greater than 1000, display the Refine Search message and the show the first 1000 records on UI.
                if(ListOfContacts.size() > Integer.valueOf(System.Label.Record_Display_Limit))
                    RefineSearch = System.Label.Refine_Search;
                    
                for(Contact con : ListOfContacts){
                    if(counter < Integer.valueOf(System.Label.Record_Display_Limit)){
                        filteredContacts.add(con);
                        counter++;
                    }
                }
            }
            
            if(!filteredContacts.isEmpty())
                DisplayContactInformation = true;
            else
                //Display No Results Found message, if the Search criteria did not return any Contact records
                NoContactRecords = System.Label.No_Results_Found;
        }
    }
}