using UnityEngine;
using MobileGameMVP.World;
using MobileGameMVP.Player;
using MobileGameMVP.Camera;
using MobileGameMVP.Persistence;

namespace MobileGameMVP
{
    public class GameManager : MonoBehaviour
    {
        [Header("References")]
        [SerializeField] private ChunkManager chunkManager;
        [SerializeField] private PlayerController playerController;
        [SerializeField] private CameraFollow cameraFollow;
        [SerializeField] private SaveLoadManager saveLoadManager;
        
        [Header("Game Settings")]
        [SerializeField] private int defaultWorldSeed = 12345;
        [SerializeField] private bool loadSavedGame = true;
        
        private GameData currentGameData;
        private int currentWorldSeed;

        private void Start()
        {
            InitializeGame();
        }

        private void InitializeGame()
        {
            Application.targetFrameRate = 60;
            Screen.orientation = ScreenOrientation.LandscapeLeft;

            if (saveLoadManager == null)
            {
                saveLoadManager = FindObjectOfType<SaveLoadManager>();
                if (saveLoadManager == null)
                {
                    GameObject saveManagerObj = new GameObject("SaveLoadManager");
                    saveLoadManager = saveManagerObj.AddComponent<SaveLoadManager>();
                }
            }

            if (loadSavedGame && saveLoadManager.HasSaveData())
            {
                currentGameData = saveLoadManager.LoadGame();
            }
            else
            {
                currentGameData = new GameData();
                currentGameData.worldSeed = defaultWorldSeed != 0 ? defaultWorldSeed : Random.Range(0, 1000000);
            }

            currentWorldSeed = currentGameData.worldSeed;

            if (chunkManager != null)
            {
                chunkManager.Initialize(currentWorldSeed);
                chunkManager.SetPlayer(playerController.transform);
            }

            if (playerController != null)
            {
                playerController.Initialize(chunkManager);
                playerController.SetPosition(currentGameData.GetPlayerPosition());
            }

            if (cameraFollow != null)
            {
                cameraFollow.SetTarget(playerController.transform);
                cameraFollow.SetPosition(currentGameData.GetPlayerPosition());
            }

            Debug.Log($"Game initialized with seed: {currentWorldSeed}");
        }

        private void OnApplicationPause(bool pauseStatus)
        {
            if (pauseStatus)
            {
                SaveGame();
            }
        }

        private void OnApplicationQuit()
        {
            SaveGame();
        }

        private void SaveGame()
        {
            if (playerController != null && saveLoadManager != null)
            {
                Vector3 playerPosition = playerController.GetPosition();
                currentGameData = new GameData(currentWorldSeed, playerPosition);
                saveLoadManager.SaveGame(currentGameData);
            }
        }

        public void NewGame(int? seed = null)
        {
            int newSeed = seed ?? Random.Range(0, 1000000);
            currentWorldSeed = newSeed;
            
            currentGameData = new GameData();
            currentGameData.worldSeed = newSeed;
            currentGameData.playerX = 0f;
            currentGameData.playerY = 0f;

            if (chunkManager != null)
            {
                chunkManager.Initialize(newSeed);
            }

            if (playerController != null)
            {
                playerController.SetPosition(Vector3.zero);
            }

            if (cameraFollow != null)
            {
                cameraFollow.SetPosition(Vector3.zero);
            }

            SaveGame();
            Debug.Log($"New game started with seed: {newSeed}");
        }

        public int GetCurrentSeed()
        {
            return currentWorldSeed;
        }
    }
}
