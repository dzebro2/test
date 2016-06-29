global class BatchShareSecureAttachmentRecordSchedule implements Schedulable{

    global void execute(SchedulableContext sct){
        BatchShareSecureAttachmentRecord b = new BatchShareSecureAttachmentRecord();
        Database.executeBatch( b );
    }
}