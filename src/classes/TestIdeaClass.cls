/**************************************************************************************
  Apex Class Name     : TestIdeaClass
  Version             : 1.0
  Function            : This is a test class for IdeaClass
  Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------
*  Ralph Tariga             2/25/2016
*************************************************************************************/
@isTest
public with sharing class TestIdeaClass {
	public TestIdeaClass() {

	}

	static testMethod void TestUpdateVoteNumber() {
		Ideas__c newIdea = new Ideas__c();
		newIdea.Name = 'testIdea';
		newIdea.Summary__c = 'Just a test';
		newIdea.Status__c = 'New';
		newIdea.Description__c = 'Just a test';
		insert newIdea;

		newIdea .Vote_Points__c = 1;

		Vote__c newVote = new Vote__c();
		newVote.Voted_by__c = UserInfo.getUserId();
		newVote.Name = 'Test';
		newVote.Voted_on__c = newIdea.Id;

		IdeaClass newIdeaClass = new IdeaClass();

		IdeaClass.updateVoteNumber(newIdea, newVote);

		System.assertNotEquals(newVote.Id, NULL);

		Ideas__c emptyIdea = new Ideas__c();
		Vote__c emptyVote = new Vote__c();

		IdeaClass.updateVoteNumber(emptyIdea, emptyVote);

		System.assertEquals(emptyVote.Id, NULL);
		System.assertEquals(emptyIdea.Id, NULL);
	}
}