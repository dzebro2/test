/**************************************************************************************
  Apex Class Name     : TestContactRelationShipController
  Version             : 1.0
  Function            : This is a test class for ContactRelationShipController .
  Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
*  
*************************************************************************************/

@isTest
private class TestContactRelationShipController{

    /*  TestContactRelationShipController
    *   @description:   This method tests AccountTrigger after insert.
    *   @parameters     null
    *   @return type    void                        
    */
    public static testMethod void TestContactRelationShipController(){
        
        Contact  cont = new Contact();
        cont.LastName = 'test';
        cont.Email    = 'test@test.com'; 
        
        Test.startTest();
        
        insert cont;
        Test.setCurrentPageReference(new PageReference('Page.ContactRelationship'));
        System.currentPageReference().getParameters().put('contactId', cont.id);
        System.currentPageReference().getParameters().put('Type', 'Relate Contact');
        ApexPages.standardController stdController = new ApexPages.standardController(cont); 
        ContactRelationShipController CRController = new ContactRelationShipController(stdController);
        CRController.contactId =cont.id;
        CRController.save();
        CRController.saveAndNew();
         PageReference pageRef = CRController.cancel();
        System.assertEquals(pageRef.getURL(),'/'+cont.Id);
        System.currentPageReference().getParameters().put('Type', 'Not Relate Contact');
        CRController = new ContactRelationShipController(stdController);
        
        System.currentPageReference().getParameters().put('Type', 'Relate User');
        CRController = new ContactRelationShipController(stdController);
        
        System.currentPageReference().getParameters().put('Type', 'RelateAccountToAccount');
        CRController = new ContactRelationShipController(stdController);
        
        System.currentPageReference().getParameters().put('Type', 'RelateContactToAccount');
        CRController = new ContactRelationShipController(stdController);
        System.currentPageReference().getParameters().put('Type', 'RelateAccountToContact');
        CRController = new ContactRelationShipController(stdController);
        
        Test.stopTest();
    }       
}