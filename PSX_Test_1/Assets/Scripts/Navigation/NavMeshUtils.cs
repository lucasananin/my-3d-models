using UnityEngine;
using UnityEngine.AI;

public static class NavMeshUtils
{
    public static Vector3 GetRandomNavMeshPoint(Vector3 center, float radius)
    {
        for (int i = 0; i < 30; i++) // Try up to 30 times to find a valid point
        {
            Vector3 randomPoint = center + Random.insideUnitSphere * radius;
            if (NavMesh.SamplePosition(randomPoint, out NavMeshHit hit, 2.0f, NavMesh.AllAreas))
            {
                return hit.position;
            }
        }

        Debug.LogWarning("Could not find a point on the NavMesh.");
        return center; // fallback if none found
    }
}
