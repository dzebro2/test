global class BatchCreateTaskForGroupAccountSchedule implements Schedulable{

    global void execute(SchedulableContext sct){
        BatchCreateTaskForGroupAccount b = new BatchCreateTaskForGroupAccount();
        Database.executeBatch( b );
    }
}