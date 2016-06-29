/**************************************************************************************
  Apex Class Name     : TestSearchPageController
  Version             : 1.0
  Function            : This class serves as Unit Test class for SearchPageController
  Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
*   Dinesh Talreja       14/11/2014                Original Version
*************************************************************************************/

@isTest

public class TestSearchPageController{
    
    /*  TestSearchPage
    *   @description:   This method is used to test the Conditions of SearchPageController
    *   @parameters     N/A
    *   @return type    N/A                     
    */
    public static testMethod void TestSearchPage(){
    
       
        PageReference pageRef = Page.SearchPage;
        
        Test.setCurrentPage(pageRef);
       
        Test.startTest();
        SearchPageController controllerObj = new SearchPageController();
        controllerObj.accountNameParam = 'Test Account';
        controllerObj.accountIDParam = '1234';
        
        controllerObj.accountSearch();
        
        
        controllerObj.contactNameParam = 'Test Contact';
        controllerObj.contactIDParam = '1234';
        controllerObj.contactPhoneParam = '8007541100';
        controllerObj.contactEmailParam = 'dtalreja@deloitte.com';
        
        controllerObj.contactSearch();
        List<String> accountType = controllerObj.AccountType;
        List<String> contactType = controllerObj.ContactType;  
        
        System.assert(accountType !=null);
        System.assert(contactType !=null);
        Test.stopTest();
    }
}