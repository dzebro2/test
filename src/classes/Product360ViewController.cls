public class Product360ViewController {

	public List<AccountWrapper> accountWrappers {get; set;}
	public Map<Id, Opportunity> currOpps {get; set;}
	public Integer numberOfRowToRemove { get; set; }
	public Id recordToDelete { get; set; }
	public Id currentOpportunity {get; set;}
	public List<Opportunity_Product__c> listOfOpportunityProducts {get; set;}
	public OpportunityWrapper currOpportunityWrapper {get; set;}
	public List<Account> currAccounts;
	public Exception constructorException {get; set;}

	@testVisible
	private AccountTeamMemberDAO.IAccountTeamMemberDAO accountTeamMemberDAOInstance;
	@testVisible
	private AccountDAO.IAccountDAO accountDAOInstance;
	@testVisible
	private OpportunityDAO.IOpportunityDAO opportunityDAOInstance;
	@testVisible
	private OpportunityProductDAO.IOpportunityProductDAO opportunityProductDAOInstance;

	public Product360ViewController() {

		this(new AccountTeamMemberDAO(), new AccountDAO(), new OpportunityDAO(), new OpportunityProductDAO());
	}

	@testVisible
	private Product360ViewController(AccountTeamMemberDAO.IAccountTeamMemberDAO accountTeamMemberDAOInstance,
	                                 AccountDAO.IAccountDAO accountDAOInstance,
	                                 OpportunityDAO.IOpportunityDAO opportunityDAOInstance,
	                                 OpportunityProductDAO.IOpportunityProductDAO opportunityProductDAOInstance) {

		this.accountTeamMemberDAOInstance = accountTeamMemberDAOInstance;
		this.accountDAOInstance = accountDAOInstance;
		this.opportunityDAOInstance = opportunityDAOInstance;
		this.opportunityProductDAOInstance = opportunityProductDAOInstance;
		buildWrappers();
	}

	private void buildWrappers() {

		try {

			Id userId = UserInfo.getUserId();
			//First query the AccountTeamMember records
			List<AccountTeamMember> members = this.accountTeamMemberDAOInstance.getAccountTeamMemberById(userId);

			//now get the Ids of all the accounts
			Set<Id> accountIds = new Set<Id>();
			for (AccountTeamMember member : members) {
				accountIds.add(member.AccountId);
			}

			currAccounts = this.accountDAOInstance.getAccountsForProduct360(userId, accountIds);
			Set<Id> oppIds = new Set<Id>();

			for (Account a : currAccounts) {
				for (Opportunity o : a.Opportunities) {
					if (o.Requested_Effective_Date__c == null)
						continue;
					if ((o.Requested_Effective_Date__c.year() == System.now().year() && o.Requested_Effective_Date__c.month() != 1) || (o.Requested_Effective_Date__c.year() == (System.now().year() + 1) && o.Requested_Effective_Date__c.month() == 1)) {
						oppIds.add(o.Id);

					}

				}
			}

			currOpps = new Map<Id, Opportunity>(this.opportunityDAOInstance.getOpportunitiesForProduct360(oppIds));

			accountWrappers = buildAccountWrappers(currAccounts);
		} catch (Exception e) {

			constructorException = e;
		}
	}

	private List<AccountWrapper> buildAccountWrappers(List<Account> accounts) {

		List<AccountWrapper> accountWrappers = new List<AccountWrapper>();


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

	private List<OpportunityWrapper> buildOpportunityWrappers(List<Opportunity> opps) {


		List<OpportunityWrapper> oppWrappers = new List<OpportunityWrapper>();

		for (Opportunity o : opps) {

			Opportunity currOpp = currOpps.get(o.Id);

			if (currOpp != null) {
				OpportunityWrapper currWrapper = new OpportunityWrapper();

				currWrapper.opportunityObj = o;

				List<OpportunityProductWrapper> opProducts = buildOpportunityProductWrappers(currOpp.Opportunity_Products__r);

				currWrapper.opportunityProducts = opProducts;
				currWrapper.numProducts = currWrapper.opportunityProducts.size();
				currWrapper.recordType = o.RecordType.Name;
				oppWrappers.add(currWrapper);
			}
		}
		return oppWrappers;
	}

	private List<OpportunityProductWrapper> buildOpportunityProductWrappers(List<Opportunity_Product__c> opportunityProducts) {

		List<OpportunityProductWrapper> opProductWrappers = new List<OpportunityProductWrapper>();
		for (Opportunity_Product__c op : opportunityProducts) {

			OpportunityProductWrapper currWrapper = new OpportunityProductWrapper();
			currWrapper.opProduct = op;
			opProductWrappers.add(currWrapper);
		}
		return opProductWrappers;
	}

	public void save() {

		try {

			List<Opportunity_Product__c> oppProducts = new List<Opportunity_Product__c>();
			for (AccountWrapper aw : accountWrappers) {
				for (OpportunityWrapper ow : aw.opps) {
					for (OpportunityProductWrapper op : ow.opportunityProducts) {
						oppProducts.add(op.opProduct);
					}
				}
			}
			this.opportunityProductDAOInstance.upsertOpportunityProducts(oppProducts);

		} catch (Exception e) {

			CreateExceptionLog.insertErrorLog(e, null, null, null, 'Apex Class', null, null, 'Product360ViewController.save()', 'High');

		}
	}

	public PageReference redirect() {

		return new PageReference('/apex/ConfirmProduct360Status');
	}

	public void addNewOpportunityProduct() {

		try {

			Opportunity op = currOpps.get(currentOpportunity);
			Opportunity_Product__c oppToDelete;
			List<Opportunity_Product__c> oppProdsToAdd = new List<Opportunity_Product__c>();

			for (AccountWrapper aw : accountWrappers) {
				for (OpportunityWrapper ow : aw.opps) {
					if (ow.opportunityObj.Id == op.Id) {

						Opportunity_Product__c newOppProd = new Opportunity_Product__c(Opportunity_Name__c = op.Id, Status__c = Label.Progress, State__c = ow.opportunityObj.HCSC_Division__c);
						OpportunityProductWrapper newWrapper = new OpportunityProductWrapper();
						newWrapper.opProduct = newOppProd;
						ow.opportunityProducts.add(newWrapper);

					}
				}
			}

		} catch (Exception e) {

			CreateExceptionLog.insertErrorLog(e, null, null, null, 'Apex Class', null, null, 'Product360ViewController.addNewOpportunityProduct()', 'High');
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
			for (AccountWrapper aw : accountWrappers) {
				for (OpportunityWrapper ow : aw.opps) {
					if (ow.opportunityObj.Id == currentOpportunity) {
						wrapperToUpdate = ow;

						for (Integer i = 0; i < ow.opportunityProducts.size(); i++) {
							if (recordToDelete == ow.opportunityProducts[i].opProduct.Id) {

								indextoremove = i;
								break;
							}
						}
					}
				}
			}

			String idstr = String.escapeSingleQuotes(recordToDelete);
			if (idstr.length() > 0 ) {

				Opportunity_Product__c oppToDelete = this.opportunityProductDAOInstance.getOpportunityProductById(recordToDelete);
				this.opportunityProductDAOInstance.deleteOpportunityProduct(oppToDelete);
				buildWrappers();
			} else {

				wrapperToUpdate.opportunityProducts.remove(numberOfRowToRemove - 1);
			}

		} catch (Exception ex) {

			CreateExceptionLog.insertErrorLog(ex, null, null, null, 'Apex Class', null, null, 'Product360ViewController.removeRow()', 'High');
		}

	}

	public void insertExceptionLog() {

		if (constructorException != null)
			CreateExceptionLog.insertErrorLog(constructorException, null, null, null, 'Apex Class', null, null, 'Product360ViewController()', 'High');
	}

	public class AccountWrapper {

		public Account accountObj {get; set;}
		public List<OpportunityWrapper> opps {get; set;}
		public Integer numProducts {get; set;}

	}

	public class OpportunityWrapper {

		public Opportunity opportunityObj {get; set;}
		public List<OpportunityProductWrapper> opportunityProducts {get; set;}
		public String recordType {get; set;}
		public Integer numProducts {get; set;}

	}

	public class OpportunityProductWrapper {

		public Opportunity_Product__c opProduct {get; set;}
	}


}