using UnityEngine;
using UnityEngine.Tilemaps;
using System.Collections.Generic;

namespace MobileGameMVP.World
{
    public class Chunk : MonoBehaviour
    {
        public const int CHUNK_SIZE = 32;
        
        public Vector2Int chunkPosition;
        public TileData[,] tiles;
        public List<GameObject> houses = new List<GameObject>();
        
        private Tilemap tilemap;
        private BiomeGenerator biomeGenerator;
        private bool isGenerated = false;

        public void Initialize(Vector2Int position, BiomeGenerator generator, Tilemap map)
        {
            chunkPosition = position;
            biomeGenerator = generator;
            tilemap = map;
            tiles = new TileData[CHUNK_SIZE, CHUNK_SIZE];
        }

        public void Generate(TileBase grassTile, TileBase waterTile, TileBase snowTile)
        {
            if (isGenerated) return;

            int worldStartX = chunkPosition.x * CHUNK_SIZE;
            int worldStartY = chunkPosition.y * CHUNK_SIZE;

            for (int x = 0; x < CHUNK_SIZE; x++)
            {
                for (int y = 0; y < CHUNK_SIZE; y++)
                {
                    int worldX = worldStartX + x;
                    int worldY = worldStartY + y;

                    BiomeType biome = biomeGenerator.GetBiomeAt(worldX, worldY);
                    bool walkable = biomeGenerator.IsWalkable(biome);

                    tiles[x, y] = new TileData(biome, new Vector2Int(worldX, worldY), walkable);

                    Vector3Int tilePosition = new Vector3Int(worldX, worldY, 0);
                    TileBase tileToPlace = GetTileForBiome(biome, grassTile, waterTile, snowTile);
                    
                    if (tilemap != null && tileToPlace != null)
                    {
                        tilemap.SetTile(tilePosition, tileToPlace);
                    }
                }
            }

            isGenerated = true;
        }

        private TileBase GetTileForBiome(BiomeType biome, TileBase grass, TileBase water, TileBase snow)
        {
            switch (biome)
            {
                case BiomeType.Grass:
                    return grass;
                case BiomeType.Water:
                    return water;
                case BiomeType.Snow:
                    return snow;
                default:
                    return grass;
            }
        }

        public void Clear()
        {
            if (tilemap != null)
            {
                int worldStartX = chunkPosition.x * CHUNK_SIZE;
                int worldStartY = chunkPosition.y * CHUNK_SIZE;

                for (int x = 0; x < CHUNK_SIZE; x++)
                {
                    for (int y = 0; y < CHUNK_SIZE; y++)
                    {
                        Vector3Int tilePosition = new Vector3Int(worldStartX + x, worldStartY + y, 0);
                        tilemap.SetTile(tilePosition, null);
                    }
                }
            }

            foreach (var house in houses)
            {
                if (house != null)
                {
                    Destroy(house);
                }
            }
            houses.Clear();

            isGenerated = false;
        }

        public bool IsWalkableAt(int localX, int localY)
        {
            if (localX < 0 || localX >= CHUNK_SIZE || localY < 0 || localY >= CHUNK_SIZE)
                return true;

            return tiles[localX, localY].isWalkable;
        }
    }
}
