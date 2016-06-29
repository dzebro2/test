/**************************************************************************************
  Apex Class Name     : TestStaticVariablesUtility 
  Version             : 1.0
  Function            : This is a test class for StaticVariablesUtility 
  Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
*  
*************************************************************************************/
@isTest
private class TestStaticVariablesUtility {

    static testMethod void myUnitTest() {
        try{
             Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
             User testUser = TestClassUtiltity.CreateUserRecord(p.Id, 'testlgnadev@user.com', 'testUser', 'test@user.com');

             system.runAs(testUser){
                StaticVariablesUtility tempController = new StaticVariablesUtility();
                system.assertEquals(StaticVariablesUtility.contactNameQueryString ,'contactName');
            }
            // 
        }catch(Exception e){
            throw e;
        }
    }
    
    
}