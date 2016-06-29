/* @Trigger Name : RecursiveHelper
 * @Description  : Class used to prevent recursive actions from occuring. 
                   This contains the code that prevents the recursion of the code from the trigger mainly.
                   when we have a trigger on an object and some action is updating the same object record, 
                   then it may result into recursion and causing an exception, this class prevents this
                   recursion to occur.
 * @Created By   : Vishnu
 * @Created On   : 08-20-2013
 * @Modification Log:  
 * -----------------------------------------------------------------------------
 * @Developer                Date                   Description     
 * -----------------------------------------------------------------------------
 * @vishnu                   08-20-2013              Created
 * @vishnu                   10-17-2013             Made changes for Defect 1122
 * @Utkarsh Dixit			04/07/2013				MErging and owner update resolution D-1608
 * @Utkarsh Dixit			07/21/2014				Removed the unused booleans, affter refactoring Account and Entity team module.
 * -----------------------------------------------------------------------------
*/
public with sharing class RecursiveHelper {
    
    //Variable defined below in this class is used to stop the recursion to occur.
    //the variables are defined along with the getter and setter methods to initialize 
    //them and to set the values from the class or trigger to stop recursion.
    //Change: OWner update on merge: Start
    public static boolean entityTeamInsertedForCIF = false;//Validations must not be performed when the Entity team is inserted from Entity Trigger.
    public static boolean ownerUpdatedAfterMerge = false;//Once the owner is updated after the merge of the accounts the recursion must stop.
    public static boolean allowOwnerUpdate = false;//Flag to suggest that the owner must be calculated after the Entity teams are deleted due to merge operation.
    public static boolean ownerOnceUpdated = false;//This flag will be true when the owner is once updated by the Entity team trigger Helper method to calculate the owner.
    //Change: OWner update on merge: End
    public static boolean entityOwnerUpdated = false;//This stops the validations to fire when the owner is updated from the entity team trigger.
    public static boolean entityTeamDeletedbyEntityTrigger = false;//Flag to identify the deletion of the Entity teams from Entity trigger in case of Merge and hence to stop the recursion.
   	public static boolean entityTeamCreatedFromAccessLog = false;
   //@Utkarsh (07/21/2014): removed unused flags.
    // private static boolean ETsAlreadyProcessed = false;
    // private static boolean accsAlreadyProcessed = false;
     //public  static boolean ProcessedETOnMerge = false;
     //Defect 1122 changes
     private static boolean createdPlaybookRecs = false;
     //@Utkarsh (07/21/2014): removed unused flags.
    //public static boolean hasAlreadyProcessedET() {
      //  return ETsAlreadyProcessed;
    //}
   // public static void setETalreadyProcessed() {
     //   ETsAlreadyProcessed = true;
    //}
 //   public static boolean hasAlreadyProcessedAccs() {
  //      return accsAlreadyProcessed;
   // }
//    public static void setAccsalreadyProcessed() {
  //      accsAlreadyProcessed = true;
    //}
   // public static boolean hasProcessedEtOnMerge() {
       // return ProcessedETOnMerge;
    //}
  //  public static void setEtOnMergeProcessed() {
   //     ProcessedETOnMerge = true;
    //}
     //Defect 1122 changes start
    public static boolean hascreatedPlaybookRecs () {
        return createdPlaybookRecs;
    }
    public static void setCreatedPlaybookRecs() {
        createdPlaybookRecs  = true;
    }
     //Defect 1122 changes end
   
}