global class BatchSendOpptyDueDateSchedule implements Schedulable{

    global void execute(SchedulableContext sct){
        BatchSendOpportunityDueDateNotification b = new BatchSendOpportunityDueDateNotification();
        Database.executeBatch( b );
    }
}