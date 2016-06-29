/**************************************************************************************
  Apex Class Name     : BenefitAgreementTriggerHandler  
  Version             : 1.0
  Function            : This is a handler class for BenefitAgreementTrigger.
  Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------
*   Jermaine Lindsay       03/08/2016                Original Version
*************************************************************************************/

public class BenefitAgreementTriggerHandler{

    /*  updateAccountFundingType
    *   @description:   This method checks if the account record is of record type Producer Account and its type is Sub Producer. It inserts/updates the producer contact record
    *                   This method is used for the after insert scenario.
    *   @parameters     Id <Account> newAccounts : accounts under current context.
    *   @return type    void
    */
    public static void updateAccountFundingType(List <Benefit_Agreement__c> processedBAList) {

        Id accountId;
        List<Benefit_Agreement__c> BAList;
        Set<String> setFundingTypes; 
        String stringFundingTypes;
        Set<Id> targetAcctIds = new Set<Id>();
        List<Account> targetAccounts;
        
        try{
            //Get list of accounts ids to update
            for(Benefit_Agreement__c ba : processedBAList){
                targetAcctIds.add(ba.Group_Account__c);
            }
            
            //Get list of accounts to update
            targetAccounts = [SELECT Id, Funding_Type__c from Account where Id in : targetAcctIds];

            //Get list of Benefit Agreements for the target accounts to update
            BAList = [SELECT Id, Group_Account__r.Id, Funding_Type__c from Benefit_Agreement__c where Group_Account__c in : targetAcctIds];

            //Get Current Funding Type list from Group Account
            for(Account account : targetAccounts){
                setFundingTypes = new Set<String>();
                stringFundingTypes = '';
                for(Benefit_Agreement__c ba : BAList){
                    if(ba.Group_Account__r.id == account.Id && ba.Funding_Type__c != null)
                        setFundingTypes.add(ba.Funding_Type__c);
                }

                for(String ft:setFundingTypes) {
                    stringFundingTypes += (stringFundingTypes==''?'':';')+ft;
                }

                account.Funding_Type__c = stringFundingTypes;
                update account; 
            }

        } catch (Exception ex){
            CreateExceptionLog.insertErrorLog(ex, null, null, null, 'Apex Class', 'Benefit Agreement', 'BenefitAgreementTrigger', 'BenefitAgreementTriggerHandler.updateAccountFundingType()', 'High');
        } 
    }

    /*  createProducerContact
    *   @description:   This method checks if the account record is of record type Producer Account and its type is Sub Producer. It inserts/updates the producer contact record
                        This method is used for the after updates scenario.
    *   @parameters     List<Account> newAccounts : new accounts under current context.
    *                   List<Account> oldAccounts : old accounts under current context.
    *   @return type    void
    */
    public static void setBenefitAgreementRecType( List<Benefit_Agreement__c> baList ) {
        try{
            Set<Id> ProdIdSet = new Set<Id>();
            for(Benefit_Agreement__c ba : baList){
                ProdIdSet.add(ba.Product__c);
            }    
            Map<Id,Product2> productMap = new Map<Id,Product2>([Select id, RecordType.Name FROM Product2 Where Id In: ProdIdSet]);
            Id BlueStarRecordType = Schema.SObjectType.Benefit_Agreement__c.getRecordTypeInfosByName().get('BlueStar').getRecordTypeId();
            Id NonBluestarRecordType = Schema.SObjectType.Benefit_Agreement__c.getRecordTypeInfosByName().get('Non BlueStar').getRecordTypeId();
            for(Benefit_Agreement__c ba : baList){
                if(productMap.keySet().contains(ba.Product__c)){
                    if(productMap.get(ba.Product__c).RecordType.Name == 'HCSC Non BlueStar Product'){
                        ba.RecordTypeId = NonBluestarRecordType;
                    }else{
                        ba.RecordTypeId = BluestarRecordType;
                    }
                }
            }
        }catch (Exception ex){
            for ( Benefit_Agreement__c ba : baList ) {
                ba.addError( Label.AnErrorHasOcurred + ' : ' + ex.getMessage() );
            }
            CreateExceptionLog.insertErrorLog(ex, null, null, null, 'Apex Class', 'Benefit Agreement', 'BenefitAgreementTrigger', 'BenefitAgreementTriggerHandler.updateAccountFundingType()', 'High');
        }
    }
}