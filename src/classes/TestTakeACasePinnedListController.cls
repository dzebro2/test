/**************************************************************************************
  Apex Class Name     : TestTakeACasePinnedListController
  Version             : 1.0
  Function            : This class is serves as Unit Test Class for TakeACasePinnedListController
  Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
*   Dinesh Talreja       14/11/2014                Original Version
*************************************************************************************/


@isTest

public class TestTakeACasePinnedListController{
    
    /*  TestTakeACase
    *   @description:   This method is used to test the Conditions of TakeACasePinnedListController
    *   @parameters     N/A
    *   @return type    N/A                     
    */
    public static testMethod void TestTakeACase(){
        
        
        Service_Console_Settings__c consoleSettings = new Service_Console_Settings__c();
        consoleSettings.Name = 'Default';
        consoleSettings .Unread_Email_Report_Name__c= 'XYZ';
        consoleSettings .Unread_Email_Refresh_Interval__c= 300;
        
        insert consoleSettings ;
        
        
        Queue_Names__c QueueNameObj = new Queue_Names__c();
        QueueNameObj.Name = 'Oklahoma';
        QueueNameObj.Count_Range_1_Color__c = '33CC33';
        QueueNameObj.Count_Range_1_End__c = 10;
        QueueNameObj.Count_Range_1_Start__c = 0;
        QueueNameObj.Count_Range_2_Color__c = 'FFC200';
        QueueNameObj.Count_Range_2_End__c = 75;
        QueueNameObj.Count_Range_3_Color__c = 'CC0000';
        QueueNameObj.Zero_Count_Color__c = '888888';
        QueueNameObj.Active__c = true;
        QueueNameObj.Sort_Order__c = 1;
        QueueNameObj.Title__c = 'Oklahoma';
        insert QueueNameObj;
        
        System.assertEquals(QueueNameObj.Name,'Oklahoma');
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        
        User ClientRepUser = new User(Alias = 'client', Email='client@testorg.com', EmailEncodingKey='UTF-8', LastName='Client', LanguageLocaleKey='en_US', 
                        LocaleSidKey='en_US', ProfileId = p.Id, department = 'STP', TimeZoneSidKey='America/Los_Angeles', UserName=Math.random() + '@test.com');
        
        System.runAs(ClientRepUser){
            
            Group GroupObj = new Group();
            GroupObj.Name = 'Oklahoma';
            GroupObj.Type = 'Queue';
            insert GroupObj;
            
            System.assertEquals(GroupObj.Name,'Oklahoma');
            
            GroupMember GroupMemberObj = new GroupMember();
            GroupMemberObj.GroupId = GroupObj.Id;
            GroupMemberObj.UserOrGroupId = ClientRepUser.Id;
            insert GroupMemberObj;
            
            Case CaseObj = new Case();
            CaseObj.Subject = 'Test';
            CaseObj.Type = 'Benefits';
            CaseObj.Sub_Category__c = 'Benefit Booklet';
            CaseObj.Status = 'Working';
            CaseObj.Priority = 'Low';
            CaseObj.Origin = 'Email';
            CaseObj.ownerId = ClientRepUser.Id;
            insert CaseObj;
            
            System.assert(CaseObj.Id !=null);
            
            Case CaseObj1 = new Case();
            CaseObj1.Subject = 'Test';
            CaseObj1.Type = 'Benefits';
            CaseObj1.Sub_Category__c = 'Benefit Booklet';
            CaseObj1.Status = 'Working';
            CaseObj1.Priority = 'Low';
            CaseObj1.Origin = 'Email';
            CaseObj1.ownerId = GroupObj.Id;
            insert CaseObj1;
            
            System.assert(CaseObj1.Id !=null);
            
            PageReference pageRef = Page.TakeACasePinnedList;
            pageRef.getParameters().put('queueId',GroupObj.Id);
            Test.setCurrentPage(pageRef);
        
            Test.startTest();
            TakeACasePinnedListController controllerObj = new TakeACasePinnedListController();
            controllerObj.createPushTopic();
            controllerObj.assignCase();
            controllerObj.callUnReadEmails();
            Test.stopTest();
        }
    }
}