/**************************************************************************************
  Apex Class Name     : FormLibraryExtTest
  Version             : 1.0
  Function            : This is a test class for FormLibraryExt.
  Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Alec Klein		          2/11/2016
*************************************************************************************/
@isTest
private class FormLibraryExtTest {
	@isTest static void testLibraryCreation(){
		try{
			test.StartTest();

			PageReference myVfPage = new PageReference('/apex/FormLibrary2');
			test.setCurrentPage(myVfPage);
			ApexPages.StandardController stdCon = new ApexPages.StandardController(new Form_Library__c());
			FormLibraryExt2 flExt = new FormLibraryExt2(stdCon);
			flExt.name = 'Test FL';
			flExt.type = 'BAA';
			flExt.state = 'IL';

			flExt.fileName = 'Test File';
			flExt.fileBody = Blob.valueOf(' ');
			flExt.description = 'This is clearly a test file';

			PageReference onProcess = flExt.processPage();

			System.assert([SELECT Name FROM Attachment].size() > 0);
			System.assert([SELECT Name FROM Form_Library__c].size() > 0);

			PageReference onSave = flExt.returnToRecord();
			flExt.obj = null;
			PageReference onCatch = flExt.returnToRecord();
			System.assertNotEquals(onProcess, onSave);
			System.assertNotEquals(onProcess, onCatch);

			test.StopTest();
		}catch(Exception e){

		}	
	}

	@isTest static void testLibraryCreationParamFailure(){
		try{
			test.StartTest();

			PageReference myVfPage = new PageReference('/apex/FormLibrary2');
			test.setCurrentPage(myVfPage);
			ApexPages.StandardController stdCon = new ApexPages.StandardController(new Form_Library__c());
			FormLibraryExt2 flExt = new FormLibraryExt2(stdCon);
			flExt.name = 'Test FL';
			flExt.type = 'BAA';
			flExt.state = 'IL';

			flExt.fileName = 'Test File';
			flExt.fileBody = Blob.valueOf(' ');
			flExt.description = 'This is clearly a test file';

			flExt.urlParamId = '0';
			PageReference onProcess = flExt.processPage();


			test.StopTest();
		}catch(Exception e){

		}	
	}
}