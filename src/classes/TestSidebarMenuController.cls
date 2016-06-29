/**************************************************************************************
  Apex Class Name     : TestSidebarMenuController
  Version             : 1.0
  Function            : This is a test class for SidebarMenuController .
  Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
*  Sruthy Dileep            6/1/2015
*************************************************************************************/
@isTest(seeAllData=true)
public class TestSidebarMenuController {

    static testMethod void myUnitTest() {
        try{
          
        test.StartTest();
        Profile profId = [select id from profile where name = 'System Administrator'];
        User usr = TestClassUtiltity.CreateUserRecord(profId.id,'sdil@deloitte.com', 'LastNameStr', 'sdil@deloitte.com');
        Sidebar_Menu_Settings__c SidebarRec= new Sidebar_Menu_Settings__c();
        SidebarRec.Name='Name';
        SidebarRec.Display_Name__c='TestDisplay';
        SidebarRec.Target__c='TestTarget';
        SidebarRec.URL__c='www.url.com';
        SidebarRec.Market_Segment__c='testmarketSegment';
        SidebarRec.Role__c='TestRole';
        SidebarRec.State__c='TestState';
        insert SidebarRec;
        system.runAs(usr){
        SidebarMenuController testSideBarMenuCntrl = new SidebarMenuController();
        //testSideBarMenuCntrl.PopulateMenuItems();
        system.assertEquals(testSideBarMenuCntrl.menuItems.size()>0,true);
        }
        test.StopTest();
        }catch(Exception e){
        throw e;
        }
    }
}