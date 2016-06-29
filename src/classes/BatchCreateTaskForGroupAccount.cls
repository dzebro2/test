/**************************************************************************************
  Apex Class Name     : BatchCreateTaskForGroupAccount
  Version             : 1.0
  Function            : 
  Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------               
* Deloitte           10/15/2015                Original Version
*************************************************************************************/
global  class BatchCreateTaskForGroupAccount implements Database.Batchable<sObject>{
    
    /*************************************************
     * @Name            : start
     * @Description     : Start method queries all the records matching criteria and returns a Database.QueryLocator for it.
 *     @Return          : Database.QueryLocator
    *************************************************/
    global Database.QueryLocator start( Database.BatchableContext BC ){
        date tempDate ;
        for(LGNA_Constants__c lgnaConstant: LGNA_Constants__c.getAll().values()){
            if(lgnaConstant.name == 'Default' && lgnaConstant.Group_Account_Task_Batch_RUn__c != null){
                tempDate = Date.newInstance(Date.today().year(),integer.valueOf(lgnaConstant.Group_Account_Task_Batch_RUn__c.split('/')[0]),integer.valueOf(lgnaConstant.Group_Account_Task_Batch_RUn__c.split('/')[1]));
            }
        }
        if(Test.isRunningTest()){
            tempDate = Date.today();
        }
        String query = '';
        if(tempDate == Date.today()){
            set<String> recordTypeNames = new set<String>{'Group_Account','Group_Account_Non_BlueSTAR'};
            query                        = 'select OwnerId,Id from Account where RecordType.DeveloperName In :recordTypeNames '+
                                            'and Group_Medicare__c = true and Status__c = \'Active\'  ';
            return Database.getQueryLocator( query ); 
        }
        else{
            System.abortJob(bc.getJobId());
            return null;
        }
        
    }
    
    /*************************************************
     * @name            : execute
     * @Description     : This method gets account records in scope and creates a task record for it. 
     * @Return          : void
    *************************************************/
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        List<Task> tasks = new List<Task>();
        String taskSubject = Label.Account_Renewal_Task_Subject;
        for( Account acct :(List<Account>)scope ) {
            taskSubject = Label.Group_Account_Task_Subject;
            tasks.add( new Task(
                    WhatId          = acct.Id,
                    OwnerId         = acct.OwnerId,
                    Subject         = taskSubject,
                    Priority        = 'Normal',
                    Status          = 'Not Started',
                    Type            = 'To Do',
                    ActivityDate    = Date.today() + 2
                ) 
            );
        }
        
        if( tasks.size() > 0 ) {
            Database.DMLOptions dmlo            = new Database.DMLOptions();
            dmlo.EmailHeader.triggerUserEmail   = true;
            try {       
                database.insert( tasks,dmlo);
            } catch( Exception e ) {
                System.debug( 'Exception in Account Renewal Batch: ' + e.getMessage() );
            }
        }
    }
    /*************************************************
     * @Name            : finish
     * @Description     : No finish method behaviour is identified yet. 
     * @Return          : void
    *************************************************/  
    global void finish(Database.BatchableContext BC){
    
    }
}