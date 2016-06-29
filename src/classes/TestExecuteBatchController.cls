/**************************************************************************************
  Apex Class Name     : TestExecuteBatchController
  Version             : 1.0
  Function            : This is a test class for ExecuteBatchController.
  Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
*  Deloitte            11/02/2015
*************************************************************************************/
@isTest
public class TestExecuteBatchController {
    public static boolean batchExecuted = false;
	static testMethod void myUnitTest1() {
    	User user = TestUtils.createTestUser('RunAsUser1', 'System Administrator');
    	System.runAs(user){
        Test.startTest();
        ExecuteBatchController executeBatchController = new ExecuteBatchController();
        executeBatchController.triggerBatchSendAccountRenewalNotification();
        executeBatchController.triggerBatchSendOppDueDateNotification();
        executeBatchController.triggerBatchCreateTaskforGroupAccount();
        executeBatchController.triggerBatchShareSecureAttachment();
        batchExecuted = true;
        system.assert(batchExecuted,'Batches have been executed');
        Test.stopTest();
    	}
    }
}