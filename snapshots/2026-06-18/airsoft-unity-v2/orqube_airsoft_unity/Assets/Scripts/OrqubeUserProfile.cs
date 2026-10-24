using System;

[Serializable]
public class OrqubeUserProfile
{
    public string userId;
    public string email;
    public string nickname;
    public string country;
    public string team;

    public int appPoint;
    public int gamePoint;
    public int orbsPendingPoint;

    public int orbsBalance;
    public int nftCount;
    public bool hasConvertedToken;
    public bool isLoggedIn;

    public static OrqubeUserProfile CreateGuest()
    {
        return new OrqubeUserProfile
        {
            userId = Guid.NewGuid().ToString(),
            email = "guest@orqube.local",
            nickname = "ORQUBE Guest",
            country = "Korea",
            team = "Red",
            appPoint = 100,
            gamePoint = 0,
            orbsPendingPoint = 0,
            orbsBalance = 0,
            nftCount = 0,
            hasConvertedToken = false,
            isLoggedIn = true
        };
    }
}
