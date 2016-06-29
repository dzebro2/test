/**************************************************************************************
  Apex Class Name     : TestRecursiveHelper
  Version             : 1.0
  Function            : This is a test class for RecursiveHelper
  Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
*  
*************************************************************************************/
@isTest
private class TestRecursiveHelper{

    static testMethod void myUnitTest() {
        try{
             Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
             User testUser = TestClassUtiltity.CreateUserRecord(p.Id, 'testlgnadev@user.com', 'testUser', 'test@user.com');

             system.runAs(testUser){
                RecursiveHelper tempController = new RecursiveHelper();
                RecursiveHelper.hascreatedPlaybookRecs();
                RecursiveHelper.setCreatedPlaybookRecs();
                system.assertEquals(RecursiveHelper.entityOwnerUpdated ,false);
            }
            // 
        }catch(Exception e){
            throw e;
        }
    }
    
    
}