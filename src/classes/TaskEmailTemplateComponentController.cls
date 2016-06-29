public with sharing class TaskEmailTemplateComponentController {
	public String recordId{get;set;}
	public string relatedrecordId{get;set;}
	public string relatedrecordName{get;set;}
	public string relatedSubject{get;set;}
	public string getOrgURL(){
		return System.Url.getSalesforceBaseURL().toExternalForm();
	}
	public string getStartingIndex(){
		return relatedrecordId.subString(0,3);
	}
	public TaskEmailTemplateComponentController(){
		
	}
}