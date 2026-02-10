using System.Collections;
using NUnit.Framework;
using UnityEngine;
using UnityEngine.TestTools;
using MobileGameMVP.World;
using MobileGameMVP.Persistence;

namespace MobileGameMVP.Tests.PlayMode
{
    [TestFixture]
    public class GameSystemsIntegrationTests
    {
        [UnityTest]
        public IEnumerator BiomeGenerator_GeneratesConsistentWorld()
        {
            int seed = 12345;
            var generator1 = new BiomeGenerator(seed);
            var generator2 = new BiomeGenerator(seed);

            // Test multiple positions
            for (int x = 0; x < 100; x += 10)
            {
                for (int y = 0; y < 100; y += 10)
                {
                    BiomeType biome1 = generator1.GetBiomeAt(x, y);
                    BiomeType biome2 = generator2.GetBiomeAt(x, y);
                    
                    Assert.AreEqual(biome1, biome2, 
                        $"Biomes should match at position ({x}, {y})");
                }
            }

            yield return null;
        }

        [UnityTest]
        public IEnumerator SaveLoadManager_PersistsGameData()
        {
            // Create SaveLoadManager
            GameObject saveManagerObj = new GameObject("TestSaveLoadManager");
            var saveLoadManager = saveManagerObj.AddComponent<SaveLoadManager>();

            // Clear any existing save data
            saveLoadManager.DeleteSaveData();
            yield return null;

            // Create and save game data
            int testSeed = 99999;
            Vector3 testPosition = new Vector3(123.45f, 678.90f, 0f);
            var originalData = new GameData(testSeed, testPosition);
            
            saveLoadManager.SaveGame(originalData);
            yield return null;

            // Verify save exists
            Assert.IsTrue(saveLoadManager.HasSaveData(), "Save data should exist");

            // Load and verify
            var loadedData = saveLoadManager.LoadGame();
            Assert.AreEqual(testSeed, loadedData.worldSeed, "Loaded seed should match saved seed");
            Assert.AreEqual(testPosition.x, loadedData.playerX, 0.01f, "Loaded X position should match");
            Assert.AreEqual(testPosition.y, loadedData.playerY, 0.01f, "Loaded Y position should match");

            // Cleanup
            saveLoadManager.DeleteSaveData();
            Object.Destroy(saveManagerObj);
            yield return null;
        }

        [UnityTest]
        public IEnumerator SaveLoadManager_DeleteSaveData_RemovesData()
        {
            GameObject saveManagerObj = new GameObject("TestSaveLoadManager");
            var saveLoadManager = saveManagerObj.AddComponent<SaveLoadManager>();

            // Save some data
            var gameData = new GameData(12345, Vector3.zero);
            saveLoadManager.SaveGame(gameData);
            yield return null;

            Assert.IsTrue(saveLoadManager.HasSaveData(), "Save data should exist before deletion");

            // Delete
            saveLoadManager.DeleteSaveData();
            yield return null;

            Assert.IsFalse(saveLoadManager.HasSaveData(), "Save data should not exist after deletion");

            // Cleanup
            Object.Destroy(saveManagerObj);
            yield return null;
        }

        [UnityTest]
        public IEnumerator SaveLoadManager_LoadWithoutSave_CreatesNewGame()
        {
            GameObject saveManagerObj = new GameObject("TestSaveLoadManager");
            var saveLoadManager = saveManagerObj.AddComponent<SaveLoadManager>();

            // Ensure no save data exists
            saveLoadManager.DeleteSaveData();
            yield return null;

            // Load should create new game
            var gameData = saveLoadManager.LoadGame();
            
            Assert.IsNotNull(gameData, "GameData should be created");
            Assert.GreaterOrEqual(gameData.worldSeed, 0, "Seed should be valid");
            Assert.AreEqual(0f, gameData.playerX, "Default X should be 0");
            Assert.AreEqual(0f, gameData.playerY, "Default Y should be 0");

            // Cleanup
            Object.Destroy(saveManagerObj);
            yield return null;
        }

        [UnityTest]
        public IEnumerator HousePlacer_WithBiomeGenerator_PlacesHousesOnValidTerrain()
        {
            int seed = 12345;
            var biomeGenerator = new BiomeGenerator(seed);
            var housePlacer = new HousePlacer(seed, biomeGenerator);

            // Test that house placement validation works
            bool foundValidPosition = false;
            bool foundInvalidPosition = false;

            for (int x = 0; x < 100; x += 5)
            {
                for (int y = 0; y < 100; y += 5)
                {
                    BiomeType biome = biomeGenerator.GetBiomeAt(x, y);
                    
                    if (biome == BiomeType.Water)
                    {
                        foundInvalidPosition = true;
                    }
                    else if (biome == BiomeType.Grass || biome == BiomeType.Snow)
                    {
                        foundValidPosition = true;
                    }

                    if (foundValidPosition && foundInvalidPosition)
                        break;
                }
                if (foundValidPosition && foundInvalidPosition)
                    break;
            }

            Assert.IsTrue(foundValidPosition, "Should find valid positions for houses");
            Assert.IsTrue(foundInvalidPosition, "Should find invalid positions (water)");

            yield return null;
        }

