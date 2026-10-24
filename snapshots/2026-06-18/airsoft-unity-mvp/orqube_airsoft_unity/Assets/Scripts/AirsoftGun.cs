using UnityEngine;

public class AirsoftGun : MonoBehaviour
{
    [Header("Gun Settings")]
    public Camera playerCamera;
    public float range = 100f;
    public int hitScore = 10;

    private void Start()
    {
        if (playerCamera == null)
        {
            playerCamera = Camera.main;
        }
    }

    private void Update()
    {
        if (Input.GetMouseButtonDown(0))
        {
            Shoot();
        }
    }

    private void Shoot()
    {
        if (playerCamera == null) return;

        Ray ray = new Ray(playerCamera.transform.position, playerCamera.transform.forward);
        RaycastHit hit;

        if (Physics.Raycast(ray, out hit, range))
        {
            AirsoftTarget target = hit.collider.GetComponent<AirsoftTarget>();

            if (target != null)
            {
                target.OnHit(hitScore);
            }

            Debug.Log("Hit: " + hit.collider.name);
        }
    }
}
