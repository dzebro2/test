/**************************************************************************************
  Apex Class Name     : TestHPS_AMGoalsController
  Version             : 1.0
  Function            : This is a test class for HPS_AMGoalsController .
  Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
*  
*************************************************************************************/
@isTest
public class TestHPS_AMGoalsController {

    static testMethod void myUnitTest() {
        try{
            Account testAccount = TestClassUtiltity.CreateAccountRecord('Test Account');
            
            list<Opportunity> opportunities = TestClassUtiltity.CreateOpportunities(testAccount.Id);
            opportunities[0].RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal').getRecordTypeId();
            opportunities[0].StageName = 'Closed Won';
            insert opportunities;
            test.StartTest();
                HPS_AMGoalsController tempController = new HPS_AMGoalsController();
                System.assertEquals(tempController.renewalWonOpportunities!=null,true);
            test.StopTest();
        }catch(Exception e){
            throw e;
        }
    }
}