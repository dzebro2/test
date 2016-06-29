public with sharing class AccountTeamMemberDAO implements IAccountTeamMemberDAO
{
    public interface IAccountTeamMemberDAO{
        List<AccountTeamMember> getAccountTeamMemberById(Id myId);
    }

    public List<AccountTeamMember> getAccountTeamMemberById(Id myId){
        return [SELECT Id, AccountId FROM AccountTeamMember WHERE UserId = :myId];
    }
}