public class CreateProspectPageController{
    Id ProspectAccountRId;
    Id AccountID;
    String CancellationStatus;

    public CreateProspectPageController(){
        AccountID = ApexPages.currentPage().getParameters().get('id');
        CancellationStatus = ApexPages.currentPage().getParameters().get('CancelStatus');
        ProspectAccountRId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
    }
    
    public PageReference returnMethod(){
        if(CancellationStatus == 'Cancelled'){
            pageReference pg = new pageReference('/' + AccountId + '/e?clone=1&RecordType=' + ProspectAccountRId + '&' + system.label.Account_Number_ID + '=&' + system.label.Account_Effective_Date_ID + '=&' + system.label.Account_Reserved_Group_Number_ID + '=&' + system.label.Account_Out_of_Business_ID + '=&retURL=' + AccountId ); 
            return pg;
        }else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Group Account is not Cancelled. Prospect cannot be created.'));
            return null;
        }
    }
}