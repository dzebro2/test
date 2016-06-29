/**************************************************************************************
  Apex Class Name     : HPS_HomePageSliderPreferencesController
  Version             : 1.0
  Function            : This is a controller class for HPS_HomePageSliderPreferences Page for saving the preferences of the Sliders to be shown on the home page for a user/profile.
*************************************************************************************/
public with sharing class HPS_HomePageSliderPreferencesController {
    
    public List<SelectOption> allPreferences 
    {
        get;
        set;
    }
    public List<SelectOption> selectedPreferences 
    {
        get;
        set;
    }
    
    public List<SelectOption> profiles 
    {
        get;
        set;
    }
    public String selectedProfile 
    {
        get;
        set;
    } 

    public List<SelectOption> allProfilePreferences 
    {
        get;
        set;
    }
    public List<SelectOption> selectedProfilePreferences 
    {
        get;
        set;
    }
    
    public static Integer maximumComponentsAllowed = 6;
    
    public static String componentCodeDelimeter = ':'; 
    
    public HPS_HomePageSliderPreferencesController() 
    {
        try 
        {
            allPreferences      = new List<SelectOption>();
            selectedPreferences = new List<SelectOption>();            
            
            allProfilePreferences      = new List<SelectOption>();
            selectedProfilePreferences = new List<SelectOption>();
            profiles = new List<SelectOption>();
            
            if( isCurrentUserSystemAdmin() ) 
            {
                populateProfiles();
            }
            populateMyPreferences();
            
        }  catch( Exception e ) 
        {
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, System.label.Error_Message + ' ' + e.getMessage() + '  ' + e.getStackTraceString() ) );
            System.debug( 'Exception : ' +e.getMessage() );
        }
    }
    
    private Boolean IsCurrentUserSystemAdmin() 
    {
       try
       { 
        if( [   select  Name
                from    Profile
                where   Id = :UserInfo.getProfileId()
                limit   1].Name == 'System Administrator' ) 
        {
            return true;
        }
       }catch(Exception e){
           System.debug( 'Exception : ' +e.getMessage() );
           throw e;
       } 
        return false;
    }
    
    private void PopulateMyPreferences() 
    {
        try 
        {
            allPreferences      = new List<SelectOption>();
            selectedPreferences = new List<SelectOption>();
                        
            List<String> selectedPreferencesList    = new List<String>();
            Set<String> selectedPreferencesSet      = new Set<String>();
            Map<String, String> componentNamesMap   = new Map<String, String>();
            
            Home_Page_Slider_Preferences__c hpsPref = Home_Page_Slider_Preferences__c.getInstance();
            Home_Page_Slider_Profile_Configuration__c hpsProfilePref = Home_Page_Slider_Profile_Configuration__c.getInstance();
            
            if(hpsPref.Component_Codes__c != null)
            {
                for( String pref :hpsPref.Component_Codes__c.split( componentCodeDelimeter, -2 ) ) 
                {
                    //This list is useful for maintaining an ordered collection of component API name
                    //This ordered collection can then be used to show preferences in an ordered format on UI
                    selectedPreferencesList.add( pref );
                    selectedPreferencesSet.add( pref );             
                }
            }
            for( Home_Page_Slider_Components__c comp :[ select  Id, Name, Component_Code__c, Component_Description__c
                                                        from    Home_Page_Slider_Components__c 
                                                        limit   :Limits.getLimitQueryRows() - Limits.getQueryRows() ] ) 
            {
                //If description is filled in, put the component description in display name
                String componentDisplayName = comp.Name;
                if( String.isNotBlank( comp.Component_Description__c ) ) 
                {
                    componentDisplayName += ' (' + comp.Component_Description__c + ')';
                }
                
                componentNamesMap.put( comp.Component_Code__c, componentDisplayName );
                
                if( !selectedPreferencesSet.contains( comp.Component_Code__c ) )
                { 
                    if( hpsProfilePref != null && hpsProfilePref.Component_Codes__c != null
                        && hpsProfilePref.Component_Codes__c.contains( comp.Component_Code__c ) ) 
                    {
                        
                        allPreferences.add( new SelectOption( comp.Component_Code__c, componentDisplayName ) );
                    }
                }
            }
            
            //This is done to maintain the sort order
            for( String compCode :selectedPreferencesList ) 
            {
                if( componentNamesMap.containsKey( compCode ) ) 
                {
                    if( hpsProfilePref != null && hpsProfilePref.Component_Codes__c != null
                        && hpsProfilePref.Component_Codes__c.contains( compCode ) ) 
                    {
                        
                        selectedPreferences.add( new SelectOption( compCode, componentNamesMap.get( compCode ) ) );
                    }
                }
            }
        }  catch( Exception e ) 
        {
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, System.label.Error_Message + ' ' + e.getMessage() + '  ' + e.getStackTraceString() ) );
        }    
    }
    
    private void PopulateProfiles() 
    {
        profiles = new List<SelectOption>();
        
        profiles.add( new SelectOption( '', '--- Select Profile ---' ) );
        
        for( Profile prof :[    select  Id, Name
                                from    Profile
                                where   UserLicense.Name = 'Salesforce'
                                limit   :Limits.getLimitQueryRows() - Limits.getQueryRows() ] )
        {
            profiles.add( new SelectOption( prof.Id, prof.Name ) );
        }                               
    }
    
    public PageReference PopulateProfilePreferences() 
    {
        try 
        {
            allProfilePreferences      = new List<SelectOption>();
            selectedProfilePreferences = new List<SelectOption>();
            
            if( String.isNotBlank( selectedProfile ) ) 
            {
                
                List<String> selectedPreferencesList    = new List<String>();
                Set<String> selectedPreferencesSet      = new Set<String>();
                Map<String, String> componentNamesMap   = new Map<String, String>();
                
                Home_Page_Slider_Profile_Configuration__c hpsPref = new Home_Page_Slider_Profile_Configuration__c();
                
                List<Home_Page_Slider_Profile_Configuration__c> hpsPreferences = [  select  Id, Component_Codes__c
                                                                                    from    Home_Page_Slider_Profile_Configuration__c
                                                                                    where   SetupOwnerId = :selectedProfile
                                                                                    limit   1 ];
                if( hpsPreferences.size() > 0 ) 
                {
                    hpsPref = hpsPreferences[0];
                }
                else 
                {
                    hpsPref = Home_Page_Slider_Profile_Configuration__c.getOrgDefaults(); 
                }
                if(hpsPref.Component_Codes__c != null)
                {
                    for( String pref :hpsPref.Component_Codes__c.split( componentCodeDelimeter, -2 ) ) 
                    {
                        //This list is useful for maintaining an ordered collection of component API name
                        //This ordered collection can then be used to show preferences in an ordered format on UI
                        selectedPreferencesList.add( pref );
                        selectedPreferencesSet.add( pref );             
                    }
                }
                for( Home_Page_Slider_Components__c comp :[ select  Id, Name, Component_Code__c, Component_Description__c
                                                            from    Home_Page_Slider_Components__c 
                                                            limit   :Limits.getLimitQueryRows() - Limits.getQueryRows() ] ) 
               {
                    //If description is filled in, put the component description in display name
                    String componentDisplayName = comp.Name;
                    if( String.isNotBlank( comp.Component_Description__c ) ) 
                    {
                        componentDisplayName += ' (' + comp.Component_Description__c + ')';
                    }
                    
                    componentNamesMap.put( comp.Component_Code__c, componentDisplayName );
                    
                    if( !selectedPreferencesSet.contains( comp.Component_Code__c ) ) 
                    { 
                        
                        allProfilePreferences.add( new SelectOption( comp.Component_Code__c, componentDisplayName ) );
                    }
                }
                
                //This is done to maintain the sort order
                for( String compCode :selectedPreferencesList ) 
                {
                    if( componentNamesMap.containsKey( compCode ) ) 
                    {
                        selectedProfilePreferences.add( new SelectOption( compCode, componentNamesMap.get( compCode ) ) );
                    }
                }       
            }
        }  catch( Exception e ) 
        {
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, System.label.Error_Message + ' ' + e.getMessage() + '  ' + e.getStackTraceString() ) );
        }       
        return null;
    }

    public PageReference SaveProfilePreferences() 
    {
        try 
        {
            if( selectedProfilePreferences.size() == 0 ) 
            {
                ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, System.label.Select_one_Record  ) );
                return null;
            }
            
            String componentCodes = '';
            List<Home_Page_Slider_Profile_Configuration__c> hpsList = [     select  Id, SetupOwnerId, Component_Codes__c
                                                                            from    Home_Page_Slider_Profile_Configuration__c
                                                                            where   SetupOwnerId = :selectedProfile
                                                                            limit   1];
                                                                
            for( Integer sequence = 0; sequence < selectedProfilePreferences.size(); sequence++ ) 
            {
                componentCodes += selectedProfilePreferences[ sequence ].getValue() + componentCodeDelimeter;
            }
            componentCodes = componentCodes.removeEnd( componentCodeDelimeter );
    
            if( hpsList.size() > 0 ) 
            {
                hpsList[0].Component_Codes__c = componentCodes;
                update hpsList[0];
            } else 
            {
                Home_Page_Slider_Profile_Configuration__c hps = new Home_Page_Slider_Profile_Configuration__c( SetupOwnerId = selectedProfile, Component_Codes__c = componentCodes );
                insert hps;
            }
            //If the user is configuring for his own profile, refresh the my preferences view as well.
            if( selectedProfile == UserInfo.getProfileId() ) 
            {
                populateMyPreferences();
            }
        }  catch( Exception e ) 
        {
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, System.label.Error_Message + ' '+  e.getMessage() + '  ' + e.getStackTraceString() ) );
           CreateExceptionLog.insertErrorLog(e, null, null, null, ConstantsController.ApexClassLabel, ConstantsController.HomePageLabel, null, 'HPS_HomePageSliderPreferencesController.saveProfilePreferences()','High'); 
            System.debug( 'Exception : ' +e.getMessage() );
        }
        return null;
    }
    
    public PageReference SavePreferences() 
    {
        try 
        {
            if( selectedPreferences.size() == 0 ) 
            {
                ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, System.label.Select_one_Record ) );
                return null;
            }
            
            if( selectedPreferences.size() > maximumComponentsAllowed ) 
            {
                ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, System.label.Maximum_Preference_Selected_Validation.replace('@@@',String.valueOf( maximumComponentsAllowed ))  ) );
                return null;
            }
            
            String componentCodes = '';
            List<Home_Page_Slider_Preferences__c> hpsList = [   select  Id, SetupOwnerId, Component_Codes__c
                                                                from    Home_Page_Slider_Preferences__c
                                                                where   SetupOwnerId = :UserInfo.getUserId()
                                                                limit   1];
                                                                
            for( Integer sequence = 0; sequence < selectedPreferences.size(); sequence++ ) 
            {
                componentCodes += selectedPreferences[ sequence ].getValue() + componentCodeDelimeter;
            }
            componentCodes = componentCodes.removeEnd( componentCodeDelimeter );
            
            if( hpsList.size() > 0 ) 
            {
                hpsList[0].Component_Codes__c = componentCodes;
                update hpsList[0];
            } else 
            {
                Home_Page_Slider_Preferences__c hps = new Home_Page_Slider_Preferences__c(SetupOwnerId=UserInfo.getUserId(), Component_Codes__c=componentCodes);
                insert hps;
            }
            return goToHomePageSlider();
        }  catch( Exception e ) 
        {
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, System.label.Error_Message + ' '+ e.getMessage() + '  ' + e.getStackTraceString() ) );
            CreateExceptionLog.insertErrorLog(e, null, null, null, ConstantsController.ApexClassLabel, ConstantsController.HomePageLabel, null, 'HPS_HomePageSliderPreferencesController.savePreferences()','High'); 
            System.debug( 'Exception : ' +e.getMessage() );
        }
        return null;
    } 

    
    public PageReference GoToHomePageSlider() 
    {
        PageReference pg = Page.HomePageSlider;
        return pg;
    }
    
}