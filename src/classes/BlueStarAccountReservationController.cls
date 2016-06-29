/**************************************************************************************
  Apex Class Name     : BlueStarAccountReservationController
  Version             : 1.0
  Function            : This is a controller class for handling the blus star Account Reservation functionality
  Modification Log    :

*************************************************************************************/
public with sharing class BlueStarAccountReservationController{


    public List<ProductgroupNumberWrapper> ProdGrpWrapperList {get;set;}
    public  String CBSRInsertXML;
    public  String UserName;
    public  String Password;
    public  string Endpoint;
    public Id accountid {get; set;}
    public String Hcsc_division {get;set;}
    Map<String,String> ProductPrefix ;
    public boolean ShowPopup {get;set;}
    public boolean NoTable {get;set;}
    public boolean DiplayError {get; set;}
    public boolean hasEditAccess{get;set;}
    
    public BlueStarAccountReservationController(ApexPages.StandardController controller) {
        if(!Test.isRunningTest()){
            controller.addFields(new List<String>{'Id','HCSC_Division__c','Time_Sent__c','External_Id__c','Integration_Status__c','Effective_Date__c'});   
        }             
       try{
        Account accountRecord=(Account)controller.getRecord(); 
        UserRecordAccess userAccess = [SELECT RecordId, HasEditAccess FROM UserRecordAccess WHERE UserId = :UserInfo.getUserId() AND RecordId = :accountRecord.Id limit 1][0];
        if(userAccess.HasEditAccess){
            hasEditAccess = true;
            Hcsc_division = accountRecord.HCSC_Division__c;
            String TimeSentGap = system.label.Integration_Time_out;
            accountid = accountRecord.Id;
            if((accountRecord.Time_Sent__c == Null || (DateTime.now().getTime() - accountRecord.Time_Sent__c.getTime() > Integer.valueOf(TimeSentGap)*60*1000 && accountRecord.Integration_Status__c == 'Sent') || accountRecord.Integration_Status__c == 'Failure') && accountRecord.External_Id__c==NULL && accountRecord.Effective_Date__c!=null){
                ProductPrefix = new Map<String,String>();
                ShowPopup = false;
                NoTable= false;
                DiplayError = false;
                ProdGrpWrapperList = new List<ProductgroupNumberWrapper>();
                DisplayProdGrpWrapperList();
            }else{
                DiplayError = true;
                if(accountRecord.Time_Sent__c!=NULL && (DateTime.now().getTime() - accountRecord.Time_Sent__c.getTime() < Integer.valueOf(TimeSentGap)*60*1000) && accountRecord.External_Id__c==NULL && accountRecord.Integration_Status__c == 'Sent')
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,system.label.BlueStar_Time_Error_Message));
                else  if(accountRecord.External_Id__c!=NULL)
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,system.label.BlueStarAccountReservationMsg8));
                else  if(accountRecord.Effective_Date__c==NULL)
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,system.label.BlueStarAccountReservationMsg9));   
            }
        }else{
            DiplayError = true;
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, system.label.InsufficientError));     
        }
      }catch(Exception e){
           ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Unexpected error occured. Please contact system administrator '));
      }  
    }
    
    public void DisplayProdGrpWrapperList(){
        try{
         Map<String,Blue_star_Account_Products__c> mapStatus = Blue_star_Account_Products__c.getAll();
         List<String> OrderedList = new List<String>();
         OrderedList.addAll(mapStatus.keyset());
         OrderedList.sort();
         for(String order : OrderedList){             
           // Wrapper list to display on VF 
             ProdGrpWrapperList.add(new ProductgroupNumberWrapper('00', mapStatus.get(order).Product_Name__c, mapStatus.get(order).Prefix__c,mapStatus.get(order).Display_Prefix__c));               
          //Map of Productname and its prefix   
             ProductPrefix.put(mapStatus.get(order).Product_Name__c , mapStatus.get(order).Prefix__c);
         }
         }catch(Exception e){
            ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.Info,e.getMessage());
            ApexPages.addMessage(errMsg);
         }
    }
    
    public void SetShowPopup(){
        Integer CountOfNumbers=0;
        Boolean flag=false; 
        String CountLimit = system.label.BlueStar_Total_Count_Limit;
        for(ProductgroupNumberWrapper pnw :ProdGrpWrapperList){
            if(pnw.selected != '00' ){
                flag = true;
                NoTable = true;
                CountOfNumbers += Integer.valueOf(pnw.selected);
            }
        }
        if(CountOfNumbers > Integer.valueOf(CountLimit)){ 
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, system.label.BlueStar_Count_Limit_Error_Message + ' ' + system.label.BlueStar_Total_Count_Limit));
            ShowPopup = false;
        }else{
            ShowPopup = true;
        }
    }
    
    public void ClosePopUp(){
        ShowPopup = false;
        NoTable= false;
    }
    public void ReserveAcctCallout(){
        String Body=''; 
        List<String> fieldAPInames = new List<String>();
        String Query ;
        Map<String , String > PrefixgroupNo = new Map<String , String >();
        Map<String,Username_Password__c> mapUSerPass  = Username_Password__c.getAll();
        try{    
        for(String cs : mapUSerPass.keyset()){
            if(mapUSerPass.get(cs).name == system.label.BlueStarModule){
               UserName=mapUSerPass.get(cs).UserName__c;
                Password=mapUSerPass.get(cs).Password__c;
                Endpoint=mapUSerPass.get(cs).EndPoinUrl__c;
            }    
        } 
       
        //Create a Map of selected froup no and product Prefix as key
         for(ProductgroupNumberWrapper prdpref : ProdGrpWrapperList ){
             if(ProductPrefix.get(prdpref.entry)!=null )
                 if(PrefixgroupNo.get(ProductPrefix.get(prdpref.entry))==null)
                     PrefixgroupNo.put(ProductPrefix.get(prdpref.entry), prdpref.selected);
                 else{
                     Integer sum = Integer.valueof(PrefixgroupNo.get(ProductPrefix.get(prdpref.entry)) ) + Integer.valueof(prdpref.selected) ;
                     PrefixgroupNo.put(ProductPrefix.get(prdpref.entry), String.valueOf(sum) );
                 }                 
         }
        // get list of Accunt fields from custom setting
        Map<String,BLue_star_callout_fields__c> BLue_star_callout_fields = BLue_star_callout_fields__c.getAll();
        for(String cs : BLue_star_callout_fields.keyset()){
            fieldAPInames.add(BLue_star_callout_fields.get(cs).Account_API_Name__c);             
        } 
                
        Query = 'select ';         
        for(String api : fieldAPInames){                 
                 Query = Query+ api + ',' ;                                    
        }             
        Query = Query.removeEnd(',');
        Query = Query+' from Account where id = \''+accountid+'\'';
        List<Account> accounts = (List<Account>)Database.query(Query);
        accounts[0].Integration_Status__c = 'Sent';
        accounts[0].Time_Sent__c = system.now();
        accounts[0].Integration_Action__c = 'Create';
        List<Database.SaveResult> Results = Database.update(accounts); 
        CreateExceptionLog.insertErrorLog(null,Results,null,accounts,'Apex Class','Account','','BlueStarAccountReservationController','High');
        
        Body = null;           
        body='<sObject xsi:type="sf:Account" xmlns:sf="urn:sobject.enterprise.soap.sforce.com">' ; 
        for(String api : fieldAPInames){   
             if(accounts[0].get(api)!=null  && ( accounts[0].get(api) instanceof String)  )
                Body=Body+ '<sf:'+ api +'>'+ ((String)accounts[0].get(api)).escapeXml() +'</sf:'+ api +'>';  
            else  if(accounts[0].get(api)==null  )
                Body=Body+ '<sf:'+ api +'>'+ '' +'</sf:'+ api +'>'; 
            else 
                Body=Body+ '<sf:'+ api +'>'+ accounts[0].get(api) +'</sf:'+ api +'>';          
        }
        
        for(String pref : PrefixgroupNo.keyset()){
            Body=Body+ '<sf:'+ pref+'>'+ PrefixgroupNo.get(pref) +'</sf:'+ pref+'>'; 
        }
          
        Body=Body+'</sObject>';          
        //helper method to which invokes webservice callout
        if(!Test.isRunningTest() && ConstantsController.shouldCBSRCalloutProcess){
            CalloutHelperclass.SendCalloutsToCBSR(Body ,UserName ,Password ,Endpoint); 
            ConstantsController.shouldCBSRCalloutProcess = false;
        }
        }catch(Exception ex){
            CreateExceptionLog.insertErrorLog(ex, null, null, null, 'Apex Class', 'Account', null, 'BlueStarAccountReservationController.ReserveAcctCallout()','High'); 
        }
      
    }
    
    public class ProductgroupNumberWrapper{
        public String  Selected          {get;set;}
        public String  entry             {get;set;}
        public String  Prefix            {get;set;}
        public String  DisplayPrefix     {get;set;}
        public ProductgroupNumberWrapper(String SelectedIn, String entryIn ,String PrefixIn ,String DisplayPrefixIn){
            Selected      = SelectedIn;
            entry         = entryIn;
            Prefix        = PrefixIn;
            DisplayPrefix = DisplayPrefixIn;
        }
        public list<SelectOption> getGroupNos(){
             list<SelectOption> options = new list<SelectOption>();
             Integer x = Integer.valueof(Label.Bluestar_Group_Number_Limit);
             for(Integer i=0;i<x;i++){
                 if(i<10)
                     options.add(new SelectOption('0'+i,'0'+i));
                 else
                     options.add(new SelectOption(''+i,''+i));    
             }
             //options.add(new SelectOption('10','10'));
             //options.add(new SelectOption('11','11'));
             return options;
       }    
    
    }
    
}