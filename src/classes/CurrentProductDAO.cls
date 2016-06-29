public class CurrentProductDAO implements ICurrentProductDAO {
	public interface ICurrentProductDAO {
		List<Current_Product__c> insertCurrentProducts(List<Current_Product__c> currentProducts);
		void deleteAllCurrentProducts(List<Current_Product__c> currentProducts);
	}

	public List<Current_Product__c> insertCurrentProducts(List<Current_Product__c> currentProducts) {
		insert currentProducts;
		return currentProducts;
	}

	public void deleteAllCurrentProducts(List<Current_Product__c> currentProducts) {
		delete currentProducts;
	}
}