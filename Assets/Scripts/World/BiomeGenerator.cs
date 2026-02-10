using UnityEngine;

namespace MobileGameMVP.World
{
    public class BiomeGenerator
    {
        private readonly int seed;
        private readonly float elevationScale = 0.05f;
        private readonly float moistureScale = 0.08f;
        private readonly int octaves = 4;
        private readonly float persistence = 0.5f;
        private readonly float lacunarity = 2.0f;

        public BiomeGenerator(int seed)
        {
            this.seed = seed;
        }

        public BiomeType GetBiomeAt(int worldX, int worldY)
        {
            float elevation = GenerateLayeredNoise(worldX, worldY, seed, elevationScale);
            float moisture = GenerateLayeredNoise(worldX, worldY, seed + 1000, moistureScale);

            if (elevation < 0.35f)
            {
                return BiomeType.Water;
            }
            else if (elevation > 0.65f && moisture < 0.4f)
            {
                return BiomeType.Snow;
            }
            else
            {
                return BiomeType.Grass;
            }
        }

        private float GenerateLayeredNoise(int x, int y, int noiseSeed, float scale)
        {
            float total = 0f;
            float amplitude = 1f;
            float frequency = 1f;
            float maxValue = 0f;

            for (int i = 0; i < octaves; i++)
            {
                float sampleX = (x + noiseSeed * 1000) * scale * frequency;
                float sampleY = (y + noiseSeed * 1000) * scale * frequency;

                float perlinValue = Mathf.PerlinNoise(sampleX, sampleY);
                total += perlinValue * amplitude;

                maxValue += amplitude;
                amplitude *= persistence;
                frequency *= lacunarity;
            }

            return total / maxValue;
        }

        public bool IsWalkable(BiomeType biome)
        {
            return biome != BiomeType.Water;
        }
    }
}
