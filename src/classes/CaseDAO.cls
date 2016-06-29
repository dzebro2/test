public class CaseDAO implements ICaseDAO {

	public interface ICaseDAO {

		Case getRequestTypeParentCase(Id caseId);
	}

	public Case getRequestTypeParentCase(Id caseId) {
		return [Select Provider_Groups__c, Request_Types__c from Case where Id = :caseId];
	}
}