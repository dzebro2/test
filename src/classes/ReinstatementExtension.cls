/*
    @Description : This is an extension class for the Reinstatement functionality on Group Account and Benefit Agreement
    @author      : Deloitte
    @date        : 9/22/2015
*/
public with sharing class ReinstatementExtension {
    Private String accountId;
public Account accountRecord                                {get;set;}
    public List<SelectOption> reinstatementTypes            {get;set;}
    public String reinstatementType                         {get;set;}
    public List<BenefitAgreementWrapper> benefitList        {get;set;}
    public String FromDate                                  {get;set;}
    public String ToDate                                    {get;set;}
    public Boolean CriteriaMatched                          {get;set;}
    public Benefit_Agreement__c tempBAObject                {get;set;}
    public Boolean isReinstatementAllowed                   {get;set;}
    public Boolean showWithdraw                             {get;set;}
    public boolean initialBARecordsPresent                  {get;set;}
    private Boolean needsWithdrawlFromApprovalProcess       {get;set;}
    public list<Benefit_Agreement__c> benefitAgreementList  {get;set;}
    public boolean isFilterPerformed                        {get;set;}
    public list<SelectOption> BAreinstatementReasons        {get;set;}
    public string BAReinstatementReasonSelected             {get;set;}
    public string BAReinstatementExplanation                {get;set;}
    public boolean hasEditAccess                            {get;set;}
    /*
        @Description : This is an constructor of this class
        @author      : Deloitte
        @date        : 9/22/2015
    */
    public ReinstatementExtension( ApexPages.StandardController controller ) {
        accountId = ( String )controller.getRecord().Id;
        UserRecordAccess userAccess = [SELECT RecordId, HasEditAccess FROM UserRecordAccess WHERE UserId = :UserInfo.getUserId() AND RecordId = :accountId limit 1][0];
        if(userAccess.HasEditAccess){
            initiateAll();
            hasEditAccess = true;
            isFilterPerformed = false;
            reinstatementTypes                              = new list<SelectOption>();
            reinstatementTypes.add( new SelectOption( 'Account', 'Account Reinstatement' ) );
            reinstatementTypes.add( new SelectOption( 'Benefit', 'Benefit Agreement Reinstatement' ) );
            BAreinstatementReasons                          = new list<SelectOption>();
            BAreinstatementReasons.add(new SelectOption('', '--none--'));
            Schema.DescribeFieldResult fieldResult = Benefit_Agreement__c.Cancellation_Reason__c.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            for( Schema.PicklistEntry f : ple)
            {
              BAreinstatementReasons.add(new SelectOption(f.getLabel(), f.getValue()));
            } 
        }else{
            hasEditAccess = false;
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, system.label.InsufficientError));             
       } 
    }

    
    /*
        @Name        : NavigateToSelectedPage
        @Description : This method will navigate to the Account Reinstatement page or BA reinstatement page according to user choice
        @author      : Deloitte
        @date        : 9/22/2015
        @return      : PageReference 
    */
    public pageReference NavigateToSelectedPage(){
        try{
            
            initiateAll();
            
            if( reinstatementType == 'Account' ) {
                
                if( AccountRecord.Status__c == 'Active' 
                        && ( AccountRecord.Cancellation_Status__c == 'Cancelled' || AccountRecord.Cancellation_Status__c == 'Requested Cancellation' ) 
                        && ( AccountRecord.Cancellation_Submitted_Date__c == Date.today() || AccountRecord.Cancellation_Submitted_Date__c == null ) ) {
                    showWithdraw            = true;
                    isReinstatementAllowed  = false;
                    ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.INFO,Label.Account_Cancellation_Not_Sent_To_Receivable_team) );
                }
                else if( AccountRecord.Status__c == 'Active' && AccountRecord.Cancellation_Status__c == 'Pending Approval' ) {
                    needsWithdrawlFromApprovalProcess   = true;
                    showWithdraw                        = true;
                    isReinstatementAllowed              = false;
                    ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.INFO,Label.Account_Cancellation_Sent_To_Receivable_Team_Not_Approved) );
                }
                else if( AccountRecord.Cancellation_Status__c != 'Cancelled' && AccountRecord.Cancellation_Status__c != 'Requested Cancellation' && AccountRecord.Status__c != 'Cancelled' ) {
                    isReinstatementAllowed = false;
                    ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR,Label.Account_Not_Cancelled_No_Reinstatement_Allowed) );
                }
                //To allow Account Reinstatement ONLY if the Account was Cancelled within One Year of Submission Date (which will be Today() when the user is trying to reinstate)
                else if( AccountRecord.Cancellation_Date__c == null || AccountRecord.Cancellation_Date__c.addYears( 1 ) <= Date.today() ) {
                    isReinstatementAllowed = false;
                    ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR,Label.Cannot_Reinstate_More_Than_One_Year_For_Cancellation ) );
                }
                else {
                    accountRecord.Requested_Cancellation_Date__c    = accountRecord.Cancellation_Date__c != null ? accountRecord.Cancellation_Date__c : accountRecord.Requested_Cancellation_Date__c;
                    accountRecord.Cancellation_Explanation__c       = null;
                    accountRecord.Cancellation_Reason__c            = null;
                    accountRecord.Cancellation_Code__c              = Label.Account_Reinstatement_Code;
                }
                return Page.AccountReinstatement;
            } 
            
            else if( reinstatementType == 'Benefit' ) {
                FromDate                                            = null;
                toDate                                              = null;
                if(AccountRecord.Status__c == 'Cancelled' || AccountRecord.Cancellation_Status__c == 'Cancelled' ) {
                    isReinstatementAllowed = false;
                    ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR,Label.Account_Cancelled_Benefit_Agreement_Reinstatement_Not_Allowed) );
                }
                else {
                    initialBARecordsPresent = false;
                    for( Benefit_Agreement__c ba : [    select  Id, Name, Status__c,Cancellation_Submitted_Date__c,Cancellation_Status__c, Group_Account__r.Status__c, Cancellation_Explanation__c, Benefit_Agreement_Number__c, Product__c,
                                                                Requested_Cancellation_Date__c, Cancellation_Date__c
                                                        from    Benefit_Agreement__c 
                                                        where   ( Requested_Cancellation_Date__c    != null Or  Cancellation_Date__c != null ) 
                                                        and Group_Account__c            =:accountId 
                                                        and (Status__c = 'Cancelled' or Cancellation_Status__c = 'Cancelled' or Cancellation_Status__c = 'Requested Cancellation') ] ) {
                        benefitAgreementList.add(  ba ) ;
                        isReinstatementAllowed                      = true;
                        initialBARecordsPresent                     = true;
                    }
                
                    if( benefitAgreementList.size() == 0 ) {
                        
                        ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, Label.Cancelled_Benefit_Agreement_Dont_Exist) );
                    }
                    
                }
                return Page.BenefitAgreementReinstatement;
                
            }
            else {
                ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, Label.Select_Type_Of_Reinstatement) );
                return null;
            }
        } catch( Exception e ) {
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, Label.AnErrorHasOcurred ) ); 
            return null;
        }
    }

    /*
        @Name        : initiateAll
        @Description : This method will initialize all the variables used in this class.
        @author      : Deloitte
        @date        : 9/22/2015
        @return      : initiateAll 
    */
    public void initiateAll() {
        accountRecord = [   select  Id, Name, Requested_Cancellation_Date__c, Cancellation_Date__c, Cancellation_Submitted_Date__c, Cancellation_Code__c,
                                    Cancellation_Explanation__c, Cancellation_Reason__c, Cancellation_Status__c, Status__c
                            from    Account 
                            where   Id =:accountId
                            limit   1 ][0];

        tempBAObject                                    = new Benefit_Agreement__c();
        benefitList                                     = new list<BenefitAgreementWrapper>();
        CriteriaMatched                                 = false;
        isReinstatementAllowed                          = true; 
        showWithdraw                                    = false;
        needsWithdrawlFromApprovalProcess               = false;   
        benefitAgreementList                            = new list<Benefit_Agreement__c>();
        isFilterPerformed                               = false;
        FromDate                                        = null;
        toDate                                          = null;
        BAReinstatementReasonSelected                   = null;
        BAReinstatementExplanation                      = null;    
    }
    /*
        @Name        : withdrawCancellation
        @Description : This method will withdraw the account cancellation and making the account as Active
        @author      : Deloitte
        @date        : 9/22/2015
        @return      : PageReference 
    */
    public PageReference withdrawCancellation() {
        Savepoint sp = Database.setSavepoint();
        try {
            accountRecord.Requested_Cancellation_Date__c    = null;
            accountRecord.Cancellation_Date__c              = null;
            accountRecord.Cancellation_Submitted_Date__c    = null;
            accountRecord.Cancellation_Code__c              = null;
            accountRecord.Cancellation_Explanation__c       = null;
            accountRecord.Cancellation_Reason__c            = null;
            accountRecord.Cancellation_Status__c            = null;
            accountRecord.Status__c                         = 'Active';
            
            update accountRecord;
            
            if( needsWithdrawlFromApprovalProcess ) {
                withdrawAccountFromApproval();
            }
            
            return new pageReference('/'+accountRecord.Id);
        } catch( Exception e ) {
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, Label.AnErrorHasOcurred));
            Database.rollback(sp);
            return null;
        }
    }
    /*
        @Name        : withdrawAccountFromApproval
        @Description : This method will withdraw the Account from Approval process beacus of Reinstatement
        @author      : Deloitte
        @date        : 9/22/2015
        @return      : void 
    */
    private void withdrawAccountFromApproval() {
        Approval.ProcessWorkItemRequest pwr = new Approval.ProcessWorkItemRequest();
        
        List<ProcessInstance> procins = new List<ProcessInstance>( [    select  Id 
                                                                        from    ProcessInstance 
                                                                        where   TargetObjectId = :accountId     
                                                                            and Status = 'Pending' ] );
        if( procins.size() > 0 ) { 
            // Retrieve the process work instance id associated to the process instance
            List<ProcessInstanceWorkitem>  workitem = new List<ProcessInstanceWorkitem>( [  select  Id 
                                                                                            from    ProcessInstanceWorkitem 
                                                                                            where   ProcessInstanceId = :procins[0].id ] );
            if( ( workitem != null ) && ( workitem.size() > 0 ) ) {
                pwr.SetComments(Label.System_Recall_Due_Reinstatement);
    
                pwr.setWorkItemId( workitem[0].id );
                pwr.setAction('Removed'); 
                // Execute process request
                Approval.ProcessResult pr = Approval.process( pwr );
            }   
        }
    }

     /*
        @Name        : submitAccountForReinstatement
        @Description : This method will update the group account record with values for reinstatement.
        @author      : Deloitte
        @date        : 9/22/2015
        @return      : pageReference 
    */
    public pageReference submitAccountForReinstatement(){
        try{
            accountRecord.Cancellation_Date__c              = null;
            accountRecord.Cancellation_Submitted_Date__c    = Date.today();
            accountRecord.Cancellation_Status__c            = 'Reinstated';
            update accountRecord;
            return new pageReference('/'+accountRecord.Id);
        }catch(Exception e){
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage())); 
            return null;
        }
    }
    
    /*
        @Name        : searchBenefitAgreements
        @Description : This method will search for the BA records matching the from and to dates criteria, 
                        the Requested Cancellation Date or Cancellation Date is equal to or greater than the From date, and 
                        the Requested Cancellation Date or Cancellation Date is equal to or less than the To date
        @author      : Deloitte
        @date        : 9/22/2015
        @return      : void 
    */
    public void searchBenefitAgreements(){
        //initiateAll();
        isFilterPerformed = true;
        benefitAgreementList = new list<Benefit_Agreement__c>();
        //FromDate = tempBAObject.Cancellation_Submitted_Date__c;
        //ToDate = tempBAObject.Requested_Cancellation_Date__c;
        
        for( Benefit_Agreement__c ba : [    select  Id, Name,Cancellation_Status__c,Cancellation_Submitted_Date__c, Status__c, Cancellation_Explanation__c, Benefit_Agreement_Number__c, Product__c, 
                                                    Requested_Cancellation_Date__c, Cancellation_Date__c 
                                            from    Benefit_Agreement__c 
                                            where   Group_Account__c =:accountId 
                                            and (Status__c = 'Cancelled' or Cancellation_Status__c = 'Cancelled' 
                                            or Cancellation_Status__c = 'Requested Cancellation')
                                            and ( Requested_Cancellation_Date__c    != null Or  Cancellation_Date__c != null )                   ] ) {
            if(ba.Cancellation_Date__c != null){
                if( (  ba.Cancellation_Date__c >= date.parse(FromDate) ) 
                    && (  ba.Cancellation_Date__c <= date.parse(ToDate) ) ) {
                    benefitAgreementList.add(  ba ) ;
                }
            }else{
                if( ( ba.Requested_Cancellation_Date__c >= date.parse(FromDate) ) 
                    && ( ba.Requested_Cancellation_Date__c <= date.parse(ToDate)  ) ) {
                    benefitAgreementList.add(  ba ) ;
                }
            }
        }
        if( benefitAgreementList.size() == 0 ) {
            isFilterPerformed = false;
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, Label.Cancelled_Benefit_Agreement_Dont_Exist) );
        }
    }

    /*
        @Name        : saveBARecords
        @Description : This method will update the selected Benefit Agreement records
        @author      : Deloitte
        @date        : 9/22/2015
        @return      : pageReference 
    */
    public pageReference saveBARecords(){
        try{
            list<Benefit_Agreement__c> updateBAList = new list<Benefit_Agreement__c>();
            for(Benefit_Agreement__c ba : benefitAgreementList){
                if((ba.Cancellation_Submitted_Date__c == date.today() || ba.Cancellation_Submitted_Date__c == null) 
                    && (ba.Cancellation_Status__c == 'Cancelled' || ba.Cancellation_Status__c == 'Requested Cancellation') 
                    && (ba.Status__c == 'Cancelled')){
                    ba.Cancellation_Code__c             = null;
                    ba.Cancellation_Reason__c           = null;
                    ba.Cancellation_Explanation__c      = null;
                    ba.Cancellation_Status__c           = null;
                    ba.Cancellation_Submitted_Date__c   = null;
                    ba.Cancellation_Date__c             = null;
                    ba.Requested_Cancellation_Date__c   = null;
                    ba.Status__c                        = 'Active';
                    updateBAList.add(ba);
                }
                else{
                    ba.Cancellation_Code__c             = /*tempBAObject.Cancellation_Code__c*/Label.Benefit_Agreement_Reinstatement_Code;
                    ba.Cancellation_Reason__c           = /*tempBAObject.Cancellation_Reason__c*/BAReinstatementReasonSelected;
                    ba.Cancellation_Explanation__c      = /*tempBAObject.Cancellation_Explanation__c*/ BAReinstatementExplanation;
                    ba.Cancellation_Status__c           = 'Reinstated';
                    ba.Cancellation_Submitted_Date__c   = Date.today();
                    updateBAList.add(ba);
                }
            }
            if(updateBAList.size()>0)
                update updateBAList;
            return new pageReference('/'+accountRecord.Id);
        }catch(Exception e){
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage())); 
            return null;
        }
    }
     /*
        @Name        : backToBAScreen
        @Description : This method will navigate back to Benefit Agreement Reinstatement home screen
        @author      : Deloitte
        @date        : 9/22/2015
        @return      : pageReference 
    */
    public pageReference backToBAScreen(){
        return Page.BenefitAgreementReinstatement;
    }
    /*
        @Name        : backToBAScreen
        @Description : This method will navigate back to  Reinstatement home screen
        @author      : Deloitte
        @date        : 9/22/2015
        @return      : pageReference 
    */
    public pageReference backToHome(){
        return Page.ReinstatementHome;
    }
    /*
        @Name        : backToBAScreen
        @Description : This method will navigate back to Benefit Agreement  Reinstatement details filling page 
        @author      : Deloitte
        @date        : 9/22/2015
        @return      : pageReference 
    */
    public pageReference NavigateToBAReasonPage(){
        if(isFilterPerformed){
            tempBAObject.Cancellation_Code__c = Label.Benefit_Agreement_Reinstatement_Code;
            return Page.BenefitAgreementFillReasonReinstatement;
        }
        else{
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, Label.ReinstatementBAFilterMandatory)); 
            return null;
        }
    }
    /*
        @Name        : BenefitAgreementWrapper
        @Description : This is a wrapper class for the managing the list of BenefitAgreement
        @author      : Deloitte
        @date        : 9/22/2015
         
    */
     public class BenefitAgreementWrapper{
        public Boolean              entrySelected {get;set;}
        public Benefit_Agreement__c entry         {get;set;}
        public BenefitAgreementWrapper(Boolean b, Benefit_Agreement__c e){
            entrySelected = b;
            entry         = e;
        }
    } 
}