public with sharing class ContactRelationShipController {

    public Contact_Relationship__c contactRelationshipObj 	{get; set;}
    public boolean renderRelatedContactSection 				{get; set;}
    public boolean renderRelatedUserSection 				{get; set;}
    public boolean renderAccountToAccountSection 			{get; set;}
    public boolean renderContactToAccountSection 			{get; set;}
    public boolean renderAccountToContactSection 			{get; set;}
    
    private string returnId;
    
    public Id contactId;
    private Id accountId;
    private String typeOfRelationship;
    
	public ContactRelationShipController(ApexPages.standardController stdController) {
      	try{
	        contactRelationshipObj = new Contact_Relationship__c();
	        
	        Schema.DescribeSObjectResult objectSchema 							= Contact_Relationship__c.SobjectType.getDescribe(); 
	        Map<String,Schema.RecordTypeInfo> contactRelationshipRecordTypeInfo = objectSchema.getRecordTypeInfosByName();
	        
	        Id relatedContactRecordTypeId 			= contactRelationshipRecordTypeInfo.get('Related Contact').getRecordTypeId();
	        Id relatedUserRecordTypeId 				= contactRelationshipRecordTypeInfo.get('Related User').getRecordTypeId();
	        Id relatedAccountToAccountRecordTypeId 	= contactRelationshipRecordTypeInfo.get('Account to Account').getRecordTypeId();
	        Id relatedContactToAccountRecordTypeId 	= contactRelationshipRecordTypeInfo.get('Contact to Account').getRecordTypeId();
	        
	        renderRelatedContactSection 	= false;
	        renderRelatedUserSection 		= false;
	        renderAccountToAccountSection 	= false;
	        renderContactToAccountSection 	= false;
	        renderAccountToContactSection 	= false;
	        
	        contactId 			= ApexPages.currentPage().getParameters().get('contactId');
	        accountId 			= ApexPages.currentPage().getParameters().get('accountId');
	        typeOfRelationship 	= ApexPages.currentPage().getParameters().get('Type');
	        
	         if(typeOfRelationship == 'Relate Contact'){
	            contactRelationshipObj.recordTypeId = relatedContactRecordTypeId;
	            contactRelationshipObj.Contact__c 	= contactId;
	            renderRelatedContactSection 		= true;
	            returnId 							= contactId;
	        }
	        
	        else if(typeOfRelationship == 'Relate User'){
	            contactRelationshipObj.recordTypeId = relatedUserRecordTypeId;
	            contactRelationshipObj.Contact__c 	= contactId;
	            renderRelatedUserSection 			= true;
	             returnId 							= contactId;
	        }
	        
	        else if(typeOfRelationship == 'RelateAccountToAccount'){
	            contactRelationshipObj.recordTypeId = relatedAccountToAccountRecordTypeId;
	            contactRelationshipObj.Account__c 	= accountId;
	            renderAccountToAccountSection 		= true;
	            returnId 							= accountId;
	        }
	        
	        else if(typeOfRelationship == 'RelateContactToAccount'){
	            contactRelationshipObj.recordTypeId = relatedContactToAccountRecordTypeId;
	            contactRelationshipObj.Contact__c 	= contactId;
	            renderContactToAccountSection 		= true;
	            returnId 							= contactId;
	        }
	        
	        else if(typeOfRelationship == 'RelateAccountToContact'){
	            contactRelationshipObj.recordTypeId = relatedContactToAccountRecordTypeId;
	            contactRelationshipObj.Account__c 	= accountId;
	            renderAccountToContactSection 		= true;
	            returnId 							= accountId;
	        }
      	}
	    catch( Exception e ) {
	        System.debug( 'Exception : ' +e.getMessage() );
	        //CreateExceptionLog.insertErrorLog(ex, null, null, null, 'Apex Class', 'opportunity', null, 'ContactRelationShipController.saveAndNew()','High'); 
	    } 
    }
    
    
    public PageReference save(){
        PageReference pageRef;
        try{
	        if( contactRelationshipObj != null ) {
	            upsert contactRelationshipObj;
	            pageRef = new PageReference('/'+returnId);
	            pageRef.setRedirect(true);
	        }
        }catch( Exception e ) {
            System.debug( 'Exception : ' +e.getMessage() );
            CreateExceptionLog.insertErrorLog(e, null, null, null, 'Apex Class', 'opportunity', null, 'ContactRelationShipController.controller()','High'); 
        } 
        return pageRef;
    }
    
    
    public PageReference saveAndNew(){
        PageReference pageRef = Page.ContactRelationship;
        try{
	        if(contactRelationshipObj !=null){
	            save();
	            if(contactId != null) {
	            	pageRef.getParameters().put('contactId', contactId);
	            }
	            if(accountId != null) {
	            	pageRef.getParameters().put('accountId', accountId);
	            }
	            pageRef.getParameters().put('Type', typeOfRelationship);
	            pageRef.setRedirect(true);
	        }
        }catch( Exception e ) {
            System.debug( 'Exception : ' +e.getMessage() );
            CreateExceptionLog.insertErrorLog(e, null, null, null, 'Apex Class', 'Contact', null, 'ContactRelationShipController.saveAndNew()','High'); 
        } 
        return pageRef;
    }
    
    
    public PageReference cancel(){
        PageReference pageRef = new PageReference('/'+returnId);
        return pageRef;
    }
}