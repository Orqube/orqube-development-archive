using UnityEngine;
using TMPro;

public class OrqubeAccessManager : MonoBehaviour
{
    public static OrqubeAccessManager Instance;

    [Header("Game Access Rule")]
    public bool requireTokenOrNft = true;
    public int requiredOrbs = 1;
    public int requiredNft = 1;

    [Header("UI")]
    public GameObject startButton;
    public TextMeshProUGUI accessMessageText;

    private void Awake()
    {
        Instance = this;
    }

    private void Start()
    {
        RefreshAccessState();
    }

    public bool CanStartGame()
    {
        OrqubeUserProfile user = OrqubeLocalAuthManager.Instance.CurrentUser;

        if (!user.isLoggedIn)
        {
            return false;
        }

        if (!requireTokenOrNft)
        {
            return true;
        }

        bool hasEnoughToken = user.orbsBalance >= requiredOrbs;
        bool hasEnoughNft = user.nftCount >= requiredNft;

        return hasEnoughToken || hasEnoughNft;
    }

    public string GetAccessMessage()
    {
        OrqubeUserProfile user = OrqubeLocalAuthManager.Instance.CurrentUser;

        if (!user.isLoggedIn)
        {
            return "로그인이 필요합니다.";
        }

        if (CanStartGame())
        {
            return "게임 실행 가능: ORBS 토큰 또는 ORQUBE NFT 보유 확인 완료";
        }

        return "게임 시작 전 안내: ORBS 토큰 전환 신청 또는 ORQUBE NFT 보유가 필요합니다.";
    }

    public void RefreshAccessState()
    {
        bool canStart = CanStartGame();

        if (startButton != null)
        {
            startButton.SetActive(canStart);
        }

        if (accessMessageText != null)
        {
            accessMessageText.text = GetAccessMessage();
        }
    }

    public void Dev_ConvertPointToToken()
    {
        OrqubeUserProfile user = OrqubeLocalAuthManager.Instance.CurrentUser;

        if (user.appPoint < 100)
        {
            if (accessMessageText != null)
            {
                accessMessageText.text = "토큰 전환 신청 실패: 앱 포인트 100 이상 필요";
            }
            return;
        }

        user.appPoint -= 100;
        user.orbsBalance += 1;
        user.hasConvertedToken = true;
        OrqubeLocalAuthManager.Instance.SaveUser();
        RefreshAccessState();
    }

    public void Dev_AddNft()
    {
        OrqubeUserProfile user = OrqubeLocalAuthManager.Instance.CurrentUser;
        user.nftCount += 1;
        OrqubeLocalAuthManager.Instance.SaveUser();
        RefreshAccessState();
    }
}
