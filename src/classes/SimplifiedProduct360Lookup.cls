/**************************************************************************************
  Apex Class Name     : SimplifiedProduct360Lookup
  Version             : 1.0
  Function            : This class handles the logic to search for a Simplified product on the Product 360 visualforce page
*************************************************************************************/
public with sharing class SimplifiedProduct360Lookup { 

	public List<Product2> results{get;set;} 
	public String searchString{get;set;} 
	public Id oppId{get;set;}
	public String HCSC{get;set;}
	public Exception constructorException {get;set;}

	@testVisible
	private OpportunityDAO.IOpportunityDAO opportunityDAOInstance;
	
	public SimplifiedProduct360Lookup(){
		this(new OpportunityDAO());
	}
	/**
	* @Method:Constructor
	* @description: Grabs the related opportunity Id to find the state for the search query and also grabs the search string from the user if found
	*/
	@testVisible
	private SimplifiedProduct360Lookup(OpportunityDAO.IOpportunityDAO opportunityDAOInstance) {

		try 
		{	
			this.opportunityDAOInstance = opportunityDAOInstance;        
			oppId = ApexPages.currentPage().getParameters().get('Id');
			Opportunity opp = this.opportunityDAOInstance.getOpportunityById(oppId);
			HCSC = opp.HCSC_Division__c;
			searchString = '';
			runSearch();  
		}
		catch (Exception e)
		{
			constructorException = e;
				
		}
			
	}

		
	/**
	* @Method:search()
	* @description: preforms the keyword search
	*/
	public PageReference search() {
		runSearch();
		return null;
	}

	/**
	* @Method:runSearch()
	* @description: sets the results to the getProducts() method which displays all the products is searchString is empty
	*/
	private void runSearch() {
		
		results = getProducts(SearchString);               
	} 

	/**
	* @Method:performSearch(string searchString)
	* @description: runs the search query from the user
	*/
	private List<Product2> performSearch(string searchString) {
        String soql = 'SELECT Simplified_Product__c, HCSC_State__c FROM Product2';

			if(searchString != '' && searchString != null){
				soql += ' WHERE Simplified_Product__c LIKE \'%' + searchString +'%\'';
				soql += ' AND HCSC_State__c = :HCSC';
				soql += ' AND NotSimple__c = false';			
			}				
		
		return database.query(soql); 
	}

	/**
	* @Method:getProducts()
	* @description: If the searchString is empty the method will grab all Simplified Products to display 
	*                 otherwise it calls the performSearch() method
	*/
	public List<Product2> getProducts(String searchString) {
            
		if (searchString == '') {
			return (List<Product2>) [SELECT Simplified_Product__c, HCSC_State__c FROM Product2 
                                WHERE 	HCSC_State__c = :HCSC AND NotSimple__c = false ORDER BY Simplified_Product__c];
		}
		else{
			return performSearch(searchString);
		}
                
	}

	public void insertExceptionLog(){
		
		if (constructorException != null)
			CreateExceptionLog.insertErrorLog(constructorException, null, null, null, 'Apex Class', null, null, 'SimplifiedProduct360Lookup()', 'High');
	}
}