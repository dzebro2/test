//************************************************************************************
// Name             : IdeaClass.cls
// Description      : This class contains methods for use by the Idea Object
// Created By       : Ralph Tariga
// Created Date     : 2/25/2016
//
// ************************Version Updates********************************************
// Date             Developer           Description
// -----------------------------------------------------------------------------------
// ************************************************************************************
global without sharing class IdeaClass {
	public IdeaClass() {

	}

	// **************************************************************************************************************
	// Name       :   updateVoteNumber
	// Description:   Webservice method to create a Vote Object update the vote number field in Idea Object
	//                without regard to sharing rules
	// Parameters :   curIdea, curVote
	// Returns    :   void
	// **************************************************************************************************************
	webService static void updateVoteNumber(Ideas__c curIdea, Vote__c curVote) {
		try {
			insert curVote;
			update curIdea;
		} catch ( Exception e ) {
			System.debug( 'Exception : ' + e.getMessage() );
		}
	}
}