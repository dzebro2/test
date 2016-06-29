/**************************************************************************************
  Apex Class Name     : RFPLargeGroupRequestExtension
  Version             : 1.0
  Function            : This is a controller  class for Recording the carrier history of cases Underwriting requirement
  Modification Log    :

*************************************************************************************/
public with sharing class RFPLargeGroupRequestExtension {
    public list<Competitor_Relationship__c> carrierHistories{get;set;}
    public Case caseObj{get;set;}
    private string caseObjId;
    public boolean showEditMode{get;set;}
    public list<CarrierHistoryWrapper> carrierHistoryList{get;set;}
    private Integer recordCount;
    public Integer rowToRemove{get;set;}
    public boolean showPage{get;set;}
    public boolean notInsuredValue{get;set;}
    private RecordType rt;
    public RFPLargeGroupRequestExtension(ApexPages.StandardController controller){
        try{
            caseObj = (Case)controller.getRecord();
            showPage = true;
            createData();
            UserRecordAccess ru = [ SELECT RecordId, HasEditAccess FROM UserRecordAccess WHERE UserId = :UserInfo.getUserId() AND RecordId = :caseObj.Id];
            showEditMode = ru.HasEditAccess;
        }catch(Exception e){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage());
            ApexPages.addMessage(myMsg);
        }
    }
    
    public void RemoveRow(){
        try{
            list<CarrierHistoryWrapper> tempList = new list<CarrierHistoryWrapper>();
            Competitor_Relationship__c deleteRecord;
            for(CarrierHistoryWrapper chw : carrierHistoryList){
                if(chw.recordNumber != rowToRemove){
                    tempList.add(chw);
                }
                else if(chw.carrierHistory.Id != null)
                    deleteRecord = chw.carrierHistory;
            }
            carrierHistoryList = new list<CarrierHistoryWrapper>();
            carrierHistoryList.addAll(tempList);
            if(deleteRecord != null)
                delete deleteRecord;
        }catch(Exception e){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage());
            ApexPages.addMessage(myMsg);
        }
    }
    
    private void CreateData(){
        try{
            recordCount = 0;
            carrierHistories = new list<Competitor_Relationship__c>();
            carrierHistoryList = new list<CarrierHistoryWrapper>();
            caseObj = [select Id,Prior_HCSC_Coverage__c,AccountId,Prior_HCSC_Account_Number__c from Case where Id =:caseObj.Id limit 1][0];
            if(caseObj.AccountId != null){
                rt = [select Id from RecordType where DeveloperName = 'Carrier' and SobjectType='Competitor_Relationship__c' limit 1][0];
                for(Competitor_Relationship__c cr : [select AFA__c,Dental__c,Group_Account__c,Rate_Effective_Date__c,Contract_End_Date__c,Not_Insured__c,Competitor_Account__c,Reinsurer__c from 
                                                        Competitor_Relationship__c where Group_Account__c = :caseObj.AccountId and RecordTypeId =:rt.Id]){
                        carrierHistoryList.add(new CarrierHistoryWrapper(cr,true,recordCount));
                        ++recordCount;                              
                }
                
                /*if(carrierHistoryList.size()==0){
                    carrierHistoryList.add(new CarrierHistoryWrapper(new Competitor_Relationship__c(RecordTypeId = rt.Id,Group_Account__c = caseObj.AccountId,status__c='Active'),false,recordCount));
                    ++recordCount;
                }*/
                for(integer i =recordCount;i<5;i++){
                    carrierHistoryList.add(new CarrierHistoryWrapper(new Competitor_Relationship__c(RecordTypeId = rt.Id,Group_Account__c = caseObj.AccountId,status__c='Active'),false,recordCount));
                    ++recordCount;
                }
            }
            else
                showPage = false;
        }catch(Exception e){
            throw e;
        }
    }
    
    public void AddRow()
    {
        carrierHistoryList.add(new CarrierHistoryWrapper(new Competitor_Relationship__c(RecordTypeId = rt.Id,Group_Account__c = caseObj.AccountId,status__c='Active'),false,recordCount));
        ++recordCount;
    }
    
    public PageReference SaveRecords(){
        try{
            carrierHistories = new list<Competitor_Relationship__c>();
            for(CarrierHistoryWrapper chw : carrierHistoryList){
                carrierHistories.add(chw.carrierHistory);
            }
            upsert carrierHistories;
           
            PageReference pg =  new PageReference('/'+caseObj.Id);
            pg.setRedirect(true);
            return pg;
        }catch(Exception e){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage());
            ApexPages.addMessage(myMsg);
            return null;
        }
    }
    public void DummyMethod(){
        try{
            for(CarrierHistoryWrapper chw : carrierHistoryList){
                if(chw.recordNumber == rowToRemove){
                    chw.carrierHistory.Not_Insured__c = notInsuredValue;
                }
               
            }
        }catch(Exception e){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage());
            ApexPages.addMessage(myMsg);
        }
    }
    public PageReference CancelRecord(){
        try{
            PageReference pg =  new PageReference('/'+caseObj.Id);
            pg.setRedirect(true);
            return pg;
        }catch(Exception e){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage());
            ApexPages.addMessage(myMsg);
            return null;
        }
    }
    
    public Class CarrierHistoryWrapper{
        public Competitor_Relationship__c carrierHistory{get;set;}
        public boolean isSelected{get;set;}
        public integer recordNumber{get;set;}
        public CarrierHistoryWrapper(Competitor_Relationship__c ch , boolean selected,Integer recNo){
            carrierHistory = ch;
            isSelected = selected;
            recordNumber = recNo;
        }
    }
}