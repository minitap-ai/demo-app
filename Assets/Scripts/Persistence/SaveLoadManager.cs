using UnityEngine;

namespace MobileGameMVP.Persistence
{
    public class SaveLoadManager : MonoBehaviour
    {
        private const string SAVE_KEY = "GameSaveData";
        private const string WORLD_SEED_KEY = "WorldSeed";
        private const string PLAYER_X_KEY = "PlayerX";
        private const string PLAYER_Y_KEY = "PlayerY";

        public static SaveLoadManager Instance { get; private set; }

        private void Awake()
        {
            if (Instance == null)
            {
                Instance = this;
                DontDestroyOnLoad(gameObject);
            }
            else
            {
                Destroy(gameObject);
            }
        }

        public void SaveGame(GameData data)
        {
            PlayerPrefs.SetInt(WORLD_SEED_KEY, data.worldSeed);
            PlayerPrefs.SetFloat(PLAYER_X_KEY, data.playerX);
            PlayerPrefs.SetFloat(PLAYER_Y_KEY, data.playerY);
            PlayerPrefs.Save();

            Debug.Log($"Game saved: Seed={data.worldSeed}, Position=({data.playerX}, {data.playerY})");
        }

        public GameData LoadGame()
        {
            if (HasSaveData())
            {
                GameData data = new GameData();
                data.worldSeed = PlayerPrefs.GetInt(WORLD_SEED_KEY, Random.Range(0, 1000000));
                data.playerX = PlayerPrefs.GetFloat(PLAYER_X_KEY, 0f);
                data.playerY = PlayerPrefs.GetFloat(PLAYER_Y_KEY, 0f);

                Debug.Log($"Game loaded: Seed={data.worldSeed}, Position=({data.playerX}, {data.playerY})");
                return data;
            }
            else
            {
                Debug.Log("No save data found, creating new game");
                return new GameData();
            }
        }

        public bool HasSaveData()
        {
            return PlayerPrefs.HasKey(WORLD_SEED_KEY);
        }

        public void DeleteSaveData()
        {
            PlayerPrefs.DeleteKey(WORLD_SEED_KEY);
            PlayerPrefs.DeleteKey(PLAYER_X_KEY);
            PlayerPrefs.DeleteKey(PLAYER_Y_KEY);
            PlayerPrefs.Save();

            Debug.Log("Save data deleted");
        }

        public void SaveGameOnQuit(int worldSeed, Vector3 playerPosition)
        {
            GameData data = new GameData(worldSeed, playerPosition);
            SaveGame(data);
        }

        private void OnApplicationPause(bool pauseStatus)
        {
            if (pauseStatus)
            {
                Debug.Log("Application paused, triggering save");
            }
        }

        private void OnApplicationQuit()
        {
            Debug.Log("Application quitting");
        }
    }
}
