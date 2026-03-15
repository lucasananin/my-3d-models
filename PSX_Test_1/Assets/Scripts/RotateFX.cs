using UnityEngine;

public class RotateFX : MonoBehaviour
{
    [SerializeField] Transform _target = null;
    [SerializeField] Vector3 _euler = default;

    private void LateUpdate()
    {
        _target.Rotate(_euler * Time.deltaTime);
    }
}
