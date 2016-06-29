@isTest(SeeAllData = false)
private class BenefitAgreementDAOTest {

	@isTest
	static void benefitAgreementDAOTest() {
		Test.StartTest();

		List<Account> accountList = new List<Account>();
		BenefitAgreementDAO.IBenefitAgreementDAO benefitAgreementDAOInstance = new BenefitAgreementDAO();

		Account testAcnt = TestClassUtiltity.CreateAccountRecord('TestAccount');
		accountList.add(testAcnt);
		Benefit_Agreement__c testBnftAgrmnt = new Benefit_Agreement__c(Group_Account__c = testAcnt.Id, Funding_Type__c = 'PREM', EffectivE_Date__c = (System.today() - 1), Status__c = 'Active');
		insert testBnftAgrmnt;
		List<Benefit_Agreement__c> bnftAgrmnts = benefitAgreementDAOInstance.getGroupAccountBenefitAgreements( accountList );

		System.assertEquals( bnftAgrmnts.size(), 1);

		Set<Id> accIds = new Set<Id>();
		accIds.add(testAcnt.Id);
		List<Benefit_Agreement__c> batchBAs = benefitAgreementDAOInstance.getBatchBenefitAgreements(accIds);
		Test.StopTest();
	}
}