public with sharing class ProductDAO implements IProductDAO {

	public interface IProductDAO {
		List<Product2> getSimpleProducts(String HCSCDivison, List<String> prodNames);
	}

	public List<Product2> getSimpleProducts(String HCSCDivison, List<String> prodNames) {
		return [SELECT Id, Name FROM Product2 WHERE NotSimple__c = false AND Name IN :prodNames AND HCSC_State__c = :HCSCDivison];
	}
}