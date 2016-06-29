/**************************************************************************************
  Apex Class Name     : ProductLandscapeController
  Version             : 1.0
  Function            : This class populates the ProductLandscape Visualforce page tables with products.

 *************************************************************************************/
public with sharing class ProductLandscapeController {

	public List<ActivelyPurchasingProductsBean> activelyPurchasingProductsList { get; set; }
	public List<CurrentProductsBean> currentProductsList { get; set; }
	public List<OtherProductsBean> otherProductsList { get; set; }
	List<Id> productIdsToBeExcluded;
	public Id accountId { get; set; }
	public String HCSCState;
	List<Account_Product_Information__c> additionalInfoList;
	String AccountName;
	String Account_ID;
	public String ChkMapKeyI { get; set; }
	public String ChkMapKeyL { get; set; }
	public List<ImpProductsBean> impb { get; set; }
	public List<LostProductsBean> lostp { get; set; }
	public Map<Id, List<String>> TeamMemberMapI { get; set; }
	public Map<Id, List<String>> TeamMemberMapL { get; set; }
	public Id newSaleRecordTypeId { get; set; }
	public Id renewalRecordTypeId { get; set; }
	public Id offcycleRecordTypeId {get; set;}
	private String Active { get; set; }
	private String Cancelled { get; set; }
	private String Won { get; set; }
	private String yes { get; set; }
	private String NewSale { get; set; }
	private String client { get; set; }
	private String imp { get; set; }
	private String lost { get; set; }

	public ProductLandscapeController(ApexPages.StandardController stdController) {
		accountId = stdController.getId();
		Account acc = [select Id, HCSC_Division__c, Name
		               from Account
		               where Id = :accountId
		                          limit 1];
		HCSCState = acc.HCSC_Division__c;
		AccountName = acc.Name;
		Account_ID = acc.ID;
		productIdsToBeExcluded = new List<Id> ();
		Active = Label.Active;
		Cancelled = Label.Cancelled;
		Won = Label.WonP;
		yes = Label.YesP;
		NewSale = Label.ProductTypeN;
		client = Label.Client;
		imp = Label.Imp;
		lost = Label.Lost;
		newSaleRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(Label.ProductTypeN).getRecordTypeId();
		renewalRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(Label.ProductTypeR).getRecordTypeId();
		offcycleRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(Label.Off_Cycle_Upsell).getRecordTypeId();
		populateActivelyPurchasingProducts();
		populateImplementingProducts();
		populateCurrentProducts();
		populateLostProducts();
		populateOtherProducts();
	}

	/********************************************************************
	 * Method Name : populateActivelyPurchasingProducts
	 *   @description :   This method populates the Actively Purchasing Products Table with products from opportunities that are not closed
	 *   @parameters  :   none
	 *   @return type :   none
	 ***************************************************************/
	private void populateActivelyPurchasingProducts() {
		activelyPurchasingProductsList = new List<ActivelyPurchasingProductsBean> ();
		List<Opportunity> activeOpp = new List<Opportunity> ();

		try {

			activeOpp = [select Id, Name, CloseDate,
			             (select Id, Name, Product__c, Funding_Type__c, Product__r.Simplified_Product__c, Product__r.Product_Category__c,
			              Projected_Members__c, Business_Type__c, Product_Family__c, Product_Category__c,
			              Current_Product__c, Benefit_Agreement__c, Benefit_Agreement__r.Product__c, Product__r.Family
			              from Opportunity_Products__r),
			             (select Id
			              from Competitor_Relationships__r)
			             from Opportunity
			             where AccountId = :accountId
			                               and IsClosed = false
			                                       limit :Limits.getLimitQueryRows() - Limits.getQueryRows()];

			for (Opportunity op : activeOpp) {

				for (Opportunity_Product__c oppProd : op.Opportunity_Products__r) {

					ActivelyPurchasingProductsBean activelyPurchasingProd = new ActivelyPurchasingProductsBean();
					activelyPurchasingProd.productFamily = oppProd.Product_Family__c;
					activelyPurchasingProd.productCategory = oppProd.Product_Category__c;
					activelyPurchasingProd.productId = oppProd.Product__c;
					activelyPurchasingProd.productName = oppProd.Product__r.Simplified_Product__c;
					activelyPurchasingProd.funding = oppProd.Funding_Type__c;
					if (op.Competitor_Relationships__r != null) {
						activelyPurchasingProd.numberOfCompetitors = op.Competitor_Relationships__r.size();
					}
					activelyPurchasingProd.businessType = oppProd.Business_Type__c;
					if (op.CloseDate != null) {
						activelyPurchasingProd.dueDate = op.CloseDate.format();
					}
					activelyPurchasingProd.numberOfProjectedMembers = Integer.valueOf(oppProd.Projected_Members__c);
					activelyPurchasingProd.associatedOpportunityName = op.Name;
					activelyPurchasingProd.associatedOpportunityId = op.Id;
					activelyPurchasingProd.opportunityProductName = oppProd.Name;

					activelyPurchasingProductsList.add(activelyPurchasingProd);

					productIdsToBeExcluded.add(oppProd.Product__c);

				}
			}
		} catch (Exception ex) {
			System.debug('#####' + Label.Error + ex.getMessage() + ex.getStackTraceString());
		}
	}

	/********************************************************************
	 * Method Name : populateCurrentProducts
	 *   @description :   This method populates the Current Products Table.  Data fed from BlueStar
	 *   @parameters  :   none
	 *   @return type :   none
	 *   @developer   :   Nick Serafin/Slalom
	 ***************************************************************/
	private void populateCurrentProducts() {
		currentProductsList = new List<CurrentProductsBean> ();
		Map<Id, CurrentProductsBean> ProductIdProductBeanMap = new Map<Id, CurrentProductsBean> ();
		Map<Id, List<Benefit_Agreement__c>> ProductIdListBAMap = new Map<Id, List<Benefit_Agreement__c>> ();
		List<Benefit_Agreement__c> fundBenefit = new List<Benefit_Agreement__c> ();
		Map<Id, Set<String>> fundMap = new Map<Id, Set<String>> ();
		CurrentProductsBean currentProd;
		List<Competitor_Products__c> compProds = new List<Competitor_Products__c>();
		List<CurrentProductsBean> fullProductList = new List<CurrentProductsBean>();
		try {

			fundBenefit = [select Id, Product__r.Product_Category__c, Product__r.Product_Type__c, Funding_Type__c, Product__r.Simplified_Product__c, Product__c, Product__r.Name, Business_Type__c,
			               Renewal_Date__c, Members__c, Product__r.Family,
			               (select Id, Name, Opportunity_Name__c, Product__c, Opportunity_Name__r.Name,
			                Projected_Members__c, Current_Product__c
			                from Opportunity_Products__r
			                where Opportunity_Name__r.IsClosed = true
			                        order by CreatedDate DESC), (select Group_Section__r.Total_Dental_Active_Members__c,
			                                Group_Section__r.Total_Healthcare_Active_Members__c
			                                from BA_GS_Assignments__r where Group_Section__r.Status__c = :Active)
			               from Benefit_Agreement__c
			               where Group_Account__c = :accountId and Status__c = :Active
			                                        and Effective_Date__c < :System.today()
			                                        and (Cancellation_Status__c != :Cancelled and Status__c != :Cancelled)
			                                        limit :Limits.getLimitQueryRows() - Limits.getQueryRows()];

			compProds = [select Id, Product__r.Product_Category__c, Product__r.Simplified_Product__c, Product__c, Product__r.Name, Business_Type__c, Renewal_Date__c, Members__c,
			             Carrier__r.Competitor_Account__c, Carrier__r.Competitor_Account__r.Name, Carrier__r.Opportunity__c, Product__r.Family
			             from Competitor_Products__c
			             where Carrier__r.Group_Account__c = :accountId
			                     and Effective_Date__c < :System.today()
			                     and Status__c != :Cancelled
			                     limit :Limits.getLimitQueryRows() - Limits.getQueryRows()];

			Map<Id, List<Competitor_Products__c>> compProdMap = new Map<Id, List<Competitor_Products__c>>();

			for (Competitor_Products__c c : compProds) {

				List<Competitor_Products__c> cp = new List<Competitor_Products__c>();

				if (compProdMap.containsKey(c.Product__c)) {
					cp = compProdMap.get(c.Product__c);
				}

				cp.add(c);
				compProdMap.put(c.Product__c, cp);

			}

			Map<Id, List<Benefit_Agreement__c>> bagr = new Map<Id, List<Benefit_Agreement__c>> ();
			for (Benefit_Agreement__c b : fundBenefit) {

				List<Benefit_Agreement__c> be = new List<Benefit_Agreement__c> ();

				if (bagr.containsKey(b.Product__c)) {
					be = bagr.get(b.Product__c);
				}

				be.add(b);
				bagr.put(b.Product__c, be);
			}
			system.debug(bagr.keySet());

			for (Benefit_Agreement__c b : fundBenefit) {

				Set<String> ba = new Set<String> ();

				if (fundMap.containsKey(b.Product__c)) {
					ba = fundMap.get(b.Product__c);
				}

				ba.add(b.Funding_Type__c);
				fundMap.put(b.Product__c, ba);
			}

			decimal memberCountACAP;
			decimal memberCountPREM;
			decimal memberCountASO;
			decimal memberCountCOST;
			decimal memberCountMPP;
			decimal memberCountPAR;
			decimal memberCountSERV;

			decimal numBaACAP;
			decimal numBaPREM;
			decimal numBaASO;
			decimal numBaCOST;
			decimal numBaMPP;
			decimal numBaPAR;
			decimal numBaSERV;

			for (String b : bagr.keySet()) {
				List<Benefit_Agreement__c> ba = new List<Benefit_Agreement__c> ();
				ba = bagr.get(b);
				memberCountACAP = 0;
				memberCountPREM = 0;
				memberCountASO = 0;
				memberCountCOST = 0;
				memberCountMPP = 0;
				memberCountPAR = 0;
				memberCountSERV = 0;

				numBaACAP = 0;
				numBaPREM = 0;
				numBaASO = 0;
				numBaCOST = 0;
				numBaMPP = 0;
				numBaPAR = 0;
				numBaSERV = 0;

				for (Benefit_Agreement__c ab : ba) {
					if (ab.Funding_Type__c == Label.ACAP) {

						for (BA_GS_Assignment__c bagsAgrrement : ab.BA_GS_Assignments__r) {

							if (ab.Product__r.Product_Type__c == Label.ProductTypeM) {
								if (bagsAgrrement.Group_Section__r.Total_Healthcare_Active_Members__c != null)
									memberCountACAP += bagsAgrrement.Group_Section__r.Total_Healthcare_Active_Members__c;
							} else if (ab.Product__r.Product_Type__c == Label.ProductTypeD) {
								if (bagsAgrrement.Group_Section__r.Total_Dental_Active_Members__c != null)
									memberCountACAP += bagsAgrrement.Group_Section__r.Total_Dental_Active_Members__c;
							}

						}
						numBaACAP += 1;
					} else if (ab.Funding_Type__c == Label.PREM) {

						for (BA_GS_Assignment__c bagsAgrrement : ab.BA_GS_Assignments__r) {

							if (ab.Product__r.Product_Type__c == Label.ProductTypeM) {
								if (bagsAgrrement.Group_Section__r.Total_Healthcare_Active_Members__c != null)
									memberCountPREM += bagsAgrrement.Group_Section__r.Total_Healthcare_Active_Members__c;
							} else if (ab.Product__r.Product_Type__c == Label.ProductTypeD) {
								if (bagsAgrrement.Group_Section__r.Total_Dental_Active_Members__c != null)
									memberCountPREM += bagsAgrrement.Group_Section__r.Total_Dental_Active_Members__c;
							}

						}
						numBaPREM += 1;
					} else if (ab.Funding_Type__c == Label.ASO) {
						for (BA_GS_Assignment__c bagsAgrrement : ab.BA_GS_Assignments__r) {

							if (ab.Product__r.Product_Type__c == Label.ProductTypeM) {
								if (bagsAgrrement.Group_Section__r.Total_Healthcare_Active_Members__c != null)
									memberCountASO += bagsAgrrement.Group_Section__r.Total_Healthcare_Active_Members__c;
							} else if (ab.Product__r.Product_Type__c == Label.ProductTypeD) {
								if (bagsAgrrement.Group_Section__r.Total_Dental_Active_Members__c != null)
									memberCountASo += bagsAgrrement.Group_Section__r.Total_Dental_Active_Members__c;
							}

						}
						numBaASO += 1;
					} else if (ab.Funding_Type__c == Label.COST) {
						for (BA_GS_Assignment__c bagsAgrrement : ab.BA_GS_Assignments__r) {

							if (ab.Product__r.Product_Type__c == Label.ProductTypeM) {
								if (bagsAgrrement.Group_Section__r.Total_Healthcare_Active_Members__c != null)
									memberCountCOST += bagsAgrrement.Group_Section__r.Total_Healthcare_Active_Members__c;
							} else if (ab.Product__r.Product_Type__c == Label.ProductTypeD) {
								if (bagsAgrrement.Group_Section__r.Total_Dental_Active_Members__c != null)
									memberCountCOST += bagsAgrrement.Group_Section__r.Total_Dental_Active_Members__c;
							}

						}
						numBaCOST += 1;
					} else if (ab.Funding_Type__c == Label.MPP) {
						for (BA_GS_Assignment__c bagsAgrrement : ab.BA_GS_Assignments__r) {

							if (ab.Product__r.Product_Type__c == Label.ProductTypeM) {
								if (bagsAgrrement.Group_Section__r.Total_Healthcare_Active_Members__c != null)
									memberCountMPP += bagsAgrrement.Group_Section__r.Total_Healthcare_Active_Members__c;
							} else if (ab.Product__r.Product_Type__c == Label.ProductTypeD) {
								if (bagsAgrrement.Group_Section__r.Total_Dental_Active_Members__c != null)
									memberCountMPP += bagsAgrrement.Group_Section__r.Total_Dental_Active_Members__c;
							}

						}
						numBaMPP += 1;
					} else if (ab.Funding_Type__c == Label.PAR) {
						for (BA_GS_Assignment__c bagsAgrrement : ab.BA_GS_Assignments__r) {

							if (ab.Product__r.Product_Type__c == Label.ProductTypeM) {
								if (bagsAgrrement.Group_Section__r.Total_Healthcare_Active_Members__c != null)
									memberCountPAR += bagsAgrrement.Group_Section__r.Total_Healthcare_Active_Members__c;
							} else if (ab.Product__r.Product_Type__c == Label.ProductTypeD) {
								if (bagsAgrrement.Group_Section__r.Total_Dental_Active_Members__c != null)
									memberCountPAR += bagsAgrrement.Group_Section__r.Total_Dental_Active_Members__c;
							}

						}
						numBaPAR += 1;
					} else {
						for (BA_GS_Assignment__c bagsAgrrement : ab.BA_GS_Assignments__r) {

							if (ab.Product__r.Product_Type__c == Label.ProductTypeM) {
								if (bagsAgrrement.Group_Section__r.Total_Healthcare_Active_Members__c != null)
									memberCountSERV += bagsAgrrement.Group_Section__r.Total_Healthcare_Active_Members__c;
							} else if (ab.Product__r.Product_Type__c == Label.ProductTypeD) {
								if (bagsAgrrement.Group_Section__r.Total_Dental_Active_Members__c != null)
									memberCountSERV += bagsAgrrement.Group_Section__r.Total_Dental_Active_Members__c;
							}

						}
						numBaSERV += 1;
					}
				}

				for (String f : fundMap.get(b)) {

					currentProd = new CurrentProductsBean();
					currentProd.productFamily = bagr.get(b)[0].Product__r.Family;
					currentProd.productCategory = bagr.get(b)[0].Product__r.Product_Category__c;
					currentProd.productId = bagr.get(b)[0].Product__c;
					currentProd.productName = bagr.get(b)[0].Product__r.Simplified_Product__c;
					currentProd.funding = f;
					currentProd.carrierName = Label.HCSC;
					currentProd.businessType = bagr.get(b)[0].Business_Type__c;

					if (f == Label.ACAP) {
						currentProd.numberOfMembers = memberCountACAP;
					} else if (f == Label.PREM) {
						currentProd.numberOfMembers = memberCountPREM;
					}  else if (f == Label.ASO) {
						currentProd.numberOfMembers = memberCountASO;
					}  else if (f == Label.COST) {
						currentProd.numberOfMembers = memberCountCOST;
					}  else if (f == Label.MPP) {
						currentProd.numberOfMembers = memberCountMPP;
					}  else if (f == Label.PAR) {
						currentProd.numberOfMembers = memberCountPAR;
					}  else {
						currentProd.numberOfMembers = memberCountSERV;
					}

					if (f == Label.ACAP) {
						currentProd.NumberOfBAs = numBaACAP;
					} else if (f == Label.PREM) {
						currentProd.NumberOfBAs = numBaPREM;
					}  else if (f == Label.ASO) {
						currentProd.NumberOfBAs = numBaASO;
					}  else if (f == Label.COST) {
						currentProd.NumberOfBAs = numBaCOST;
					}  else if (f == Label.MPP) {
						currentProd.NumberOfBAs = numBaMPP;
					}  else if (f == Label.PAR) {
						currentProd.NumberOfBAs = numBaPAR;
					}  else {
						currentProd.NumberOfBAs = numBaSERV;
					}
					currentProd.ReportURL = System.label.Benefit_Agreement_Report_Id + '?pv2="' + Account_ID.substring(0, 15) + '"&pv3="' + bagr.get(b)[0].Product__r.Name + '"';
					if (bagr.get(b)[0].Renewal_Date__c != null) {
						currentProd.renewalDate = bagr.get(b)[0].Renewal_Date__c.format();
					}

					for (Opportunity_Product__c oppProd : bagr.get(b)[0].Opportunity_Products__r) {
						if (oppProd.Product__c != bagr.get(b)[0].Product__c) {
							currentProd.numberOfProjectedMembers = Integer.valueOf(oppProd.Projected_Members__c);
							currentProd.associatedOpportunityId = oppProd.Opportunity_Name__c;
							currentProd.associatedOpportunityName = oppProd.Opportunity_Name__r.Name;
						}
					}
					fullProductList.add(currentProd);

				}
			}

			for (Id c : compProdMap.keySet()) {

				currentProd = new CurrentProductsBean();

				currentProd.productFamily = compProdMap.get(c)[0].Product__r.Family;
				currentProd.productCategory = compProdMap.get(c)[0].Product__r.Product_Category__c;
				currentProd.productId = compProdMap.get(c)[0].Product__c;
				currentProd.productName = compProdMap.get(c)[0].Product__r.Simplified_Product__c;
				currentProd.carrierId = compProdMap.get(c)[0].Carrier__r.Competitor_Account__c;
				currentProd.carrierName = compProdMap.get(c)[0].Carrier__r.Competitor_Account__r.Name;
				currentProd.businessType = compProdMap.get(c)[0].Business_Type__c;
				currentProd.numberOfMembers = Integer.valueOf(compProdMap.get(c)[0].Members__c);
				if (compProdMap.get(c)[0].Renewal_Date__c != null) {
					currentProd.renewalDate = compProdMap.get(c)[0].Renewal_Date__c.format();
				}
				fullProductList.add(currentProd);
			}

			currentProductsList = fullProductList;
		} catch (Exception ex) {
			System.debug('#####' + Label.Error + ex.getMessage() + ex.getStackTraceString());
		}
	}

	/********************************************************************
	 * Method Name : populateOtherProducts
	 *   @description :   This method populates the Other HCSC Products Table.  Data fed from BlueStar
	 *   @parameters  :   none
	 *   @return type :   none
	 ***************************************************************/
	private void populateOtherProducts() {
		otherProductsList = new List<OtherProductsBean> ();
		List<Product2> prods = new List<Product2> ();
		additionalInfoList = new List<Account_Product_Information__c> ();
		try {

			prods = [select Id, Name, Product_Category__c, Simplified_Product__c, Family, HCSC_State__c, RecordType.Name,
			         (select Id, Additional_Information__c
			          from Account_Product_Information__r
			          where Account__c = :accountId)
			         from Product2
			         where IsActive = true
			                          AND NotSimple__c = false
			                                  ORDER BY Name
			                                  limit :Limits.getLimitQueryRows() - Limits.getQueryRows()];

			for (Product2 prod : prods) {

				if ((prod.HCSC_State__c == HCSCState && (prod.RecordType.Name == Label.HCSCBlueStar || prod.RecordType.Name == Label.HCSCNonBlueStar)) || (prod.HCSC_State__c == Null && prod.RecordType.Name == Label.HCSCNonBlueStar)) {
					OtherProductsBean otherProd = new OtherProductsBean();
					otherProd.productFamily = prod.Family;
					otherProd.productCategory = prod.Product_Category__c;
					otherProd.productId = prod.Id;
					otherProd.productName = prod.Simplified_Product__c;
					if (prod.Account_Product_Information__r != null && prod.Account_Product_Information__r.size() > 0) {
						otherProd.accoutProductInfo = prod.Account_Product_Information__r[0];
						additionalInfoList.add(prod.Account_Product_Information__r[0]);
					} else {
						Account_Product_Information__c additionalInfo = new Account_Product_Information__c();
						additionalInfo.Account__c = accountId;
						additionalInfo.Product__c = prod.Id;
						additionalInfoList.add(additionalInfo);
					}
					otherProductsList.add(otherProd);
				}
			}
		} catch (Exception ex) {
			System.debug('#####' + Label.Error + ex.getMessage() + ex.getStackTraceString());
		}
	}

	/********************************************************************
	 * Method Name : populateImplementingProducts
	 *   @description :   This method populates the Implementing Products Table.  This table only displays won opportunity products on
	 *					won opportunities that are from a new sale or have an upsell indication that was added on a Renewal Opportunity.
	 *					Also the product will only be shown as long as the related Opportunties effective date is less than today.
	 *
	 *   @parameters  :   none
	 *   @return type :   none
	 *   @developer   :   Nick Serafin/Slalom
	 ***************************************************************/
	private void populateImplementingProducts() {

		impb = new List<ImpProductsBean> ();
		List<Opportunity> opportunity = new List<Opportunity> ();
		TeamMemberMapI = new Map<Id, List<String>> ();
		List<String> teamMembers = new List<String> ();
		try {
			opportunity = [SELECT Id, RecordTypeId, Name,
			               (SELECT Id, Name, Product__c, Product__r.Name, Effective_Date__c, Product__r.Simplified_Product__c, Opportunity_Name__c,
			                Opportunity_Name__r.Name, Account_Product_Name__c, Member_Count__c, Projected_Members__c, Funding_Type__c, Status__c, Upsell__c
			                FROM Opportunity_Products__r WHERE Effective_Date__c > :System.Today() AND Upsell__c != 'None' AND Status__c = :Won),
			               (SELECT User.Name, TeamMemberRole, OpportunityId FROM OpportunityTeamMembers WHERE TeamMemberRole = :client OR TeamMemberRole = :imp)
			               FROM Opportunity WHERE AccountId = :accountId AND(RecordTypeId = :newSaleRecordTypeId OR RecordTypeId = :renewalRecordTypeId OR RecordTypeId = :offcycleRecordTypeId) AND StageName = :Won ORDER BY Id];


			for (Opportunity op : opportunity) {

				for (Opportunity_Product__c prod : op.Opportunity_Products__r) {

					ImpProductsBean imp = new ImpProductsBean();
					imp.oppId = prod.Opportunity_Name__c;
					imp.oppName = prod.Opportunity_Name__r.Name;
					imp.productId = prod.Product__c;
					imp.productName = prod.Product__r.Simplified_Product__c;
					imp.members = Integer.valueOf(prod.Projected_Members__c);
					imp.funding = prod.Funding_Type__c;
					imp.effectiveDate = prod.Effective_Date__c.format();
					impb.add(imp);
				}

				for (OpportunityTeamMember team : op.OpportunityTeamMembers) {
					teamMembers = new List<String> ();
					if (TeamMemberMapI.containsKey(op.Id)) {
						teamMembers = TeamMemberMapI.get(op.Id);
					}

					if (Team.OpportunityId == op.Id) {
						teamMembers.add(team.User.Name + ' - ' + team.TeamMemberRole);
					}
					TeamMemberMapI.put(op.Id, teamMembers);
					ChkMapKeyI = string.valueof(TeamMemberMapI.keyset());
				}

			}



		} catch (Exception e) {
			System.debug('#####' + Label.Error + e.getMessage() + e.getStackTraceString());
		}
	}

	/********************************************************************
	 * Method Name : populateLostProducts
	 *   @description :   This method populates the Implementing Products Table.  This table only displays lost opportunity products on
	 *					won opportunities that are from a new sale or have an upsell indication that was added on a Renewal Opportunity.
	 *   @parameters  :   none
	 *   @return type :   none
	 *   @developer   :   Nick Serafin/Slalom
	 ***************************************************************/
	private void populateLostProducts() {

		lostp = new List<LostProductsBean> ();
		List<Opportunity> opportunity = new List<Opportunity> ();
		TeamMemberMapL = new Map<Id, List<String>> ();
		List<String> teamMembers = new List<String> ();
		try {

			opportunity = [SELECT Id, RecordTypeId, Name,
			               (SELECT Id, Name, Product__c, Product__r.Name, Effective_Date__c, Product__r.Simplified_Product__c, Opportunity_Name__c,
			                Opportunity_Name__r.Name, Account_Product_Name__c, Member_Count__c, Projected_Members__c, Funding_Type__c, Status__c, Upsell__c
			                FROM Opportunity_Products__r WHERE Status__c = :lost),
			               (SELECT User.Name, TeamMemberRole, OpportunityId FROM OpportunityTeamMembers WHERE TeamMemberRole = :client OR TeamMemberRole = :imp)
			               FROM Opportunity WHERE AccountId = :accountId AND(RecordTypeId = :newSaleRecordTypeId OR RecordTypeId = :renewalRecordTypeId OR RecordTypeId = :offcycleRecordTypeId) AND StageName = :Won ORDER BY Id];

			for (Opportunity op : opportunity) {

				for (Opportunity_Product__c prod : op.Opportunity_Products__r) {

					LostProductsBean los = new LostProductsBean();
					los.oppId = prod.Opportunity_Name__c;
					los.oppName = prod.Opportunity_Name__r.Name;
					los.productId = prod.Product__c;
					los.productName = prod.Product__r.Simplified_Product__c;
					los.members = Integer.valueOf(prod.Projected_Members__c);
					los.funding = prod.Funding_Type__c;
					los.effectiveDate = prod.Effective_Date__c.format();
					lostp.add(los);
				}
				for (OpportunityTeamMember team : op.OpportunityTeamMembers) {
					teamMembers = new List<String> ();
					if (TeamMemberMapL.containsKey(op.Id)) {
						teamMembers = TeamMemberMapL.get(op.Id);
					}
					if (Team.OpportunityId == op.Id) {
						teamMembers.add(team.User.Name + ' - ' + team.TeamMemberRole);
					}
					TeamMemberMapL.put(op.Id, teamMembers);
					ChkMapKeyL = string.valueof(TeamMemberMapL.keyset());
				}



			}

		} catch (Exception e) {
			System.debug('#####' + Label.Error + e.getMessage() + e.getStackTraceString());
		}

	}



	/********************************************************************
	 * Method Name : saveAdditionalInformation
	 *   @description :   This method allow the user to save information on the Other HCSC Products table that was inserted with inline editing.
	 *   @parameters  :   none
	 *   @return type :   PageReference
	 ***************************************************************/
	public PageReference saveAdditionalInformation() {
		try {
			upsert additionalInfoList;
			populateOtherProducts();
		} catch (Exception e) {
			CreateExceptionLog.insertErrorLog(e, null, null, null, 'Apex Class', 'Product Landscape', null, 'ProductLandscapeController.saveAdditionalInformation()', 'High');
		}
		return null;
	}

	/********************************************************************
	 * Method Name : cancelAdditionalInformation
	 *   @description :   This method cancels any unsaved inline editing of the Additional Information in the Other HCSC Products table
	 *   @parameters  :   none
	 *   @return type :   PageReference
	 ***************************************************************/
	public PageReference cancelAdditionalInformation() {

		populateOtherProducts();
		return null;
	}

	/**************************************************************************************
	  Apex Class Name     : ActivelyPurchasingProductsBean
	  Version             : 1.0
	  Function            : This class holds the values that were set in populateActivelyPurchasingProducts()

	 *************************************************************************************/
	public class ActivelyPurchasingProductsBean {
		public String productFamily { get; set; }
		public String productCategory { get; set; }
		public String productId { get; set; }
		public String productName { get; set; }
		public String funding { get; set; }
		public Integer numberOfCompetitors { get; set; }
		public String businessType { get; set; }
		public String dueDate { get; set; }
		public Integer numberOfProjectedMembers { get; set; }
		public String associatedOpportunityName { get; set; }
		public String associatedOpportunityId { get; set; }
		public String opportunityProductName { get; set; }
	}

	/**************************************************************************************
	  Apex Class Name     : CurrentProductsBean
	  Version             : 1.0
	  Function            : This class holds the values that were set in populateCurrentProducts()

	 *************************************************************************************/
	public class CurrentProductsBean {
		public String productFamily { get; set; }
		public String productCategory { get; set; }
		public String productId { get; set; }
		public String productName { get; set; }
		public String funding { get; set; }
		public String carrierId { get; set; }
		public String simpProdId { get; set; }
		public String simpProdName { get; set; }
		public String carrierName { get; set; }
		public String businessType { get; set; }
		public String renewalDate { get; set; }
		public Decimal numberOfMembers { get; set; }
		public Integer numberOfProjectedMembers { get; set; }
		public Id associatedOpportunityId { get; set; }
		public String associatedOpportunityName { get; set; }
		public Decimal NumberOfBAs { get; set; }
		public String ReportURL { get; set; }
	}

	/**************************************************************************************
	  Apex Class Name     : OtherProductsBean
	  Version             : 1.0
	  Function            : This class holds the values that were set in populateOtherProducts()

	 *************************************************************************************/
	public class OtherProductsBean {
		public String productFamily { get; set; }
		public String productCategory { get; set; }
		public String productId { get; set; }
		public String productName { get; set; }
		public Account_Product_Information__c accoutProductInfo { get; set; }
	}
	/**************************************************************************************
	  Apex Class Name     : ImpProductsBean
	  Version             : 1.0
	  Function            : This class holds the values that were set in populateImplementingProducts()

	 *************************************************************************************/
	public class ImpProductsBean {
		public Id productId { get; set; }
		public String productName { get; set; }
		public Id oppId { get; set; }
		public String oppName { get; set; }
		public Integer members { get; set; }
		public String funding { get; set; }
		public String teamMember { get; set; }
		public String role { get; set; }
		public String effectiveDate { get; set; }

	}
	/**************************************************************************************
	  Apex Class Name     : OtherProductsBean
	  Version             : 1.0
	  Function            : This class holds the values that were set in populateLostProducts()

	 *************************************************************************************/
	public class LostProductsBean {
		public Id productId { get; set; }
		public String productName { get; set; }
		public Id oppId { get; set; }
		public String oppName { get; set; }
		public Integer members { get; set; }
		public String funding { get; set; }
		public String teamMember { get; set; }
		public String role { get; set; }
		public String effectiveDate { get; set; }

	}

}