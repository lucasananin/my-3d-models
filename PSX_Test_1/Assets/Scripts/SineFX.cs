using UnityEngine;

public class SineFX : MonoBehaviour
{
    [SerializeField] Transform _target = null;
    public float amplitude = 1f;   // How high and low the object moves
    public float frequency = 1f;   // How fast the oscillation happens

    private Vector3 startPos;

    void Start()
    {
        startPos = _target.position;
    }

    void Update()
    {
        //float offset = Mathf.PingPong(Time.time, frequency) * amplitude;
        float offset = Mathf.Sin(Time.time * frequency) * amplitude;
        _target.position = startPos + Vector3.up * offset;
    }
}
