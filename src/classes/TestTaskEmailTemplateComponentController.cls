/*
    @Description : This is an test class for TaskEmailTemplateComponentController
    @author      : Deloitte
    @date        : 11/18/2015
*/
@isTest
public with sharing class TestTaskEmailTemplateComponentController {
	/*
        @Description : This is a testMethod 
        @author      : Deloitte
        @date        : 11/18/2015
    */
    static testMethod void myUnitTest1() {
    	
    	TaskEmailTemplateComponentController temp = new TaskEmailTemplateComponentController();
    	temp.getOrgURL();
    	temp.relatedrecordId = '005';
    	temp.recordId = '005';
    	temp.relatedrecordName = 'test';
    	temp.relatedSubject = 'test';
    	String str = temp.getStartingIndex();
    	system.assertEquals('005',str);
    }
}