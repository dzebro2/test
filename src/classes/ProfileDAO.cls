public with sharing class ProfileDAO implements IProfileDAO {
	public interface IProfileDAO {
		Profile getProfileByName(String name);
	}

	public Profile getProfileByName(String name) {
		return [SELECT id, name FROM profile WHERE name = :name LIMIT 1];
	}
}