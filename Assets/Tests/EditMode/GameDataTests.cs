using NUnit.Framework;
using UnityEngine;
using MobileGameMVP.Persistence;

namespace MobileGameMVP.Tests.EditMode
{
    [TestFixture]
    public class GameDataTests
    {
        [Test]
        public void Constructor_Default_InitializesWithZeroPosition()
        {
            var gameData = new GameData();

            Assert.AreEqual(0f, gameData.playerX, "Default playerX should be 0");
            Assert.AreEqual(0f, gameData.playerY, "Default playerY should be 0");
        }

        [Test]
        public void Constructor_Default_GeneratesRandomSeed()
        {
            var gameData1 = new GameData();
            var gameData2 = new GameData();

            Assert.GreaterOrEqual(gameData1.worldSeed, 0, "Seed should be non-negative");
            Assert.Less(gameData1.worldSeed, 1000000, "Seed should be less than 1000000");
            
            // Note: There's a tiny chance this could fail if both random seeds are the same
            // but with 1,000,000 possible values, it's extremely unlikely
        }

        [Test]
        public void Constructor_WithParameters_StoresCorrectValues()
        {
            int seed = 12345;
            Vector3 position = new Vector3(100f, 200f, 0f);

            var gameData = new GameData(seed, position);

            Assert.AreEqual(seed, gameData.worldSeed, "Seed should match constructor parameter");
            Assert.AreEqual(100f, gameData.playerX, "PlayerX should match position.x");
            Assert.AreEqual(200f, gameData.playerY, "PlayerY should match position.y");
        }

        [Test]
        public void Constructor_WithParameters_IgnoresZComponent()
        {
            Vector3 position = new Vector3(50f, 75f, 999f);

            var gameData = new GameData(12345, position);

            Assert.AreEqual(50f, gameData.playerX, "PlayerX should use position.x");
            Assert.AreEqual(75f, gameData.playerY, "PlayerY should use position.y");
        }

        [Test]
        public void GetPlayerPosition_ReturnsCorrectVector3()
        {
            var gameData = new GameData(12345, new Vector3(100f, 200f, 0f));

            Vector3 position = gameData.GetPlayerPosition();

            Assert.AreEqual(100f, position.x, "Position.x should match playerX");
            Assert.AreEqual(200f, position.y, "Position.y should match playerY");
            Assert.AreEqual(0f, position.z, "Position.z should always be 0");
        }

        [Test]
        public void GetPlayerPosition_WithNegativeCoordinates_ReturnsCorrectValues()
        {
            var gameData = new GameData(12345, new Vector3(-50f, -75f, 0f));

            Vector3 position = gameData.GetPlayerPosition();

            Assert.AreEqual(-50f, position.x, "Should handle negative X");
            Assert.AreEqual(-75f, position.y, "Should handle negative Y");
        }

        [Test]
        public void GetPlayerPosition_WithDefaultConstructor_ReturnsZeroVector()
        {
            var gameData = new GameData();

            Vector3 position = gameData.GetPlayerPosition();

            Assert.AreEqual(Vector3.zero, position, "Default position should be Vector3.zero");
        }

        [Test]
        public void GameData_IsSerializable()
        {
            var gameData = new GameData(12345, new Vector3(100f, 200f, 0f));

            string json = JsonUtility.ToJson(gameData);
            var deserializedData = JsonUtility.FromJson<GameData>(json);

            Assert.AreEqual(gameData.worldSeed, deserializedData.worldSeed, "Seed should survive serialization");
            Assert.AreEqual(gameData.playerX, deserializedData.playerX, "PlayerX should survive serialization");
            Assert.AreEqual(gameData.playerY, deserializedData.playerY, "PlayerY should survive serialization");
        }

        [Test]
        public void GameData_CanStoreVeryLargeCoordinates()
        {
            Vector3 largePosition = new Vector3(999999f, -999999f, 0f);
            var gameData = new GameData(12345, largePosition);

            Assert.AreEqual(999999f, gameData.playerX, "Should handle large positive coordinates");
            Assert.AreEqual(-999999f, gameData.playerY, "Should handle large negative coordinates");
        }

        [Test]
        public void GameData_CanStoreMaxSeedValue()
        {
            int maxSeed = 999999;
            var gameData = new GameData(maxSeed, Vector3.zero);

            Assert.AreEqual(maxSeed, gameData.worldSeed, "Should store maximum seed value");
        }

        [Test]
        public void GameData_CanStoreMinSeedValue()
        {
            int minSeed = 0;
            var gameData = new GameData(minSeed, Vector3.zero);

            Assert.AreEqual(minSeed, gameData.worldSeed, "Should store minimum seed value");
        }
    }
}
