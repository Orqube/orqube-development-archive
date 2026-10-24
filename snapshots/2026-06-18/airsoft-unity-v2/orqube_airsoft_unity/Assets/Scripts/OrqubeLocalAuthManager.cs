using UnityEngine;

public class OrqubeLocalAuthManager : MonoBehaviour
{
    public static OrqubeLocalAuthManager Instance;
    public OrqubeUserProfile CurrentUser { get; private set; }

    private const string SaveKey = "ORQUBE_USER_PROFILE";

    private void Awake()
    {
        if (Instance != null && Instance != this)
        {
            Destroy(gameObject);
            return;
        }

        Instance = this;
        DontDestroyOnLoad(gameObject);
        AutoLogin();
    }

    public void AutoLogin()
    {
        string json = PlayerPrefs.GetString(SaveKey, "");

        if (string.IsNullOrEmpty(json))
        {
            CurrentUser = OrqubeUserProfile.CreateGuest();
            SaveUser();
        }
        else
        {
            CurrentUser = JsonUtility.FromJson<OrqubeUserProfile>(json);
            if (CurrentUser == null)
            {
                CurrentUser = OrqubeUserProfile.CreateGuest();
                SaveUser();
            }
        }

        Debug.Log("ORQUBE Auto Login: " + CurrentUser.nickname);
    }

    public void UpdateProfile(string nickname, string country, string team)
    {
        CurrentUser.nickname = nickname;
        CurrentUser.country = country;
        CurrentUser.team = team;
        SaveUser();
    }

    public void SaveUser()
    {
        string json = JsonUtility.ToJson(CurrentUser);
        PlayerPrefs.SetString(SaveKey, json);
        PlayerPrefs.Save();
    }

    public void ResetLocalUser()
    {
        PlayerPrefs.DeleteKey(SaveKey);
        CurrentUser = OrqubeUserProfile.CreateGuest();
        SaveUser();
    }
}
