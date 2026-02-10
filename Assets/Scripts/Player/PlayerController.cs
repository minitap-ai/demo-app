using UnityEngine;
using MobileGameMVP.Input;
using MobileGameMVP.World;

namespace MobileGameMVP.Player
{
    [RequireComponent(typeof(PlayerMovement))]
    public class PlayerController : MonoBehaviour
    {
        [Header("References")]
        [SerializeField] private VirtualJoystick joystick;
        
        [Header("Visual")]
        [SerializeField] private SpriteRenderer spriteRenderer;
        [SerializeField] private bool flipSpriteWithDirection = true;
        
        private PlayerMovement movement;
        private Vector2 lastMovementDirection = Vector2.down;

        private void Awake()
        {
            movement = GetComponent<PlayerMovement>();
        }

        private void Start()
        {
            if (joystick == null)
            {
                joystick = FindObjectOfType<VirtualJoystick>();
            }

            if (spriteRenderer == null)
            {
                spriteRenderer = GetComponentInChildren<SpriteRenderer>();
            }
        }

        public void Initialize(ChunkManager chunkManager)
        {
            movement.Initialize(chunkManager);
        }

        private void Update()
        {
            HandleInput();
            UpdateVisuals();
        }

        private void HandleInput()
        {
            Vector2 input = Vector2.zero;

            if (joystick != null)
            {
                input = joystick.Direction;
            }
            else
            {
                input.x = UnityEngine.Input.GetAxisRaw("Horizontal");
                input.y = UnityEngine.Input.GetAxisRaw("Vertical");
                
                if (input.magnitude > 1f)
                {
                    input.Normalize();
                }
            }

            movement.SetMovementInput(input);

            if (input.magnitude > 0.1f)
            {
                lastMovementDirection = input.normalized;
            }
        }

        private void UpdateVisuals()
        {
            if (spriteRenderer != null && flipSpriteWithDirection)
            {
                if (lastMovementDirection.x < -0.1f)
                {
                    spriteRenderer.flipX = true;
                }
                else if (lastMovementDirection.x > 0.1f)
                {
                    spriteRenderer.flipX = false;
                }
            }
        }

        public void SetPosition(Vector3 position)
        {
            transform.position = position;
        }

        public Vector3 GetPosition()
        {
            return transform.position;
        }

        public Vector2 GetFacingDirection()
        {
            return lastMovementDirection;
        }
    }
}
