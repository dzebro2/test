/**************************************************************************************
  Apex Class Name     : StrategicPlanTriggerHandler  
  Version             : 1.0
  Function            : This is a handler class for StrategicPlanTrigger.
  Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------
*   Jermaine Lindsay       03/15/2016                Original Version
*************************************************************************************/

public class StrategicPlanTriggerHandler{

    /*  validateRecordChange
    *   @description:   This method checks if theuser is able to update the strategic plan based on the effective date.
    *                   This method is used for the before update scenario
    *   @parameters     Map <Id, Strategic_Plan__c> newPlans & Map <Id, Strategic_Plan__c> oldPlans
    *   @return type    void
    */
    public static void validateRecordChange(Map <Id, Strategic_Plan__c> newPlans, Map <Id, Strategic_Plan__c> oldPlans) {

        Strategic_Plan__c OldSp;
        Set<Id> newKeys;

        try{
            //Get profile of current user
            List<Profile> PROFILE = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
            String userProfile = PROFILE[0].Name;

            Boolean spProfile = false;
            List<Strategic_Plan_Super_Users__c> spSuperList = Strategic_Plan_Super_Users__c.getall().values();
            for(Strategic_Plan_Super_Users__c spu : spSuperList){
                if (spu.Name == userProfile) { 
                  spProfile = true;
                }
            }

            Strategic_Plan__c newSp;
            newKeys = newPlans.KeySet();
            //Execute the logic if the profile is not in the list of approved Strategic Plan Super Users
            if(!spProfile){
                for(Id curId : newKeys){
                    newSp = newPlans.get(curId);
                    OldSp = oldPlans.get(newSp.Id);
                    if(OldSp.Effective_Date__c <= Date.today()){
                        if(newSp.Effective_Date__c != OldSp.Effective_Date__c || newSp.Name != OldSp.Name ||
                        newSp.Account_Name__c != OldSp.Account_Name__c){
                            newSp.addError(Label.Strategic_Plan_Update_Not_Allowed);
                        }
                    }
                }
            }  
        }catch (Exception ex){
            for(Id curId : newKeys){
                newPlans.get(curId).addError( Label.AnErrorHasOcurred + ' : ' + ex.getMessage() );
            } 
            CreateExceptionLog.insertErrorLog(ex, null, null, null, 'Apex Class', 'Strategic Plan', 'StrategicPlanTrigger', 'StrategicPlanTriggerHandler.validateRecordChange()', 'High');
        } 
    }

    /*  resetFieldsForCloned
    *   @description:   This method resetsCertainFields for cloned Strategic Plans
    *                  
    *   @parameters     List<Strategic_Plan__c>
    *   @return type    void
    */
    public static void resetFieldsForClonedSP(List <Strategic_Plan__c> newPlans) {

        if (newPlans != null){
            try{ 
                for(Strategic_Plan__c sp : newPlans){
                    if (sp.isClone()) { 
                      sp.Manager_Approval__c = false;
                    }
                }

            }catch (Exception ex){
                for(Strategic_Plan__c sp : newPlans){
                    sp.addError( Label.AnErrorHasOcurred + ' : ' + ex.getMessage() );
                } 
                CreateExceptionLog.insertErrorLog(ex, null, null, null, 'Apex Class', 'Strategic Plan', 'StrategicPlanTrigger', 'StrategicPlanTriggerHandler.validateRecordChange()', 'High');
            }
        } 
    }  
}