/**************************************************************************************
  Apex Class Name     : TestHomePageSliderController
  Version             : 1.0
  Function            : This is a test class for HomePageSliderController.
  Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
*  Nitin Paliwal           6/3/2015
*************************************************************************************/
@isTest
private class TestHomePageSliderController {

    static testMethod void myUnitTest() {
       Test.startTest();
       		 Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
			 User testUser = TestClassUtiltity.CreateUserRecord(p.Id, 'testlgnadev@user.com', 'testUser', 'test@user.com');
		     system.runAs(testUser){
	   			TestClassUtiltity.createHomePageSliderComponents();
			    TestClassUtiltity.createHomePageSliderPreferences();
			    TestClassUtiltity.createHomePageSliderProfileConfig();   
			    HomePageSliderController temp = new HomePageSliderController();
			    temp.getAccordionHTML();
			    PageReference pg  = temp.gotoPreferencesPage();
			    system.assertEquals(pg.getUrl(),Page.HPS_HomePageSliderPreferences.getURL());
		     }
       Test.StopTest();
    }
    
    static testMethod void myUnitTest1() {
       Test.startTest();
       		 Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
			 User testUser = TestClassUtiltity.CreateUserRecord(p.Id, 'testlgnadev@user.com', 'testUser', 'test@user.com');
		     system.runAs(testUser){
	   			Account TestAcnt = TestClassUtiltity.CreateAccountRecord('TestAccount');
			    ApexPAges.StandardController sc2 = new ApexPages.StandardController(TestAcnt);
	            HomePageSliderController myCntrl = new HomePageSliderController(sc2);
	       		PageReference pg  = myCntrl.gotoPreferencesPage();
			    system.assertEquals(pg.getUrl(),Page.HPS_HomePageSliderPreferences.getURL());
		     }
       Test.StopTest();
    }
}