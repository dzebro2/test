/**************************************************************************************
  Apex Class Name     : TestCaseOwnerShipTrackingTrigger
  Version             : 1.0
  Function            : This is a test class for CaseOwnerShipTrackingTrigger
  Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
*  
*************************************************************************************/
@isTest
public with sharing class TestCaseOwnerShipTrackingTrigger {
	static testMethod void unitTest1(){
		
		RecordType GroupAccountRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Account' AND Name = 'Group Account'];
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.RecordTypeId = GroupAccountRecordType.id;
        acc.HCSC_Division__c = 'TX';
        acc.Market_Segment__c = 'NRMM';
        insert acc;
        Case CaseObj = new Case();
        CaseObj.Subject = 'Test';
        CaseObj.Type = 'Benefits';
        CaseObj.status= 'New';
        CaseObj.Sub_Category__c = 'Benefit Booklet';
        CaseObj.Status = 'New';
        CaseObj.Priority = 'Low';
        CaseObj.Origin = 'Email';
        CaseObj.AccountId = acc.Id;
        
        insert CaseObj;
        Case_Ownership_Tracking__c ct = new Case_Ownership_Tracking__c();
        ct.Case__c = CaseObj.Id;
        ct.End__c = date.today();
        ct.Start__c = date.today().addDays(-1);
        insert ct;
        ct.End__c = null;
        update ct;
        ct = [select Days_Outstanding_Number__c from Case_Ownership_Tracking__c where id =:ct.Id][0];
        system.assertEquals(ct.Days_Outstanding_Number__c,0);
        LGNA_Constants__c temp = new LGNA_Constants__c();
		temp.name = 'Default';
		temp.Total_Working_Hours_per_Day__c = 5;
		temp.UW_Due_Date_PrePop_Bigger_Interval__c = 12;
		temp.UW_Due_Date_PrePop_Smaller_Interval__c = 2;
		
		insert temp;
        ct.End__c = date.today();
        update ct;
        
	}
}