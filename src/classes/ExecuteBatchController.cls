public with sharing class ExecuteBatchController {
  public ExecuteBatchController(){
    
  }
  public void triggerBatchSendAccountRenewalNotification(){
    BatchAccountRenewalNotification temp = new BatchAccountRenewalNotification();
    database.executeBatch(temp);
  }
  public void triggerBatchShareSecureAttachment(){
    BatchShareSecureAttachmentRecord temp = new BatchShareSecureAttachmentRecord();
    database.executeBatch(temp);
  }
  public void triggerBatchSendOppDueDateNotification(){
    BatchSendOpportunityDueDateNotification temp = new BatchSendOpportunityDueDateNotification();
    database.executeBatch(temp);
  }
  public void triggerBatchCreateTaskforGroupAccount(){
    BatchCreateTaskForGroupAccount temp = new BatchCreateTaskForGroupAccount();
    database.executeBatch(temp);
  }
}