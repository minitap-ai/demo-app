using UnityEngine;
using UnityEngine.UI;
using UnityEngine.EventSystems;

namespace MobileGameMVP.Input
{
    public class VirtualJoystick : MonoBehaviour, IPointerDownHandler, IPointerUpHandler, IDragHandler
    {
        [Header("Joystick Components")]
        [SerializeField] private RectTransform joystickBackground;
        [SerializeField] private RectTransform joystickHandle;
        
        [Header("Settings")]
        [SerializeField] private float handleRange = 50f;
        [SerializeField] private float deadZone = 0.1f;
        [SerializeField] private bool dynamicJoystick = true;
        
        private Vector2 inputVector = Vector2.zero;
        private Vector2 joystickPosition = Vector2.zero;
        private Canvas canvas;
        private Camera mainCamera;
        private bool isActive = false;

        public Vector2 Direction => inputVector;
        public float Horizontal => inputVector.x;
        public float Vertical => inputVector.y;

        private void Start()
        {
            canvas = GetComponentInParent<Canvas>();
            mainCamera = Camera.main;
            
            if (joystickBackground != null)
            {
                joystickBackground.gameObject.SetActive(false);
            }
        }

        public void OnPointerDown(PointerEventData eventData)
        {
            if (!IsInLeftHalfOfScreen(eventData.position))
                return;

            isActive = true;

            if (dynamicJoystick && joystickBackground != null)
            {
                Vector2 localPoint;
                RectTransformUtility.ScreenPointToLocalPointInRectangle(
                    canvas.transform as RectTransform,
                    eventData.position,
                    canvas.renderMode == RenderMode.ScreenSpaceOverlay ? null : mainCamera,
                    out localPoint
                );

                joystickBackground.anchoredPosition = localPoint;
                joystickBackground.gameObject.SetActive(true);
                joystickPosition = localPoint;
            }

            OnDrag(eventData);
        }

        public void OnDrag(PointerEventData eventData)
        {
            if (!isActive)
                return;

            Vector2 localPoint;
            RectTransformUtility.ScreenPointToLocalPointInRectangle(
                joystickBackground,
                eventData.position,
                canvas.renderMode == RenderMode.ScreenSpaceOverlay ? null : mainCamera,
                out localPoint
            );

            Vector2 delta = localPoint;
            float distance = delta.magnitude;
            Vector2 direction = delta.normalized;

            if (distance > handleRange)
            {
                delta = direction * handleRange;
            }

            if (joystickHandle != null)
            {
                joystickHandle.anchoredPosition = delta;
            }

            float normalizedDistance = distance / handleRange;
            
            if (normalizedDistance < deadZone)
            {
                inputVector = Vector2.zero;
            }
            else
            {
                float adjustedDistance = (normalizedDistance - deadZone) / (1f - deadZone);
                inputVector = direction * Mathf.Clamp01(adjustedDistance);
            }
        }

        public void OnPointerUp(PointerEventData eventData)
        {
            if (!isActive)
                return;

            isActive = false;
            inputVector = Vector2.zero;

            if (joystickHandle != null)
            {
                joystickHandle.anchoredPosition = Vector2.zero;
            }

            if (dynamicJoystick && joystickBackground != null)
            {
                joystickBackground.gameObject.SetActive(false);
            }
        }

        private bool IsInLeftHalfOfScreen(Vector2 screenPosition)
        {
            return screenPosition.x < Screen.width * 0.5f;
        }

        public void ResetJoystick()
        {
            inputVector = Vector2.zero;
            isActive = false;
            
            if (joystickHandle != null)
            {
                joystickHandle.anchoredPosition = Vector2.zero;
            }
            
            if (joystickBackground != null)
            {
                joystickBackground.gameObject.SetActive(false);
            }
        }
    }
}
