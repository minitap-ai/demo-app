using UnityEngine;

namespace MobileGameMVP.Camera
{
    public class CameraFollow : MonoBehaviour
    {
        [Header("Target")]
        [SerializeField] private Transform target;
        
        [Header("Follow Settings")]
        [SerializeField] private float smoothSpeed = 5f;
        [SerializeField] private Vector3 offset = new Vector3(0, 0, -10);
        
        [Header("Bounds (Optional)")]
        [SerializeField] private bool useBounds = false;
        [SerializeField] private Vector2 minBounds;
        [SerializeField] private Vector2 maxBounds;
        
        [Header("Camera Settings")]
        [SerializeField] private float orthographicSize = 8f;
        
        private UnityEngine.Camera cam;

        private void Awake()
        {
            cam = GetComponent<UnityEngine.Camera>();
            
            if (cam != null)
            {
                cam.orthographic = true;
                cam.orthographicSize = orthographicSize;
            }
        }

        private void LateUpdate()
        {
            if (target == null)
                return;

            Vector3 targetPosition = target.position + offset;

            if (useBounds)
            {
                targetPosition.x = Mathf.Clamp(targetPosition.x, minBounds.x, maxBounds.x);
                targetPosition.y = Mathf.Clamp(targetPosition.y, minBounds.y, maxBounds.y);
            }

            Vector3 smoothedPosition = Vector3.Lerp(
                transform.position,
                targetPosition,
                smoothSpeed * Time.deltaTime
            );

            smoothedPosition.z = offset.z;

            transform.position = smoothedPosition;
        }

        public void SetTarget(Transform newTarget)
        {
            target = newTarget;
        }

        public void SetPosition(Vector3 position)
        {
            position.z = offset.z;
            transform.position = position;
        }

        public void SetOrthographicSize(float size)
        {
            orthographicSize = size;
            if (cam != null)
            {
                cam.orthographicSize = size;
            }
        }

        public void EnableBounds(Vector2 min, Vector2 max)
        {
            useBounds = true;
            minBounds = min;
            maxBounds = max;
        }

        public void DisableBounds()
        {
            useBounds = false;
        }
    }
}
