global with sharing class BatchCreateCurrentProducts implements Database.Batchable<sObject> {

	public String query;

	@testVisible
	private BenefitAgreementDAO.IBenefitAgreementDAO benefitAgreementDAOInstance;
	@testVisible
	private CompetitorProductsDAO.ICompetitorProductsDAO competitorProductsDAOInstance;
	@testVisible
	private CurrentProductDAO.ICurrentProductDAO currentProductDAOInstance;

	@testVisible
	private BatchCreateCurrentProducts(BenefitAgreementDAO.IBenefitAgreementDAO benefitAgreementDAOInstance,
	                                   CompetitorProductsDAO.ICompetitorProductsDAO competitorProductsDAOInstance,
	                                   CurrentProductDAO.ICurrentProductDAO currentProductDAOInstance,
	                                   String query) {

		this.benefitAgreementDAOInstance = benefitAgreementDAOInstance;
		this.competitorProductsDAOInstance = competitorProductsDAOInstance;
		this.currentProductDAOInstance = currentProductDAOInstance;
		this.query = query;
	}

	global BatchCreateCurrentProducts(String query) {

		this(new BenefitAgreementDAO(), new CompetitorProductsDAO(), new CurrentProductDAO(), query);
	}
	/**
	* @description First method run of the batch to grab all records in query
	* @param batchContext 			Internal Apex object for running batch jobs
	* @return Database.querylocator Object that contains the query results
	*/
	global Database.querylocator start(Database.BatchableContext batchContext) {
		return Database.getQueryLocator(query);
	}

	/**
	* @description This method runs for each batch of records in the job. Creates a new Current_Product__c record
	*			   for each line item in an Account's Current Products table.
	*
	* @param batchContext	   	 Internal Apex object for running batch jobs
	* @param scope List<sObject> List containing the records to be processed in this batch
	*/
	global void execute(Database.BatchableContext batchContext, List<sObject> scope) {

		try {

			List<Current_Product__c> productsToInsert = new List<Current_Product__c>();
			List<Account> accounts = new List<Account>();
			Map<Id, List<Benefit_Agreement__c>> baMap = new Map<Id, List<Benefit_Agreement__c>>();
			Map<Id, List<Competitor_Products__c>> compProdsMap = new Map<Id, List<Competitor_Products__c>>();
			Set<Id> accountIds = new Set<Id>();

			for (sObject c : scope) {

				Account a = (Account) c;
				accounts.add(a);
				accountIds.add(a.Id);

			}

			List<Benefit_Agreement__c> batchBAs = this.benefitAgreementDAOInstance.getBatchBenefitAgreements(accountIds);

			if (batchBAs != null) {
				for (Benefit_Agreement__c currBA : batchBAs) {

					List<Benefit_Agreement__c> accBAs = baMap.get(currBA.Group_Account__c);

					if (accBAs == null) {
						List<Benefit_Agreement__c> newList = new List<Benefit_Agreement__c>();
						newList.add(currBA);
						baMap.put(currBA.Group_Account__c, newList);
					} else {
						accBAs.add(currBA);
					}
				}
			}

			List<Competitor_Products__c> compProds = this.competitorProductsDAOInstance.getBatchCompetitorProducts(accountIds);

			if (compProds != null) {
				for (Competitor_Products__c currCompProd : compProds) {

					List<Competitor_Products__c> accCompProds = compProdsMap.get(currCompProd.Carrier__r.Group_Account__c);

					if (accCompProds == null) {
						List<Competitor_Products__c> newList = new List<Competitor_Products__c>();
						newList.add(currCompProd);
						compProdsMap.put(currCompProd.Carrier__r.Group_Account__c, newList);
					} else {
						accCompProds.add(currCompProd);
					}
				}
			}

			for (Account a : accounts) {

				Map<String, Current_Product__c> currentProducts = new Map<String, Current_Product__c>();

				if (baMap != null && !baMap.isEmpty()) {

					List<Benefit_Agreement__c> baList = baMap.get(a.Id);

					if (baList != null && !baList.isEmpty()) {
						for (Benefit_Agreement__c ba : baList) {

							Current_Product__c currBAProduct = currentProducts.get(String.valueOf(ba.Group_Account__c) + '#' + String.valueOf(ba.Funding_Type__c) + '#' + String.valueOf(ba.Product__r.Simplified_Product__c));

							if (currBAProduct != null) {
								currBAProduct.Number_Of_BAs__c += 1;
							} else {
								Current_Product__c currProduct = new Current_Product__c();
								currProduct.Product_Family__c = ba.Product__r.Family;
								currProduct.Product_Category__c = ba.Product__r.Product_Category__c;
								currProduct.Product__c = ba.Product__c;
								currProduct.Simplified_Product__c = ba.Product__r.Simplified_Product__c;
								currProduct.Funding_Type__c = ba.Funding_Type__c;
								currProduct.Carrier_Name__c = Label.HCSC;
								currProduct.Business_Type__c = ba.Business_Type__c;
								currProduct.Account__c = ba.Group_Account__c;
								currProduct.Number_Of_BAs__c = 1;
								currProduct.Renewal_Date__c = ba.Renewal_Date__c;
								currentProducts.put(String.valueOf(ba.Group_Account__c) + '#' + String.valueOf(ba.Funding_Type__c) + '#' + String.valueOf(ba.Product__r.Simplified_Product__c), currProduct);
							}

						}
					}
				}
				if (compProdsMap != null && !compProdsMap.isEmpty()) {

					List<Competitor_Products__c> compProdsList = compProdsMap.get(a.Id);

					if (compProdsList != null && !compProdsList.isEmpty()) {
						for (Competitor_Products__c compProd : compProdsList) {
							if (compProd != null) {

								Current_Product__c currBAProduct = currentProducts.get(String.valueOf(compProd.Carrier__r.Competitor_Account__c) + '#' + 'Competitor' + '#' + String.valueOf(compProd.Product__r.Simplified_Product__c));

								if (currBAProduct != null) {
									currBAProduct.Number_Of_BAs__c += 1;
								} else {
									Current_Product__c currProduct = new Current_Product__c();
									currProduct.Product_Family__c = compProd.Product__r.Family;
									currProduct.Product_Category__c = compProd.Product__r.Product_Category__c;
									currProduct.Product__c = compProd.Product__c;
									currProduct.Simplified_Product__c = compProd.Product__r.Simplified_Product__c;
									currProduct.Funding_Type__c = 'Competitor';
									currProduct.Carrier_Name__c = compProd.Carrier__r.Competitor_Account__r.Name;
									currProduct.Business_Type__c = compProd.Business_Type__c;
									currProduct.Account__c = compProd.Carrier__r.Group_Account__c;
									currProduct.Number_Of_BAs__c = 1;
									currProduct.Renewal_Date__c = compProd.Renewal_Date__c;
									currentProducts.put(String.valueOf(compProd.Carrier__r.Competitor_Account__c) + '#' + 'Competitor' + '#' + String.valueOf(compProd.Product__r.Simplified_Product__c), currProduct);
								}
							}
						}
					}
				}
				productsToInsert.addAll(currentProducts.values());
			}

			this.currentProductDAOInstance.insertCurrentProducts(productsToInsert);

		} catch (Exception e) {
			CreateExceptionLog.insertErrorLog(e, null, null, null, 'Apex Class', null, null, 'BatchCreateCurrentProducts', 'High');
		}

	}

	global void finish(Database.BatchableContext batchContext) {

	}


}