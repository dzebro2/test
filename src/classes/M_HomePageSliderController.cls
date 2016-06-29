public with sharing class M_HomePageSliderController { 
    public Component.Apex.OutputPanel GetAccordionHTML() {
        Component.Apex.OutputPanel outPanel = new Component.Apex.OutputPanel();
        try {
            
            Map<String, Home_Page_Slider_Components__c> componentNamesMap = new Map<String, Home_Page_Slider_Components__c>();
            for( Home_Page_Slider_Components__c comp :[ select  Id, Name, Icon_Class__c, Component_Code__c, Component_URL__c
                                                        from    Home_Page_Slider_Components__c 
                                                        limit   :Limits.getLimitQueryRows() - Limits.getQueryRows() ] ) {
                componentNamesMap.put( comp.Component_Code__c, comp );
            }
                    
            
            outPanel.layout     = 'block';
            outPanel.styleClass = 'accordion salesforce-blue';
    
            
            Home_Page_Slider_Preferences__c hpsPref = Home_Page_Slider_Preferences__c.getInstance();
            List<String> componentCodes = hpsPref.Component_Codes__c.split( ':', -2 ) ;
            for( Integer sequence = 0; sequence < componentCodes.size(); sequence++ ) {        
                String pref = componentCodes[ sequence ];
                if( componentNamesMap.containsKey( pref ) ) {
                    Component.Apex.OutputText htmlTxt = new Component.Apex.OutputText();
                    
                    if(sequence == 0){
                        htmlTxt.value = '<div class="accordion-label arrow">'
                                                + '<input type="radio" id="accordion-'+ sequence +'" name="accordion" checked="checked" class="tab-1" onChange="adjustWidth();"/>'
                                                + '<label align="right" for="accordion-'+ sequence +'">'
                                                    + '<i class="' + componentNamesMap.get( pref ).Icon_Class__c + '"></i>'
                                                    + '<h4 >' + componentNamesMap.get( pref ).Name + '</h4>'
                                                + '</label>'
                                                + '<ul class="accordion-section-one">'
                                                    + '<div class="media-holder" pageurl="' + componentNamesMap.get( pref ).Component_URL__c  + '">'
                                                    + '</div>'
                                                + '</ul>'
                                        + '</div>';
                        htmlTxt.escape = false;
                    }
                    else{
                        htmlTxt.value = '<div class="accordion-label arrow">'
                                                + '<input type="radio" id="accordion-'+ sequence +'" name="accordion" class="tab-1" onChange="adjustWidth();"/>'
                                                + '<label for="accordion-'+ sequence +'">'
                                                    + '<i class="' + componentNamesMap.get( pref ).Icon_Class__c + '"></i>'
                                                    + '<h4>' + componentNamesMap.get( pref ).Name + '</h4>'
                                                + '</label>'
                                                + '<ul class="accordion-section-one">'
                                                    + '<div class="media-holder" pageurl="' + componentNamesMap.get( pref ).Component_URL__c  + '">'
                                                    + '</div>'
                                                + '</ul>'
                                        + '</div>';
                        htmlTxt.escape = false;
                    }
                    outPanel.childComponents.add( htmlTxt );
                }
            }

        } catch( Exception e ) {
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR,  e.getMessage()  ) );
            //CreateExceptionLog.insertErrorLog(e, null, null, null, 'Apex Class', 'HomePage', null, 'HomePageSliderController.getAccordionHTML()','High'); 
            System.debug( 'Exception : ' +e.getMessage() );
        }
        return outPanel;
        
    }
    
    public M_HomePageSliderController() {
    }
    
    public M_HomePageSliderController(ApexPages.StandardController ctrl) {
    }   
    public PageReference gotoPreferencesPage() {
        PageReference pg = Page.HPS_HomePageSliderPreferences;
        return pg;
    }
}