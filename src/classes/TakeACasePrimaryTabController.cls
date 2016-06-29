/**************************************************************************************
  Apex Class Name     : TakeACasePrimaryTabController
  Version             : 1.0
  Function            : This class is used to get the list of cases to show it in cases primary tab. 
  Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
*   Suyog Dongaonkar       26/09/2014                Original Version
*************************************************************************************/
public with sharing class TakeACasePrimaryTabController 
{
    
    public Id CaseId {get; set;}
    public List<Case> ListOfCases {get; set;}
    public List<Case> CasesAssignedToMe {get; set;}
	public Boolean openContactAsSubtab {get; set;}

    /*  TakeACasePrimaryTabController
    *   Initilization
    */
    public TakeACasePrimaryTabController(ApexPages.standardController controller) 
    {
        //populateCaseLists();
        ListOfCases         = new List<Case>();
        CasesAssignedToMe   = new List<Case>();
        
        try {
        	openContactAsSubtab = Service_Console_Settings__c.getInstance( 'Default' ).Open_Contact_as_a_subtab_of_Account__c;
        } catch( Exception e ) {
        	openContactAsSubtab = true;
        }
    }

 
    /*  populateCaseLists
    *   @description:   This method gets the list of cases. The fields are fetched based on the configuration in field sets.
    *   @parameters     N/A
    *   @return type    N/A                     
    */  
    public void PopulateCaseLists() 
    {
        try {
	        Id CurrentUserId = UserInfo.getUserId();
	        String CasesIOwnQuery = ' SELECT ';
	        String CasesAssignedToMeQuery = ' SELECT ';
	        
	        //Calculate query row limit
	        Integer queryLimit = Limits.getLimitQueryRows() - Limits.getQueryRows() ;
	        
	        for( Schema.FieldSetMember f :SObjectType.Case.FieldSets.TakeACase.getFields() ) 
	        {
	            CasesIOwnQuery += f.getFieldPath() + ', ';
	        }
	        
	         for( Schema.FieldSetMember f :SObjectType.Case.FieldSets.TakeACaseAssignedToMe.getFields() ) 
	        {
	            CasesAssignedToMeQuery += f.getFieldPath() + ', ';
	        }
	        CasesIOwnQuery +=  ' Id, IsEscalated, CaseNumber, Contact_s_Account_Name__c, Contact_s_Account_Id__c'
	                 		+  ' FROM  Case '
	                 		+  ' WHERE isClosed = false ';
	                 
	        CasesAssignedToMeQuery +=  ' Id, IsEscalated, CaseNumber, Contact_s_Account_Name__c, Contact_s_Account_Id__c'
	                 				+  ' FROM  Case '
	                 				+  ' WHERE isClosed = false ' ;
	                 
	                 
	        String MyCasesQuery  = CasesIOwnQuery
	                                +   ' AND OwnerId =:CurrentUserId '
	                                +   ' order by  LastModifiedDate '
	                                +   ' limit :queryLimit';
	        
	        ListOfCases = (List<Case>) Database.Query( MyCasesQuery );
	        
	        //Recalculate query row limit
	        queryLimit = Limits.getLimitQueryRows() - Limits.getQueryRows() ;
	
	        String AssignedCasesQuery    = CasesAssignedToMeQuery
	                                        +   ' AND OwnerId           !=:CurrentUserId '
	                                        +   ' AND Assigned_To__c    =:CurrentUserId '
	                                        +   ' order by  LastModifiedDate '
	                                        +	' limit :queryLimit';     
	                                
	        CasesAssignedToMe = (List<Case>) Database.Query( AssignedCasesQuery );
	    }catch(Exception e) {
	    	System.debug( Label.AnErrorHasOcurred + ' ' + e.getMessage() + '. Stack Trace: ' + e.getStackTraceString() );
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, Label.AnErrorHasOcurred + ' ' + e.getMessage() + '. '+ Label.Case_Queues_Error_Message_Text ) );
	    }
    
    }
    
}