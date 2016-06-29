/**************************************************************************************
  Apex Class Name     : TestProductLandscapeController
  Version             : 1.0
  Function            : This is a test class for ProductLandscapeController .
  Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
*  Sruthy Dileep            6/2/2015
*************************************************************************************/
@isTest
public class TestProductLandscapeController {
    
    @isTest static void myUnitTest1() {
        try{
            
            Account TestAcnt = TestClassUtiltity.CreateAccountRecord('TestAccount');
           // RecordType RecId = [SELECT id, Name from RecordType where  Name = 'Competitor' LIMIT 1];
            TestAcnt.RecordTypeid = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Competitor').getRecordTypeId();  
            TestAcnt.HCSC_Division__c = 'IL';
            update TestAcnt;
            system.debug('#### Acc ' + TestAcnt);
            Account TestAcntGrp = TestClassUtiltity.CreateAccountRecord('TestAccountGrp');  
            //RecordType RecId1 = [SELECT id, Name from RecordType where  Name = 'Group Account' LIMIT 1];
            TestAcntGrp.RecordTypeid = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Group Account').getRecordTypeId();
            TestAcntGrp.HCSC_Division__c = 'IL';
            update TestAcntGrp;
            
            
            List<Opportunity> TestOppLst = TestClassUtiltity.CreateOpportunities(TestAcntGrp.id);
            //TestOppLst[0].IsClosed = true;
            //TestOppLst[0].StageName = 'Won';
            //TestOppLst[0].Primary_Closed_Reason__c = 'Savings';
            insert TestOppLst;
           
            list<Product2> LstProduct =  TestClassUtiltity.createProducts();
            LstProduct[0].RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('HCSC Non BlueStar Product').getRecordTypeId();
            LstProduct[0].HCSC_State__c = 'IL';
            LstProduct[0].Product_Type__c = 'Medical';
            
            LstProduct[1].RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('HCSC Non BlueStar Product').getRecordTypeId();
            LstProduct[1].HCSC_State__c = 'IL';
            LstProduct[1].Product_Type__c = 'Dental';
            
            
            LstProduct.addAll(TestClassUtiltity.createProducts());
            LstProduct[2].RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('HCSC Non BlueStar Product').getRecordTypeId();
            LstProduct[2].HCSC_State__c = 'IL';
            LstProduct[2].Product_Type__c = 'Dental';
           
            LstProduct[3].RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('HCSC Non BlueStar Product').getRecordTypeId();
            LstProduct[3].HCSC_State__c = 'IL';
            LstProduct[3].Product_Type__c = 'Medical';
         
            insert LstProduct;
            
            list<Group_Section__c> TestGroupSection = new list<Group_Section__c>();
            Group_Section__c temp = new Group_Section__c();
              temp.Group_Account__c = TestAcntGrp.id;
              temp.status__c = 'Active';
              temp.Cancellation_Status__c = 'Cancellation Rejected';
              temp.Total_Healthcare_Active_Members__c = 10;
              temp.Total_Dental_Active_Members__c = 10;
              TestGroupSection.add(temp);
              Group_Section__c temp1 = new Group_Section__c();
              temp1.Group_Account__c = TestAcntGrp.id;
              temp1.status__c = 'Active';
              temp1.Total_Dental_Active_Members__c = 10;
              temp1.Total_Healthcare_Active_Members__c = 10;
              temp1.Cancellation_Status__c = 'Cancellation Rejected';
              TestGroupSection.add(temp1);
              insert TestGroupSection;
              
            list<Benefit_Agreement__c> TestBenefitAgreementLst = new list<Benefit_Agreement__c>();
            Benefit_Agreement__c TestBnftAgrmt1 = new Benefit_Agreement__c ();
            TestBnftAgrmt1.Group_Account__c= TestAcntGrp.id;
            TestBnftAgrmt1.Effective_Date__c =  system.today()-1;
            TestBnftAgrmt1.Product__c = LstProduct[0].id;
            TestBnftAgrmt1.Renewal_Date__c = system.today();
                  TestBnftAgrmt1.Funding_Type__c = 'ACAP';
            TestBnftAgrmt1.Status__c = 'Active';
            TestBenefitAgreementLst.add(TestBnftAgrmt1);
            
            Benefit_Agreement__c TestBnftAgrmt2 = new Benefit_Agreement__c ();
            TestBnftAgrmt2.Group_Account__c= TestAcntGrp.id;
            TestBnftAgrmt2.Effective_Date__c =  system.today()-1;
            TestBnftAgrmt2.Product__c = LstProduct[0].id;
            TestBnftAgrmt2.Status__c = 'Active';
                  TestBnftAgrmt2.Funding_Type__c = 'ASO';
            TestBnftAgrmt2.Renewal_Date__c = system.today();
            TestBenefitAgreementLst.add(TestBnftAgrmt2);
            Benefit_Agreement__c TestBnftAgrmt3 = new Benefit_Agreement__c ();
            TestBnftAgrmt3.Group_Account__c= TestAcntGrp.id;
            TestBnftAgrmt3.Effective_Date__c =  system.today()-1;
            TestBnftAgrmt3.Product__c = LstProduct[1].id;
            TestBnftAgrmt3.Status__c = 'Active';
                  TestBnftAgrmt3.Funding_Type__c = 'PREM';
            TestBnftAgrmt3.Renewal_Date__c = system.today();
            TestBenefitAgreementLst.add(TestBnftAgrmt3); 
            insert TestBenefitAgreementLst;

                  Benefit_Agreement__c TestBnftAgrmt6 = new Benefit_Agreement__c ();
            TestBnftAgrmt6.Group_Account__c= TestAcntGrp.id;
            TestBnftAgrmt6.Effective_Date__c =  system.today()-1;
            TestBnftAgrmt6.Product__c = LstProduct[1].id;
            TestBnftAgrmt6.Status__c = 'Active';
                  TestBnftAgrmt6.Funding_Type__c = 'MPP';
            TestBnftAgrmt6.Renewal_Date__c = system.today();
                  insert TestBnftAgrmt6;

                  Benefit_Agreement__c TestBnftAgrmt7 = new Benefit_Agreement__c ();
            TestBnftAgrmt7.Group_Account__c= TestAcntGrp.id;
            TestBnftAgrmt7.Effective_Date__c =  system.today()-1;
            TestBnftAgrmt7.Product__c = LstProduct[1].id;
            TestBnftAgrmt7.Status__c = 'Active';
                  TestBnftAgrmt7.Funding_Type__c = 'COST';
            TestBnftAgrmt7.Renewal_Date__c = system.today();
                  insert TestBnftAgrmt7;

                  Benefit_Agreement__c TestBnftAgrmt8 = new Benefit_Agreement__c ();
            TestBnftAgrmt8.Group_Account__c= TestAcntGrp.id;
            TestBnftAgrmt8.Effective_Date__c =  system.today()-1;
            TestBnftAgrmt8.Product__c = LstProduct[1].id;
            TestBnftAgrmt8.Status__c = 'Active';
                  TestBnftAgrmt8.Funding_Type__c = 'PAR';
            TestBnftAgrmt8.Renewal_Date__c = system.today();
                  insert TestBnftAgrmt8;


                   BA_GS_Assignment__c temp7BAGS = new BA_GS_Assignment__c();
              temp7BAGS.Benefit_Agreement__c = TestBnftAgrmt8.id;
              temp7BAGS.Group_Section__c = TestGroupSection[1].id;
              temp7BAGS.External_ID__c = '1010154344345';
              insert temp7BAGS;

                   BA_GS_Assignment__c temp6BAGS = new BA_GS_Assignment__c();
              temp6BAGS.Benefit_Agreement__c = TestBnftAgrmt7.id;
              temp6BAGS.Group_Section__c = TestGroupSection[1].id;
              temp6BAGS.External_ID__c = '1010154344';
              insert temp6BAGS;

                   BA_GS_Assignment__c temp5BAGS = new BA_GS_Assignment__c();
              temp5BAGS.Benefit_Agreement__c = TestBnftAgrmt6.id;
              temp5BAGS.Group_Section__c = TestGroupSection[1].id;
              temp5BAGS.External_ID__c = '10101543';
              insert temp5BAGS;
            
            list<BA_GS_Assignment__c> TestBAGSAsgnt = new list<BA_GS_Assignment__c>();
              BA_GS_Assignment__c tempBAGS = new BA_GS_Assignment__c();
              tempBAGS.Benefit_Agreement__c = TestBenefitAgreementLst[0].id;
              tempBAGS.Group_Section__c = TestGroupSection[0].id;
              tempBAGS.External_ID__c = '101011';
              TestBAGSAsgnt.add(tempBAGS);
              BA_GS_Assignment__c temp1BAGS = new BA_GS_Assignment__c();
              temp1BAGS.Benefit_Agreement__c = TestBenefitAgreementLst[0].id;
              temp1BAGS.Group_Section__c = TestGroupSection[1].id;
              temp1BAGS.External_ID__c = '101012';
              TestBAGSAsgnt.add(temp1BAGS);
              BA_GS_Assignment__c temp2BAGS = new BA_GS_Assignment__c();
              temp2BAGS.Benefit_Agreement__c = TestBenefitAgreementLst[1].id;
              temp2BAGS.Group_Section__c = TestGroupSection[0].id;
              temp2BAGS.External_ID__c = '101013';
              TestBAGSAsgnt.add(temp2BAGS);
              BA_GS_Assignment__c temp3BAGS = new BA_GS_Assignment__c();
              temp3BAGS.Benefit_Agreement__c = TestBenefitAgreementLst[1].id;
              temp3BAGS.Group_Section__c = TestGroupSection[1].id;
              temp3BAGS.External_ID__c = '101014';
              TestBAGSAsgnt.add(temp3BAGS);
              BA_GS_Assignment__c temp4BAGS = new BA_GS_Assignment__c();
              temp4BAGS.Benefit_Agreement__c = TestBenefitAgreementLst[2].id;
              temp4BAGS.Group_Section__c = TestGroupSection[1].id;
              temp4BAGS.External_ID__c = '101015'; 
              TestBAGSAsgnt.add(temp4BAGS);
              insert TestBAGSAsgnt;
            
             Test.StartTest();
            
            ApexPAges.StandardController sc2 = new ApexPages.StandardController(TestAcntGrp );
            ProductLandscapeController myCntrl = new ProductLandscapeController(sc2);
           
            myCntrl.accountId = TestAcntGrp.id;
            myCntrl.saveAdditionalInformation();
            myCntrl.cancelAdditionalInformation();
            ProductLandscapeController.OtherProductsBean bn = new ProductLandscapeController.OtherProductsBean();
            bn.productFamily = 'test';
            bn.productCategory = 'test';
            bn.productId = 'test';
            bn.productName = 'test';
            bn.accoutProductInfo = new Account_Product_Information__c();
            ProductLandscapeController.CurrentProductsBean curbn = new ProductLandscapeController.CurrentProductsBean();
            curbn.renewalDate = 'test';
            curbn.numberOfprojectedMembers = 12;
            curbn.associatedOpportunityId = null;
            curbn.associatedOpportunityName = 'test';

            Test.StopTest();
         
      }catch(Exception e){
            throw e;
      }
        
    }

