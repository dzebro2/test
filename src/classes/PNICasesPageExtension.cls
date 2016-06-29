public class PNICasesPageExtension{
    
    public Id ParentAccountId;
    private final Case ParentCase;
    private final Integer CaseCreatedBeforeNumberOfYears = -2;
    
    public PNICasesPageExtension(ApexPages.StandardController controller) {
       try{
        ParentCase = (Case)controller.getRecord();
        ParentAccountId = [SELECT AccountId, Id FROM Case WHERE Id =: ParentCase.Id LIMIT 1].AccountId;
       }catch(Exception ex){
           system.debug('### ERROR: ' + ex.getMessage() + '  ' + ex.getStackTraceString());
       } 
    }

    public List<Schema.FieldSetMember> getFields() {
        return SObjectType.Case.FieldSets.PNICasesDisplayFields.getFields();
    }

    public List<Case> getCaseDisplayList() {
        try{
            Integer LimitForQuery = Limits.getLimitQueryRows() - Limits.getQueryRows();
            String query = 'SELECT ';
            DateTime CompareDate = system.now().addYears(CaseCreatedBeforeNumberOfYears);
            for(Schema.FieldSetMember f : this.getFields()) {
                query += f.getFieldPath() + ', ';
            }
            query += 'Id, AccountId FROM Case WHERE ';
            query += 'AccountId =: ParentAccountId and RecordType.Name IN (\'' + system.label.PNICasesPage_Network_Information + '\',\'' + system.label.PNICasesPage_Proposal + '\')';
            query += 'and CreatedDate >=: CompareDate ORDER BY LastModifiedDate LIMIT: LimitForQuery'; 
            return Database.query(query);
        }catch(Exception ex){
            system.debug('### ERROR: ' + ex.getMessage() + '  ' + ex.getStackTraceString());
            return null;
        }
    }
    
}