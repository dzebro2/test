/**************************************************************************************
  Apex Class Name     : TestConsoleMenuController
  Version             : 1.0
  Function            : This class serves as Unit Test class for ConsoleMenuController
  Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
*   Suyog Dongaonkar       14/11/2014                Original Version
*************************************************************************************/

@isTest
public class  TestConsoleMenuController{
    
    /*  testPopulateMenuItems
    *   @description:   This method is used to test the PopulateMenuItems method of ConsoleMenuController
    *   @parameters     N/A
    *   @return type    N/A                     
    */
    public static testMethod void testPopulateMenuItems(){
        Console_Menu_Settings__c consoleMenuObj = new Console_Menu_Settings__c();
        consoleMenuObj.Name = 'Home';
        consoleMenuObj.Sort_Order__c = 1;
        consoleMenuObj.Target__c = 'Console';
        consoleMenuObj.URL__c = '/home/home.jsp';
        insert consoleMenuObj;
        
        system.assertEquals(consoleMenuObj.Target__c,'Console');
        
        Test.startTest();
        ConsoleMenuController controllerObj = new ConsoleMenuController();
        Test.stopTest();
    }
}