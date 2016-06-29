/**************************************************************************************
  Apex Class Name     : TestRSSNewsTickerController
  Version             : 1.0
  Function            : This is a test class for RSSNewsTickerController .
  Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
*  Sruthy Dileep            6/1/2015
*************************************************************************************/
@isTest
public class TestRSSNewsTickerController {

    static testMethod void myUnitTest() {
        try{
        
        Account testAccount = TestClassUtiltity.CreateAccountRecord('Test Account');
         
        test.StartTest();
        PageReference myVfPage = new PageReference('/apex/RSSNewsTicker');
        myVfPage.getParameters().put('id',testAccount.id);
        Test.setCurrentPage(myVfPage);
        
        ApexPAges.StandardController sc = new ApexPages.StandardController(testAccount);
        RSSNewsTickerController testController = new RSSNewsTickerController(sc);
        testController.selectedExternalFilters='Account';
        RSSNewsTickerController.getRSSData('string','true');
        testController.getExternalFilters();
        system.assertEquals(testController.accountName,'Test Account');
        testController.selectedExternalFilters= null;       
        String s = testController.selectedExternalFilters;
        test.StopTest();
        }catch(Exception e){
        throw e;
        }
    }
}