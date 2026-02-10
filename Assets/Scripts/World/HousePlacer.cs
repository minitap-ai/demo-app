using UnityEngine;
using System.Collections.Generic;

namespace MobileGameMVP.World
{
    public class HousePlacer
    {
        private readonly int seed;
        private readonly BiomeGenerator biomeGenerator;
        private readonly float houseDensity = 0.05f;
        private readonly float minHouseDistance = 8f;

        public GameObject housePrefab;

        public HousePlacer(int seed, BiomeGenerator biomeGenerator)
        {
            this.seed = seed;
            this.biomeGenerator = biomeGenerator;
        }

        public void PlaceHousesInChunk(Chunk chunk, Transform parent)
        {
            if (housePrefab == null)
            {
                Debug.LogWarning("House prefab not set in HousePlacer");
                return;
            }

            int chunkSeed = GetChunkSeed(chunk.chunkPosition);
            System.Random random = new System.Random(chunkSeed);

            int maxHouses = Mathf.FloorToInt(Chunk.CHUNK_SIZE * Chunk.CHUNK_SIZE * houseDensity);
            int houseCount = random.Next(0, maxHouses + 1);

            List<Vector2> placedHouses = new List<Vector2>();

            for (int i = 0; i < houseCount; i++)
            {
                int attempts = 0;
                const int maxAttempts = 10;

                while (attempts < maxAttempts)
                {
                    int localX = random.Next(2, Chunk.CHUNK_SIZE - 2);
                    int localY = random.Next(2, Chunk.CHUNK_SIZE - 2);

                    int worldX = chunk.chunkPosition.x * Chunk.CHUNK_SIZE + localX;
                    int worldY = chunk.chunkPosition.y * Chunk.CHUNK_SIZE + localY;

                    if (IsValidHousePosition(worldX, worldY, placedHouses))
                    {
                        Vector3 housePosition = new Vector3(worldX + 0.5f, worldY + 0.5f, 0);
                        GameObject house = Object.Instantiate(housePrefab, housePosition, Quaternion.identity, parent);
                        house.name = $"House_{worldX}_{worldY}";
                        
                        chunk.houses.Add(house);
                        placedHouses.Add(new Vector2(worldX, worldY));
                        break;
                    }

                    attempts++;
                }
            }
        }

        private bool IsValidHousePosition(int worldX, int worldY, List<Vector2> existingHouses)
        {
            BiomeType biome = biomeGenerator.GetBiomeAt(worldX, worldY);
            if (!biomeGenerator.IsWalkable(biome))
            {
                return false;
            }

            for (int dx = -1; dx <= 1; dx++)
            {
                for (int dy = -1; dy <= 1; dy++)
                {
                    BiomeType surroundingBiome = biomeGenerator.GetBiomeAt(worldX + dx, worldY + dy);
                    if (!biomeGenerator.IsWalkable(surroundingBiome))
                    {
                        return false;
                    }
                }
            }

            Vector2 position = new Vector2(worldX, worldY);
            foreach (var existingHouse in existingHouses)
            {
                if (Vector2.Distance(position, existingHouse) < minHouseDistance)
                {
                    return false;
                }
            }

            return true;
        }

        private int GetChunkSeed(Vector2Int chunkPosition)
        {
            int hash = seed;
            hash = hash * 31 + chunkPosition.x;
            hash = hash * 31 + chunkPosition.y;
            return hash;
        }
    }
}
