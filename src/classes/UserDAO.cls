/**************************************************************************************
  Apex Class Name     : UserDAO
  Version             : 1.0
  Function            : This is a User DAO class for accessing the User object.
  Modification Log    :
* Developer                 Date
* ----------------------------------------------------------------------------
* Alec Klein                6/8/2016
*************************************************************************************/
public class UserDAO implements IUserDAO {

	public interface IUserDAO {
		User createUser(Id profileId, String username, String lastName, String email);
		Id getUserIdByProfileName(String name);
		List<User> getUsersWithEmployeeNumber(Set<String> userIds);
		UserRecordAccess getUserEditAccess(Id userId, Id recordId);
	}

	public User createUser(Id profileId, String username, String lastName, String email) {
		return new User(Alias = 'test', Email = email, EmailEncodingKey = 'UTF-8', LastName = lastName, LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = profileId, TimeZoneSidKey = 'America/Los_Angeles', UserName = username);
	}

	public Id getUserIdByProfileName(String name) {
		return [SELECT Id FROM User WHERE Profile.Name = : name LIMIT 1].Id;
	}

	public List<User> getUsersWithEmployeeNumber(Set<String> userIds) {
		return [SELECT Id, EmployeeNumber FROM User WHERE Id IN :userIds];
	}

	public UserRecordAccess getUserEditAccess(Id userId, Id recordId) {
		return [SELECT RecordId, HasEditAccess FROM UserRecordAccess WHERE UserId = :userId AND RecordId = :recordId limit 1] [0];
	}
}