using UnityEngine;

public class AirsoftTarget : MonoBehaviour
{
    [Header("Target Info")]
    public string targetTeam = "Red";
    public string targetCountry = "Korea";

    [Header("Target Health")]
    public int health = 30;

    private int startHealth;

    private void Start()
    {
        startHealth = health;
    }

    public void OnHit(int damage)
    {
        health -= damage;

        if (AirsoftGameManager.Instance != null)
        {
            AirsoftGameManager.Instance.AddScore(targetTeam, targetCountry, damage);
        }

        if (health <= 0)
        {
            RespawnTarget();
        }
    }

    private void RespawnTarget()
    {
        health = startHealth;

        float randomX = Random.Range(-5f, 5f);
        float randomZ = Random.Range(6f, 14f);

        transform.position = new Vector3(randomX, 1f, randomZ);
    }
}
