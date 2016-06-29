public with sharing class ContactRelationshipTriggerHandler {
    
    
    public static void manageContactRelationships( List<Contact_Relationship__c> newRecords ) {
        Map<Id, RecordType> recordTypes = LGNAUtilityClass.createRecordTypeIdToRecordTypeMap( 'Contact_Relationship__c' );
        
        Map<Id, Contact_Relationship__c> contactRelationshipsToBeCreated = new Map<Id, Contact_Relationship__c>(); 
        for( Contact_Relationship__c contactRel :newRecords ) {
            if( recordTypes.get( contactRel.RecordTypeId ).DeveloperName == 'Related_Contact' 
                && String.isBlank( contactRel.Related_Contact_Relationship_Id__c ) ) {
                
                Contact_Relationship__c cr  = new Contact_Relationship__c();
                
                cr.RecordTypeId                         = contactRel.RecordTypeId;
                cr.Contact__c                           = contactRel.Related_Contact__c;
                cr.Related_Contact__c                   = contactRel.Contact__c;
                cr.Relationship_Info__c                 = contactRel.Relationship_Info__c;
                cr.Related_Contact_Relationship_Id__c   = contactRel.Id;
                
                contactRelationshipsToBeCreated.put( contactRel.Id, cr );
            }
            
            if( recordTypes.get( contactRel.RecordTypeId ).DeveloperName == 'Account_to_Account' 
                && String.isBlank( contactRel.Related_Contact_Relationship_Id__c ) ) {
                
                Contact_Relationship__c cr  = new Contact_Relationship__c();
                
                cr.RecordTypeId                         = contactRel.RecordTypeId;
                cr.Account__c                           = contactRel.Related_Account__c;
                cr.Related_Account__c                   = contactRel.Account__c;
                cr.Relationship_Info__c                 = contactRel.Relationship_Info__c;
                cr.Dollars_Invested__c                  = contactRel.Dollars_Invested__c;
                cr.Status__c                            = contactRel.Status__c;
                cr.Type__c                              = contactRel.Type__c;
                cr.Related_Contact_Relationship_Id__c   = contactRel.Id;
                
                contactRelationshipsToBeCreated.put( contactRel.Id, cr );
            }
        }   
        if( contactRelationshipsToBeCreated.size() > 0 ) {
            insert contactRelationshipsToBeCreated.values();
        }
           
    }
    
    public static void manageContactRelationshipsUpdate( Map<Id, Contact_Relationship__c> newRecordsMap, Map<Id, Contact_Relationship__c> oldRecordsMap ) {
        Map<Id, RecordType> recordTypes = LGNAUtilityClass.createRecordTypeIdToRecordTypeMap( 'Contact_Relationship__c' );
        
        List<Contact_Relationship__c> contactRelationshipsToBeUpdated = new List<Contact_Relationship__c>(); 
        
        Map<Id, List<Contact_Relationship__c>> relatedContactToContactRelationshipMap = new Map<Id, List<Contact_Relationship__c>>(); 
        Map<Id, List<Contact_Relationship__c>> relatedAccountToContactRelationshipMap = new Map<Id, List<Contact_Relationship__c>>();
        
        for( Contact_Relationship__c contactRel :oldRecordsMap.values() ) {
            if( recordTypes.get( contactRel.RecordTypeId ).DeveloperName == 'Related_Contact' ) {
                if( !relatedContactToContactRelationshipMap.containsKey( contactRel.Related_Contact__c ) ) {
                    relatedContactToContactRelationshipMap.put( contactRel.Related_Contact__c, new List<Contact_Relationship__c>() );
                }
                relatedContactToContactRelationshipMap.get( contactRel.Related_Contact__c ).add( newRecordsMap.get( contactRel.Id ) );
            }
            else if( recordTypes.get( contactRel.RecordTypeId ).DeveloperName == 'Account_to_Account' ) {
                if( !relatedContactToContactRelationshipMap.containsKey( contactRel.Related_Account__c ) ) {
                    relatedAccountToContactRelationshipMap.put( contactRel.Related_Account__c, new List<Contact_Relationship__c>() );
                }
                relatedAccountToContactRelationshipMap.get( contactRel.Related_Account__c ).add( newRecordsMap.get( contactRel.Id ) );
            }
        }
        
        for( Contact_Relationship__c contactRelRec :[       select  Id, Contact__c, Related_Contact__c, Relationship_Info__c, Related_Contact_Relationship_Id__c,
                                                                    Account__c, Related_Account__c, Status__c, Dollars_Invested__c, Type__c, RecordTypeId
                                                            from    Contact_Relationship__c
                                                            where   Contact__c IN :relatedContactToContactRelationshipMap.keySet()
                                                            limit   :Limits.getLimitQueryRows() - Limits.getQueryRows()] ) {
            if( relatedContactToContactRelationshipMap.containsKey( contactRelRec.Contact__c ) ) {
                for(  Contact_Relationship__c newContactRel :relatedContactToContactRelationshipMap.get( contactRelRec.Contact__c ) ) {
                    
                    if( contactRelRec.Related_Contact__c == newContactRel.Contact__c
                        &&  (   newContactRel.Relationship_Info__c  != oldRecordsMap.get( newContactRel.Id ).Relationship_Info__c 
                            ||  newContactRel.Related_Contact__c    != oldRecordsMap.get( newContactRel.Id ).Related_Contact__c ) ) {
                        
                        contactRelRec.Relationship_Info__c  = newContactRel.Relationship_Info__c;
                        contactRelRec.Contact__c            = newContactRel.Related_Contact__c;
                        contactRelationshipsToBeUpdated.add( contactRelRec );
                    }
                }
            }
        }
        

        for( Contact_Relationship__c contactRelRec :[   select  Id, Contact__c, Related_Contact__c, Relationship_Info__c, Related_Contact_Relationship_Id__c,
                                                                Account__c, Related_Account__c, Status__c, Dollars_Invested__c, Type__c, RecordTypeId
                                                        from    Contact_Relationship__c
                                                        where   Account__c IN :relatedAccountToContactRelationshipMap.keySet()
                                                        limit   :Limits.getLimitQueryRows() - Limits.getQueryRows()  ] ) {
            
            if( relatedAccountToContactRelationshipMap.containsKey( contactRelRec.Account__c ) ) {
                for(  Contact_Relationship__c newContactRel :relatedAccountToContactRelationshipMap.get( contactRelRec.Account__c ) ) {
                    
                    if( contactRelRec.Related_Account__c == newContactRel.Account__c    
                        && (    newContactRel.Relationship_Info__c  != oldRecordsMap.get( newContactRel.Id ).Relationship_Info__c 
                            ||  newContactRel.Related_Account__c    != oldRecordsMap.get( newContactRel.Id ).Related_Account__c
                            ||  newContactRel.Status__c             != oldRecordsMap.get( newContactRel.Id ).Status__c
                            ||  newContactRel.Dollars_Invested__c   != oldRecordsMap.get( newContactRel.Id ).Dollars_Invested__c
                            ||  newContactRel.Type__c               != oldRecordsMap.get( newContactRel.Id ).Type__c ) ) {
                        
                        contactRelRec.Relationship_Info__c  = newContactRel.Relationship_Info__c;
                        contactRelRec.Account__c            = newContactRel.Related_Account__c;
                        contactRelRec.Status__c             = newContactRel.Status__c;
                        contactRelRec.Dollars_Invested__c   = newContactRel.Dollars_Invested__c;
                        contactRelRec.Type__c               = newContactRel.Type__c;
                                
                        contactRelationshipsToBeUpdated.add( contactRelRec );
                    }
                }
            }
        }
        
        
        if( contactRelationshipsToBeUpdated.size() > 0 ) {
            update contactRelationshipsToBeUpdated;
        }   
    }
    
    
    public static void manageContactRelationshipsDelete( Map<Id, Contact_Relationship__c> oldRecordsMap ) {
        Map<Id, RecordType> recordTypes = LGNAUtilityClass.createRecordTypeIdToRecordTypeMap( 'Contact_Relationship__c' );
        
        List<Contact_Relationship__c> contactRelationshipsToBeDeleted = new List<Contact_Relationship__c>(); 
        
        Map<Id, List<Contact_Relationship__c>> relatedContactToContactRelationshipMap = new Map<Id, List<Contact_Relationship__c>>(); 
        Map<Id, List<Contact_Relationship__c>> relatedAccountToContactRelationshipMap = new Map<Id, List<Contact_Relationship__c>>();
        
        for( Contact_Relationship__c contactRel :oldRecordsMap.values() ) {
            if( recordTypes.get( contactRel.RecordTypeId ).DeveloperName == 'Related_Contact' ) {
                if( !relatedContactToContactRelationshipMap.containsKey( contactRel.Related_Contact__c ) ) {
                    relatedContactToContactRelationshipMap.put( contactRel.Related_Contact__c, new List<Contact_Relationship__c>() );
                }
                relatedContactToContactRelationshipMap.get( contactRel.Related_Contact__c ).add( contactRel );
            }
            else if( recordTypes.get( contactRel.RecordTypeId ).DeveloperName == 'Account_to_Account' ) {
                if( !relatedContactToContactRelationshipMap.containsKey( contactRel.Related_Account__c ) ) {
                    relatedAccountToContactRelationshipMap.put( contactRel.Related_Account__c, new List<Contact_Relationship__c>() );
                }
                relatedAccountToContactRelationshipMap.get( contactRel.Related_Account__c ).add( contactRel );
            }
        }
        
        System.debug('relatedAccountToContactRelationshipMap='+relatedAccountToContactRelationshipMap);
        
        for( Contact_Relationship__c contactRelRec :[       select  Id, Contact__c, Related_Contact__c, Relationship_Info__c, Related_Contact_Relationship_Id__c,
                                                                    Account__c, Related_Account__c, Status__c, Dollars_Invested__c, Type__c, RecordTypeId
                                                            from    Contact_Relationship__c
                                                            where   Contact__c IN :relatedContactToContactRelationshipMap.keySet()
                                                            limit   :Limits.getLimitQueryRows() - Limits.getQueryRows()] ) {
            
            if( relatedContactToContactRelationshipMap.containsKey( contactRelRec.Account__c ) ) {
                for(  Contact_Relationship__c newContactRel :relatedContactToContactRelationshipMap.get( contactRelRec.Contact__c ) ) {
                    if( contactRelRec.Related_Contact__c == newContactRel.Contact__c ) {
                        contactRelationshipsToBeDeleted.add( contactRelRec );                       
                    }
                }
            }
        }
        
        for( Contact_Relationship__c contactRelRec :[   select  Id, Contact__c, Related_Contact__c, Relationship_Info__c, Related_Contact_Relationship_Id__c,
                                                                Account__c, Related_Account__c, Status__c, Dollars_Invested__c, Type__c, RecordTypeId
                                                        from    Contact_Relationship__c
                                                        where   Account__c IN :relatedAccountToContactRelationshipMap.keySet()
                                                        limit   :Limits.getLimitQueryRows() - Limits.getQueryRows()  ] ) {
            if( relatedAccountToContactRelationshipMap.containsKey( contactRelRec.Account__c ) ) {
                for(  Contact_Relationship__c newContactRel :relatedAccountToContactRelationshipMap.get( contactRelRec.Account__c ) ) {
                    if( contactRelRec.Related_Account__c == newContactRel.Account__c ) {
                        contactRelationshipsToBeDeleted.add( contactRelRec );                       
                    }
                }
            }
        }
        
        System.debug('contactRelationshipsToBeDeleted='+contactRelationshipsToBeDeleted);
        
        if( contactRelationshipsToBeDeleted.size() > 0 ) {
            delete contactRelationshipsToBeDeleted;
        }   
    }
        
}