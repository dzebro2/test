/**************************************************************************************
  Apex Class Name     : OpportunityDAOTest
  Version             : 1.0
  Function            : This is a test class for the OpportunityDAO class
* Developer                        Date                  
* ----------------------------------------------------------------------------                 
* Nick Serafin/Slalom             5/23/2016
*************************************************************************************/

@isTest(SeeAllData=false)
private class OpportunityDAOTest{

    @isTest
    static void opportunityDAOTest(){

        OpportunityDAO.IOpportunityDAO opportunityDAOInstance = new OpportunityDAO();

        Account testAcnt = TestClassUtiltity.CreateAccountRecord('TestAccount');

        Opportunity opp = new Opportunity(AccountId = testAcnt.Id, HCSC_Division__c = 'IL', Name='oppName 2',StageName = 'Expected In', CloseDate = system.Today().addYears(2), Expected_RFP_Release_Date__c = system.Today().addYears(1), Expected_Decision_Date__c = system.Today().addYears(1), RFI_RFP_Received_Date__c = system.Today().addYears(1), Primary_Closed_Reason__c = 'Savings');
        opp.Requested_Effective_Date__c = System.Today() + 1;    
        insert opp;

        Opportunity opportunityObj = opportunityDAOInstance.getOpportunityById(opp.Id);

        opportunityObj.HCSC_Division__c = 'TX';

        opportunityDAOInstance.updateOpportunity(opportunityObj);

        System.assert(opportunityObj != null);
        System.assertEquals('TX', opportunityObj.HCSC_Division__c);
    
    }
}