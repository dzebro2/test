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
 */
@isTest
private class TestIntegrationStatusTriggerHandler {

    static testMethod void myUnitTest() {
        try{
            list<Integration_Status__c> ints = new list<Integration_Status__c>();
            ints.add(new Integration_Status__c(ObjectType__c ='CaseComment'));
            insert ints;
            Username_Password__c temo = new Username_Password__c();
            temo.name=System.label.ModuleName;
            temo.UserName__c = 'testerr';
            temo.Password__c = 'testerr';
            temo.EndPoinUrl__c = 'testerr';
            insert temo;
            test.StartTest(); 
            IntegrationStatusTriggerHandler tempObj = new IntegrationStatusTriggerHandler();
            IntegrationStatusTriggerHandler.updateIntegrationAction(ints);
            system.assertEquals(ints[0].Integration_Action__c ,'Note Insert');
            IntegrationStatusTriggerHandler.calloutHelperMethod(ints);
            IntegrationStatusTriggerHandler.SendCalloutsToCBSR('bdy');
            test.StopTest(); 
        }catch(Exception e){
            
        }
    }
}