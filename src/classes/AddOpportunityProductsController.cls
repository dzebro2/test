/**************************************************************************************
  Apex Class Name     : AddOpportunityProductsController
  Version             : 1.0
  Function            : This class handles the logic to add an opportuntiy product to an opportunity
 *************************************************************************************/
public with sharing class AddOpportunityProductsController {

	public Id opportunityId { get; set; }
	public Decimal winProb {get; set;}
	public Opportunity opportunityObj { get; set; }
	public Id newSaleRecordTypeId { get; set; }
	public Id renewalRecordTypeId { get; set; }
	public Id offcycleRecordTypeId { get; set; }
	private String Active { get; set; }
	public Integer numberOfRowToRemove { get; set; }
	public Id recordToDelete { get; set; }
	public Map<Id, Opportunity_Product__c> mapOfIdAndOpportunityProduct;
	public OpportunityProductWrapper opportunityProductWrapperObj;
	public boolean hasEditAccess { get; set; }
	public List<OpportunityProductWrapper> listOfOpportunityProducts { get; set; }
	public List<Opportunity_Product__c> selectedOpportunityProducts;
	public string rowCount { get; set; }
	public string BARecordId { get; set; }

	@testVisible
	private UserDAO.IUserDAO userDAOInstance;

	@testVisible
	private OpportunityProductDAO.IOpportunityProductDAO opportunityProductDAOInstance;

	@testVisible
	private ProductDAO.IProductDAO productDAOInstance;

	@testVisible
	private BenefitAgreementDAO.IBenefitAgreementDAO benefitAgreementDAOInstance;

	/**
	 * @Method:getOpportunityRecord()
	 * @description: Method to grab the opportunity record related to the AddOpportunityProducts visualforce page
	 */
	private Opportunity getOpportunityRecord() {
		try {
			Opportunity oppRec = [SELECT Id, Name, StageName, AccountId, CloseDate, Probability, HCSC_Division__c, RecordTypeId FROM Opportunity WHERE Id = :opportunityId LIMIT 1];
			return oppRec;
		} catch (Exception ex) {
			CreateExceptionLog.insertErrorLog(ex, null, null, null, 'Apex Class', 'opportunity', null, 'AddOpportunityProductsController.getOpportunityRecord()', 'High');
			return null;
		}
	}
	/**
	 * @Method:getFields()
	 * @description: Method to grab the field set for use in the visualforce page
	 */
	public List<Schema.FieldSetMember> getFields() {
		if (opportunityObj.RecordTypeId == newSaleRecordTypeId) {
			return SObjectType.Opportunity_Product__c.FieldSets.New_Sale_Opportunity_Products.getFields();
		} else if (opportunityObj.RecordTypeId == renewalRecordTypeId) {
			return SObjectType.Opportunity_Product__c.FieldSets.Renewal_Opportunity_Products.getFields();
		} else {
			return SObjectType.Opportunity_Product__c.FieldSets.Off_Cycle.getFields();
		}
	}

	public AddOpportunityProductsController(ApexPages.standardSetController stdController) {
		this(stdController, new UserDAO(), new OpportunityProductDAO(), new ProductDAO(), new BenefitAgreementDAO());
	}

	/**
	 * @Method:Constructor
	 * @description: Based on the record type of the opportunity, opportunity products are populated in the visualforce page.
	 *              If there are existing products on the opportunity they are displayed but if there are no opportunity products
	 *              on the opportunity, products are displayed from the account from the benefit agreements(if applicable).
	 *
	 */
	@testVisible
	private AddOpportunityProductsController(ApexPages.standardSetController stdController,
	        UserDAO.IUserDAO userDAOInstance,
	        OpportunityProductDAO opportunityProductDAOInstance,
	        ProductDAO productDAOInstance,
	        BenefitAgreementDAO benefitAgreementDAOInstance) {

		this.userDAOInstance = userDAOInstance;
		this.opportunityProductDAOInstance = opportunityProductDAOInstance;
		this.productDAOInstance = productDAOInstance;
		this.benefitAgreementDAOInstance = benefitAgreementDAOInstance;
		opportunityId = ApexPages.currentPage().getParameters().get('opportunityId');
		Active = Label.Active;
		UserRecordAccess userAccess = this.userDAOInstance.getUserEditAccess(UserInfo.getUserId(), opportunityId);
		if (userAccess.HasEditAccess) {
			hasEditAccess = true;

			opportunityObj = getOpportunityRecord();
			try {
				newSaleRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(Label.ProductTypeN).getRecordTypeId();
				renewalRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(Label.ProductTypeR).getRecordTypeId();
				offcycleRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(Label.Off_Cycle_Upsell).getRecordTypeId();
				winProb = opportunityObj.Probability;

				if (opportunityObj.RecordTypeId == newSaleRecordTypeId) {

					List<Opportunity_Product__c> existingOpportunityProducts = new List<Opportunity_Product__c> ();
					listOfOpportunityProducts = new List<OpportunityProductWrapper> ();


					existingOpportunityProducts = this.opportunityProductDAOInstance.getExistingOpProducts(this.getFields());
					mapOfIdAndOpportunityProduct = new Map<Id, Opportunity_Product__c> (existingOpportunityProducts);


					if (!existingOpportunityProducts.isEmpty()) {
						Opportunity_Product__c tempOpportunityProduct;
						boolean benefitAgreementCheck = false;

						Map<String, Opportunity_Product__c> oppProdMap = new Map<String, Opportunity_Product__c> ();
						for (Opportunity_Product__c b : existingOpportunityProducts) {
							Opportunity_Product__c opp = new Opportunity_Product__c();

							if (oppProdMap.containsKey(b.Id)) {
								opp = oppProdMap.get(b.Id);
							}

							opp = b;
							oppProdMap.put(b.Id, opp);
						}

						List<String> prodName = new List<String> ();
						for (Id b : oppProdMap.keySet()) {
							String product = oppProdMap.get(b).Product__r.Simplified_Product__c;
							prodName.add(product);
						}

						Map<String, Product2> prodMap = new Map<String, Product2> ();

						List<Product2> oprod = new List<Product2> ();
						oprod = this.productDAOInstance.getSimpleProducts(opportunityObj.HCSC_Division__c, prodName);
						for (Product2 p : oprod) {
							Product2 Nprod = new Product2();
							Nprod = p;
							prodMap.put(p.Name, Nprod);
						}

						for (Id c : oppProdMap.keySet()) {
							if (oppProdMap.get(c) != null) {
								tempOpportunityProduct = new Opportunity_Product__c();
								tempOpportunityProduct.Opportunity_Name__c = oppProdMap.get(c).Opportunity_Name__c;
								tempOpportunityProduct.Id = oppProdMap.get(c).Id;
								tempOpportunityProduct.Category__c = oppProdMap.get(c).Category__c;

								for (Schema.FieldSetMember f : this.getFields()) {
									tempOpportunityProduct.put(f.getFieldPath(), oppProdMap.get(c).get(f.getFieldPath()));
								}

								if (prodMap.get(oppProdMap.get(c).Product__r.Simplified_Product__c) == null) {
									tempOpportunityProduct.Product__c = oppProdMap.get(c).Product__c;
								} else {
									tempOpportunityProduct.Product__c = prodMap.get(oppProdMap.get(c).Product__r.Simplified_Product__c).Id;
								}

								opportunityProductWrapperObj = new OpportunityProductWrapper(true, tempOpportunityProduct, false);
								listOfOpportunityProducts.add(opportunityProductWrapperObj);
							}
						}
					} else {
						listOfOpportunityProducts = new List<OpportunityProductWrapper> ();

						opportunityProductWrapperObj = new OpportunityProductWrapper(true, new Opportunity_Product__c(Opportunity_Name__c = opportunityId, Status__c = label.Progress, Product_Type__c = Label.ProductTypeN, State__c = opportunityObj.HCSC_Division__c), false);

						listOfOpportunityProducts.add(opportunityProductWrapperObj);
					}

				}
				if (opportunityObj.RecordTypeId == renewalRecordTypeId) {

					List<Opportunity_Product__c> existingOpportunityProducts = new List<Opportunity_Product__c> ();
					listOfOpportunityProducts = new List<OpportunityProductWrapper> ();


					existingOpportunityProducts = this.opportunityProductDAOInstance.getExistingOpProducts(this.getFields());
					mapOfIdAndOpportunityProduct = new Map<Id, Opportunity_Product__c> (existingOpportunityProducts);

					if (!existingOpportunityProducts.isEmpty()) {
						Opportunity_Product__c tempOpportunityProduct;
						boolean benefitAgreementCheck = false;

						Map<String, Opportunity_Product__c> oppProdMap = new Map<String, Opportunity_Product__c> ();
						for (Opportunity_Product__c b : existingOpportunityProducts) {
							Opportunity_Product__c opp = new Opportunity_Product__c();

							if (oppProdMap.containsKey(b.Id)) {
								opp = oppProdMap.get(b.Id);
							}

							opp = b;
							oppProdMap.put(b.Id, opp);
						}

						List<String> prodName = new List<String> ();
						for (Id b : oppProdMap.keySet()) {
							String product = oppProdMap.get(b).Product__r.Simplified_Product__c;
							prodName.add(product);
						}

						Map<String, Product2> prodMap = new Map<String, Product2> ();

						List<Product2> oprod = new List<Product2> ();
						oprod = this.productDAOInstance.getSimpleProducts(opportunityObj.HCSC_Division__c, prodName);
						for (Product2 p : oprod) {
							Product2 Nprod = new Product2();
							Nprod = p;
							prodMap.put(p.Name, Nprod);
						}

						for (Id c : oppProdMap.keySet()) {
							if (oppProdMap.get(c) != null) {
								if (oppProdMap.get(c).Benefit_Agreement__c != null) {
									benefitAgreementCheck = true;

								}
								tempOpportunityProduct = new Opportunity_Product__c();
								tempOpportunityProduct.Opportunity_Name__c = oppProdMap.get(c).Opportunity_Name__c;
								tempOpportunityProduct.Id = oppProdMap.get(c).Id;
								tempOpportunityProduct.Category__c = oppProdMap.get(c).Category__c;

								for (Schema.FieldSetMember f : this.getFields()) {
									tempOpportunityProduct.put(f.getFieldPath(), oppProdMap.get(c).get(f.getFieldPath()));
								}

								if (prodMap.get(oppProdMap.get(c).Product__r.Simplified_Product__c) == null) {
									tempOpportunityProduct.Product__c = oppProdMap.get(c).Product__c;
								} else {
									tempOpportunityProduct.Product__c = prodMap.get(oppProdMap.get(c).Product__r.Simplified_Product__c).Id;
								}

								opportunityProductWrapperObj = new OpportunityProductWrapper(true, tempOpportunityProduct, benefitAgreementCheck);
								listOfOpportunityProducts.add(opportunityProductWrapperObj);
								benefitAgreementCheck = false;
							}
						}

					} else {

						String Cancelled = Label.Cancelled;
						List<Benefit_Agreement__c> ben = new List<Benefit_Agreement__c> ();
						Map<String, List<Benefit_Agreement__c>> agr = new Map<String, List<Benefit_Agreement__c>> ();
						Opportunity_Product__c tempOpportunityProduct;

						ben = this.benefitAgreementDAOInstance.getBenefitAgreementsForAddOpProds(opportunityObj.AccountId);


						for (Benefit_Agreement__c b : ben) {
							List<Benefit_Agreement__c> be = new List<Benefit_Agreement__c> ();

							if (agr.containsKey(b.Product__r.Simplified_Product__c)) {
								be = agr.get(b.Product__r.Simplified_Product__c);
							}

							be.add(b);
							agr.put(b.Product__r.Simplified_Product__c, be);
						}

						Map<String, Set<String>> fund = new Map<String, Set<String>> ();

						for (Benefit_Agreement__c b : ben) {
							Set<String> ba = new Set<String> ();

							if (fund.containsKey(b.Product__r.Simplified_Product__c)) {
								ba = fund.get(b.Product__r.Simplified_Product__c);
							}

							ba.add(b.Funding_Type__c);
							fund.put(b.Product__r.Simplified_Product__c, ba);
						}

						List<String> prods = new List<String> ();
						for (String b : agr.keySet()) {
							String product = agr.get(b) [0].Product__r.Simplified_Product__c;
							prods.add(product);
						}

						Map<String, List<Product2>> prodMap = new Map<String, List<Product2>> ();

						List<Product2> prodx = new List<Product2> ();
						prodx = this.productDAOInstance.getSimpleProducts(opportunityObj.HCSC_Division__c, prods);
						for (Product2 p : prodx) {
							List<Product2> Nprod = new List<Product2> ();
							Nprod.add(p);
							prodMap.put(p.Name, Nprod);
						}

						decimal memberCountACAP;
						decimal memberCountPREM;
						decimal memberCountASO;
						decimal memberCountCOST;
						decimal memberCountMPP;
						decimal memberCountPAR;
						decimal memberCountSERV;

						decimal memberCountACAPContracts;
						decimal memberCountPREMContracts;
						decimal memberCountASOContracts;
						decimal memberCountCOSTContracts;
						decimal memberCountMPPContracts;
						decimal memberCountPARContracts;
						decimal memberCountSERVContracts;

						for (String b : agr.keySet()) {

							List<Benefit_Agreement__c> ba = new List<Benefit_Agreement__c> ();
							ba = agr.get(b);
							memberCountACAP = 0;
							memberCountPREM = 0;
							memberCountASO = 0;
							memberCountCOST = 0;
							memberCountMPP = 0;
							memberCountPAR = 0;
							memberCountSERV = 0;

							memberCountACAPContracts = 0;
							memberCountPREMContracts = 0;
							memberCountASOContracts = 0;
							memberCountCOSTContracts = 0;
							memberCountMPPContracts = 0;
							memberCountPARContracts = 0;
							memberCountSERVContracts = 0;

							for (Benefit_Agreement__c ab : ba) {
								if (ab.Funding_Type__c == Label.ACAP) {
									for (BA_GS_Assignment__c bagsAgrrement : ab.BA_GS_Assignments__r) {

										if (ab.Product__r.Product_Type__c == Label.ProductTypeM) {
											if (bagsAgrrement.Group_Section__r.Total_Healthcare_Active_Members__c != null) {
												memberCountACAP += bagsAgrrement.Group_Section__r.Total_Healthcare_Active_Members__c;
											}
											if (bagsAgrrement.Group_Section__r.Total_Active_Subscribers__c != null) {
												memberCountACAPContracts += bagsAgrrement.Group_Section__r.Total_Active_Subscribers__c;
											}
										} else if (ab.Product__r.Product_Type__c == Label.ProductTypeD) {
											if (bagsAgrrement.Group_Section__r.Total_Dental_Active_Members__c != null) {
												memberCountACAP += bagsAgrrement.Group_Section__r.Total_Dental_Active_Members__c;
											}
											if (bagsAgrrement.Group_Section__r.Total_Active_Subscribers__c != null) {
												memberCountACAPContracts += bagsAgrrement.Group_Section__r.Total_Active_Subscribers__c;
											}
										}
									}
								} else if (ab.Funding_Type__c == Label.PREM) {
									for (BA_GS_Assignment__c bagsAgrrement : ab.BA_GS_Assignments__r) {

										if (ab.Product__r.Product_Type__c == Label.ProductTypeM) {
											if (bagsAgrrement.Group_Section__r.Total_Healthcare_Active_Members__c != null) {
												memberCountPREM += bagsAgrrement.Group_Section__r.Total_Healthcare_Active_Members__c;
											}
											if (bagsAgrrement.Group_Section__r.Total_Active_Subscribers__c != null) {
												memberCountPREMContracts += bagsAgrrement.Group_Section__r.Total_Active_Subscribers__c;
											}
										} else if (ab.Product__r.Product_Type__c == Label.ProductTypeD) {
											if (bagsAgrrement.Group_Section__r.Total_Dental_Active_Members__c != null) {
												memberCountPREM += bagsAgrrement.Group_Section__r.Total_Dental_Active_Members__c;
											}
											if (bagsAgrrement.Group_Section__r.Total_Active_Subscribers__c != null) {
												memberCountPREMContracts += bagsAgrrement.Group_Section__r.Total_Active_Subscribers__c;
											}
										}
									}
								} else if (ab.Funding_Type__c == Label.ASO) {
									for (BA_GS_Assignment__c bagsAgrrement : ab.BA_GS_Assignments__r) {

										if (ab.Product__r.Product_Type__c == Label.ProductTypeM) {
											if (bagsAgrrement.Group_Section__r.Total_Healthcare_Active_Members__c != null) {
												memberCountASO += bagsAgrrement.Group_Section__r.Total_Healthcare_Active_Members__c;
											}
											if (bagsAgrrement.Group_Section__r.Total_Active_Subscribers__c != null) {
												memberCountASOContracts += bagsAgrrement.Group_Section__r.Total_Active_Subscribers__c;
											}
										} else if (ab.Product__r.Product_Type__c == Label.ProductTypeD) {
											if (bagsAgrrement.Group_Section__r.Total_Dental_Active_Members__c != null) {
												memberCountASo += bagsAgrrement.Group_Section__r.Total_Dental_Active_Members__c;
											}
											if (bagsAgrrement.Group_Section__r.Total_Active_Subscribers__c != null) {
												memberCountASOContracts += bagsAgrrement.Group_Section__r.Total_Active_Subscribers__c;
											}
										}
									}
								} else if (ab.Funding_Type__c == Label.COST) {
									for (BA_GS_Assignment__c bagsAgrrement : ab.BA_GS_Assignments__r) {

										if (ab.Product__r.Product_Type__c == Label.ProductTypeM) {
											if (bagsAgrrement.Group_Section__r.Total_Healthcare_Active_Members__c != null) {
												memberCountCOST += bagsAgrrement.Group_Section__r.Total_Healthcare_Active_Members__c;
											}
											if (bagsAgrrement.Group_Section__r.Total_Active_Subscribers__c != null) {
												memberCountCOSTContracts += bagsAgrrement.Group_Section__r.Total_Active_Subscribers__c;
											}
										} else if (ab.Product__r.Product_Type__c == Label.ProductTypeD) {
											if (bagsAgrrement.Group_Section__r.Total_Dental_Active_Members__c != null) {
												memberCountCOST += bagsAgrrement.Group_Section__r.Total_Dental_Active_Members__c;
											}
											if (bagsAgrrement.Group_Section__r.Total_Active_Subscribers__c != null) {
												memberCountCOSTContracts += bagsAgrrement.Group_Section__r.Total_Active_Subscribers__c;
											}
										}
									}
								} else if (ab.Funding_Type__c == Label.MPP) {
									for (BA_GS_Assignment__c bagsAgrrement : ab.BA_GS_Assignments__r) {

										if (ab.Product__r.Product_Type__c == Label.ProductTypeM) {
											if (bagsAgrrement.Group_Section__r.Total_Healthcare_Active_Members__c != null) {
												memberCountMPP += bagsAgrrement.Group_Section__r.Total_Healthcare_Active_Members__c;
											}
											if (bagsAgrrement.Group_Section__r.Total_Active_Subscribers__c != null) {
												memberCountMPPContracts += bagsAgrrement.Group_Section__r.Total_Active_Subscribers__c;
											}
										} else if (ab.Product__r.Product_Type__c == Label.ProductTypeD) {
											if (bagsAgrrement.Group_Section__r.Total_Dental_Active_Members__c != null) {
												memberCountMPP += bagsAgrrement.Group_Section__r.Total_Dental_Active_Members__c;
											}
											if (bagsAgrrement.Group_Section__r.Total_Active_Subscribers__c != null) {
												memberCountMPPContracts += bagsAgrrement.Group_Section__r.Total_Active_Subscribers__c;
											}
										}
									}
								} else if (ab.Funding_Type__c == Label.PAR) {
									for (BA_GS_Assignment__c bagsAgrrement : ab.BA_GS_Assignments__r) {

										if (ab.Product__r.Product_Type__c == Label.ProductTypeM) {
											if (bagsAgrrement.Group_Section__r.Total_Healthcare_Active_Members__c != null) {
												memberCountPAR += bagsAgrrement.Group_Section__r.Total_Healthcare_Active_Members__c;
											}
											if (bagsAgrrement.Group_Section__r.Total_Active_Subscribers__c != null) {
												memberCountPARContracts += bagsAgrrement.Group_Section__r.Total_Active_Subscribers__c;
											}
										} else if (ab.Product__r.Product_Type__c == Label.ProductTypeD) {
											if (bagsAgrrement.Group_Section__r.Total_Dental_Active_Members__c != null) {
												memberCountPAR += bagsAgrrement.Group_Section__r.Total_Dental_Active_Members__c;
											}
											if (bagsAgrrement.Group_Section__r.Total_Active_Subscribers__c != null) {
												memberCountPARContracts += bagsAgrrement.Group_Section__r.Total_Active_Subscribers__c;
											}
										}
									}
								} else {
									for (BA_GS_Assignment__c bagsAgrrement : ab.BA_GS_Assignments__r) {

										if (ab.Product__r.Product_Type__c == Label.ProductTypeM) {
											if (bagsAgrrement.Group_Section__r.Total_Healthcare_Active_Members__c != null) {
												memberCountSERV += bagsAgrrement.Group_Section__r.Total_Healthcare_Active_Members__c;
											}
											if (bagsAgrrement.Group_Section__r.Total_Active_Subscribers__c != null) {
												memberCountSERVContracts += bagsAgrrement.Group_Section__r.Total_Active_Subscribers__c;
											}
										} else if (ab.Product__r.Product_Type__c == Label.ProductTypeD) {
											if (bagsAgrrement.Group_Section__r.Total_Dental_Active_Members__c != null) {
												memberCountSERV += bagsAgrrement.Group_Section__r.Total_Dental_Active_Members__c;
											}
											if (bagsAgrrement.Group_Section__r.Total_Active_Subscribers__c != null) {
												memberCountSERVContracts += bagsAgrrement.Group_Section__r.Total_Active_Subscribers__c;
											}
										}
									}
								}
							}

							for (String g : fund.get(b)) {
								if (agr.get(b) != null) {
									tempOpportunityProduct = new Opportunity_Product__c();
									tempOpportunityProduct.Upsell__c = Label.NoneP;
									tempOpportunityProduct.Category__c = agr.get(b) [0].Product__r.Product_Type__c;
									tempOpportunityProduct.Win_Probability__c = opportunityObj.Probability;
									if (prodMap.get(b) == null) {
										tempOpportunityProduct.Product__c = agr.get(b) [0].Product__c;
									} else {
										tempOpportunityProduct.Product__c = prodMap.get(b) [0].Id;
									}
									tempOpportunityProduct.Opportunity_Name__c = opportunityId;
									tempOpportunityProduct.Funding_Type__c = g;
									if (g == Label.ACAP) {
										tempOpportunityProduct.Projected_Members__c = memberCountACAP;
									} else if (g == Label.PREM) {
										tempOpportunityProduct.Projected_Members__c = memberCountPREM;
									} else if (g == Label.ASO) {
										tempOpportunityProduct.Projected_Members__c = memberCountASO;
									} else if (g == Label.COST) {
										tempOpportunityProduct.Projected_Members__c = memberCountCOST;
									} else if (g == Label.MPP) {
										tempOpportunityProduct.Projected_Members__c = memberCountMPP;
									} else if (g == Label.PAR) {
										tempOpportunityProduct.Projected_Members__c = memberCountPAR;
									} else {
										tempOpportunityProduct.Projected_Members__c = memberCountSERV;
									}

									if (g == Label.ACAP) {
										tempOpportunityProduct.Projected_Contracts__c = memberCountACAPContracts;
									} else if (g == Label.PREM) {
										tempOpportunityProduct.Projected_Contracts__c = memberCountPREMContracts;
									} else if (g == Label.ASO) {
										tempOpportunityProduct.Projected_Contracts__c = memberCountASOContracts;
									} else if (g == Label.COST) {
										tempOpportunityProduct.Projected_Contracts__c = memberCountCOSTContracts;
									} else if (g == Label.MPP) {
										tempOpportunityProduct.Projected_Contracts__c = memberCountMPPContracts;
									} else if (g == Label.PAR) {
										tempOpportunityProduct.Projected_Contracts__c = memberCountPARContracts;
									} else {
										tempOpportunityProduct.Projected_Contracts__c = memberCountSERVContracts;
									}

									tempOpportunityProduct.Premium_type__c = agr.get(b) [0].Premium_Type__c;
									tempOpportunityProduct.Status__c = Label.Progress;
									tempOpportunityProduct.Product_Type__c = Label.ProductTypeR;
									tempOpportunityProduct.State__c = opportunityObj.HCSC_Division__c;

									opportunityProductWrapperObj = new OpportunityProductWrapper(true, tempOpportunityProduct, true);
									listOfOpportunityProducts.add(opportunityProductWrapperObj);
								}
							}
						}
					}

				}

				if (opportunityObj.RecordTypeId == offcycleRecordTypeId) {

					List<Opportunity_Product__c> existingOpportunityProducts = new List<Opportunity_Product__c> ();
					listOfOpportunityProducts = new List<OpportunityProductWrapper> ();


					existingOpportunityProducts = this.opportunityProductDAOInstance.getExistingOpProducts(this.getFields());
					mapOfIdAndOpportunityProduct = new Map<Id, Opportunity_Product__c> (existingOpportunityProducts);


					if (!existingOpportunityProducts.isEmpty()) {
						Opportunity_Product__c tempOpportunityProduct;
						boolean benefitAgreementCheck = false;

						for (Opportunity_Product__c opportunityProductObj : existingOpportunityProducts) {

							tempOpportunityProduct = new Opportunity_Product__c();
							tempOpportunityProduct.Opportunity_Name__c = opportunityProductObj.Opportunity_Name__c;
							tempOpportunityProduct.Id = opportunityProductObj.Id;

							for (Schema.FieldSetMember f : this.getFields()) {
								tempOpportunityProduct.put(f.getFieldPath(), opportunityProductObj.get(f.getFieldPath()));
							}

							opportunityProductWrapperObj = new OpportunityProductWrapper(true, tempOpportunityProduct, false);
							listOfOpportunityProducts.add(opportunityProductWrapperObj);
						}
					} else {
						listOfOpportunityProducts = new List<OpportunityProductWrapper> ();

						opportunityProductWrapperObj = new OpportunityProductWrapper(true, new Opportunity_Product__c(Opportunity_Name__c = opportunityId, Product_Type__c = Label.Upsell, Status__c = label.Progress, State__c = opportunityObj.HCSC_Division__c), false);

						listOfOpportunityProducts.add(opportunityProductWrapperObj);
					}

				}

			} catch (Exception e) {
				hasEditAccess = false;
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, system.label.InsufficientError));
			}
		}
	}

	/**
	 * @Method:getTheUpdatedMembersCount()
	 * @description: Grabs the amount of Health or Dental Members that are associated with a given Product Type
	 */
	public void getTheUpdatedMembersCount() {
		try {

			decimal memberCount = 0;
			for (Benefit_Agreement__c ba : [select id, Product__r.Product_Type__c,
			                                (select Group_Section__r.Total_Dental_Active_Members__c, Group_Section__r.Total_Healthcare_Active_Members__c
			                                 from BA_GS_Assignments__r where Group_Section__r.Status__c = :Active)
			                                from Benefit_Agreement__c where Name = :BARecordId and status__c = :Active]) {
				for (BA_GS_Assignment__c bagsAgrrement : ba.BA_GS_Assignments__r) {
					if (ba.Product__r.Product_Type__c == Label.ProductTypeM) {
						if (bagsAgrrement.Group_Section__r.Total_Healthcare_Active_Members__c != null)
							memberCount += bagsAgrrement.Group_Section__r.Total_Healthcare_Active_Members__c;
					} else if (ba.Product__r.Product_Type__c == Label.ProductTypeD) {
						if (bagsAgrrement.Group_Section__r.Total_Dental_Active_Members__c != null)
							memberCount += bagsAgrrement.Group_Section__r.Total_Dental_Active_Members__c;
					}
				}
			}

			decimal recCount = 1;
			for (OpportunityProductWrapper opw : listOfOpportunityProducts) {
				if (recCount == decimal.valueOf(rowCount)) {
					opw.opportunityProductObj.Projected_Members__c = memberCount;
				}
				++ recCount;
			}
		} catch (Exception e) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
		}
	}

	/**
	 * @Method:removeRow
	 * @description: Deletes a row of products in the AddOpportunityProducts visualforce page
	 */
	public PageReference removeRow() {

		try {

			if (opportunityObj.StageName != Label.WonP) {
				listOfOpportunityProducts.remove(numberOfRowToRemove - 1);
				if (recordToDelete != null && !mapOfIdAndOpportunityProduct.isEmpty()) {
					if (mapOfIdAndOpportunityProduct.containsKey(recordToDelete)) {
						delete mapOfIdAndOpportunityProduct.get(recordToDelete);
					}
				}

			} else {

				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ProductsRemoved));
				return null;
			}


		} catch (Exception ex) {
			CreateExceptionLog.insertErrorLog(ex, null, null, null, 'Apex Class', 'opportunity', null, 'AddOpportunityProductsController.removeRow()', 'High');

		}
		return null;
	}

	/**
	 * @Method:AddNewOpportunityProduct()
	 * @description: Method to add new Opportunity Product for an Opportunity
	 */
	public PageReference AddNewOpportunityProduct() {

		if (opportunityObj.RecordTypeId == newSaleRecordTypeId) {

			if (opportunityObj.StageName != Label.WonP) {

				opportunityProductWrapperObj = new OpportunityProductWrapper(true, new Opportunity_Product__c(Opportunity_Name__c = opportunityId, Status__c = Label.Progress, Product_Type__c = Label.ProductTypeN, Win_Probability__c = opportunityObj.Probability, State__c = opportunityObj.HCSC_Division__c), false);

				listOfOpportunityProducts.add(opportunityProductWrapperObj);
				return null;

			} else {

				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, label.ProductsAdded));
				return null;
			}

		} else if (opportunityObj.RecordTypeId == renewalRecordTypeId) {

			if (opportunityObj.StageName != Label.WonP) {

				opportunityProductWrapperObj = new OpportunityProductWrapper(true, new Opportunity_Product__c(Opportunity_Name__c = opportunityId, Status__c = Label.Progress, Product_Type__c = Label.ProductTypeR, Win_Probability__c = opportunityObj.Probability, State__c = opportunityObj.HCSC_Division__c), false);

				listOfOpportunityProducts.add(opportunityProductWrapperObj);
				return null;

			} else {

				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, label.ProductsAdded));
				return null;

			}

		} else if (opportunityObj.RecordTypeId == offcycleRecordTypeId) {

			if (opportunityObj.StageName != Label.WonP) {

				opportunityProductWrapperObj = new OpportunityProductWrapper(true, new Opportunity_Product__c(Opportunity_Name__c = opportunityId, Status__c = Label.Progress, Product_Type__c = Label.Upsell, Win_Probability__c = opportunityObj.Probability, State__c = opportunityObj.HCSC_Division__c), false);

				listOfOpportunityProducts.add(opportunityProductWrapperObj);
				return null;

			} else {

				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, label.ProductsAdded));
				return null;

			}
		} else {

			return null;
		}

	}

	/**
	 * @Method:saveOpportunityProducts()
	 * @description: Saves the opportunity products that have been selected on the visualforce page
	 */
	public PageReference saveOpportunityProducts() {
		selectedOpportunityProducts = new List<Opportunity_Product__c> ();
		try {

			if (opportunityObj.StageName != Label.WonP) {

				for (OpportunityProductWrapper opportunityProductWrapperIterator : listOfOpportunityProducts) {

					if (opportunityObj.RecordTypeId == renewalRecordTypeId) {
						if (opportunityProductWrapperIterator.opportunityProductObj.Product_Type__c == Label.ProductTypeN) {
							ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.CannotSelectNewSaleProd));
							return null;
						}
					} else if (opportunityObj.RecordTypeId == offcycleRecordTypeId) {
						if (opportunityProductWrapperIterator.opportunityProductObj.Product_Type__c == Label.ProductTypeN || opportunityProductWrapperIterator.opportunityProductObj.Product_Type__c == Label.ProductTypeR) {
							ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.CannotSelectNSorRProd));
							return null;
						}
					} else if (opportunityObj.RecordTypeId == newSaleRecordTypeId) {
						if (OpportunityProductWrapperIterator.opportunityProductObj.Product_Type__c != Label.ProductTypeN) {
							ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.CannotSelectNonNewSaleProduct));
							return null;
						}
					}
					if (opportunityProductWrapperIterator.isSelected == true) {
						selectedOpportunityProducts.add(opportunityProductWrapperIterator.opportunityProductObj);

					}
				}
				if (!selectedOpportunityProducts.isEmpty()) {

					upsert selectedOpportunityProducts;
					String lostProducts = '';
					String selectedProducts = '';
					List<Opportunity_Product__c> lostprods = this.opportunityProductDAOInstance.getLostProductsForAddOpProds(selectedOpportunityProducts);

					for (Opportunity_Product__c op : lostprods) {

						if (op.Status__c == Label.Lost) {

							if (String.isEmpty(lostProducts)) {
								lostProducts = op.Id;
							} else {
								lostProducts = lostProducts + '-' + op.Id;
							}
						}
					}

					for (Opportunity_Product__c oppProd : selectedOpportunityProducts) {

						if (String.isEmpty(selectedProducts)) {
							selectedProducts = oppProd.Id;
						} else {
							selectedProducts = selectedProducts + '-' + oppProd.Id;
						}
					}

					if (String.isEmpty(lostProducts) && String.isEmpty(selectedProducts)) {
						return new PageReference('/' + opportunityId);
					} else {
						return new PageReference('/apex/ConfirmProgressOnLostProducts?oid=' + opportunityId + '&ids=' + lostProducts + '&pids=' + selectedProducts);
					}

				} else {
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ProductSelect));
					return null;
				}


			} else {

				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ProductSave));
				return null;
			}



		} catch (Exception ex) {
			CreateExceptionLog.insertErrorLog(ex, null, null, null, 'Apex Class', 'opportunity', null, 'AddOpportunityProductsController.removeRow()', 'High');
			return null;
		}

	}

	/**
	 * @Method:gotoOpportunity()
	 * @description: Redirects the page to the opportuntiy
	 */
	public PageReference gotoOpportunity() {
		return new PageReference('/' + opportunityId);
	}

	/**
	 * @class:OpportunityProductWrapper
	 * @description: Wrapper Class used to hold the products that are selected on the Visualforce page.  The products can then be used
	  for any logic neccessary
	 */
	public class OpportunityProductWrapper {
		public boolean isSelected { get; set; }
		public Opportunity_Product__c opportunityProductObj { get; set; }
		public boolean benefitAgreementCheck { get; set; }

		public OpportunityProductWrapper(boolean isSelected, Opportunity_Product__c opportunityProductObj, boolean benefitAgreementCheck) {
			this.isSelected = isSelected;
			this.opportunityProductObj = opportunityProductObj;
			this.benefitAgreementCheck = benefitAgreementCheck;
		}
	}
}