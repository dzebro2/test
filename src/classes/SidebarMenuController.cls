public with sharing class SidebarMenuController {
    
    public List<Sidebar_Menu_Settings__c> menuItems { get; set; }
    User currentUserRecord; 
    
    //Constructor
    public SidebarMenuController() 
    {
        currentUserRecord = [   select  Market_Segment__c, State, UserRole.Name
                                from    User
                                where   Id = :UserInfo.getUserId()
                                limit   1 ];
        PopulateMenuItems();
    }
    
    /*  PopulateMenuItems
    *   @description:   This method populates menu items configured in Sidebar_Menu_Settings__c custom setting.
    *   @parameters     N/A
    *   @return type    void                     
    */     
    private void PopulateMenuItems()
    {
       try{
        //Set<Id> menuItemIds = new Set<Id>();
        Set<String> displayNames = new Set<String>();
        menuItems = new List<Sidebar_Menu_Settings__c>();
        for( Sidebar_Menu_Settings__c menuSetting 
                    :[   select  Id, Display_Name__c, Target__c, URL__c, Market_Segment__c, Role__c, State__c
                        from    Sidebar_Menu_Settings__c
                        where   ( Market_Segment__c = :currentUserRecord.Market_Segment__c or Market_Segment__c = null )
                                and ( State__c = :currentUserRecord.State or State__c = null )
                                and ( Role__c = :currentUserRecord.UserRole.Name or Role__c = null )
                        order by Sort_Order__c, Market_Segment__c, State__c, Role__c NULLS LAST
                        limit   :Limits.getLimitQueryRows() - Limits.getQueryRows() ] )
        {
            if( !displayNames.contains( menuSetting.Display_Name__c ) ) {
                displayNames.add( menuSetting.Display_Name__c );
                menuItems.add( menuSetting );
            }
        }                        
        
        
        /*for( Sidebar_Menu_Settings__c menuSetting 
                    :[  select  Id
                        from    Sidebar_Menu_Settings__c
                        where   Market_Segment__c = null
                                and State__c = null
                                and Role__c = null
                                and Display_Name__c NOT IN :displayNames
                        order by Sort_Order__c
                        limit   :Limits.getLimitQueryRows() - Limits.getQueryRows() ] )
        {
            menuItemIds.add( menuSetting.Id );
        }
        
        menuItems = [   select  Id, Name, Display_Name__c, Target__c, URL__c, Market_Segment__c, Role__c, State__c
                        from    Sidebar_Menu_Settings__c
                        where   Id IN :menuItemIds
                        order by Sort_Order__c
                        limit   :Limits.getLimitQueryRows() - Limits.getQueryRows() ];
        */
      }catch(Exception e){
          System.debug( 'Exception : ' +e.getMessage() );
      }
      
    }
    

}