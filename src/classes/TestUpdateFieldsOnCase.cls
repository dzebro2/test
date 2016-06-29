/**************************************************************************************
  Apex Class Name     : TestUpdateFieldsOnCase
  Version             : 1.0
  Function            : This class is serves as Unit Test Class for UpdateFieldsOnCase
  Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
*   Dinesh Talreja       14/11/2014                Original Version
*************************************************************************************/

@isTest

public class TestUpdateFieldsOnCase{
    
    /*  TestUpdatePriorityToCritical
    *   @description:   This method is used to test the Update Priority to Critical Condition of UpdateFieldsOnCase
    *   @parameters     N/A
    *   @return type    N/A                     
    */
    public static testMethod void TestUpdatePriorityToCritical()
    {
       
        Case caseObj = new Case();
        caseObj.Subject = 'Test';
        caseObj.Type = 'Benefits';
        caseObj.Sub_Category__c = 'Benefit Booklet';
        caseObj.Status = 'New';
        caseObj.Priority = 'Medium';
        caseObj.Origin = 'Email';
        insert caseObj;
        
        System.assert(caseObj.Id !=null);
        
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        
        email.Subject = 'Update: Priority: ?Critical?: '+caseObj.Id;
        
        Test.startTest();
        UpdateFieldsOnCase controllerObj = new UpdateFieldsOnCase();
        controllerObj.handleInboundEmail(email, env);
        Test.stopTest();
    }
    /*  TestUpdatePriorityToMedium
    *   @description:   This method is used to test the Update Priority to One Up Condition of UpdateFieldsOnCase
    *   @parameters     N/A
    *   @return type    N/A                     
    */
    public static testMethod void TestUpdatePriorityToMedium()
    {
        
        Case caseObj = new Case();
        caseObj.Subject = 'Test';
        caseObj.Type = 'Benefits';
        caseObj.Sub_Category__c = 'Benefit Booklet';
        caseObj.Status = 'New';
        caseObj.Priority = 'Low';
        caseObj.Origin = 'Email';
        insert caseObj;
        
        System.assert(caseObj.Id !=null);
        
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        
        email.Subject = 'Update: Priority: <One Up>: '+caseObj.Id;
        
        Test.startTest();
        UpdateFieldsOnCase controllerObj = new UpdateFieldsOnCase();
        controllerObj.handleInboundEmail(email, env);
        Test.stopTest();
    }
    /*  TestUpdatePriorityToHigh
    *   @description:   This method is used to test the Update Priority to One Up Condition of UpdateFieldsOnCase
    *   @parameters     N/A
    *   @return type    N/A                     
    */
    public static testMethod void TestUpdatePriorityToHigh()
    {
        
        Case caseObj = new Case();
        caseObj.Subject = 'Test';
        caseObj.Type = 'Benefits';
        caseObj.Sub_Category__c = 'Benefit Booklet';
        caseObj.Status = 'New';
        caseObj.Priority = 'Medium';
        caseObj.Origin = 'Email';
        insert caseObj;
        
        System.assert(caseObj.Id !=null);
        
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        
        email.Subject = 'Update: Priority: <One Up>: '+caseObj.Id;
        
        Test.startTest();
        UpdateFieldsOnCase controllerObj = new UpdateFieldsOnCase();
        controllerObj.handleInboundEmail(email, env);
        Test.stopTest();
    }
    /*  TestUpdatePriorityToCriticalOneUp
    *   @description:   This method is used to test the Update Priority to One Up Condition of UpdateFieldsOnCase
    *   @parameters     N/A
    *   @return type    N/A                     
    */
    public static testMethod void TestUpdatePriorityToCriticalOneUp()
    {
        
        Case caseObj = new Case();
        caseObj.Subject = 'Test';
        caseObj.Type = 'Benefits';
        caseObj.Sub_Category__c = 'Benefit Booklet';
        caseObj.Status = 'New';
        caseObj.Priority = 'High';
        caseObj.Origin = 'Email';
        insert caseObj;
        
        System.assert(caseObj.Id !=null);
        
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        
        email.Subject = 'Update: Priority: <One Up>: '+caseObj.Id;
        
        Test.startTest();
        UpdateFieldsOnCase controllerObj = new UpdateFieldsOnCase();
        controllerObj.handleInboundEmail(email, env);
        Test.stopTest();
    }
    /*  TestUpdateStatus
    *   @description:   This method is used to test the Update Status to Closed - No Response Condition of UpdateFieldsOnCase
    *   @parameters     N/A
    *   @return type    N/A                     
    */
    public static testMethod void TestUpdateStatus()
    {
        
        Case caseObj = new Case();
        caseObj.Subject = 'Test';
        caseObj.Type = 'Benefits';
        caseObj.Sub_Category__c = 'Benefit Booklet';
        caseObj.Status = 'Working';
        caseObj.Priority = 'Low';
        caseObj.Origin = 'Email';
        insert caseObj;
        
        System.assert(caseObj.Id !=null);
        
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        
        email.Subject = 'Update: Status: ?Closed - No Response?: '+caseObj.Id;
        
        Test.startTest();
        UpdateFieldsOnCase controllerObj = new UpdateFieldsOnCase();
        controllerObj.handleInboundEmail(email, env);
        Test.stopTest();
    }
    /*  TestSendEmailToOwnersManager
    *   @description:   This method is used to test Send Email to Owner's Manager Condition of UpdateFieldsOnCase
    *   @parameters     N/A
    *   @return type    N/A                     
    */
    public static testMethod void TestSendEmailToOwnersManager()
    {
        
        EmailTemplate emailTemplateObj = [SELECT Id, DeveloperName FROM EmailTemplate LIMIT 1];
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator']; 

        User ManagerUser = new User(Alias = 'manager', Email='manager@testorg.com', EmailEncodingKey='UTF-8', LastName='Manager', LanguageLocaleKey='en_US', 
                        LocaleSidKey='en_US', ProfileId = p.Id, department = 'STP', TimeZoneSidKey='America/Los_Angeles', UserName=Math.random() + '@test.com');
        
        insert ManagerUser;
        
        User ClientRepUser = new User(Alias = 'client', Email='client@testorg.com', EmailEncodingKey='UTF-8', LastName='Client', LanguageLocaleKey='en_US', 
                        LocaleSidKey='en_US', ProfileId = p.Id, department = 'STP', TimeZoneSidKey='America/Los_Angeles', UserName=Math.random() + '@test.com', ManagerId = ManagerUser.Id);
        
        System.runAs(ClientRepUser){
            Case caseObj = new Case();
            caseObj.Subject = 'Test';
            caseObj.Type = 'Benefits';
            caseObj.Sub_Category__c = 'Benefit Booklet';
            caseObj.Status = 'Working';
            caseObj.Priority = 'Low';
            caseObj.Origin = 'Email';
            caseObj.ownerId = ClientRepUser.Id;
            insert caseObj;
            
            System.assert(caseObj.Id !=null);
            
            Messaging.InboundEmail email = new Messaging.InboundEmail();
            Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
            
            email.Subject = 'Mail: '+caseObj.OwnerId+': '+caseObj.Id+':'+emailTemplateObj.DeveloperName;
            
            Test.startTest();
            UpdateFieldsOnCase controllerObj = new UpdateFieldsOnCase();
            controllerObj.handleInboundEmail(email, env);
            Test.stopTest();
        }
        
    }
    /*  TestSendEmailToQueue
    *   @description:   This method is used to test the Send Email to Queue Condition of UpdateFieldsOnCase
    *   @parameters     N/A
    *   @return type    N/A                     
    */
    public static testMethod void TestSendEmailToQueue()
    {
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator']; 
        
        EmailTemplate emailTemplateObj = [SELECT Id, DeveloperName FROM EmailTemplate LIMIT 1];
        
       
        
        User ClientRepUser = new User(Alias = 'client', Email='client@testorg.com', EmailEncodingKey='UTF-8', LastName='Client', LanguageLocaleKey='en_US', 
                        LocaleSidKey='en_US', ProfileId = p.Id, department = 'STP', TimeZoneSidKey='America/Los_Angeles', UserName=Math.random() + '@test.com');
        
       
        
        System.runAs(ClientRepUser)
        {
            Group GroupObj = new Group();
            GroupObj.Name = 'Oklahoma';
            GroupObj.Type = 'Queue';
            insert GroupObj;
            
            system.assertEquals(GroupObj.Name,'Oklahoma');
            
            GroupMember GroupMemberObj = new GroupMember();
            GroupMemberObj.GroupId = GroupObj.Id;
            GroupMemberObj.UserOrGroupId = ClientRepUser.Id;
            insert GroupMemberObj;
        
            Case caseObj = new Case();
            caseObj.Subject = 'Test';
            caseObj.Type = 'Benefits';
            caseObj.Sub_Category__c = 'Benefit Booklet';
            caseObj.Status = 'Working';
            caseObj.Priority = 'Low';
            caseObj.Origin = 'Email';
            caseObj.ownerId = groupObj.Id;
            insert caseObj;
            
            System.assert(caseObj.Id !=null);
            
            Messaging.InboundEmail email = new Messaging.InboundEmail();
            Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
            
            email.Subject = 'Mail: '+caseObj.OwnerId+': '+caseObj.Id+':'+emailTemplateObj.DeveloperName;
            
            Test.startTest();
            UpdateFieldsOnCase controllerObj = new UpdateFieldsOnCase();
            controllerObj.handleInboundEmail(email, env);
            Test.stopTest();
        }
       
    }
}