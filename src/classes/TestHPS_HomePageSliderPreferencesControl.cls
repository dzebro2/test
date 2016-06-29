/**************************************************************************************
  Apex Class Name     : TestHPS_HomePageSliderPreferencesControl
  Version             : 1.0
  Function            : This is a test class for HPS_HomePageSliderPreferencesController
  Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
*  
*************************************************************************************/
@isTest
public with sharing class TestHPS_HomePageSliderPreferencesControl {
	
	static testMethod void myUnitTest() {
		try{
			 Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
			 User testUser = TestClassUtiltity.CreateUserRecord(p.Id, 'testlgnadev@user.com', 'testUser', 'test@user.com');
		     system.runAs(testUser){
				TestClassUtiltity.createHomePageSliderComponents();
				TestClassUtiltity.createHomePageSliderPreferences();
				TestClassUtiltity.createHomePageSliderProfileConfig();
				HPS_HomePageSliderPreferencesController tempController = new HPS_HomePageSliderPreferencesController();
				tempController.selectedProfile = p.Id;
				tempController.populateProfilePreferences();
				tempController.saveProfilePreferences();
				PageReference pg = tempcontroller.savePreferences();
				system.assertEquals(pg.getURL(),Page.HomePageSlider.getURL());
		     }
		}catch(Exception e){
			throw e;
		}	
	}
	static testMethod void myUnitTest1() {
		try{
			 Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
			 User testUser = TestClassUtiltity.CreateUserRecord(p.Id, 'testlgnadev@user.com', 'testUser', 'test@user.com');
			TestClassUtiltity.createHomePageSliderComponents();
			TestClassUtiltity.createHomePageSliderPreferences();
			TestClassUtiltity.createHomePageSliderProfileConfig();
			HPS_HomePageSliderPreferencesController tempController = new HPS_HomePageSliderPreferencesController();
			/*tempController.selectedProfile = p.Id;
			tempController.populateProfilePreferences();
			tempController.saveProfilePreferences();
			tempcontroller.savePreferences();*/
			//system.assertNotEquals(tempController.profiles.size(),0);
		}catch(Exception e){
			throw e;
		}	
	}
	static testMethod void myUnitTest2() {
		try{
			 Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
			 User testUser = TestClassUtiltity.CreateUserRecord(p.Id, 'testlgnadev@user.com', 'testUser', 'test@user.com');
			TestClassUtiltity.createHomePageSliderComponents();
			TestClassUtiltity.createHomePageSliderPreferences();
			TestClassUtiltity.createHomePageSliderProfileConfig();
			HPS_HomePageSliderPreferencesController tempController = new HPS_HomePageSliderPreferencesController();
			
			HPS_HomePageSliderPreferencesController.maximumComponentsAllowed = 0;
			tempController.saveProfilePreferences();
			PageReference pg = tempcontroller.savePreferences();
			system.assertEquals(pg,null);
		}catch(Exception e){
			throw e;
		}	
	}
}