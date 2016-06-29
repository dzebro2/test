global class BatchCaseMarkedForDeleteSchedule implements Schedulable{

    global void execute(SchedulableContext sct){
        BatchCaseMarkedForDelete b=new BatchCaseMarkedForDelete();
        Database.executeBatch(b,2000);
    }
}