global class BatchAccountRenewalNotificationSchedule implements Schedulable{

    global void execute(SchedulableContext sct){
        BatchAccountRenewalNotification b = new BatchAccountRenewalNotification();
        Database.executeBatch( b );
    }
}