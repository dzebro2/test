/**************************************************************************************
  Apex Class Name     : TestBatchCreateTaskForGroupAccount
  Version             : 1.0
  Function            : This is a test class for BatchCreateTaskForGroupAccount.
  Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
*  Deloitte            10/28/2015					Original Version
*************************************************************************************/
@isTest(SeeAllData=true)
public class TestBatchCreateTaskForGroupAccount {
    static testmethod void batchCreateTaskForGroupAccountTestmethod(){
        List<sObject> lAccount = new List<sObject>();
        Account testAccount = TestClassUtiltity.CreateAccountRecord('Test Account');
        testAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Group Account').getRecordTypeId();
        testAccount.Group_Medicare__c = true;
        testAccount.Status__c = 'Active';
        update testAccount;
        lAccount.add(testAccount);
        
        LGNA_Constants__c lgnaConstants = new LGNA_Constants__c();
        lgnaConstants.Group_Account_Task_Batch_RUn__c = '10/27';
        lgnaConstants.UW_Due_Date_PrePop_Smaller_Interval__c = 5;
        lgnaConstants.UW_Due_Date_PrePop_Bigger_Interval__c = 8;
        lgnaConstants.Name = 'Default1';
        lgnaConstants.Total_Working_Hours_per_Day__c = 9;
        insert lgnaConstants;
        
        User user = TestUtils.createTestUser('RunAsUser1', 'System Administrator');
        System.runAs(user){
            Test.startTest();
            Database.batchableContext bc ;
            BatchCreateTaskForGroupAccount b = new BatchCreateTaskForGroupAccount();
        //The Query used by the batch job.
        set<String> recordTypeNames = new set<String>{'Group_Account','Group_Account_Non_BlueSTAR'};
			String que = 'select OwnerId,Id from Account where RecordType.DeveloperName In :recordTypeNames '+
											'and Group_Medicare__c = true and Status__c = \'Active\'  ';
			//b.query = que;
            //b.tempDate = Date.today();
          Id batchId=Database.executeBatch(b);
            System.assertNOTEquals(batchId,null);
            //system.abortJob(batchId);
            //b.start(bc);
            //b.execute(bc,lAccount);
            Test.stopTest();
        }
        }
}