/*
    @Description : This is a test class for M_HomePageSliderController
    @author      : Deloitte
    @date        : 11/02/2015
*/
@isTest
public with sharing class TestM_HomePageSliderController {
	static testMethod void myUnitTest() {
		try{
			 Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
			 User testUser = TestClassUtiltity.CreateUserRecord(p.Id, 'testlgnadev@user.com', 'testUser', 'test@user.com');
		     system.runAs(testUser){
				TestClassUtiltity.createHomePageSliderComponents();
				TestClassUtiltity.createHomePageSliderPreferences();
				TestClassUtiltity.createHomePageSliderProfileConfig();
				M_HomePageSliderController tempController = new M_HomePageSliderController();
				tempController.GetAccordionHTML();
				PageReference pg = tempController.gotoPreferencesPage();
				system.assertEquals(pg.getURL(),Page.HPS_HomePageSliderPreferences.getURL());
				
				Account acc = TestClassUtiltity.CreateAccountRecord('test');
				ApexPages.StandardController sc = new ApexPages.StandardController(acc);
				tempController = new M_HomePageSliderController(sc);
		     }
		}catch(Exception e){
			throw e;
		}	
	}
}