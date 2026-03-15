using UnityEngine;
using UnityEngine.AI;

public class AIRandomMover : MonoBehaviour
{
    [SerializeField] NavMeshAgent _agent = null;
    [SerializeField] float _rotationSpeed = 10f;
    [SerializeField] float _minRotationMagnitude = 0.1f;
    [SerializeField] Vector2 _moveRateRange = new(1f, 2f);

    [Header("// DEBUG")]
    [SerializeField] float _waitTime = 0f;
    [SerializeField] float _timer = 0f;

    private void Awake()
    {
        _waitTime = Random.Range(_moveRateRange.x, _moveRateRange.y);
    }

    private void Update()
    {
        if (HasReachedDestination())
        {
            _timer += Time.deltaTime;

            if (_timer > _waitTime)
            {
                _timer = 0;
                _waitTime = Random.Range(_moveRateRange.x, _moveRateRange.y);
                MoveToRandomDestination();
            }
        }

        RotateToMovement();
    }

    public void MoveToRandomDestination()
    {
        var _randomPoint = NavMeshUtils.GetRandomNavMeshPoint(transform.position, 10f);
        SetDestination(_randomPoint);
    }

    public void SetDestination(Vector3 _position)
    {
        _agent.SetDestination(_position);
    }

    public void RotateToMovement()
    {
        if (_agent.velocity.sqrMagnitude > _minRotationMagnitude)
        {
            var _forward = new Vector3(_agent.velocity.x, 0, _agent.velocity.z).normalized;

            if (_forward != Vector3.zero)
            {
                Quaternion _targetRotation = Quaternion.LookRotation(_forward);
                transform.rotation = Quaternion.Slerp(transform.rotation, _targetRotation, Time.deltaTime * _rotationSpeed);
            }
        }
    }

    public bool HasReachedDestination()
    {
        return !_agent.hasPath || (_agent.pathPending && _agent.velocity == Vector3.zero);
    }
}
