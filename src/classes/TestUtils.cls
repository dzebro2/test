@isTest
public with sharing class TestUtils {
 public static User createTestUser(String userName, String profileName ){

        Id profileId;
        try{
            profileId = [SELECT Id FROM Profile WHERE  name =: profileName LIMIT 1 ].Id;
        }catch (Exception ex) {
            System.assert( false, profileName + ' profile does not exist in the system');
        }

        User testUser = new User();
        testUser.LastName = 'test ' + UserName;
        testUser.Alias = (userName.length() > 8 ) ?  userName.substring(0 , 8) : userName;
        testUser.Email = UserName+'@test.com';
        testUser.Username = UserName+UserName+'@test.com';
        testUser.ProfileId = profileId;
        testUser.CommunityNickname = 'a'+UserName;
        testUser.TimeZoneSidKey = 'America/New_York';
        testUser.LocaleSidKey = 'en_US';
        testUser.EmailEncodingKey = 'ISO-8859-1';
        testUser.LanguageLocaleKey = 'en_US';
        testUser.IsActive = true;

        return testUser;
    }
    
}