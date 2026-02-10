using UnityEngine;

namespace MobileGameMVP.Persistence
{
    [System.Serializable]
    public class GameData
    {
        public int worldSeed;
        public float playerX;
        public float playerY;

        public GameData()
        {
            worldSeed = Random.Range(0, 1000000);
            playerX = 0f;
            playerY = 0f;
        }

        public GameData(int seed, Vector3 playerPosition)
        {
            worldSeed = seed;
            playerX = playerPosition.x;
            playerY = playerPosition.y;
        }

        public Vector3 GetPlayerPosition()
        {
            return new Vector3(playerX, playerY, 0f);
        }
    }
}
