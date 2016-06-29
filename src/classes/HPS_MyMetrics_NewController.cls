/**************************************************************************************
  Apex Class Name     : HPS_MyMetrics_NewController
  Version             : 1.0
  Function            : This class is used for showing the performance of the logged in used on the home page slider in terms of sales
  Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
**/
public with sharing class HPS_MyMetrics_NewController {
  public decimal medicalRecordsCount{get;set;}
  public decimal DentalRecordsCount{get;set;}
  public decimal numberOfSales {get; set;}
  public decimal numberOfSalesAncillaryProds {get; set;}
  public String OppotunityCloseRatio {get; set;}
  public HPS_MyMetrics_NewController()
  {
      try    
        { Date CompareDate = Date.newInstance(Date.Today().year(),1,31);
          Decimal OppotunityCloseRatioDec; 
          Integer NumberOfOpportunitiesWon = 0;
          medicalRecordsCount = 0;
          DentalRecordsCount = 0;
          numberOfSales = 0;
          numberOfSalesAncillaryProds = 0;
          Set<Id> AccountIdSet = new Set<Id>();
          List<Opportunity> OwnerOpportunityList = [SELECT id, AccountId, CloseDate,StageName, (SELECT id, Product__c, Product__r.Family FROM Opportunity_Products__r WHERE Product__r.Family = :ConstantsController.ProductsRequired) From Opportunity WHERE OwnerId =: UserInfo.getUserId() AND (StageName = 'Won' OR StageName = 'Lost')];
          for(Opportunity oppty : OwnerOpportunityList)
          {
              if(oppty.StageName == 'Won')
              {
                  AccountIdSet.add(oppty.AccountId);
                  NumberOfOpportunitiesWon++; 
                  if(oppty.CloseDate > CompareDate)
                  {
                      numberOfSales++;
                  }
                  if(oppty.Opportunity_Products__r != null && oppty.Opportunity_Products__r.size() > 0)
                      numberOfSalesAncillaryProds++;
              }
              
          }
          list<Account> activeAccounts = [select id,Active_Health_Members__c,Active_Dental_Members__c,New_Active_Health_Members__c,New_Active_Dental_Members__c,X1_31_Account_Status__c,X1_31_Membership__c from Account Where Id IN: AccountIdSet and Status__c = 'Active' and Effective_Date__c >=: CompareDate];
          for(Account acc : activeAccounts){
             if(acc.New_Active_Health_Members__c != null )
                 medicalRecordsCount += acc.New_Active_Health_Members__c;
             if(acc.New_Active_Dental_Members__c != null )
                 DentalRecordsCount += acc.New_Active_Dental_Members__c;
          }
          if(NumberOfOpportunitiesWon > 0 ){
              OppotunityCloseRatioDec = integer.valueOf((NumberOfOpportunitiesWon/OwnerOpportunityList.size())*100);
              OppotunityCloseRatio = String.valueOf(OppotunityCloseRatioDec) + '%';
          }else{
              OppotunityCloseRatio = '0%';
          }
        }catch(Exception e)
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage());
          ApexPages.addMessage(myMsg);
        }
    }
}