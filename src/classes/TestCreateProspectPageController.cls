/**************************************************************************************
  Apex Class Name     : TestAccountTrigger
  Version             : 1.0
  Function            : This is a test class for CreateProspectPageController
  Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
*   Sumedh Ambokar       6/23/2015                Original Version
*************************************************************************************/

@isTest
public class TestCreateProspectPageController{

    public static testmethod void testmethod1(){
        Account acc = TestClassUtiltity.CreateAccountRecord('Test Account');
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Group Account').getRecordTypeId();
        //acc.RecordTypeId = devRecordTypeId;
        //update acc;
        pageReference pg = new pageReference('Page.CreateProspectPage');
        Test.setCurrentPage(pg);
        ApexPages.currentPage().getParameters().put('id', acc.id);
        ApexPages.currentPage().getParameters().put('CancelStatus', 'Cancelled');
        CreateProspectPageController cntrl = new CreateProspectPageController();
        PageReference pg1 =  cntrl.returnMethod();
        String ProspectAccountRId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
        pageReference pg2 = new pageReference('/' + acc.Id + '/e?clone=1&RecordType=' + ProspectAccountRId + '&' + system.label.Account_Number_ID + '=&' + system.label.Account_Effective_Date_ID + '=&' + system.label.Account_Reserved_Group_Number_ID + '=&' + system.label.Account_Out_of_Business_ID + '=&retURL=' + acc.Id ); 
        system.assertEquals(pg1.getURL(),pg2.getURL());
        pg = new pageReference('Page.CreateProspectPage');
        Test.setCurrentPage(pg);
        ApexPages.currentPage().getParameters().put('id', acc.id);
        ApexPages.currentPage().getParameters().put('CancelStatus', 'test');
        cntrl = new CreateProspectPageController();
        cntrl.returnMethod();
    }
}