public class FormLibraryExt {
    
    public String selectedType {get;set;}
    public Boolean selectedAwesomeness {get;set;}
    public String description {get;set;}
    private Form_Library__c fl {get;set;} 
    public String fileName {get;set;}
    public Blob fileBody {get;set;}
    public Form_Library__c obj {get;set;}
    public String name {get;set;}
    
    public FormLibraryExt(ApexPages.StandardController controller) { 
        this.fl = (Form_Library__c)controller.getRecord();
    }   
    
    // creates a new Form_Library__c record
    private Database.SaveResult saveCustomAttachment() {
       obj = new Form_Library__c();
       obj.name = name;
        
        // fill out cust obj fields
        return Database.insert(obj);
    }
    
    // create an actual Attachment record with the Form_Library__c as parent
    private Database.SaveResult saveStandardAttachment(Id parentId) {
        Database.SaveResult result;
        
        Attachment attachment = new Attachment();
        attachment.body = this.fileBody;
        attachment.name = this.fileName;
        attachment.parentId = parentId;
        // inser the attahcment
        result = Database.insert(attachment);
        // reset the file for the view state
        fileBody = Blob.valueOf(' ');
        return result;
    }
    
    
    public PageReference processUpload() {
        try {
            Database.SaveResult customAttachmentResult = saveCustomAttachment();
        
            if (customAttachmentResult == null || !customAttachmentResult.isSuccess()) {
                ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
                  'Could not save attachment.'));
                return null;
            }
        
            Database.SaveResult attachmentResult = saveStandardAttachment(customAttachmentResult.getId());
        
            if (attachmentResult == null || !attachmentResult.isSuccess()) {
                ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
                  'Could not save attachment.'));            
                return null;
            } else {
                // update the custom attachment record with some attachment info
                Form_Library__c customAttachment = [select id from Form_Library__c where id = :customAttachmentResult.getId()];
                //customAttachment.name = this.fileName;
                //customAttachment.Attachment__c = attachmentResult.getId();
               // update customAttachment;
            }
        
        } catch (Exception e) {
            ApexPages.AddMessages(e);
            return null;
        }
        
        return new PageReference('/apex/FormLibrary?id=' +obj.id );
    }
    
    

}