/**************************************************************************************
  Apex Class Name     : myTeamsCasesList 
  Version             : 1.0
  Function            : This is a controller class for HPS_MyOpportunitiesContro Page for showing the information of current logged in user goals.
  Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------    
  Dinesh           :       March                    Original Version
  mayuri                   June                     Updated Code comments
*************************************************************************************/
public with sharing class HPS_MyTeamsCasesController {
    
   	public List<Case> myTeamsCasesList {get; set;} // list of cases of logged in user /case team member whos user is logged in user
	public Id medicalUWRecordTypeId {get;set;}
	public Id dentalUWRecordTypeId 	{get;set;}   
   
   	Set<string> statusClosed ;
   	private static integer userLevel = 0;
   /*************************************************
     * Method name  : HPS_MyTeamsCasesController
     * Description  : Constructor of the Controller class HPS_MyTeamsCasesController
     * Return Type  : Void
     * Parameter    : StandardController
     *************************************************/  
    public HPS_MyTeamsCasesController(){
        try{ 
            statusClosed = new Set<String>{ 'Closed - No Response','Closed'};
            populateRecordTypeIds();
            populateMyTeamsCases();
        }catch(Exception e){
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'An error occured while loading. Please contact your administrator with this error:' + e.getMessage() + '  ' + e.getStackTraceString() ) );
        }
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
     * Method name  : populateMyTeamsCases
     * Description  : Method to Collect Teams Cases which belong to logged in user in list to populate on Page.
     * Return Type  : void
     * Parameter    : None
  ************************************************************ */
   
    private void populateMyTeamsCases(){
        myTeamsCasesList    = new List<Case>();
        //Set<Id> teamUserIds = new Set<Id>();
        Set<Id> caseIds     = new Set<Id>();
        
        //Id lgnaCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('LGNA - General Case').getRecordTypeId();
        try{   
           // query case ids of cases which  has logged in user as team member
            /*for( User userObj :[    SELECT  Id 
                                    FROM    User 
                                    WHERE   ManagerId =:UserInfo.getUserId() 
                                    limit   :Limits.getLimitQueryRows() - Limits.getQueryRows() ] ) {
                teamUserIds.add( userObj.Id );
            }    
                //get all the users who are 2 level below the current login user
            teamUserIds.addAll(ConstantsController.getAllSubordinateUsers(teamUserIds));*/
            for(CaseTeamMember ctm : [select ParentId from CaseTeamMember where MemberId = :UserInfo.getUserId() ]){
                caseIds.add(ctm.ParentId);
            }
         // query case details of colllected ids of cases as well cases of users who are two level below of logged in user
            for( Case caseObj :[    SELECT  Id, AccountId, Subject, Status, Type, Account.Name, CreatedDate, Days_Open__c, CaseNumber,
                                            RecordTypeid, OwnerId, Mail_Date_Due_Date__c, Underwriting_Due_Date__c
                                    FROM    Case 
                                    WHERE   ( ( 	OwnerId = :UserInfo.getUserId() OR Direct_Indirect_Manager_of_Owner__c = true )//OwnerId =: UserInfo.getUserId() OR OwnerId IN: teamUserIds 
                                            OR Id In :caseIds) 
                                        AND Status NOT IN :statusClosed  and ISCLOSED = false
                                    limit   :Limits.getLimitQueryRows() - Limits.getQueryRows() ] ) {
                
                if(myTeamsCasesList.size()<10000)
                	myTeamsCasesList.add( caseObj );
            }
        }catch(Exception e){
            System.debug( 'Exception : ' +e.getMessage() );
            throw e;
        }
   }
   /*public static Set<ID> getRoleSubordinateUsers() {
        try{
            // get requested user's role
            Id roleId = [select UserRoleId from User where Id = :userInfo.getUserId()].UserRoleId;
            // get all of the roles underneath the user
            Set<Id> allSubRoleIds = getAllSubRoleIds(new Set<ID>{roleId});
            system.debug('==subroles=='+allSubRoleIds);
            // get all of the ids for the users in those roles
            Map<Id,User> users = new Map<Id, User>([Select Id, Name From User where 
              UserRoleId IN :allSubRoleIds]);
            // return the ids as a set so you can do what you want with them
            return users.keySet();
        }catch(Exception e){
            System.debug( 'Exception : ' +e.getMessage() );
            throw e;
        }
  }
  
  private static Set<ID> getAllSubRoleIds(Set<ID> roleIds) {
    try{
        ++userLevel;
        Set<ID> currentRoleIds = new Set<ID>();
    
        // get all of the roles underneath the passed roles
        for(UserRole userRole :[select Id from UserRole where ParentRoleId 
          IN :roleIds AND ParentRoleID != null])
        currentRoleIds.add(userRole.Id);
        system.debug('level==='+ userLevel);
        // go fetch some more rolls!
        if(currentRoleIds.size() > 0 && userLevel <=1)
          currentRoleIds.addAll(getAllSubRoleIds(currentRoleIds));
    
        return currentRoleIds;
    }catch(Exception e){
        System.debug( 'Exception : ' +e.getMessage() );
        throw e;
    }
  }*/
   
}