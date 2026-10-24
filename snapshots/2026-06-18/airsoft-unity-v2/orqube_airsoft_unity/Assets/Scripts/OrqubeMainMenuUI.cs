using UnityEngine;
using UnityEngine.SceneManagement;
using TMPro;

public class OrqubeMainMenuUI : MonoBehaviour
{
    public TextMeshProUGUI userInfoText;
    public TextMeshProUGUI guideText;
    public string gameSceneName = "MainScene";

    private void Start()
    {
        RefreshUI();
    }

    public void RefreshUI()
    {
        OrqubeUserProfile user = OrqubeLocalAuthManager.Instance.CurrentUser;

        if (userInfoText != null)
        {
            userInfoText.text =
                "ORQUBE Login Complete\n" +
                "Nickname: " + user.nickname + "\n" +
                "Country: " + user.country + "\n" +
                "Team: " + user.team + "\n" +
                "App Point: " + user.appPoint + "\n" +
                "ORBS Balance: " + user.orbsBalance + "\n" +
                "NFT Count: " + user.nftCount;
        }

        if (guideText != null && OrqubeAccessManager.Instance != null)
        {
            guideText.text = OrqubeAccessManager.Instance.GetAccessMessage();
        }
    }

    public void OnClickStartGame()
    {
        if (OrqubeAccessManager.Instance.CanStartGame())
        {
            SceneManager.LoadScene(gameSceneName);
        }
        else
        {
            if (guideText != null)
            {
                guideText.text = OrqubeAccessManager.Instance.GetAccessMessage();
            }
        }
    }

    public void OnClickConvertToken()
    {
        OrqubeAccessManager.Instance.Dev_ConvertPointToToken();
        RefreshUI();
    }

    public void OnClickAddTestNft()
    {
        OrqubeAccessManager.Instance.Dev_AddNft();
        RefreshUI();
    }

    public void OnClickResetUser()
    {
        OrqubeLocalAuthManager.Instance.ResetLocalUser();
        RefreshUI();
    }
}
