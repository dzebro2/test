public with sharing class ContactRelationshipMapController {
    private Id recId;                       
    
    public String relationshipsNodes    { get; set; }
    public String relationshipsEdges    { get; set; }
    
    public Integer repulsion            { get; set; }
    
    public Boolean showCurrentContact   { get; set; }
    public Boolean showPrimaryContacts  { get; set; }
    public Boolean showSecondayContacts { get; set; }
    public Boolean showRelatedAccounts	{ get; set; }
    
    public ContactRelationshipMapController( ApexPages.StandardController stdController ) {
        recId                   = stdController.getId();
        showCurrentContact      = true;
        showPrimaryContacts     = true;
        showSecondayContacts    = false;
        showRelatedAccounts		= false;
        
        repulsion               = 800;
        populateContactRelationshipInfo();
    }
    
    public PageReference populateContactRelationshipInfo() {
        String relationshipInfo = '';
        String title = '';
        String company = '';
        try{
        //Populate contact data
        Contact contactRec= [   select  Id, Name,
                                        ReportsToId, ReportsTo.Name, ReportsTo.Account.Name, ReportsTo.Title
                                from    Contact
                                where   Id = :recId
                                limit   1];
                                        
        List<AggregateResult> relationshipsRecords = [  select  count(Id)
                                                        from    Contact_Relationship__c
                                                        where   Contact__c = :contactRec.Id ];
        
        Integer relationshipsCount = 0;
        if( relationshipsRecords.size() > 0 ) {
            relationshipsCount = Integer.valueOf(relationshipsRecords[0].get('expr0') );
        }
        
        if( showPrimaryContacts == false || relationshipsCount == 0  ) { 
            repulsion = 0;
        } else {
            repulsion = 600;
        }
        
        if( !showPrimaryContacts ) {
            showSecondayContacts    = false;
        }

        
        relationshipsNodes = '"' + contactRec.Id +'":{"color":"red","label":"' + contactRec.Name + '", "relInfo":"Current Contact"}'; 
        
        
        //Populate contact primary relationship data
        relationshipsEdges = '"' + contactRec.Id + '":{';

        
        if( showPrimaryContacts && contactRec.ReportsToId != null ) {
            
            title = contactRec.ReportsTo.Title == null || String.isBlank(contactRec.ReportsTo.Title) ? '' : contactRec.ReportsTo.Title;
            company = contactRec.ReportsTo.Account == null || String.isBlank(contactRec.ReportsTo.Account.Name) ? '' : contactRec.ReportsTo.Account.Name;
            
            relationshipsNodes += ',"' + contactRec.ReportsToId + '":{"color":"blue","label":"' + contactRec.ReportsTo.Name + '","relInfo":"Reports To","relTitle":"' + title + '","relCompany":"' + company
                            +'","image":"/resource/ContactImage","image_w":32,"image_h":36}';
                                                                    
            relationshipsEdges += '"' + contactRec.ReportsToId + '":{"weight":5},';
        }
        
        Set<Id> relatedContactIds 	= new Set<Id>();
        Set<Id> relatedUserIds 		= new Set<Id>();
        Set<Id> relatedAccountIds 	= new Set<Id>();
        
        for( Contact_Relationship__c contactRel :[  select  Id, Contact__c, Related_Contact__c, Relationship_Info__c,
                                                            Related_Contact__r.Name, Related_Contact__r.Account.Name, Related_Contact__r.Title,
                                                            Related_User__c, Related_User__r.Name, Related_User__r.UserRole.Name, Related_User__r.CompanyName,
                                                            Account__c, Account__r.Name
                                                    from    Contact_Relationship__c
                                                    where   Contact__c = :contactRec.Id
                                                    limit   :Limits.getLimitQueryRows() - Limits.getQueryRows() ] ) {
            relationshipInfo = '---';
            
            if( String.isNotBlank( contactRel.Relationship_Info__c ) ) {
                relationshipInfo = contactRel.Relationship_Info__c;
            }
            
            if( showPrimaryContacts ) {
                //If contact
                if( String.isNotBlank( contactRel.Related_Contact__r.Name ) ) {
                    
                    title = contactRel.Related_Contact__r.Title == null || String.isBlank(contactRel.Related_Contact__r.Title) ? '' : contactRel.Related_Contact__r.Title;
                    company = contactRel.Related_Contact__r.Account == null || String.isBlank(contactRel.Related_Contact__r.Account.Name) ? '' : contactRel.Related_Contact__r.Account.Name;
                            
                    relationshipsNodes += ',"' + contactRel.Related_Contact__c + '":{"color":"blue","label":"' + contactRel.Related_Contact__r.Name + '","relInfo":"'+ relationshipInfo 
                                        + '","relTitle":"' + title + '","relCompany":"' + company
                                        +'","image":"/resource/ContactImage","image_w":32,"image_h":36}';
                                                                                
                    relationshipsEdges += '"' + contactRel.Related_Contact__c + '":{"weight":5},';
                    
                    relatedContactIds.add( contactRel.Related_Contact__c );
                    
                    
                }

                //If user
                else if( String.isNotBlank( contactRel.Related_User__r.Name ) ) {
                    
                    title = contactRel.Related_User__r.UserRole == null || String.isBlank(contactRel.Related_User__r.UserRole.Name) ? '' : contactRel.Related_User__r.UserRole.Name;
                    company = contactRel.Related_User__r.CompanyName == null || String.isBlank(contactRel.Related_User__r.CompanyName) ? '' : contactRel.Related_User__r.CompanyName;
                    
                    relationshipsNodes +=  ',"' + contactRel.Related_User__c + '":{"color":"blue","label":"' + contactRel.Related_User__r.Name + '","relInfo":"'+ relationshipInfo 
                                        + '","relTitle":"' + title + '","relCompany":"' + company
                                        +'","image":"/resource/UserImage","image_w":32,"image_h":29}';
                    relationshipsEdges += '"' + contactRel.Related_User__c + '":{"weight":5},';
                    relatedUserIds.add( contactRel.Related_User__c );
                }
            }
			//If Account
            if( showRelatedAccounts && String.isNotBlank( contactRel.Account__c ) ) {
                
                title = '';
                company = '';
                
                relationshipsNodes +=  ',"' + contactRel.Account__c + '":{"color":"green","label":"' + contactRel.Account__r.Name + '","relInfo":"'+ relationshipInfo 
                                    + '","relTitle":"' + title + '","relCompany":"' + company
                                    +'","image":"/resource/AccountImage","image_w":32,"image_h":29}';
                relationshipsEdges += '"' + contactRel.Account__c + '":{"weight":5},';
                relatedAccountIds.add( contactRel.Account__c );
            }            
        }
        relationshipsEdges = relationshipsEdges.removeEnd(',');
        relationshipsEdges += '}';
        
        //Populate contact secondary relationship data
        if( showPrimaryContacts ) {
            
            for( Contact con :[ select  Id, 
                                    (   select  Id, Contact__c, Relationship_Info__c,
                                                Related_Contact__c, Related_Contact__r.Name, Related_Contact__r.Account.Name, Related_Contact__r.Title,
                                                Related_User__c, Related_User__r.Name, Related_User__r.UserRole.Name, Related_User__r.CompanyName
                                        from    Contact_Relationships__r )
                                from    Contact
                                where   Id IN :relatedContactIds
                                limit   :Limits.getLimitQueryRows() - Limits.getQueryRows() ] ) {
                
                relationshipsEdges += ',"' + con.Id + '":{';
                
                for( Contact_Relationship__c contactRel :con.Contact_Relationships__r) {
                    relationshipInfo = '---';
                    if( String.isNotBlank( contactRel.Relationship_Info__c ) ) {
                        relationshipInfo = contactRel.Relationship_Info__c;
                    }
                    
                    if( showSecondayContacts ) {
                        if( String.isNotBlank( contactRel.Related_Contact__r.Name ) && contactRel.Related_Contact__r.Id != contactRec.Id ) {
                            if( !relatedContactIds.contains( contactRel.Related_Contact__c ) ) {
                                
                                title = contactRel.Related_Contact__r.Title == null || String.isBlank(contactRel.Related_Contact__r.Title) ? '' : contactRel.Related_Contact__r.Title;
                                company = contactRel.Related_Contact__r.Account == null || String.isBlank(contactRel.Related_Contact__r.Account.Name) ? '' : contactRel.Related_Contact__r.Account.Name;
                    
                                relationshipsNodes += ',"' + contactRel.Related_Contact__c + '":{"color":"orange","label":"' + contactRel.Related_Contact__r.Name + '","relInfo":"'+ relationshipInfo 
                                                    + '","relTitle":"' + title + '","relCompany":"' + company
                                                    +'","image":"/resource/ContactImage","image_w":32,"image_h":36}';
                            }
                            relationshipsEdges += '"' + contactRel.Related_Contact__c + '":{"weight":2},';
                        }
                        
                        else if( String.isNotBlank( contactRel.Related_User__r.Name ) && contactRel.Related_Contact__r.Id != contactRec.Id  ) {
                            if( !relatedUserIds.contains( contactRel.Related_User__c ) ) {
                                
                                title = contactRel.Related_User__r.UserRole == null || String.isBlank(contactRel.Related_User__r.UserRole.Name) ? '' : contactRel.Related_User__r.UserRole.Name;
                                company = contactRel.Related_User__r.CompanyName == null || String.isBlank(contactRel.Related_User__r.CompanyName) ? '' : contactRel.Related_User__r.CompanyName;
                                
                                relationshipsNodes +=  ',"' + contactRel.Related_User__c + '":{"color":"orange","label":"' + contactRel.Related_User__r.Name + '","relInfo":"'+ relationshipInfo 
                                                    + '","relTitle":"' + title + '","relCompany":"' + company
                                                    +'","image":"/resource/UserImage","image_w":32,"image_h":29}';
                                relationshipsEdges += '"' + contactRel.Related_User__c + '":{"weight":2},';
                            }
                        }
                    }
                }           
                
                relationshipsEdges = relationshipsEdges.removeEnd(',');
                relationshipsEdges += '}';
            }
        }
      }catch(Exception e){
          System.debug( 'Exception : ' +e.getMessage() );
      }    
            
        return null;
    }
    
}