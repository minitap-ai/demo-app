using NUnit.Framework;
using UnityEngine;
using MobileGameMVP.World;
using System.Reflection;

namespace MobileGameMVP.Tests.EditMode
{
    [TestFixture]
    public class HousePlacerTests
    {
        private BiomeGenerator biomeGenerator;
        private HousePlacer housePlacer;

        [SetUp]
        public void SetUp()
        {
            biomeGenerator = new BiomeGenerator(12345);
            housePlacer = new HousePlacer(12345, biomeGenerator);
        }

        [Test]
        public void Constructor_InitializesWithSeedAndBiomeGenerator()
        {
            var placer = new HousePlacer(12345, biomeGenerator);
            Assert.IsNotNull(placer, "HousePlacer should be created successfully");
        }

        [Test]
        public void GetChunkSeed_SameChunkPosition_ReturnsSameSeed()
        {
            var chunkPos = new Vector2Int(5, 10);
            
            int seed1 = InvokeGetChunkSeed(housePlacer, chunkPos);
            int seed2 = InvokeGetChunkSeed(housePlacer, chunkPos);

            Assert.AreEqual(seed1, seed2, "Same chunk position should produce same seed");
        }

        [Test]
        public void GetChunkSeed_DifferentChunkPositions_ReturnsDifferentSeeds()
        {
            var chunkPos1 = new Vector2Int(5, 10);
            var chunkPos2 = new Vector2Int(6, 10);
            
            int seed1 = InvokeGetChunkSeed(housePlacer, chunkPos1);
            int seed2 = InvokeGetChunkSeed(housePlacer, chunkPos2);

            Assert.AreNotEqual(seed1, seed2, "Different chunk positions should produce different seeds");
        }

        [Test]
        public void GetChunkSeed_NegativeCoordinates_ReturnsValidSeed()
        {
            var chunkPos = new Vector2Int(-5, -10);
            
            int seed = InvokeGetChunkSeed(housePlacer, chunkPos);

            // Just verify it returns a value without throwing
            Assert.IsTrue(true, "Should handle negative coordinates");
        }

        [Test]
        public void IsValidHousePosition_OnWater_ReturnsFalse()
        {
            // Find a water tile
            Vector2Int waterPosition = FindBiomePosition(BiomeType.Water);
            
            var result = InvokeIsValidHousePosition(
                housePlacer, 
                waterPosition.x, 
                waterPosition.y, 
                new System.Collections.Generic.List<Vector2>()
            );

            Assert.IsFalse(result, "House should not be valid on water");
        }

        [Test]
        public void IsValidHousePosition_OnGrass_ReturnsTrue()
        {
            // Find a grass tile with grass surroundings
            Vector2Int grassPosition = FindValidGrassPosition();
            
            var result = InvokeIsValidHousePosition(
                housePlacer, 
                grassPosition.x, 
                grassPosition.y, 
                new System.Collections.Generic.List<Vector2>()
            );

            Assert.IsTrue(result, "House should be valid on grass with grass surroundings");
        }

        [Test]
        public void IsValidHousePosition_TooCloseToExistingHouse_ReturnsFalse()
        {
            Vector2Int grassPosition = FindValidGrassPosition();
            
            var existingHouses = new System.Collections.Generic.List<Vector2>
            {
                new Vector2(grassPosition.x + 2, grassPosition.y + 2) // Within minHouseDistance (8)
            };

            var result = InvokeIsValidHousePosition(
                housePlacer, 
                grassPosition.x, 
                grassPosition.y, 
                existingHouses
            );

            Assert.IsFalse(result, "House should not be valid too close to existing house");
        }

        [Test]
        public void IsValidHousePosition_FarFromExistingHouse_ReturnsTrue()
        {
            Vector2Int grassPosition = FindValidGrassPosition();
            
            var existingHouses = new System.Collections.Generic.List<Vector2>
            {
                new Vector2(grassPosition.x + 20, grassPosition.y + 20) // Far enough away
            };

            var result = InvokeIsValidHousePosition(
                housePlacer, 
                grassPosition.x, 
                grassPosition.y, 
                existingHouses
            );

            Assert.IsTrue(result, "House should be valid far from existing house");
        }