    @isTest static void myUnitTest2() {
      try{  
                  Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
                  User testUser = TestClassUtiltity.CreateUserRecord(p.Id, 'testlgnadev@user.com', 'testUser', 'test@user.com');

            Account TestAcnt = TestClassUtiltity.CreateAccountRecord('TestAccount');
            


            Opportunity opp2 = new Opportunity(AccountId = TestAcnt.id, HCSC_Division__c = 'IL', Name='oppName 2',StageName = 'Expected In', CloseDate = system.Today().addYears(2), Expected_RFP_Release_Date__c = system.Today().addYears(1), Expected_Decision_Date__c = system.Today().addYears(1), RFI_RFP_Received_Date__c = system.Today().addYears(1), Primary_Closed_Reason__c = 'Savings');
            opp2.Requested_Effective_Date__c = System.Today() + 1;         
            insert opp2;

                  List<OpportunityTeamMember> oppTeam = TestClassUtiltity.createOppTeamMember(opp2.Id, testUser.Id);
                  oppTeam[0].TeamMemberRole = 'Client Implementation Consultant';
                  insert oppTeam;

            list<Product2> products = TestClassUtiltity.createProducts();
            insert products;

            list<Product2> product = TestClassUtiltity.createProducts();
            insert product;

            list<Opportunity_Product__c> OppProducts = TestClassUtiltity.createOppProducts(opp2.id,products[0].Id);
            OppProducts[0].Status__c = 'Won';
            OppProducts[0].State__c = 'IL';
            OppProducts[0].Product__c = products[0].Id;
                  OppProducts[0].Upsell__c = 'Yes';
            insert OppProducts;

            list<Opportunity_Product__c> OpptyProd = TestClassUtiltity.createOppProducts(opp2.id,product[0].Id);
            OpptyProd[0].Status__c = 'Lost';
            OpptyProd[0].State__c = 'IL';
            OpptyProd[0].Product__c = product[0].Id;
                  OpptyProd[0].Upsell__c = 'Yes';
            insert OpptyProd;

            opp2.StageName='Won';
            opp2.Date_Closed__c = system.today();
            update opp2;
           
            test.StartTest();
            ApexPages.StandardController sc2 = new ApexPages.StandardController(TestAcnt);
            ProductLandscapeController myCntrl = new ProductLandscapeController(sc2);
            myCntrl.HCSCState = 'IL';

              System.assertEquals(myCntrl.impb.size(), 1);
              System.assertEquals(myCntrl.lostp.size(), 1);


            ProductLandscapeController.OtherProductsBean other = new ProductLandscapeController.OtherProductsBean();
            other.productFamily = 'Test';
            other.productCategory = 'Test';
            other.productId = 'Test';
            other.productName = 'Test';
             test.StopTest(); 
          
         }catch(Exception e){
            throw e;
         }
      }
    

