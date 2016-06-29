/**************************************************************************************
  Apex Class Name     : SearchPageController
  Version             : 1.0
  Function            : This class is used to construct the URL to pass Account/Contact 
                              filters parameters to DisplayResults page. 
  Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
*   Dinesh Talreja          26/09/2014                Original Version
*************************************************************************************/

public with sharing class SearchPageController {

    public List<String> AccountType {
        get {
            if (AccountType == null) {
                AccountType = new List<String>();
                for(RecordType recordTypeObj : [SELECT Name FROM RecordType WHERE SobjectType = 'Account'])
                    AccountType.add(recordTypeObj.Name);
            }
            return AccountType;          
        }
        set;
    }
    public List<String> ContactType {
        get {
            if (ContactType == null) {
                ContactType = new List<String>();
                for(RecordType recordTypeObj : [SELECT Name FROM RecordType WHERE SobjectType = 'Contact'])
                    ContactType.add(recordTypeObj.Name);
            }
            return ContactType;          
        }
        set;
    }
    public String accountNameParam {get;set;}
    public String accountIDParam {get;set;}
    public String accountTypeParam {get;set;}
    
    public String contactNameParam {get;set;}
    public String contactIDParam {get;set;}
    public String contactPhoneParam {get;set;}
    public String contactEmailParam {get;set;}
    public String contactTypeParam {get;set;}
    
    
    public String accountURL{get;set;}
    public String contactURL{get;set;}
    
    /*  SearchPageController
    *   Initilization
    */
    
    public SearchPageController(){
        
    }
    
    /*  accountSearch
    *   @description:   This method constructs the URL to redirect to Display results page by passing Account filter parameters.
    *   @parameters     N/A
    *   @return type    N/A                     
    */   
    
    public void accountSearch(){
        if(accountNameParam !=null && accountNameParam !='')
            //Encode Account Name to pass it in the URL
            accountNameParam = EncodingUtil.urlEncode( accountNameParam, StaticVariablesUtility.urlEncodingScheme );
        if(accountIDParam !=null && accountIDParam !='')
            //Encode Account ID to pass it in the URL
            accountIDParam = EncodingUtil.urlEncode( accountIDParam, StaticVariablesUtility.urlEncodingScheme );
            
        accountURL = '/apex/DisplayResults?'
        			+ StaticVariablesUtility.accountNameQueryString + '=' + String.escapeSingleQuotes(accountNameParam)
        			+ '&' + StaticVariablesUtility.accountIDQueryString + '=' + String.escapeSingleQuotes(accountIDParam)
        			+ '&' + StaticVariablesUtility.accountTypeQueryString + '='+accountTypeParam 
        			+ '&' + StaticVariablesUtility.searchQueryString + '=' + Label.Search_Criteria_Account ;
    }
    
    /*  contactSearch
    *   @description:   This method constructs the URL to redirect to Display results page by passing Contact filter parameters.
    *   @parameters     N/A
    *   @return type    N/A                     
    */   
    
    public void contactSearch(){
        if(contactNameParam !=null && contactNameParam !='')
            //Encode Contact Name to pass it in the URL
            contactNameParam = EncodingUtil.urlEncode(contactNameParam,'UTF-8');
        if(contactIDParam !=null && contactIDParam !='')
            //Encode Contact ID to pass it in the URL
            contactIDParam = EncodingUtil.urlEncode(contactIDParam,'UTF-8');
        contactURL = '/apex/DisplayResults?' 
        			+ StaticVariablesUtility.contactNameQueryString + '=' + String.escapeSingleQuotes(contactNameParam)
        			+ '&' + StaticVariablesUtility.contactIDQueryString + '=' + String.escapeSingleQuotes(contactIDParam)
        			+ '&' + StaticVariablesUtility.contactPhoneQueryString + '=' + String.escapeSingleQuotes(contactPhoneParam)
        			+ '&' + StaticVariablesUtility.contactEmailQueryString + '=' + String.escapeSingleQuotes(contactEmailParam)
        			+ '&' + StaticVariablesUtility.contactTypeQueryString + '=' + contactTypeParam
        			+ '&' + StaticVariablesUtility.searchQueryString + '=' + Label.Search_Criteria_Contact ;
    }
    
}