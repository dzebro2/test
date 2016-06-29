public class FormLibraryExt2 {
    
    private Form_Library__c formLibrary {get;set;}
    public Form_Library__c obj {get;set;}

    public Boolean reRend {get;set;}
    public String urlParamId {get;set;}

    public String description {get;set;}
    public String fileName {get;set;}
    public Blob fileBody {get;set;}
    public String fileType {get;set;}
    
    public String name {get;set;}
    public String type {get;set;}
    public String state {get;set;}
    Database.SaveResult currentFormRecord;

    //A list for displaying the current
    public List<Attachment> attachmentDetails {get;set;}
    
    public FormLibraryExt2(ApexPages.StandardController controller) { 
        this.formLibrary = (Form_Library__c) controller.getRecord();
        this.attachmentDetails = new List<Attachment>();
        urlParamId = ApexPages.currentPage().getParameters().get('id');
        reRend = True;
    }   
    
    // creates a new Form_Library__c record
    private Database.SaveResult saveFormLibrary() {
        try{
            obj = new Form_Library__c();
            obj.Name = formLibrary.Name;
            obj.Type__c = formLibrary.Type__c;
            obj.State__c = formLibrary.State__c;
            Database.SaveResult saveResult = Database.insert(obj); 
            return saveResult;
        }catch(Exception e){
            return null;
        }
    }
    
    // create an actual Attachment record with the Form_Library__c as parent
    private Database.SaveResult saveAttachment(Id parentId) {
        Database.SaveResult result;
        Attachment attachment = new Attachment();
        attachment.body = this.fileBody;
        attachment.name = this.fileName;
        attachment.contenttype = this.fileType;
        attachment.parentId = parentId;
        // inser the attahcment
        result = Database.insert(attachment);
        // reset the file for the view state
        fileBody = null;
        fileName = null;
        parentId = null;
        attachment.body = fileBody;
        attachmentDetails.add(attachment);
        return result;
    }

    public PageReference processPage(){
        try{
            if(urlParamId == null){
                urlParamId = saveFormLibrary().getId();
            }
            saveAttachment(urlParamId);
            return new PageReference('/apex/FormLibrary2?id=' + urlParamId).setRedirect(false);
        }
        catch(Exception e){
            return null;
        }
    }

    public PageReference returnToRecord(){
        try{
            return new PageReference('/'+obj.id);
        }catch (Exception e) {
            ApexPages.AddMessages(e);
            return null;
        }
    }
}