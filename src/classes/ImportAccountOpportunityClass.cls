public without sharing class ImportAccountOpportunityClass{
    public List<sObject> AccountRecordList {get; set;}
    public List<sObject> OpportunityRecordList {get; set;}
    public List<DisplayWrapper> DisplayWrapperList;
    public String Type {get; set;}
    public Account testRec {get; set;}
    public Set<Id> UserContactIdSet;
    public Opportunity currentOpportunity {get; set;}
    public sObject CurrentObject {get; set;}
    public Id CurrentObjectId {get; set;}
    public String CurrentObjectName {get; set;}
    public List<String> AccountDisplayFields {get; set;}
    public List<String> AccountRelFields {get; set;} //need to be removed
    public String objectLabel {get; set;}
    public Map<String,String> TypeFieldMap {get; set;}
    public Map<String,String> AccountFieldMap = new Map<String,String>();
    public String AccountIdCompareFieldName;
    public String OpportunityIdCompareFieldName;
    public Schema.SObjectType OpportunityRelSObject;
    public sObject AccountRelObject {get; set;}
    public List<String> AccountObjectFieldLabels {get; set;}
    public Map<String,Boolean> InputOutputFieldMap {get; set;} 
    public Map<Id,sObject> CompareIdRelatedObjectMap {get; set;}
    public Set<String> InputFieldSet {get; set;}
    public String sObjectParentField;
    public Boolean DisplayMessageFlag {get; set;}
    public Map<String, String> AccountRelQueryClauseMap;
    public Map<String, String> CurrentObjectRelQueryClauseMap;
    public Map<String, String> ObjectFieldValueMap;
    public String ParentRecordAccessForUser;
    
    public void setDisplayWrapperList(List<DisplayWrapper> DisplayWrapperListSet){
        DisplayWrapperList = DisplayWrapperListSet;
    }

    public List<DisplayWrapper> getDisplayWrapperList(){
    
        try{
            DisplayMessageFlag = false;
            system.debug('$$$$  Type  ' + Type  + ' CurrentObjectId ' + CurrentObjectId + ' CurrentObjectName ' +CurrentObjectName );
            DisplayWrapperList = new List<DisplayWrapper>();
            List<ObjectFieldSet__c> ObjectFieldList = ObjectFieldSet__c.getAll().values();
            TypeFieldMap = new Map<String,String>();
            String CurrentObjectQuery = 'SELECT ';
            for(ObjectFieldSet__c Field : ObjectFieldList){
                if(Field.ObjectName__c == CurrentObjectName){
                    CurrentObjectQuery += Field.FieldName__c + ', ';
                    if(Field.Type__c != null || Field.Type__c != '')
                        TypeFieldMap.put(Field.Type__c,Field.FieldName__c);
                }
            }
            CurrentObjectQuery = CurrentObjectQuery.substring(0,CurrentObjectQuery.length()-2);
            CurrentObjectQuery += ' FROM ' + CurrentObjectName + ' WHERE Id =\'' + CurrentObjectId + '\'';
            CurrentObject = database.query(CurrentObjectQuery);
            UserContactIdSet = new Set<Id>();
            
            AccountRelFields = new List<String>();
            List<String> OpportunityRelFields = new List<String>();
            AccountObjectFieldLabels = new List<String>();
            AccountDisplayFields = new List<String>();
            InputOutputFieldMap = new Map<String,Boolean>();
            CompareIdRelatedObjectMap = new Map<Id,sObject>();
            InputFieldSet = new Set<String>();
            AccountRelQueryClauseMap = new Map<String, String>();
            CurrentObjectRelQueryClauseMap = new Map<String, String>();
            AccountFieldMap = new Map<String,String>();
            ObjectFieldValueMap = new Map<String,String>();
            String AccountRelObjectName;
            String OpportunityRelObjectName;
            String AccountConditionFieldName;
            String OpportunityConditionFieldName;
            List<AccountFieldMapping__c> AccountFieldMappings = AccountFieldMapping__c.getAll().values();
            for(AccountFieldMapping__c rec : AccountFieldMappings){
                if(rec.Type__c == Type){
                    AccountFieldMap.put(rec.AccountField__c,rec.ObjectFieldName__c);
                }
            }
            List<ImportOpptyFields__c> CustomSettingFields = ImportOpptyFields__c.getAll().values();
            List<AccountOpportunityObjectRelations__c> AccountOpptyObjectRelation = AccountOpportunityObjectRelations__c.getAll().values();
            for(AccountOpportunityObjectRelations__c rec : AccountOpptyObjectRelation){
                if(rec.Type__c == Type){
                    if(rec.ObjectRelation__c == 'Account'){
                        AccountRelObjectName = rec.ObjectAPIName__c;
                    }else if(rec.ObjectRelation__c == 'Opportunity'){
                        OpportunityRelObjectName = rec.ObjectAPIName__c;
                    }
                    if(rec.AccessToParentRecord__c != ''){
                        ParentRecordAccessForUser = rec.AccessToParentRecord__c;
                    }
                }
            }
            Schema.SObjectType AccountRelSObject = Schema.getGlobalDescribe().get(AccountRelObjectName);
            AccountRelObject = AccountRelSObject.newSObject();
            OpportunityRelSObject = Schema.getGlobalDescribe().get(OpportunityRelObjectName);
            for(ImportOpptyFields__c rec : CustomSettingFields){
                if(rec.Type__c == Type){
                    if(rec.ObjectName__c == AccountRelObjectName){
                        AccountRelFields.add(rec.FieldName__c);
                        if(rec.ConditionField__c == true){
                            AccountConditionFieldName = rec.FieldName__c;
                        }
                        if(rec.IdCompareField__c == true){
                            AccountIdCompareFieldName = rec.FieldName__c;
                        }
                        if(rec.DisplayField__c == true){
                            AccountDisplayFields.add(rec.FieldName__c);
                        }
                        if(rec.IsInputField__c == true){
                            InputOutputFieldMap.put(rec.FieldName__c,true); 
                            InputFieldSet.add(rec.FieldName__c);
                        }else{
                            InputOutputFieldMap.put(rec.FieldName__c,false);
                        }
                        if(rec.InQueryCondition__c == true ){
                            AccountRelQueryClauseMap.put(rec.FieldName__c, rec.Value__c);
                        }
                    }else if(rec.ObjectName__c == OpportunityRelObjectName){
                        OpportunityRelFields.add(rec.FieldName__c);
                        if(rec.ConditionField__c == true){
                            OpportunityConditionFieldName = rec.FieldName__c;
                        }
                        if(rec.IdCompareField__c == true){
                            OpportunityIdCompareFieldName = rec.FieldName__c;
                        }
                        if(rec.ParentField__c == true){
                            sObjectParentField = rec.FieldName__c;
                        }
                        if(rec.InQueryCondition__c == true){
                            CurrentObjectRelQueryClauseMap.put(rec.FieldName__c, rec.Value__c);
                        }
                        if(rec.SetValueWhileInsert__c == true){
                            if(rec.Value__c != ''){
                                ObjectFieldValueMap.put(rec.FieldName__c, rec.Value__c);
                            }
                        }
                    }
                }
            }
            for(String FieldName : AccountDisplayFields){
                AccountObjectFieldLabels.add(Schema.getGlobalDescribe().get(AccountRelObjectName).getDescribe().fields.getMap().get(FieldName).getDescribe().getLabel());
            }
            List<Schema.DescribeSObjectResult> describeSobjectsResult = Schema.describeSObjects(new List<String>{AccountRelObjectName});
            objectLabel = describeSobjectsResult[0].getLabel();
            String AccountQueryString = 'SELECT ';
            for(String Field : AccountRelFields){
                AccountQueryString += Field + ', ';
            }
            AccountQueryString = AccountQueryString.substring(0,AccountQueryString.length()-2);
            AccountQueryString += ' FROM ' + AccountRelObjectName;
            //AccountQueryString += ' WHERE ' + AccountConditionFieldName + ' = ' + '\'' + currentOpportunity.AccountId + '\'';
            Id AccountId = Id.valueOf(String.valueOf(currentObject.get(TypeFieldMap.get('AccountId'))));
            AccountQueryString += ' WHERE ' + AccountConditionFieldName + ' = \'' + AccountId + '\' ';
            if(AccountRelQueryClauseMap.size() > 0){
                for(String Field : AccountRelQueryClauseMap.keySet()){
                    AccountQueryString += 'AND ' + Field + ' = \'' + AccountRelQueryClauseMap.get(Field) + '\' ';
                }
            }
            String currentObjectQueryString = 'SELECT ';
            for(String Field : OpportunityRelFields){
                currentObjectQueryString += Field + ', ';
            }
            currentObjectQueryString = currentObjectQueryString.substring(0,currentObjectQueryString.length()-2);
            currentObjectQueryString += ' FROM ' + OpportunityRelObjectName;
            currentObjectQueryString += ' WHERE ' + OpportunityConditionFieldName + ' = \'' + CurrentObjectId + '\'';
            if(CurrentObjectRelQueryClauseMap.size() > 0){
                for(String Field : CurrentObjectRelQueryClauseMap.keySet()){
                    currentObjectQueryString += 'AND ' + Field + ' = \'' + CurrentObjectRelQueryClauseMap.get(Field) + '\' ';
                }
            }
            system.debug('#### currentObjectQueryString ' + currentObjectQueryString);
            system.debug('#### AccountQueryString ' + AccountQueryString);
            AccountRecordList = database.query(AccountQueryString);
            OpportunityRecordList = database.query(currentObjectQueryString);
            //sObject OpportunityRelObject = OpportunityRelSObject.newSObject();
            if(OpportunityRecordList != null && OpportunityRecordList.size() > 0){
                for(sObject rec : OpportunityRecordList){
                    system.debug('########## OpportunityIdCompareFieldName ' + OpportunityIdCompareFieldName);
                    Object var = rec.get(OpportunityIdCompareFieldName);
                    if(var != null)
                        UserContactIdSet.add(Id.valueOf(String.valueOf(var)));
                    CompareIdRelatedObjectMap.put(Id.valueOf(String.valueOf(var)),rec);
                }
            }
            if(AccountRecordList != null && AccountRecordList.size() > 0){
                for(sObject rec : AccountRecordList){
                    DisplayWrapper dsWrp;
                    system.debug('########## AccountIdCompareFieldName ' + AccountIdCompareFieldName);
                    Object var = rec.get(AccountIdCompareFieldName);
                    system.debug('#### SET ' + UserContactIdSet + '  value  ' + Id.valueOf(String.valueOf(var)));
                    if(var != null && UserContactIdSet.contains(Id.valueOf(String.valueOf(var)))){
                        for(String FieldName : InputFieldSet){
                            rec.put(FieldName,CompareIdRelatedObjectMap.get(Id.valueOf(String.valueOf(var))).get(AccountFieldMap.get(FieldName)));
                        }
                        dsWrp = new DisplayWrapper(rec, true, true);
                    }else{
                        dsWrp = new DisplayWrapper(rec, false, false);
                    }
                    DisplayWrapperList.add(dsWrp);
                }
            }
            return DisplayWrapperList;
        }catch(Exception ex){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Unexpected error occured. Please contact system administrator .'+ex.getMessage()));
            system.debug('#### ERROR :  ' + ex.getMessage() + '  ' + ex.getStackTraceString());
            //CreateExceptionLog.insertErrorLog(ex, null, null, null, 'Apex Class', 'SObject', null, 'ImportAccountOpportunityClass.getDisplayWrapperList()','High'); 
            return null;
        }
    }

    public ImportAccountOpportunityClass(){
           
    }
    
    public pageReference ImportRecords(){
        try{
            List<sObject> InsertionList = new List<sObject>();
            List<sObject> UpdateList = new List<sObject>();
            sObject DummyRecord;
            for(DisplayWrapper wrapperRec : DisplayWrapperList){
                if(wrapperRec.Selected == true){
                    system.debug('### SELECTED RECORD');
                    if(!UserContactIdSet.contains(Id.valueOf(String.valueOf(wrapperRec.Record.get(AccountIdCompareFieldName))))){ 
                        system.debug('#### IN INSERTION ');
                        system.debug('#### AccountFieldMap ' + AccountFieldMap );       
                        DummyRecord = OpportunityRelSObject.newSObject();
                        for(String AccountField : AccountFieldMap.keySet()){
                            DummyRecord.put(AccountFieldMap.get(AccountField), wrapperRec.Record.get(AccountField));
                        }
                        if(ObjectFieldValueMap.size() > 0){
                            for(String Field : ObjectFieldValueMap.keySet()){
                                DummyRecord.put(Field,ObjectFieldValueMap.get(Field));
                            }
                        }
                        DummyRecord.put(sObjectParentField, currentObject.Id);
                        InsertionList.add(DummyRecord);
                    }else{
                        DummyRecord = OpportunityRelSObject.newSObject();
                        for(String AccountField : AccountFieldMap.keySet()){
                            DummyRecord.put(AccountFieldMap.get(AccountField), wrapperRec.Record.get(AccountField));
                        }
                        if(ObjectFieldValueMap.size() > 0){
                            for(String Field : ObjectFieldValueMap.keySet()){
                                DummyRecord.put(Field,ObjectFieldValueMap.get(Field));
                            }
                        }
                        DummyRecord.put('Id',CompareIdRelatedObjectMap.get(Id.valueOf(String.valueOf(wrapperRec.Record.get(AccountIdCompareFieldName)))).id);
                        UpdateList.add(DummyRecord);
                    }
                }
            }
            system.debug('#### INSERTION LIST ' + InsertionList);
            insert InsertionList;
            update UpdateList;
            if(Type == 'TeamMember'){
                List<OpportunityShare> shares = [select Id, OpportunityAccessLevel, RowCause from OpportunityShare where OpportunityId =: CurrentObjectId and RowCause = 'Team'];
                for (OpportunityShare share : shares)  
                    share.OpportunityAccessLevel = ParentRecordAccessForUser;
                update shares;
            }
           // pageReference pg = new pageReference('/' + currentObject.Id);
           // return pg;
           getDisplayWrapperList();
           DisplayMessageFlag = true;
           return null;
        }catch(Exception ex){
            system.debug('##### ERROR:  ' + ex.getMessage() + ' ' + ex.getStackTraceString());
            CreateExceptionLog.insertErrorLog(ex, null, null, null, 'Apex Class', 'SObject', null, 'ImportAccountOpportunityClass.ImportRecords()','High');  
            return null;
        }
    }
    
    public void resetDisplayMessageFlag(){
        DisplayMessageFlag = false;
    }
    
    public pageReference cancelMethod(){
        pageReference pg = new pageReference('/' + CurrentObjectId);
        return pg;
    }
    
    public class DisplayWrapper{
        public Boolean Selected {get; set;}
        public sObject Record {get; set;}
        public Boolean IsDisabled {get; set;}
        public DisplayWrapper(sObject objectRecord, Boolean flag, Boolean flag2){
            Record = objectRecord;
            Selected = flag;
            IsDisabled = flag2;
        }
    }
}