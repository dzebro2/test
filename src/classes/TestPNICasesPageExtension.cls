/**************************************************************************************
  Apex Class Name     : TestPNICasesPageExtension
  Version             : 1.0
  Function            : This is a test class for PNICasesPageExtension .
  Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
*  Sruthy Dileep            6/2/2015
*************************************************************************************/
@isTest
public class TestPNICasesPageExtension {
    
     static testMethod void myUnitTest1() {
        try{
            test.StartTest();
            Account TestAcnt = TestClassUtiltity.CreateAccountRecord('TestAccount');
            List<Case> LstCase = TestClassUtiltity.createCaseRecords(TestAcnt.id);
            insert LstCase;

            
            ApexPAges.StandardController sc2 = new ApexPages.StandardController(LstCase[0]);
            PNICasesPageExtension myCntrl = new PNICasesPageExtension(sc2);
            myCntrl.getFields();
            list<Case> cases = myCntrl.getCaseDisplayList();
         
 			system.assertEquals(cases.size(),0);
            test.StopTest();
            
            }catch(Exception e){
            throw e;
            }
        
    }
    
}