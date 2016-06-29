public class Product360ControllerWorking { 
	
	public List<AccountWrapper> accountWrappers {get;set;}
	public Map<Id, Opportunity> currOpps {get; set;}
	public Boolean showRequiredFieldsError {get; set;}
	public Integer numberOfRowToRemove { get; set; }
	public Id recordToDelete { get; set; }
	public Id currentOpportunity {get; set;}
	public List<Opportunity_Product__c> listOfOpportunityProducts {get; set;}
	public OpportunityWrapper currOpportunityWrapper {get; set;}
	public List<OpportunityProductWrapper> newOppProdsMap;
	
	public List<Account> curraccounts;
	

	public Product360ControllerWorking() {
		
		try {
			
			
			newOppProdsMap = new List<OpportunityProductWrapper>();
			Id userId = UserInfo.getUserId();
			//First query the AccountTeamMember records
			List<AccountTeamMember> members = [SELECT Id, AccountId FROM AccountTeamMember WHERE UserId = :userId];
			
			//now get the Ids of all the accounts
			Set<Id> accountIds = new Set<Id>();
			for(AccountTeamMember member : members) {
				accountIds.add(member.AccountId);
			}
			
			curraccounts = [SELECT Id, Name, (Select Id, Requested_Effective_Date__c, Name, RecordType.Name, HCSC_Division__c, Expected_Health_Members__c, Expected_Health_Contracts__c, Expected_Dental_Members__c, Expected_Dental_Contracts__c From Opportunities) FROM Account WHERE (Id IN :accountIds OR OwnerId = :userId) AND Id in (Select AccountId from Opportunity)];
			
			Set<Id> oppIds = new Set<Id>();		
			Set<Id> nonCurrentOppIds = new Set<Id>();

			for(Account a : curraccounts){
				for(Opportunity o : a.Opportunities) {
					if ((o.Requested_Effective_Date__c.year() == System.now().year() && o.Requested_Effective_Date__c.month() != 1) || (o.Requested_Effective_Date__c.year() == (System.now().year()+1) && o.Requested_Effective_Date__c.month() == 1)) {
						oppIds.add(o.Id);
					}
					
				}
			}

			currOpps = new Map<Id, Opportunity>([Select Id, Name,Expected_Health_Members__c, Expected_Health_Contracts__c, (Select Id, Name, Projected_Members__c, Projected_Contracts__c, Product__r.Name, Status__c, Product_Type__c, Win_Probability__c, Funding_Type__c, Premium_Type__c from Opportunity_Products__r) From Opportunity Where Id in :oppIds]); 
			accountWrappers = buildAccountWrappers(curraccounts);
			
			
		} catch (Exception e) {
			System.debug(e);
			System.debug(e.getLineNumber());
		}
	}

	
	/**
	* @description 
	* @param accounts 
	* @return List<AccountWrapper> 
	*/
	private List<AccountWrapper> buildAccountWrappers(List<Account> accounts){
		
		List<AccountWrapper> accountWrappers = new List<AccountWrapper>();
		try {	        
			
			for (Account a : accounts) {
				Integer products = 0;
				AccountWrapper currWrapper = new AccountWrapper();
				currWrapper.accountObj = a;
				currWrapper.opps = buildOpportunityWrappers(a.Opportunities);
				if (currWrapper.opps.size() == 0)
					continue;
				for (OpportunityWrapper ow : currWrapper.opps)
					products = products + ow.numProducts;
			
				currWrapper.numProducts = products;
				accountWrappers.add(currWrapper);

			}	
			return accountWrappers;
		}
		catch (Exception e)
		{

			System.debug(e);
			System.debug(e.getLineNumber());
			return null;
		}
		
	}

	private List<OpportunityWrapper> buildOpportunityWrappers(List<Opportunity> opps) {
		
		List<OpportunityWrapper> oppWrappers = new List<OpportunityWrapper>();
		try {
			for (Opportunity o : opps) {
			
				Opportunity currOpp = currOpps.get(o.Id);

				if (currOpp != null){
					OpportunityWrapper currWrapper = new OpportunityWrapper();
			
					currWrapper.opportunityObj = o;
					List<Opportunity_Product__c> opProducts = o.Opportunity_Products__r;
					opProducts.sort();
					
					currWrapper.opportunityProducts = opProducts;
					
				
			
					currWrapper.numProducts = currWrapper.opportunityProducts.size();
					currWrapper.recordType = o.RecordType.Name;
					oppWrappers.add(currWrapper);
				}
			}


			return oppWrappers;
		}
		catch (Exception e){
			
			CreateExceptionLog.insertErrorLog(e, null, null, null, 'Apex Class', 'HomePage', null, 'Product360Controller.updateTaskStatus()','High'); 
			return null;
		}
	}

	

	public void save(){
		
		
		try 
		{	  
			
			List<Opportunity_Product__c> oppProducts = new List<Opportunity_Product__c>();
			for (AccountWrapper aw : accountWrappers) {
				for (OpportunityWrapper ow : aw.opps) {
					
					oppProducts.addall(ow.opportunityProducts);
				}
			}
			upsert oppProducts;
			
			
			Id userId = UserInfo.getUserId();
			//First query the AccountTeamMember records
			List<AccountTeamMember> members = [SELECT Id, AccountId FROM AccountTeamMember WHERE UserId = :userId];
			
			//now get the Ids of all the accounts
			Set<Id> accountIds = new Set<Id>();
			for(AccountTeamMember member : members) {
				accountIds.add(member.AccountId);
			}
			
			curraccounts = [SELECT Id, Name, (Select Id, Requested_Effective_Date__c, Name, RecordType.Name, HCSC_Division__c, Expected_Health_Members__c, Expected_Health_Contracts__c, Expected_Dental_Members__c, Expected_Dental_Contracts__c From Opportunities) FROM Account WHERE (Id IN :accountIds OR OwnerId = :userId) AND Id in (Select AccountId from Opportunity)];
			
			Set<Id> oppIds = new Set<Id>();		
			Set<Id> nonCurrentOppIds = new Set<Id>();

			for(Account a : curraccounts){
				for(Opportunity o : a.Opportunities) {
					if ((o.Requested_Effective_Date__c.year() == System.now().year() && o.Requested_Effective_Date__c.month() != 1) || (o.Requested_Effective_Date__c.year() == (System.now().year()+1) && o.Requested_Effective_Date__c.month() == 1)) {
						oppIds.add(o.Id);
					}
					
				}
			}

			currOpps = new Map<Id, Opportunity>([Select Id, Name,Expected_Health_Members__c, Expected_Health_Contracts__c, (Select Id, Name, Projected_Members__c, Projected_Contracts__c, Product__r.Name, Status__c, Product_Type__c, Win_Probability__c, Funding_Type__c, Premium_Type__c from Opportunity_Products__r) From Opportunity Where Id in :oppIds]); 
			accountWrappers = buildAccountWrappers(curraccounts);
			
			
		}
		catch (Exception e)
		{
			
			System.debug(e +' ' + e.getLineNumber());
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'required fields missed'));
			
		}
		
		
	}

	
	public void addNewOpportunityProduct(){
		
		try{
			
			Opportunity op = currOpps.get(currentOpportunity);
			Opportunity_Product__c oppToDelete;
			List<Opportunity_Product__c> oppProdsToAdd = new List<Opportunity_Product__c>();
			
			for (AccountWrapper aw : accountWrappers) {
				for (OpportunityWrapper ow : aw.opps) {
					if (ow.opportunityObj.Id == op.Id) {
					
						Opportunity_Product__c newOppProd = new Opportunity_Product__c(Opportunity_Name__c = op.Id, Status__c = Label.Progress, State__c = ow.opportunityObj.HCSC_Division__c);
						//opportunityWrappersToOpportunityMap.put(op.Id, newOppProd);

						//newOppProdsMap.add(newOppProd);
						ow.opportunityProducts.add(newOppProd);
						
					}
				}
			}
			
		} catch (Exception e) {
			
			System.debug(e + ' ' + e.getLineNumber());
		}

	}
	/**
	 * @Method:removeRow
	 * @description: Deletes a row of products in the AddOpportunityProducts visualforce page
	 */
	public void removeRow() {
	 
		try {
			
			Integer indextoremove;
			
			OpportunityWrapper wrapperToUpdate;
			for (AccountWrapper aw : accountWrappers){
				for (OpportunityWrapper ow : aw.opps){
					if (ow.opportunityObj.Id == currentOpportunity) {
						wrapperToUpdate = ow;
						
						for (Integer i = 0; i < ow.opportunityProducts.size(); i++){
							if (recordToDelete == ow.opportunityProducts[i].Id){
								
								indextoremove = i;
								break;
							}
						}
					}
				}
			}

			String idstr = String.escapeSingleQuotes(recordToDelete);
			if (idstr.length() > 0 ){
				
				//wrapperToUpdate.opportunityProducts.remove(indextoremove);
				Opportunity_Product__c oppToDelete = [Select Id from Opportunity_Product__c where Id = :recordToDelete limit 1];
				delete oppToDelete;

				
				Id userId = UserInfo.getUserId();
				//First query the AccountTeamMember records
				List<AccountTeamMember> members = [SELECT Id, AccountId FROM AccountTeamMember WHERE UserId = :userId];
			
				//now get the Ids of all the accounts
				Set<Id> accountIds = new Set<Id>();
				for(AccountTeamMember member : members) {
					accountIds.add(member.AccountId);
				}
			
				curraccounts = [SELECT Id, Name, (Select Id, Requested_Effective_Date__c, Name, RecordType.Name, HCSC_Division__c, Expected_Health_Members__c, Expected_Health_Contracts__c, Expected_Dental_Members__c, Expected_Dental_Contracts__c From Opportunities) FROM Account WHERE (Id IN :accountIds OR OwnerId = :userId) AND Id in (Select AccountId from Opportunity)];
			
				Set<Id> oppIds = new Set<Id>();		
				Set<Id> nonCurrentOppIds = new Set<Id>();

				for(Account a : curraccounts){
					for(Opportunity o : a.Opportunities) {
						if ((o.Requested_Effective_Date__c.year() == System.now().year() && o.Requested_Effective_Date__c.month() != 1) || (o.Requested_Effective_Date__c.year() == (System.now().year()+1) && o.Requested_Effective_Date__c.month() == 1)) {
							oppIds.add(o.Id);
						}
					
					}
				}

				currOpps = new Map<Id, Opportunity>([Select Id, Name,Expected_Health_Members__c, Expected_Health_Contracts__c, (Select Id, Name, Projected_Members__c, Projected_Contracts__c, Product__r.Name, Status__c, Product_Type__c, Win_Probability__c, Funding_Type__c, Premium_Type__c from Opportunity_Products__r) From Opportunity Where Id in :oppIds]); 
				accountWrappers = buildAccountWrappers(curraccounts);
				


				//opportunityWrappersToOpportunityMap = new Map<Id, Opportunity_Product__c>();
			}
			else {
				
				wrapperToUpdate.opportunityProducts.remove(numberOfRowToRemove - 1);
				
			}

		} catch (Exception ex) {
			System.debug(ex + ' ' + ex.getLineNumber());
			CreateExceptionLog.insertErrorLog(ex, null, null, null, 'Apex Class', 'opportunity', null, 'AddOpportunityProductsController.removeRow()', 'High');

		}
		
	}

	public class AccountWrapper{
		
		public Account accountObj {get;set;}
		public List<OpportunityWrapper> opps {get; set;}
		public Integer numProducts {get; set;}

	}

	public class OpportunityWrapper {
		
		public Opportunity opportunityObj {get;set;}
		public List<Opportunity_Product__c> opportunityProducts {get; set;}
		
		public String recordType {get;set;}
		public Integer numProducts {get; set;}

	}

	public class OpportunityProductWrapper {
		
		public Opportunity_Product__c opportunityProductObj {get;set;}
		public Account accountOfOppProd;
		public Opportunity oppOfOppProd;
	}
}