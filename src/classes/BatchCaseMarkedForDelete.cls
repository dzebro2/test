/********************************************************************************************************
** This batch class is to delete the cases that have status updated to "Closed (Marked for delete) ". 
** The batch should clean the cases up to yesterday by the last modified date. The batch should run daily at 2 am 
** after a back up data report has been sent to Management as scheduled. 
*
**  Author                 Date                              Update
**  Mei Chen              03/10/2015                         Initial   
**
**********************************************************************************************************/

global class BatchCaseMarkedForDelete implements Database.Batchable<Sobject>, Database.Stateful {

  
  private Date dt=system.today();//+// yesterday Integer.valueOf(Utility.constantMap.get(467));//-
 // private Date dt=date.newInstance(todayDt.YEAR, todayDT.MONTH, todayDT.DAY);
  public String query ='Select id, lastmodifieddate from case ';
  private boolean error=false;
  
  public BatchCaseMarkedForDelete(){
    
    if(Test.isRunningTest()){
        dt=system.today()-1;//Integer.valueOf(Utility.constantMap.get(5));//+dayOffset;
    }else{
        dt=system.today()+Integer.valueOf(Utility.constantMap.get(5));
    }
    system.debug('dt: '+dt);
    query='Select id, lastmodifieddate, createdDate from case where createdDate <=:dt AND status=\'Closed (Marked for Delete)\'';
    
    //if(Test.isRunningTest()){
    //   query='Select id, lastmodifieddate from case where status=\'Closed (Marked for Delete)\'';
    //}
    system.debug('query: '+query);
 
  }
  
  global Database.queryLocator start(Database.batchableContext cxt){
   // query='Select id, lastmodifieddate from case where lastmodifieddate =:dt AND status=\'Closed (Marked for Delete)\'';
    system.debug(query);
    return Database.getQueryLocator(query);
  }
  
  global void Execute(Database.batchableContext txt, List<SObject> scope){
    
 
     list<Case> closedCases=(list<Case>)scope;
     system.debug(closedCases);
     try{
           if(closedCases.size()>0){
              system.debug('number of cases to be deleted: '+closedCases.size());
              delete closedCases;
           }
     }catch (Exception e){
           error=true;
          system.debug(e);
     }
    
  }
    
  global void finish(Database.batchableContext ctx){
      AsyncApexJob a = [SELECT id, ApexClassId, JobItemsProcessed, TotalJobItems, 
                          NumberOfErrors, CreatedBy.Email 
                          FROM AsyncApexJob 
                          WHERE id = :ctx.getJobId()];
      
      String emailMsg='Your batch job Delete Case has been finished. It Executed '+a.totalJobItems+ 'batch. \n';
      
      if(error){
        emailMsg+='Your batch job Delete Cases has been running Failed.';
      }else{
        emailMsg+='Your batch job Delete Cases has been running successfully.';
      }
      
       Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        // Variable
        
        Integer emailLoop = 0;
        Integer tempInt = 0;
        String tempStr1 = null;
        String tempStr2=null;
        
        if(Test.isRunningTest()){
            tempStr2 = 'mei_chen@bcbsil.com, noreply@salesforce.com';
        }else{
            tempStr2 = Utility.constantMap.get(1);
        }
        
        if(tempStr2!=null){
          emailLoop = tempStr2.countMatches('@');//Utility.constantMap.get(104));
        }
        String[] toAddresses = new String[]{};
        
       // if(emailLoop==0){
       //   system.debug('no email available. no email sent for batch result.');
        //  return;
      //  }
        // Fetch Values from Custom Setting and assign to toAddress
        
        for (Integer kk = 0; kk < emailLoop; ++kk) {
            
            // Validate if multiple emails
            
            if (tempStr2.contains(',')) {
                tempStr1 = tempStr2.substring(0, tempStr2.IndexOf(','));//Utility.constantMap.get(105)));
                tempInt = tempStr1.length() + 1;
                tempStr2 = tempStr2.substring(tempInt, tempStr2.length());
            }
            // Single email
            
            else {
                tempStr1 = tempStr2;
            }
            
            // Add email to toAddresses
            
            toAddresses.add(tempStr1);      
        }

        mail.setToAddresses(toAddresses);
        mail.setReplyTo(Utility.constantMap.get(2));//'NoReply@salesforce.com'
        mail.setSenderDisplayName(Utility.constantMap.get(3));//'Scheduled Job Notification'
        mail.setSubject(Utility.constantMap.get(4));//'Small Group Delete Cases Batch Job Completed'
        mail.setPlainTextBody(emailMsg);
        mail.setHtmlBody(emailMsg);
      // if(!test.isRunningTest()){
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });           
       // }        
      
    }
    
 }