        [UnityTest]
        public IEnumerator GameData_RoundTrip_PreservesData()
        {
            // Test that GameData can be created, serialized, and deserialized
            int originalSeed = 54321;
            Vector3 originalPosition = new Vector3(999.99f, -888.88f, 0f);

            var originalData = new GameData(originalSeed, originalPosition);

            // Serialize to JSON
            string json = JsonUtility.ToJson(originalData);
            Assert.IsNotEmpty(json, "JSON should not be empty");

            // Deserialize
            var deserializedData = JsonUtility.FromJson<GameData>(json);

            // Verify
            Assert.AreEqual(originalSeed, deserializedData.worldSeed, "Seed should survive round trip");
            Assert.AreEqual(originalPosition.x, deserializedData.playerX, 0.01f, "X should survive round trip");
            Assert.AreEqual(originalPosition.y, deserializedData.playerY, 0.01f, "Y should survive round trip");

            // Verify GetPlayerPosition
            Vector3 restoredPosition = deserializedData.GetPlayerPosition();
            Assert.AreEqual(originalPosition.x, restoredPosition.x, 0.01f, "Restored X should match");
            Assert.AreEqual(originalPosition.y, restoredPosition.y, 0.01f, "Restored Y should match");

            yield return null;
        }

        [UnityTest]
        public IEnumerator BiomeGenerator_ProducesReasonableDistribution()
        {
            var generator = new BiomeGenerator(12345);
            
            int grassCount = 0;
            int waterCount = 0;
            int snowCount = 0;
            int totalSamples = 0;

            // Sample a large area
            for (int x = 0; x < 200; x += 2)
            {
                for (int y = 0; y < 200; y += 2)
                {
                    BiomeType biome = generator.GetBiomeAt(x, y);
                    totalSamples++;

                    switch (biome)
                    {
                        case BiomeType.Grass:
                            grassCount++;
                            break;
                        case BiomeType.Water:
                            waterCount++;
                            break;
                        case BiomeType.Snow:
                            snowCount++;
                            break;
                    }
                }
            }

            // Verify all biomes are present
            Assert.Greater(grassCount, 0, "Should have some grass tiles");
            Assert.Greater(waterCount, 0, "Should have some water tiles");
            Assert.Greater(snowCount, 0, "Should have some snow tiles");

            // Verify reasonable distribution (no biome should dominate completely)
            float grassPercent = (float)grassCount / totalSamples;
            float waterPercent = (float)waterCount / totalSamples;
            float snowPercent = (float)snowCount / totalSamples;

            Assert.Greater(grassPercent, 0.1f, "Grass should be at least 10% of tiles");
            Assert.Greater(waterPercent, 0.05f, "Water should be at least 5% of tiles");
            Assert.Greater(snowPercent, 0.05f, "Snow should be at least 5% of tiles");

            Debug.Log($"Biome distribution: Grass={grassPercent:P}, Water={waterPercent:P}, Snow={snowPercent:P}");

            yield return null;
        }

        [UnityTest]
        public IEnumerator SaveLoadManager_MultipleSavesOverwrite()
        {
            GameObject saveManagerObj = new GameObject("TestSaveLoadManager");
            var saveLoadManager = saveManagerObj.AddComponent<SaveLoadManager>();

            // Clear existing data
            saveLoadManager.DeleteSaveData();
            yield return null;

            // First save
            var firstData = new GameData(11111, new Vector3(100f, 100f, 0f));
            saveLoadManager.SaveGame(firstData);
            yield return null;

            // Second save (should overwrite)
            var secondData = new GameData(22222, new Vector3(200f, 200f, 0f));
            saveLoadManager.SaveGame(secondData);
            yield return null;

            // Load and verify it's the second save
            var loadedData = saveLoadManager.LoadGame();
            Assert.AreEqual(22222, loadedData.worldSeed, "Should load the most recent save");
            Assert.AreEqual(200f, loadedData.playerX, 0.01f, "Should load the most recent position");

            // Cleanup
            saveLoadManager.DeleteSaveData();
            Object.Destroy(saveManagerObj);
            yield return null;
        }
    }
}
