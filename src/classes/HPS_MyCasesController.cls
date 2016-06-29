/**************************************************************************************
  Apex Class Name     : HPS_MyCasesController
  Version             : 1.0
  Function            : This is a controller class for HPS_MyCases Page for showing the information of current logged in user Cases.
 Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------    
  Dinesh           :       March                    Original Version
  mayuri                   June                     Updated Code comments
*************************************************************************************/
public with sharing class HPS_MyCasesController {
    
    public List<Case> myCasesList 	{get; set;} // List of cases assigned to logged in user
    public Id medicalUWRecordTypeId {get;set;}
    public Id dentalUWRecordTypeId 	{get;set;}
    
    Set<string>  statusClosed;
   
   /*************************************************
     * Method name  : HPS_MyTeamsCasesController
     * Description  : Constructor of the Controller class HPS_MyTeamsCasesController
     * Return Type  : Void
     * Parameter    : StandardController
   *************************************************/
    public HPS_MyCasesController(){
        statusClosed = new Set<String>{ 'Closed - No Response','Closed'};
        
        populateRecordTypeIds();
        populateMyCases();
    }
    
    private void populateRecordTypeIds() {
		for( RecordType rt :[	select	Id, DeveloperName
        						from	RecordType	
        						where	DeveloperName IN ('Underwriting', 'Dental_Underwriting')
        							and SobjectType = 'Case'
        						limit	2] ) {
			if( rt.DeveloperName == 'Underwriting' ) {
				medicalUWRecordTypeId = rt.Id;
			}
			else if( rt.DeveloperName == 'Dental_Underwriting' ) {
				dentalUWRecordTypeId = rt.Id;
			}
		}    	
    }
    
     /*************************************************************
     * Method name  : populateMyCases
     * Description  : Method to Collect cases whose owner/case team member is logged in user in a list to populate on Page.
     * Return Type  : void
     * Parameter    : None
  ************************************************************ */
    
    private void PopulateMyCases(){
        myCasesList         = new List<Case>();
        Set<Id> accountIds  = new Set<Id>();
        Set<Id> caseIds     = new Set<Id>(); // stores Case Ids
       // Id lgnaCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('LGNA - General Case').getRecordTypeId();
        try{
          // Query All case Ids of cases where case team has  logged in User as a member
            for(CaseTeamMember caseteamObj :[   SELECT  parentId, Memberid 
                                                FROM    CaseTeamMember 
                                                WHERE   Memberid =: UserInfo.getUserId() 
                                                limit   :Limits.getLimitQueryRows() - Limits.getQueryRows() ] ) {
                caseIds.add( caseteamObj.parentId );
            }
         
         // Query All cases details of case Ids queried above
            for(Case caseObj :[ SELECT  Id, AccountId, Subject, Status, Type, Account.Name, CreatedDate, Days_Open__c, caseNumber, RecordTypeId, Mail_Date_Due_Date__c, Underwriting_Due_Date__c
                                FROM    Case 
                                WHERE   ( Id IN: caseIds 
                                        OR ownerid=: UserInfo.getUserId() ) 
                                    AND Status NOT in :statusClosed and ISCLOSED = false
                                limit   :Limits.getLimitQueryRows() - Limits.getQueryRows() ] ) {
                if(myCasesList.size()<10000)
                	myCasesList.add( caseObj );
            }
        } catch( Exception e ) {
              System.debug( 'Exception : ' +e.getMessage() );   
              ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage());
              ApexPages.addMessage(myMsg);
        }  
    }
   
}