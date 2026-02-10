using UnityEngine;
using UnityEngine.Tilemaps;
using System.Collections.Generic;

namespace MobileGameMVP.World
{
    public class ChunkManager : MonoBehaviour
    {
        [Header("References")]
        [SerializeField] private Tilemap tilemap;
        [SerializeField] private Transform player;
        
        [Header("Tiles")]
        [SerializeField] private TileBase grassTile;
        [SerializeField] private TileBase waterTile;
        [SerializeField] private TileBase snowTile;
        
        [Header("Settings")]
        [SerializeField] private int viewDistance = 3;
        [SerializeField] private int unloadDistance = 5;
        
        private Dictionary<Vector2Int, Chunk> activeChunks = new Dictionary<Vector2Int, Chunk>();
        private Queue<Chunk> chunkPool = new Queue<Chunk>();
        private BiomeGenerator biomeGenerator;
        private HousePlacer housePlacer;
        private Vector2Int lastPlayerChunk = new Vector2Int(int.MaxValue, int.MaxValue);

        public void Initialize(int worldSeed)
        {
            biomeGenerator = new BiomeGenerator(worldSeed);
            housePlacer = new HousePlacer(worldSeed, biomeGenerator);
        }

        private void Update()
        {
            if (player == null) return;

            Vector2Int currentPlayerChunk = GetChunkPosition(player.position);

            if (currentPlayerChunk != lastPlayerChunk)
            {
                UpdateChunks(currentPlayerChunk);
                lastPlayerChunk = currentPlayerChunk;
            }
        }

        private void UpdateChunks(Vector2Int playerChunk)
        {
            HashSet<Vector2Int> chunksToKeep = new HashSet<Vector2Int>();

            for (int x = -viewDistance; x <= viewDistance; x++)
            {
                for (int y = -viewDistance; y <= viewDistance; y++)
                {
                    Vector2Int chunkPos = new Vector2Int(playerChunk.x + x, playerChunk.y + y);
                    chunksToKeep.Add(chunkPos);

                    if (!activeChunks.ContainsKey(chunkPos))
                    {
                        LoadChunk(chunkPos);
                    }
                }
            }

            List<Vector2Int> chunksToUnload = new List<Vector2Int>();
            foreach (var kvp in activeChunks)
            {
                Vector2Int chunkPos = kvp.Key;
                int distance = Mathf.Max(Mathf.Abs(chunkPos.x - playerChunk.x), 
                                        Mathf.Abs(chunkPos.y - playerChunk.y));

                if (distance > unloadDistance)
                {
                    chunksToUnload.Add(chunkPos);
                }
            }

            foreach (var chunkPos in chunksToUnload)
            {
                UnloadChunk(chunkPos);
            }
        }

        private void LoadChunk(Vector2Int chunkPosition)
        {
            Chunk chunk = GetChunkFromPool();
            chunk.Initialize(chunkPosition, biomeGenerator, tilemap);
            chunk.Generate(grassTile, waterTile, snowTile);
            
            if (housePlacer != null)
            {
                housePlacer.PlaceHousesInChunk(chunk, transform);
            }

            activeChunks[chunkPosition] = chunk;
        }

        private void UnloadChunk(Vector2Int chunkPosition)
        {
            if (activeChunks.TryGetValue(chunkPosition, out Chunk chunk))
            {
                chunk.Clear();
                ReturnChunkToPool(chunk);
                activeChunks.Remove(chunkPosition);
            }
        }

        private Chunk GetChunkFromPool()
        {
            if (chunkPool.Count > 0)
            {
                Chunk chunk = chunkPool.Dequeue();
                chunk.gameObject.SetActive(true);
                return chunk;
            }

            GameObject chunkObj = new GameObject("Chunk");
            chunkObj.transform.SetParent(transform);
            return chunkObj.AddComponent<Chunk>();
        }

        private void ReturnChunkToPool(Chunk chunk)
        {
            chunk.gameObject.SetActive(false);
            chunkPool.Enqueue(chunk);
        }

        private Vector2Int GetChunkPosition(Vector3 worldPosition)
        {
            int chunkX = Mathf.FloorToInt(worldPosition.x / Chunk.CHUNK_SIZE);
            int chunkY = Mathf.FloorToInt(worldPosition.y / Chunk.CHUNK_SIZE);
            return new Vector2Int(chunkX, chunkY);
        }

        public bool IsPositionWalkable(Vector3 worldPosition)
        {
            Vector2Int chunkPos = GetChunkPosition(worldPosition);
            
            if (!activeChunks.TryGetValue(chunkPos, out Chunk chunk))
                return true;

            int localX = Mathf.FloorToInt(worldPosition.x) - (chunkPos.x * Chunk.CHUNK_SIZE);
            int localY = Mathf.FloorToInt(worldPosition.y) - (chunkPos.y * Chunk.CHUNK_SIZE);

            return chunk.IsWalkableAt(localX, localY);
        }

        public void SetPlayer(Transform playerTransform)
        {
            player = playerTransform;
        }
    }
}
