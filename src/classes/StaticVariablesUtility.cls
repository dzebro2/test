/******************************************************************************************
 * Created By:       Deloitte Consulting LLP.
 * Created Date:      11/19/2014
 * Description:     Class containing static variables for used acroos all the classes. These variables 
                    are used whereever the hard code of the string or integer values are required. 
                    This class also contains the methods those could be used as utility methods 
                    in the application. 
 *
 *     Modification Log:
 *    -----------------------------------------------------------------------------
 *    * Developer                   Date            Description
 *    * ----------------------------------------------------------------------------                 
 *    * Suyog Dongaonkar           11/19/2014      Initial version.                                 
 ******************************************************************************************/
public with sharing class StaticVariablesUtility {
    
    //Static variables related to DisplayResultsController and SearchPageController
     
    public static String searchQueryString = 'search';
    
    public static String accountNameQueryString     = 'accountName';
    public static String accountIDQueryString       = 'accountID';
    public static String accountTypeQueryString     = 'accountType';
    
    public static String contactNameQueryString     = 'contactName';
    public static String contactIDQueryString       = 'contactID';
    public static String contactPhoneQueryString    = 'contactPhone';
    public static String contactEmailQueryString    = 'contactEmail';
    public static String contactTypeQueryString     = 'contactType';
    
    public static String urlEncodingScheme          = 'UTF-8'; 
    
    
    //Static variables related to TakeACasePinnedListController
    public static Double casePushTopicAPIVersion        = 28.0;
    public static String casePushTopicName              = 'HCSCCaseNotifications'; 
    public static String testCasePushTopicName          = 'TestTest';   
    public static String casePushTopicDescription       = 'Case Notifications';
    public static String casePushTopicNotifyForFields   = 'Referenced';
    public static String casePushTopicQuery             = 'SELECT Id, ownerId, Assigned_To__c, Status FROM Case';
    
    //Static variables related to UpdateFieldsOnCase
    public static String casePriorityLow        = 'Low';
    public static String casePriorityMedium     = 'Medium';
    public static String casePriorityHigh       = 'High';
    public static String casePriorityCritical   = 'Critical';
    
    //Static variables related to Account Cancellation
    public static String AccCancelStatusPending = 'Pending Approval';
    public static String AccCancelStatusCancelled = 'Cancelled';
    
}