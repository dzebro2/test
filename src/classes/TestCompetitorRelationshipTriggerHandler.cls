/**************************************************************************************
  Apex Class Name     : TestCompetitorRelationshipTriggerHandler 
  Version             : 1.0
  Function            : This is a test class for CompetitorRelationshipTrigger.
  Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
*  Sruthy Dileep            6/1/2015
*************************************************************************************/
@isTest(seeAllData = false)
public class TestCompetitorRelationshipTriggerHandler {
    static testMethod void myUnitTest1() {
        Account testAccount1 = TestClassUtiltity.CreateAccountRecord('Test Account');
        string carrierRecordTypeId;
        //query the record type of carrier 
        for(RecordType rt : [select Id from RecordType where SobjectType = 'Competitor_Relationship__c' and DeveloperName ='Carrier'])
        {
            carrierRecordTypeId = rt.Id;
        }
        list<Competitor_Relationship__c> carrierList = TestClassUtiltity.createCompRel(testAccount1.Id);
        carrierList[0].Sliced__c = true;
        carrierList[0].Status__c = 'Active';
        carrierList[0].Total_Members__c= 10;
        carrierList[0].RecordtypeId = carrierRecordTypeId;
        
        
        insert carrierList;
        
        list<Product2> products = TestClassUtiltity.createProducts();
        products[1].RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get( 'Competitor Product' ).getRecordTypeId();
        insert products;
        
        List<Competitor_Products__c> lstCompProd = TestClassUtiltity.createCompProd(carrierList[0].Id,products[1].Id);
        insert lstCompProd;
        test.startTest();
            Account tempAccount = [select Sliced__c from Account where Id =:testAccount1.Id limit 1][0];
            system.assertEquals(true,tempAccount.Sliced__c);
            
            
        test.stopTest();    
    }
}