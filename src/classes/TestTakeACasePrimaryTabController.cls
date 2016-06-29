/**************************************************************************************
  Apex Class Name     : TestTakeACasePrimaryTabController
  Version             : 1.0
  Function            : This class is used serves as Unit Test Class for TakeACasePrimaryTabController
  Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
*   Dinesh Talreja       14/11/2014                Original Version
*************************************************************************************/

@isTest

public class TestTakeACasePrimaryTabController{
    
    /*  TestTakeACase
    *   @description:   This method is used to test the Conditions of TakeACasePrimaryTabController
    *   @parameters     N/A
    *   @return type    N/A                     
    */
    public static testMethod void TestTakeACase(){
    
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        
        User ClientRepUser = new User(Alias = 'client', Email='client@testorg.com', EmailEncodingKey='UTF-8', LastName='Client', LanguageLocaleKey='en_US', 
                        LocaleSidKey='en_US', Is_Super_User__c = true, ProfileId = p.Id, department = 'STP', TimeZoneSidKey='America/Los_Angeles', UserName=Math.random() + '@test.com');
        
        System.runAs(ClientRepUser)
        {
            
            Group GroupObj = new Group();
            GroupObj.Name = 'Oklahoma';
            GroupObj.Type = 'Queue';
            insert GroupObj;
            
            System.assertEquals(GroupObj.Name,'Oklahoma');
            
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
            caseObj.ownerId = ClientRepUser.Id;
            insert caseObj;
            
            System.assert(caseObj.Id !=null);
            
            Case caseObj1 = new Case();
            caseObj1.Subject = 'Test';
            caseObj1.Type = 'Benefits';
            caseObj1.Sub_Category__c = 'Benefit Booklet';
            caseObj1.Status = 'Working';
            caseObj1.Priority = 'Low';
            caseObj1.Origin = 'Email';
            caseObj1.ownerId = GroupObj.Id;
            caseObj1.Assigned_To__c = ClientRepUser.Id;
            insert caseObj1;
            
            System.assert(caseObj1.Id !=null);
            
            PageReference pageRef = Page.TakeACasePrimaryTab;
            Test.setCurrentPage(pageRef);
            
            ApexPages.standardController controller = new ApexPages.standardController(caseObj);
            Test.startTest();
            TakeACasePrimaryTabController controllerObj = new TakeACasePrimaryTabController(controller);
            controllerObj.populateCaseLists();
            Test.stopTest();
        }
        
    }
}