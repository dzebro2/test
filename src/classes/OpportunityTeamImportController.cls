/**************************************************************************************
  Apex Class Name     : OpportunityTeamImportController
  Version             : 1.0
  Function            :
  Modification Log    :

*************************************************************************************/
public class OpportunityTeamImportController
{
    public Id RecordId {get; set;}
    public String ObjectAPIName {get; set;}
    public String Type {get; set;}
    public Opportunity CurrentOpportunity {get; set;}
    //public List<String> SelectImportOptions {get; set;}
    public Map<String,String> SelectImportOptionsMap {get; set;}
    public String SelectedValue {get; set;}
    public Boolean ShowSelectSection {get; set;}
    
    public List<SelectOption> getSelectImportOptions() 
    {
        List<SelectOption> options = new List<SelectOption>(); 
        options.add(new SelectOption('ContactRole','Contact Role')); 
        options.add(new SelectOption('TeamMember','Team Member')); 
        options.add(new SelectOption('TeamNonSF','Team Member Non SF')); 
        return options; 
    }

    public OpportunityTeamImportController(ApexPages.StandardController controller)
    {
       try
       {
         if(!test.isRunningTest())
          controller.addFields(new List<String>{'Name','Id'});
        CurrentOpportunity = (Opportunity)controller.getRecord();
        ShowSelectSection = true;
        RecordId = CurrentOpportunity.Id;
        ObjectAPIName = 'Opportunity';
        SelectedValue = 'ContactRole';
        SelectImportOptionsMap = new Map<String,String>{'ContactRole'=>'Contact Role','TeamMember'=>'Team Member','TeamNonSF'=>'Team Member Non SF','ProducerAssociation'=>'Producer Group Association'};
        system.debug('$$$$ Controller  Type  ' + Type  + ' CurrentObjectId ' + RecordId + ' CurrentObjectName ' + ObjectAPIName );
      }catch(Exception e)
      {
          System.debug( 'Exception : ' +e.getMessage() );
      }
    }   
    
  
    
    public pageReference CancelMethod()
    {
        pageReference pg = new pageReference('/'+RecordId);
        return pg;
    }
    
}