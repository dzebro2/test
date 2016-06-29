/**************************************************************************************
  Apex Class Name     : ConsoleMenuController
  Version             : 1.0
  Function            : This is a controller for Console Menu widget.	
  Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
*   Suyog Dongaonkar       03/10/2014                Original Version
*************************************************************************************/
public with sharing class ConsoleMenuController 
{
    
    public List<Console_Menu_Settings__c> MenuItems { get; set; }
    
    //Constructor
    public ConsoleMenuController() 
    {
        PopulateMenuItems();
    }
    
    /*  PopulateMenuItems
    *   @description:   This method populates menu items configured in Console_Menu_Settings__c custom setting.
    *   @parameters     N/A
    *   @return type    Boolean                     
    */     
    private void PopulateMenuItems()
    {
        MenuItems = [   select  Id, Name, Target__c, URL__c
                        from    Console_Menu_Settings__c
                        order by Sort_Order__c
                        limit   :Limits.getLimitQueryRows() - Limits.getQueryRows() ];
    }
}