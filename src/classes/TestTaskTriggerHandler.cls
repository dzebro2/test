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
public class TestTaskTriggerHandler {

    static testMethod void myUnitTestMethod() {
         try{
             Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
             User testUser = TestClassUtiltity.CreateUserRecord(p.Id, 'testlgnadev@user.com', 'testUser', 'test@user.com');
             //system.runAs(testUser){
                //create Account
                Account testAccount = TestClassUtiltity.CreateAccountRecord('Test Account');
                testAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Group Account').getRecordTypeId();
                testAccount.status__c = 'Sold';
                testAccount.Fax = '1234567';
                update testAccount;
                
                //create Case
                list<Case> cases = TestClassUtiltity.createCaseRecords(testAccount.Id);
                cases[0].RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(ConstantsController.UnderwritingCaseRecordType).getRecordTypeId();
                cases[0].Proposed_Employee__c  = 10;
                
                cases.addAll(TestClassUtiltity.createCaseRecords(testAccount.Id));
                cases[1].RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(ConstantsController.UnderwritingCaseRecordType).getRecordTypeId();
                cases[1].Proposed_Employee__c  = 10;
                insert cases;
                
                
                list<Task> tasks = TestClassUtiltity.createTasks(cases[0].Id);
                tasks[0].status='In progress';
                tasks[0].Type = ConstantsController.TaskTypeForUpdatingCaseStatus;
                tasks[1].status='Completed';
                tasks[1].WhatId=cases[1].Id;
                tasks[1].Type = ConstantsController.TaskTypeForUpdatingCaseStatus;
                insert tasks;
                test.StartTest(); 
                /*tasks[0].status='Completed'; 
                update tasks;*/
                Case c = [select Status from Case where Id =:cases[0].Id][0];
                
                system.assertEquals(c.status,'In Progress');
                test.StopTest(); 
                TaskTriggerHandler Classvar = new TaskTriggerHandler();
         }catch(Exception e){
            
         }
    }
}