public with sharing class CustomContractCaseListExtension {
	
	public CustomContractCaseListExtension(ApexPages.StandardController controller){
		
	}

	public ApexPages.StandardSetController setCon {
		get{
			if(setCon == null){
				setCon = new ApexPages.StandardSetController(Database.getQueryLocator([SELECT Id FROM Case WHERE RecordType.Name = 'Custom Contracts']));
			}
			return setCon;
		}
		set;
	}

	public List<Case> getCases() {
		return (List<Case>) setCon.getRecords();
	}
}