global with sharing class DeleteCurrentProducts implements Database.Batchable<sObject> {

	public String query;
	@testVisible
	private CurrentProductDAO.ICurrentProductDAO currentProductDAOInstance;

	@testVisible
	private DeleteCurrentProducts(CurrentProductDAO.ICurrentProductDAO currentProductDAOInstance, String query) {
		this.query = query;
		this.currentProductDAOInstance = currentProductDAOInstance;
	}

	public DeleteCurrentProducts(String query) {
		this(new CurrentProductDAO(), query);
	}
	/**
	* @description 	First method run of the batch to grab all records in query
	* @param batchContext 			Internal Apex object for running batch jobs
	* @return Database.querylocator Object that contains the query results
	*/
	global Database.querylocator start(Database.BatchableContext batchContext) {
		return Database.getQueryLocator(query);
	}

	/**
	* @description 	This method runs for each batch of records in the job. It will delete all Current_Product__c objects
	* @param batchContext	   		Internal Apex object for running batch jobs
	* @param scope List<sObject> 	List containing the records to be processed in this batch
	*/
	global void execute(Database.BatchableContext batchContext, List<sObject> scope) {
		this.currentProductDAOInstance.deleteAllCurrentProducts(scope);
	}

	global void finish(Database.BatchableContext batchContext) {

	}
}