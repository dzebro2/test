/**************************************************************************************
  Apex Class Name     : AccountProductsExtension
  Version             : 1.0
  Function            : This is an extension for the Account Products Page.
  Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
*  Nick Serafin           2/11/2016                 Grabs the Opportunity Products for a Closed Won Opportunity
                                                    and display it on the Account Detail Page
*************************************************************************************/

public with sharing class AccountProductsExtension {

    public String acctId {get;set;}
    public Integer pageSize{get;set;}
    public Integer noOfPages{get;set;}
    public Integer totalNoOfRecs{get;set;}
    public Integer pageNumber{get;set;}
    public String baseQuery;
    public List<Opportunity_Product__c> opportunities{get;set;}
    public List<Opportunity> opp{get;set;}

    public AccountProductsExtension(ApexPages.StandardController con) {
        //Grab the account Id
        acctId = ApexPages.CurrentPage().getparameters().get('id'); 
        //Set amount of records per page in related list    
        pageSize = 6;
        //grab the opps that are related to the account and have a stage of Closed Won
        opp = [SELECT Id, StageName FROM Opportunity WHERE AccountId =:acctId AND StageName = 'Won'];
        System.debug(opp);     
        //grab the amount of products and products related to those opportunities
        totalNoOfRecs = [SELECT count() FROM Opportunity_Product__c WHERE Opportunity_Name__c IN :opp AND Status__c = 'Won'];       
        baseQuery = 'SELECT Id, Name, Product__c, Product__r.Name, Opportunity_Name__c,Opportunity_Name__r.Name, Account_Product_Name__c, Member_Count__c, Projected_Members__c, Status__c FROM Opportunity_Product__c WHERE Opportunity_Name__c IN :opp AND Status__c = \'Won\' ORDER BY Id';

        //Call method to set up related list and pagination
        getInitialProductSet();
    }

    //Grabs records for related list
    public PageReference getInitialProductSet()
    {        
        pageNumber = 0;
        if (totalNoOfRecs <= 0){
            //error message if no records are returned
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Account Products cannot be generated as there are no products associated to this Account'));       
        
        } else {

            noOfPages = totalNoOfRecs/pageSize;
            //increase page number if there are more records than 6
            if (Math.mod(totalNoOfRecs, pageSize) > 0)
                noOfPages++;
        
            try{
                //grab those products with a limit of 6 per page
                opportunities = Database.query(baseQuery + ' limit ' +pageSize);
                System.debug(opportunities);
            }
            catch(Exception e){
                ApexPages.addMessages(e);
            }
        }

        return null;  
    }
    //increase page number
    public PageReference next(){
        pageNumber++; 
        
        queryProducts();
        return null;
    }
    //decrease page number
    public PageReference previous(){
        pageNumber--;
        if (pageNumber < 0)
            return null;
        
        queryProducts();
        return null;
    }
    //grab records for previous page or the next page of the related list
    private void queryProducts()
    {
        Integer offset = pageNumber * pageSize;    
        String query = baseQuery + ' limit ' + pageSize + ' offset ' + offset;
        System.debug('Query is'+query);
        try{
            opportunities = Database.query(query);
        }
        catch(Exception e){
            ApexPages.addMessages(e);
        }       
    }
}