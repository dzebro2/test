public class AccountDAO implements IAccountDAO
{
    public interface IAccountDAO{
        List<Account> getAccountsForProduct360(Id userId, Set<Id> accountIds);
    }

    public List<Account> getAccountsForProduct360(Id userId, Set<Id> accountIds){
        return [SELECT Id, Name, (Select Id, Requested_Effective_Date__c, Name, RecordType.Name, HCSC_Division__c, Expected_Health_Members__c, Expected_Health_Contracts__c, Expected_Dental_Members__c, Expected_Dental_Contracts__c From Opportunities) FROM Account WHERE (Id IN :accountIds OR OwnerId = :userId) AND Id in (Select AccountId from Opportunity)];
    }
    //hello
}