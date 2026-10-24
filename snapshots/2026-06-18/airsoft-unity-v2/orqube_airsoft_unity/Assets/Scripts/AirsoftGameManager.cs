using UnityEngine;
using TMPro;

public class AirsoftGameManager : MonoBehaviour
{
    public static AirsoftGameManager Instance;

    [Header("Player Info")]
    public string playerName = "ORQUBE Player";
    public string playerTeam = "Red Team";
    public string playerCountry = "Korea";

    [Header("Scores")]
    public int personalScore = 0;
    public int redTeamScore = 0;
    public int blueTeamScore = 0;

    public int koreaScore = 0;
    public int japanScore = 0;
    public int usaScore = 0;

    [Header("ORQUBE Reward")]
    public int orbsPoint = 0;

    [Header("UI")]
    public TextMeshProUGUI infoText;

    private void Awake()
    {
        if (Instance == null)
        {
            Instance = this;
        }
        else
        {
            Destroy(gameObject);
        }
    }

    private void Start()
    {
        UpdateUI();
    }

    public void AddScore(string team, string country, int score)
    {
        personalScore += score;
        orbsPoint += score;

        if (OrqubeRewardManager.Instance != null)
        {
            OrqubeRewardManager.Instance.AddGameReward(score);
        }

        if (team == "Red")
        {
            redTeamScore += score;
        }
        else if (team == "Blue")
        {
            blueTeamScore += score;
        }

        if (country == "Korea")
        {
            koreaScore += score;
        }
        else if (country == "Japan")
        {
            japanScore += score;
        }
        else if (country == "USA")
        {
            usaScore += score;
        }

        UpdateUI();
    }

    private string GetExternalRewardText()
    {
        if (OrqubeRewardManager.Instance == null) return "";
        return OrqubeRewardManager.Instance.GetRewardSummary();
    }

    public void UpdateUI()
    {
        if (infoText == null) return;

        infoText.text =
            "ORQUBE AIRSOFT SURVIVAL\n\n" +
            "Player: " + playerName + "\n" +
            "Team: " + playerTeam + "\n" +
            "Country: " + playerCountry + "\n\n" +
            "Personal Score: " + personalScore + "\n" +
            "ORBS Point: " + orbsPoint + "\n" +
            GetExternalRewardText() + "\n\n" +
            "[Team Ranking]\n" +
            "Red Team: " + redTeamScore + "\n" +
            "Blue Team: " + blueTeamScore + "\n\n" +
            "[Country Ranking]\n" +
            "Korea: " + koreaScore + "\n" +
            "Japan: " + japanScore + "\n" +
            "USA: " + usaScore;
    }
}