        [Test]
        public void IsValidHousePosition_AdjacentToWater_ReturnsFalse()
        {
            // Find a position that's grass but has water nearby
            Vector2Int positionNearWater = FindGrassPositionNearWater();
            
            if (positionNearWater != Vector2Int.zero)
            {
                var result = InvokeIsValidHousePosition(
                    housePlacer, 
                    positionNearWater.x, 
                    positionNearWater.y, 
                    new System.Collections.Generic.List<Vector2>()
                );

                Assert.IsFalse(result, "House should not be valid adjacent to water");
            }
            else
            {
                Assert.Inconclusive("Could not find suitable test position");
            }
        }

        // Helper methods using reflection to test private methods
        private int InvokeGetChunkSeed(HousePlacer placer, Vector2Int chunkPosition)
        {
            MethodInfo method = typeof(HousePlacer).GetMethod("GetChunkSeed", 
                BindingFlags.NonPublic | BindingFlags.Instance);
            return (int)method.Invoke(placer, new object[] { chunkPosition });
        }

        private bool InvokeIsValidHousePosition(HousePlacer placer, int worldX, int worldY, 
            System.Collections.Generic.List<Vector2> existingHouses)
        {
            MethodInfo method = typeof(HousePlacer).GetMethod("IsValidHousePosition", 
                BindingFlags.NonPublic | BindingFlags.Instance);
            return (bool)method.Invoke(placer, new object[] { worldX, worldY, existingHouses });
        }

        private Vector2Int FindBiomePosition(BiomeType targetBiome)
        {
            for (int x = 0; x < 200; x++)
            {
                for (int y = 0; y < 200; y++)
                {
                    if (biomeGenerator.GetBiomeAt(x, y) == targetBiome)
                    {
                        return new Vector2Int(x, y);
                    }
                }
            }
            return Vector2Int.zero;
        }

        private Vector2Int FindValidGrassPosition()
        {
            for (int x = 10; x < 200; x++)
            {
                for (int y = 10; y < 200; y++)
                {
                    if (biomeGenerator.GetBiomeAt(x, y) == BiomeType.Grass)
                    {
                        // Check if all surrounding tiles are also walkable
                        bool allWalkable = true;
                        for (int dx = -1; dx <= 1; dx++)
                        {
                            for (int dy = -1; dy <= 1; dy++)
                            {
                                BiomeType surroundingBiome = biomeGenerator.GetBiomeAt(x + dx, y + dy);
                                if (!biomeGenerator.IsWalkable(surroundingBiome))
                                {
                                    allWalkable = false;
                                    break;
                                }
                            }
                            if (!allWalkable) break;
                        }
                        
                        if (allWalkable)
                        {
                            return new Vector2Int(x, y);
                        }
                    }
                }
            }
            return new Vector2Int(50, 50); // Fallback
        }

        private Vector2Int FindGrassPositionNearWater()
        {
            for (int x = 10; x < 200; x++)
            {
                for (int y = 10; y < 200; y++)
                {
                    if (biomeGenerator.GetBiomeAt(x, y) == BiomeType.Grass)
                    {
                        // Check if any surrounding tile is water
                        for (int dx = -1; dx <= 1; dx++)
                        {
                            for (int dy = -1; dy <= 1; dy++)
                            {
                                if (dx == 0 && dy == 0) continue;
                                BiomeType surroundingBiome = biomeGenerator.GetBiomeAt(x + dx, y + dy);
                                if (surroundingBiome == BiomeType.Water)
                                {
                                    return new Vector2Int(x, y);
                                }
                            }
                        }
                    }
                }
            }
            return Vector2Int.zero;
        }
    }
}
