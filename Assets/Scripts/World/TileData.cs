using UnityEngine;

namespace MobileGameMVP.World
{
    public struct TileData
    {
        public BiomeType biomeType;
        public Vector2Int position;
        public bool isWalkable;

        public TileData(BiomeType biomeType, Vector2Int position, bool isWalkable)
        {
            this.biomeType = biomeType;
            this.position = position;
            this.isWalkable = isWalkable;
        }
    }
}
