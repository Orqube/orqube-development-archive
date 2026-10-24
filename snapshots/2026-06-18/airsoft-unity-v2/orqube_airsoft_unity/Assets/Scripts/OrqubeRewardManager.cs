using UnityEngine;

public class OrqubeRewardManager : MonoBehaviour
{
    public static OrqubeRewardManager Instance;

    private void Awake()
    {
        Instance = this;
    }

    public void AddGameReward(int score)
    {
        OrqubeUserProfile user = OrqubeLocalAuthManager.Instance.CurrentUser;
        user.gamePoint += score;
        user.orbsPendingPoint += score;
        OrqubeLocalAuthManager.Instance.SaveUser();
    }

    public string GetRewardSummary()
    {
        OrqubeUserProfile user = OrqubeLocalAuthManager.Instance.CurrentUser;
        return "Game Point: " + user.gamePoint + " / Pending ORBS Point: " + user.orbsPendingPoint;
    }
}
