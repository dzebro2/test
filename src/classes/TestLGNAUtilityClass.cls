/**************************************************************************************
  Apex Class Name     : TestLGNAUtilityClass
  Version             : 1.0
  Function            : This is a test class for LGNAUtilityClass
  Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
*  
*************************************************************************************/
@isTest
public with sharing class TestLGNAUtilityClass {
	static testmethod void unittest1(){
		Map<String, Id> recordTypeMap = LGNAUtilityClass.createRecordTypeNameToIdMap('Account');
		system.assertEquals(recordTypeMap.size()>0,true);
	}
}