    @isTest static void myUnitTest3(){

            Account TestAcnt = TestClassUtiltity.CreateAccountRecord('TestAccount');
           
            Opportunity opp3 = new Opportunity(AccountId = TestAcnt.id, HCSC_Division__c = 'IL', Name='oppName 3',StageName = 'Expected In', CloseDate = system.Today().addYears(2), Expected_RFP_Release_Date__c = system.Today().addYears(1), Expected_Decision_Date__c = system.Today().addYears(1), RFI_RFP_Received_Date__c = system.Today().addYears(1), Primary_Closed_Reason__c = 'Savings');
            opp3.Requested_Effective_Date__c = System.Today() - 1;         
            insert opp3;

            list<Product2> product = TestClassUtiltity.createProducts();
            insert product;
            
            list<Opportunity_Product__c> OpptyProd2 = TestClassUtiltity.createOppProducts(opp3.id,product[0].Id);
            OpptyProd2[0].Status__c = 'In Progress';
            OpptyProd2[0].State__c = 'IL';
            OpptyProd2[0].Product__c = product[0].Id;
            insert OpptyProd2;

            ApexPages.StandardController sc2 = new ApexPages.StandardController(TestAcnt);
            ProductLandscapeController myCntrl = new ProductLandscapeController(sc2);
            myCntrl.HCSCState = 'IL';

            ProductLandscapeController.ActivelyPurchasingProductsBean active = new ProductLandscapeController.ActivelyPurchasingProductsBean();
            active.productFamily = 'Test';
            active.productCategory = 'Test';
            active.productId = 'Test';
            active.productName = 'Test'; 

    }
}