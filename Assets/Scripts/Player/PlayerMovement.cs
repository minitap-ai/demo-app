using UnityEngine;
using MobileGameMVP.World;

namespace MobileGameMVP.Player
{
    [RequireComponent(typeof(Rigidbody2D))]
    [RequireComponent(typeof(CircleCollider2D))]
    public class PlayerMovement : MonoBehaviour
    {
        [Header("Movement Settings")]
        [SerializeField] private float moveSpeed = 5f;
        [SerializeField] private float acceleration = 20f;
        [SerializeField] private float deceleration = 15f;
        
        [Header("Collision")]
        [SerializeField] private LayerMask collisionLayer;
        [SerializeField] private float collisionCheckRadius = 0.3f;
        
        private Rigidbody2D rb;
        private Vector2 currentVelocity = Vector2.zero;
        private Vector2 movementInput = Vector2.zero;
        private ChunkManager chunkManager;

        private void Awake()
        {
            rb = GetComponent<Rigidbody2D>();
            rb.gravityScale = 0f;
            rb.constraints = RigidbodyConstraints2D.FreezeRotation;
            rb.collisionDetectionMode = CollisionDetectionMode2D.Continuous;
        }

        public void Initialize(ChunkManager manager)
        {
            chunkManager = manager;
        }

        public void SetMovementInput(Vector2 input)
        {
            movementInput = input;
        }

        private void FixedUpdate()
        {
            UpdateMovement();
        }

        private void UpdateMovement()
        {
            Vector2 targetVelocity = movementInput * moveSpeed;

            if (movementInput.magnitude > 0.01f)
            {
                currentVelocity = Vector2.MoveTowards(
                    currentVelocity,
                    targetVelocity,
                    acceleration * Time.fixedDeltaTime
                );
            }
            else
            {
                currentVelocity = Vector2.MoveTowards(
                    currentVelocity,
                    Vector2.zero,
                    deceleration * Time.fixedDeltaTime
                );
            }

            if (currentVelocity.magnitude > 0.01f)
            {
                Vector2 newPosition = rb.position + currentVelocity * Time.fixedDeltaTime;

                if (IsPositionValid(newPosition))
                {
                    rb.MovePosition(newPosition);
                }
                else
                {
                    Vector2 horizontalPosition = new Vector2(newPosition.x, rb.position.y);
                    Vector2 verticalPosition = new Vector2(rb.position.x, newPosition.y);

                    if (IsPositionValid(horizontalPosition))
                    {
                        rb.MovePosition(horizontalPosition);
                    }
                    else if (IsPositionValid(verticalPosition))
                    {
                        rb.MovePosition(verticalPosition);
                    }
                    else
                    {
                        currentVelocity = Vector2.zero;
                    }
                }
            }
        }

        private bool IsPositionValid(Vector2 position)
        {
            if (chunkManager != null && !chunkManager.IsPositionWalkable(position))
            {
                return false;
            }

            Collider2D[] colliders = Physics2D.OverlapCircleAll(position, collisionCheckRadius, collisionLayer);
            
            foreach (var collider in colliders)
            {
                if (collider.gameObject != gameObject)
                {
                    return false;
                }
            }

            return true;
        }

        public Vector2 GetVelocity()
        {
            return currentVelocity;
        }

        public bool IsMoving()
        {
            return currentVelocity.magnitude > 0.1f;
        }

        private void OnDrawGizmosSelected()
        {
            Gizmos.color = Color.yellow;
            Gizmos.DrawWireSphere(transform.position, collisionCheckRadius);
        }
    }
}
