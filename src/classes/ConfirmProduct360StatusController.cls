public class ConfirmProduct360StatusController { 
	
	
	public List<Opportunity_Product__c> opProducts {get;set;}
	public List<Opportunity> opportunityObjects {get;set;}
	public List<OpportunityProductWrapper> opportunityProductWrappers{get; set;}
	public List<OpportunityWrapper> opportunityWrappers{get;set;}
	public List<Account> currAccounts;
	public Integer opportunityProductCount {get;set;}
	public Exception constructorException {get;set;}

	@testVisible
	private AccountTeamMemberDAO.IAccountTeamMemberDAO accountTeamMemberDAOInstance;
	@testVisible
	private AccountDAO.IAccountDAO accountDAOInstance;
	@testVisible
	private OpportunityDAO.IOpportunityDAO opportunityDAOInstance;
	@testVisible
	private OpportunityProductDAO.IOpportunityProductDAO opportunityProductDAOInstance;

	public ConfirmProduct360StatusController(){
		this(new AccountTeamMemberDAO(), new AccountDAO(), new OpportunityDAO(), new OpportunityProductDAO());
	}

	@testVisible
	private ConfirmProduct360StatusController(AccountTeamMemberDAO.IAccountTeamMemberDAO accountTeamMemberDAOInstance,
											  AccountDAO.IAccountDAO accountDAOInstance,
											  OpportunityDAO.IOpportunityDAO opportunityDAOInstance,
											  OpportunityProductDAO.IOpportunityProductDAO opportunityProductDAOInstance){
		try{
			this.accountTeamMemberDAOInstance = accountTeamMemberDAOInstance;
			this.accountDAOInstance = accountDAOInstance;
			this.opportunityDAOInstance = opportunityDAOInstance;
			this.opportunityProductDAOInstance = opportunityProductDAOInstance;
			opportunityProductWrappers = new List<OpportunityProductWrapper>();
			opportunityWrappers = new List<OpportunityWrapper>();
				
			Id userId = UserInfo.getUserId();
		
			List<AccountTeamMember> members = this.accountTeamMemberDAOInstance.getAccountTeamMemberById(userId);

			Set<Id> accountIds = new Set<Id>();
			for(AccountTeamMember member : members) {
				accountIds.add(member.AccountId);
			}
			
			currAccounts = this.accountDAOInstance.getAccountsForProduct360(userId, accountIds);

			Set<Id> oppIds = new Set<Id>();		
		
			for(Account a : currAccounts){
				for(Opportunity o : a.Opportunities) {
					if (o.Requested_Effective_Date__c == null)
						continue;
					if ((o.Requested_Effective_Date__c.year() == System.now().year() && o.Requested_Effective_Date__c.month() != 1) || (o.Requested_Effective_Date__c.year() == (System.now().year()+1) && o.Requested_Effective_Date__c.month() == 1)) {
						oppIds.add(o.Id);
						
					}
					
				}
			}

			opportunityObjects = this.opportunityDAOInstance.getOpportunitiesForProduct360(oppIds);
		
			for (Opportunity o : opportunityObjects){
						
				OpportunityWrapper currWrapper = new OpportunityWrapper();
				currWrapper.opportunityObj = o;
				currWrapper.projectedHealthMembersRollup = 0;
				currWrapper.projectedHealthContractsRollup = 0;
				currWrapper.projectedDentalMembersRollup = 0;
				currWrapper.projectedDentalContractsRollup = 0;

				if (!o.Opportunity_Products__r.isEmpty()) {
				
					for (Opportunity_Product__c product : o.Opportunity_Products__r){
					
						if (product.Product__r.Non_Medical_Compensation__c == True && product.Product_Type__c != Label.ProductTypeR && product.Status__c == Label.Lost){
							OpportunityProductWrapper currOpportunityProduct = new OpportunityProductWrapper();
							currOpportunityProduct.opportunityObj = o;
							currOpportunityProduct.opportunityProduct = product;
							opportunityProductWrappers.add(currOpportunityProduct);
						}
					
						if (product.Category__c == Label.ProductTypeM) {
						
							if (product.Status__c != Label.Lost && product.Product_Type__c != Label.Upsell) {
							
								currWrapper.projectedHealthMembersRollup += product.Projected_Members__c;
								currWrapper.projectedHealthContractsRollup += product.Projected_Contracts__c;
							}
                    
						} else if (product.Category__c == Label.ProductTypeD) {

							if (product.Status__c != Label.Lost && product.Product_Type__c != Label.Upsell) {

								currWrapper.projectedDentalMembersRollup += product.Projected_Members__c;
								currWrapper.projectedDentalContractsRollup += product.Projected_Contracts__c;
							}
						}
					}
				}
				opportunityWrappers.add(currWrapper);

			}
			opportunityProductCount = opportunityProductWrappers.size();
		} catch (Exception e) {
			constructorException = e;
		}
	}

	public PageReference save(){

		try {
			List<Opportunity_Product__c> opportunityProductsToUpdate = new List<Opportunity_Product__c>();
			List<Opportunity> opportunitiesToUpdate = new List<Opportunity>();
			for (OpportunityProductWrapper op : opportunityProductWrappers){
				opportunityProductsToUpdate.add(op.opportunityProduct);
			}
			for (OpportunityWrapper op : opportunityWrappers){
				opportunitiesToUpdate.add(op.opportunityObj);
			}
			this.opportunityDAOInstance.updateOpportunities(opportunitiesToUpdate);
			this.opportunityProductDAOInstance.updateOpportunityProducts(opportunityProductsToUpdate);
			return new PageReference('/apex/Product360View');

		} catch(Exception ex) {
			
			CreateExceptionLog.insertErrorLog(ex, null, null, null, 'Apex Class', 'opportunity', null, 'ConfirmProduct360StatusController.save()', 'High');
			return null;
		}
	}

	public PageReference cancel(){
		
		return new PageReference('/apex/Product360View');
	}

	public void insertExceptionLog(){
		
		if (constructorException != null)
			CreateExceptionLog.insertErrorLog(constructorException, null, null, null, 'Apex Class', null, null, 'ConfirmProductStatusController()', 'High');
	}
	
	public class OpportunityProductWrapper{
		
		public Opportunity opportunityObj {get;set;}
		public Opportunity_Product__c opportunityProduct {get;set;} 
	}

	public class OpportunityWrapper{
		
		public Opportunity opportunityObj {get; set;}
		public Decimal projectedHealthMembersRollup {get; set;}
        public Decimal projectedHealthContractsRollup {get; set;}
        public Decimal projectedDentalMembersRollup {get; set;}
        public Decimal projectedDentalContractsRollup {get; set;}
	}
}