/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 
 **  Author                 Date                              Update
 **     Mei Chen              03/10/2015                         Initial   
 */
@isTest
private class TestBatchCaseMarkedForDelete {
  
   static testMethod void BatchCaseMarkedForDeleteTestMethod() {
       
       list <Case> testCases=new list<Case>();
       
       String testStr=null;
       system.debug('start batch case marked for deleted test method');
       Case case1=new Case();
        case1.subject='EWF MT Approved for Final Distribution';
        case1.Description='Unit test case';
        case1.status='Closed (Marked for Delete)';
        case1.lastmodifieddate = system.today()-1;
        case1.createddate=system.today()-2;
        testCases.add(case1);
                           
        Case case2=new Case();
        case2.subject='EWF Oklahoma Approved for Final Distribution';
        case2.Description='test test';
        case2.status='Closed (Marked for Delete)';
        testCases.add(case2);
        insert testCases;
       
        User user = TestUtils.createTestUser('RunAsUser1', 'System Administrator');
        
        System.runAs(user){
            Test.startTest();
       Database.batchableContext bc ;
            BatchCaseMarkedForDelete b=new BatchCaseMarkedForDelete();
            b.query='Select id, lastmodifieddate from case where status= \'Closed (Marked for Delete)\' limit 200';
            Id batchId=Database.executeBatch(b,200);
            System.assertNOTEquals(batchId,null);
            system.abortJob(batchId);
           testCases[0].id=null;
           b.Execute(bc,testCases);
            Test.stopTest();
       }
    }
    
  
   static testMethod void BatchCaseMarkedForDeleteSchedulerTestMethod(){
    
        Test.startTest();
        
        String CRON_EXP = '0 0 0 3 9 ? 2022';

        // Schedule the test job     
        String jobId = System.schedule('BatchCaseMarkedforDeletedSchdule', CRON_EXP, new BatchCaseMarkedForDeleteSchedule());
		
		System.assertNOTEquals(jobId,null);
        // Stop the test
        Test.stopTest();
    }
}