/*
    @Description : This is an LGNA Utilit Class
    @author      : Deloitte
    @date        : 10/06/2015
*/
public without sharing class  LGNAUtilityClass {
     
     /*
        @Name        : ShareRecords
        @Description : This is a Generic method which would create a share record for the record Id provided in the method
        @author      : Deloitte
        @date        : 10/06/2015
        @return      : void 
    */
    public static list<Sobject> ShareRecords(String recordId,map<String,string> userIds, string accessType,Schema.SobjectType sObjectType,string rowCause){
        try{
            list<Sobject> shareRecords  = new list<Sobject>();
            for(String userId : userIds.keySet()){
                Sobject fs              = sObjectType.newSObject();
                fs.put('ParentId',recordId);
                fs.put('UserOrGroupId',userId);
                fs.put('AccessLevel',userIds.get(userId));
                fs.put('RowCause',rowCause);
                shareRecords.add(fs);
            }
            //Database.SaveResult[] lsr     = Database.insert(shareRecords,false);
            return shareRecords;
        }catch(Exception e){
            throw e;
            
        }
    }
    
    /*
        @Name        : GetNextWorking DateTime
        @Description : This is a Generic method which would return the next working date after some Milliseconds
        @author      : Deloitte
        @date        : 10/15/2015
        @return      : void 
    */
    public static DateTime getNextBuisnessDate(String businessHoursId,DateTime startDate,Integer periodNumber,Integer workingHours){
        Long intervalMillisecods = (Long)(((periodNumber+1)*workingHours)*1000*60*60);
        DateTime nextWorkingDate = BusinessHours.add(businessHoursId,startDate,intervalMillisecods);
        return nextWorkingDate;
    }
    
    public static double getDifferenceBetweenDays(String businessHoursId, DateTime startDate, DateTime endDate,Integer workingHours ) {
        Long businessMilliseconds = BusinessHours.diff( businessHoursId, startDate, endDate );
        system.debug('===='+businessMilliseconds);
        return ( double ) ( ( double.valueOf(businessMilliseconds) / ( 1000.00*60.00*60.00 ) ) / double.valueof(workingHours) ) ;
        
    }
    
    public static Map<String, Id> createRecordTypeNameToIdMap( String objectName ) {
        Map<String, Id> recordTypeNameToIdMap = new Map<String, Id>();
        for( RecordType recType :[  SELECT  Id, DeveloperName 
                                    FROM    RecordType 
                                    where   SobjectType = :objectName
                                    limit   :Limits.getLimitQueryRows() - Limits.getQueryRows() ] )
        {
            recordTypeNameToIdMap.put( recType.DeveloperName, recType.Id );
        }   
        return recordTypeNameToIdMap;                               
    }   
    
    public static Map<Id, RecordType> createRecordTypeIdToRecordTypeMap( String objectName ) {
        return new Map<Id, RecordType>( [   select  Id, DeveloperName
                                            from    RecordType
                                            where   SobjectType = :objectName
                                            limit   :Limits.getLimitQueryRows() - Limits.getQueryRows() ] ); 
        
    
        
    }
    
    public static List<String> populateNotificationEnabledProfiles( String fieldName ) {
        List<String> notificationEnabledProfiles = new List<String>();
        
        String query =      '   select  Name '
                        +   '   from    Custom_Notification_Enabled_Profiles__c '
                        +   '   where   ' + fieldName + ' = true ';
        
        for(    Custom_Notification_Enabled_Profiles__c prof :( List<Custom_Notification_Enabled_Profiles__c> ) Database.query( query ) )
        {
            notificationEnabledProfiles.add( prof.Name );
        }                                               
        return notificationEnabledProfiles;             
    }
        
    /*
        @Name        : createSecureAttachmentSharingData
        @Description : This is a Generic method which would return the the map of secure Attachment and the users to which it is to be shared
        @author      : Deloitte
        @date        : 10/19/2015
        @return      : map<String,set<String>> 
    */
    public static map<String,map<String,string>> createSecureAttachmentSharingData(list<Secure_Information__c> secureAttachments){
        //map<String,set<String>> secureAttachmentUserIds         = new map<String,set<String>>();
        map<String,map<String,string>> secureAttachmentUserIds         = new map<String,map<String,string>>();
        map<String,set<String>> accountSecureAttachments        = new map<String,set<String>>();
        map<String,set<String>> oppSecureAttachments            = new map<String,set<String>>();
        map<String,String> secureAttachmentOwnerId              = new map<String,string>();
        set<String> secureAttachmentIds                         = new set<String>();
        for(Secure_Information__c sc : secureAttachments){
            if(sc.Account__c != null){
                if(!accountSecureAttachments.containsKey(sc.Account__c))
                    accountSecureAttachments.put(sc.Account__c,new set<String>());
                accountSecureAttachments.get(sc.Account__c).add(sc.Id);
                secureAttachmentIds.add(sc.Id);
            }
            if(sc.Opportunity_Name__c != null){
                if(!oppSecureAttachments.containsKey(sc.Opportunity_Name__c))
                    oppSecureAttachments.put(sc.Opportunity_Name__c,new set<String>());
                oppSecureAttachments.get(sc.Opportunity_Name__c).add(sc.Id);
                secureAttachmentIds.add(sc.Id);
            }
            secureAttachmentOwnerId.put(sc.Id,sc.OwnerId);
        }
        list<Secure_Information__share> delshareRecords         = new list<Secure_Information__share>();
        for(Secure_Information__share temp : [select Id,ParentId,UserOrGroupId,Parent.OwnerId from Secure_Information__share 
                                                                where ParentId In :secureAttachmentIds  
                                                                and RowCause =:Schema.Secure_Information__share.RowCause.Secure_Information_Sharing_Reason__c]){
                if(temp.UserOrGroupId != temp.Parent.OwnerId)
                    delshareRecords.add(temp);  
                
                                                                    
        }
        if(delshareRecords.size()>0)
            delete delshareRecords;
        for(OpportunityTeamMember otm : [Select userId,OpportunityId,OpportunityAccessLevel from OpportunityTeamMember where OpportunityId =:oppSecureAttachments.keySet()]){
            if(oppSecureAttachments.containsKey(otm.OpportunityId)){
                for(String secureAttId : oppSecureAttachments.get(otm.OpportunityId)){
                    if(!secureAttachmentOwnerId.get(secureAttId).contains(otm.userId)){
                        if(!secureAttachmentUserIds.containsKey(secureAttId)){
                            string accesslevel = ((otm.OpportunityAccessLevel == 'Read' || otm.OpportunityAccessLevel == 'None' ) ? 'Read' : 'Edit');
                            secureAttachmentUserIds.put(secureAttId,new map<String,string>());
                            secureAttachmentUserIds.get(secureAttId).put(otm.userId,accesslevel);
                        }
                        else if(secureAttachmentUserIds.containsKey(secureAttId)){
                            string accesslevel = ((otm.OpportunityAccessLevel == 'Read' || otm.OpportunityAccessLevel == 'None' ) ? 'Read' : 'Edit');
                            if(!secureAttachmentUserIds.get(secureAttId).containsKey(otm.userId)){
                                secureAttachmentUserIds.get(secureAttId).put(otm.userId,accesslevel);
                            }
                            else if(secureAttachmentUserIds.get(secureAttId).get(otm.userId) == 'Read' && otm.OpportunityAccessLevel == 'Edit'){
                                
                                secureAttachmentUserIds.get(secureAttId).put(otm.userId,accesslevel);
                            }
                        }
                        //secureAttachmentUserIds.get(secureAttId).add(otm.userId);
                    }
                }
            }
        }
        for(AccountTeamMember otm : [Select userId,user.Name,AccountId,AccountAccessLevel from AccountTeamMember where AccountId =:accountSecureAttachments.keySet()]){
            if(accountSecureAttachments.containsKey(otm.AccountId)){
                for(String secureAttId : accountSecureAttachments.get(otm.AccountId)){
                    if(!secureAttachmentOwnerId.get(secureAttId).contains(otm.userId)){
                        if(!secureAttachmentUserIds.containsKey(secureAttId)){
                           system.debug('======='+otm.AccountAccessLevel+'====='+otm.user.Name);
                            string accesslevel = ((otm.AccountAccessLevel == 'Read' || otm.AccountAccessLevel == 'None' ) ? 'Read' : 'Edit');
                             secureAttachmentUserIds.put(secureAttId,new map<String,string>());
                            secureAttachmentUserIds.get(secureAttId).put(otm.userId,accesslevel);
                        }
                        else if(secureAttachmentUserIds.containsKey(secureAttId)){
                            system.debug('======='+otm.AccountAccessLevel+'====='+otm.user.Name);
                            string accesslevel = ((otm.AccountAccessLevel == 'Read' || otm.AccountAccessLevel == 'None' ) ? 'Read' : 'Edit');
                            if(!secureAttachmentUserIds.get(secureAttId).containsKey(otm.userId)){
                                secureAttachmentUserIds.get(secureAttId).put(otm.userId,accesslevel);
                            }
                            else if(secureAttachmentUserIds.get(secureAttId).get(otm.userId) == 'Read' && otm.AccountAccessLevel == 'Edit'){
                                secureAttachmentUserIds.get(secureAttId).put(otm.userId,accesslevel);
                            }
                        }
                    }
                }
            }
        }
        return secureAttachmentUserIds;
    }
}