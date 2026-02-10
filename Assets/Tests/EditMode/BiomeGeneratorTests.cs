using NUnit.Framework;
using MobileGameMVP.World;

namespace MobileGameMVP.Tests.EditMode
{
    [TestFixture]
    public class BiomeGeneratorTests
    {
        [Test]
        public void GetBiomeAt_WithSameSeed_ReturnsSameBiome()
        {
            int seed = 12345;
            var generator1 = new BiomeGenerator(seed);
            var generator2 = new BiomeGenerator(seed);

            BiomeType biome1 = generator1.GetBiomeAt(10, 20);
            BiomeType biome2 = generator2.GetBiomeAt(10, 20);

            Assert.AreEqual(biome1, biome2, "Same seed should produce same biome at same coordinates");
        }

        [Test]
        public void GetBiomeAt_WithDifferentSeeds_MayReturnDifferentBiomes()
        {
            var generator1 = new BiomeGenerator(12345);
            var generator2 = new BiomeGenerator(67890);

            BiomeType biome1 = generator1.GetBiomeAt(10, 20);
            BiomeType biome2 = generator2.GetBiomeAt(10, 20);

            // Note: This test may occasionally fail if both seeds happen to produce the same biome
            // at this specific coordinate, but it's statistically unlikely
            bool foundDifference = false;
            for (int x = 0; x < 100; x += 10)
            {
                for (int y = 0; y < 100; y += 10)
                {
                    if (generator1.GetBiomeAt(x, y) != generator2.GetBiomeAt(x, y))
                    {
                        foundDifference = true;
                        break;
                    }
                }
                if (foundDifference) break;
            }

            Assert.IsTrue(foundDifference, "Different seeds should produce different biomes across multiple coordinates");
        }

        [Test]
        public void GetBiomeAt_ReturnsValidBiomeType()
        {
            var generator = new BiomeGenerator(12345);

            for (int x = 0; x < 50; x += 5)
            {
                for (int y = 0; y < 50; y += 5)
                {
                    BiomeType biome = generator.GetBiomeAt(x, y);
                    Assert.IsTrue(
                        biome == BiomeType.Grass || biome == BiomeType.Water || biome == BiomeType.Snow,
                        $"Biome at ({x}, {y}) should be a valid BiomeType"
                    );
                }
            }
        }

        [Test]
        public void GetBiomeAt_ProducesAllBiomeTypes()
        {
            var generator = new BiomeGenerator(12345);
            bool hasGrass = false;
            bool hasWater = false;
            bool hasSnow = false;

            for (int x = 0; x < 200; x += 2)
            {
                for (int y = 0; y < 200; y += 2)
                {
                    BiomeType biome = generator.GetBiomeAt(x, y);
                    if (biome == BiomeType.Grass) hasGrass = true;
                    if (biome == BiomeType.Water) hasWater = true;
                    if (biome == BiomeType.Snow) hasSnow = true;

                    if (hasGrass && hasWater && hasSnow) break;
                }
                if (hasGrass && hasWater && hasSnow) break;
            }

            Assert.IsTrue(hasGrass, "Generator should produce Grass biomes");
            Assert.IsTrue(hasWater, "Generator should produce Water biomes");
            Assert.IsTrue(hasSnow, "Generator should produce Snow biomes");
        }

        [Test]
        public void GetBiomeAt_IsDeterministic()
        {
            var generator = new BiomeGenerator(12345);

            BiomeType firstCall = generator.GetBiomeAt(50, 50);
            BiomeType secondCall = generator.GetBiomeAt(50, 50);
            BiomeType thirdCall = generator.GetBiomeAt(50, 50);

            Assert.AreEqual(firstCall, secondCall, "Multiple calls should return same biome");
            Assert.AreEqual(secondCall, thirdCall, "Multiple calls should return same biome");
        }

        [Test]
        public void GetBiomeAt_WorksWithNegativeCoordinates()
        {
            var generator = new BiomeGenerator(12345);

            BiomeType biome1 = generator.GetBiomeAt(-10, -20);
            BiomeType biome2 = generator.GetBiomeAt(-10, -20);

            Assert.AreEqual(biome1, biome2, "Should handle negative coordinates consistently");
            Assert.IsTrue(
                biome1 == BiomeType.Grass || biome1 == BiomeType.Water || biome1 == BiomeType.Snow,
                "Should return valid biome for negative coordinates"
            );
        }

        [Test]
        public void IsWalkable_WaterIsNotWalkable()
        {
            var generator = new BiomeGenerator(12345);
            Assert.IsFalse(generator.IsWalkable(BiomeType.Water), "Water should not be walkable");
        }

        [Test]
        public void IsWalkable_GrassIsWalkable()
        {
            var generator = new BiomeGenerator(12345);
            Assert.IsTrue(generator.IsWalkable(BiomeType.Grass), "Grass should be walkable");
        }

        [Test]
        public void IsWalkable_SnowIsWalkable()
        {
            var generator = new BiomeGenerator(12345);
            Assert.IsTrue(generator.IsWalkable(BiomeType.Snow), "Snow should be walkable");
        }

        [Test]
        public void GetBiomeAt_AdjacentTilesCanDiffer()
        {
            var generator = new BiomeGenerator(12345);

            bool foundDifference = false;
            for (int x = 0; x < 100; x++)
            {
                BiomeType current = generator.GetBiomeAt(x, 0);
                BiomeType next = generator.GetBiomeAt(x + 1, 0);
                if (current != next)
                {
                    foundDifference = true;
                    break;
                }
            }

            Assert.IsTrue(foundDifference, "Adjacent tiles should sometimes have different biomes");
        }

        [Test]
        public void GetBiomeAt_LargeCoordinates_ReturnsValidBiome()
        {
            var generator = new BiomeGenerator(12345);

            BiomeType biome = generator.GetBiomeAt(10000, 10000);

            Assert.IsTrue(
                biome == BiomeType.Grass || biome == BiomeType.Water || biome == BiomeType.Snow,
                "Should handle large coordinates"
            );
        }
    }
}
