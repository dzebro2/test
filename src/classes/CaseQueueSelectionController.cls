public class CaseQueueSelectionController {
    //The case that will be used on screen
    public Case myCase {get; set;}
    public Boolean isOwner {get;set;}
    public Id currentRecordId {get;set;}

    public CaseQueueSelectionController(ApexPages.StandardController stdController){
        isOwner = false;
        myCase = new Case();
        Case c = (Case) stdController.getRecord();
        c = [SELECT Subject, OwnerId, Owner.Name, Owner.Type, Id FROM Case WHERE Id =: c.Id];
        
        currentRecordId = c.Id;
        Id currentUserId = UserInfo.getUserId();
        Id currentUserProfile = UserInfo.getProfileId();
        Id currentUserRole = UserInfo.getUserRoleId();
        
        Set<String> allowedProfiles = new Set<String>{'System Administrator', 'Administrator', 'Underwriting'};
        Profile userProfile = [SELECT Name FROM Profile WHERE Id =: currentUserProfile];
        User currentUser = [SELECT Is_Super_User__c FROM User WHERE Id =: currentUserId];

        //If the current user is a Sys Admin or Admin, allow them
        if(allowedProfiles.contains(userProfile.Name) || currentUser.Is_Super_User__c)
            isOwner = True;
        //If the user owns the case, allow them
        else if(c.Owner.Type == 'User')
            isOwner = (currentUserId == c.OwnerId);
        //If the user or role that the user belongs to owns the case, allow them
        else if(c.Owner.Type == 'Queue'){
            Set<Id> currentUserGroupIds = new Set<Id>();
            if(currentUserRole != null)
                for(Group g: [SELECT Id, RelatedId FROM Group WHERE RelatedId =: currentUserRole])
                    currentUserGroupIds.add(g.Id);
            if([SELECT Group.Name FROM GroupMember WHERE (UserOrGroupId =:currentUserId or UserOrGroupId IN :currentUserGroupIds) AND Group.Type =: c.Owner.Type AND Group.Name =: c.Owner.Name].size() != 0)
                isOwner = True;
        }
        if(!isOwner)
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Fatal, 'You do not have permission to change this Case Owner'));
    }
    
    //Save method because the Standard save could not be used
    //Gets the current Id of the page's case and updates it with the new Id
    public PageReference save() {  
        try{
            Id caseId = ApexPages.currentPage().getParameters().get('id');
            myCase.Id = caseId;
            System.debug(myCase.Id);
            update myCase;  
            PageReference pr = new pagereference('/' + myCase.id); 
            return pr; 
        }catch(DmlException e){
            System.debug('A DML Exception occurred: ' + e.getMessage());
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Info, 'There was a problem updating this case. Check for missing required fields');
            ApexPages.addMessage(msg);
        }
        return null;
    }
}