# Mobile Game MVP - Architecture Documentation

## System Overview

This mobile game MVP implements an infinite procedurally generated 2D top-down world with the following core systems:

1. **World Generation System** - Procedural biome generation using Perlin noise
2. **Chunk Management System** - Infinite world streaming with chunk loading/unloading
3. **Input System** - Virtual joystick for mobile touch controls
4. **Player System** - Character movement with collision detection
5. **Camera System** - Smooth camera following
6. **House Placement System** - Deterministic structure placement
7. **Persistence System** - Save/load game state

## System Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                        GameManager                          │
│  - Orchestrates all systems                                 │
│  - Handles game lifecycle (start, pause, quit)              │
│  - Manages save/load operations                             │
└────────────┬────────────────────────────────────────────────┘
             │
             ├──────────────┬──────────────┬──────────────┬───────────────┐
             │              │              │              │               │
             ▼              ▼              ▼              ▼               ▼
    ┌────────────┐  ┌─────────────┐  ┌──────────┐  ┌──────────┐  ┌──────────────┐
    │ChunkManager│  │PlayerControl│  │CameraFoll│  │VirtualJoy│  │SaveLoadMgr   │
    │            │  │ler          │  │ow        │  │stick     │  │              │
    └─────┬──────┘  └──────┬──────┘  └────┬─────┘  └────┬─────┘  └──────────────┘
          │                │              │             │
          │                │              │             │
          ▼                ▼              │             │
    ┌──────────┐    ┌─────────────┐      │             │
    │BiomeGen  │    │PlayerMovemt │      │             │
    │          │    │             │      │             │
    └────┬─────┘    └──────┬──────┘      │             │
         │                 │              │             │
         │                 └──────────────┴─────────────┘
         │                        │
         ▼                        ▼
    ┌──────────┐           ┌──────────┐
    │HousePlacer│          │  Player  │
    │          │           │GameObject│
    └──────────┘           └──────────┘
```

## Core Systems

### 1. World Generation System

**Components:**
- `BiomeGenerator.cs` - Generates biome types using layered Perlin noise
- `BiomeType.cs` - Enum defining available biomes (Grass, Water, Snow)

**How it works:**
1. Uses Unity's `Mathf.PerlinNoise()` with multiple octaves for natural variation
2. Generates two noise maps:
   - **Elevation map** - Determines base terrain type
   - **Moisture map** - Adds variation within terrain types
3. Combines noise values to determine biome at each world position
4. Deterministic - same seed always produces same world

**Key Parameters:**
- `elevationScale` (0.05) - Controls size of elevation features
- `moistureScale` (0.08) - Controls size of moisture features
- `octaves` (4) - Number of noise layers for detail
- `persistence` (0.5) - How much each octave contributes
- `lacunarity` (2.0) - Frequency multiplier between octaves

**Biome Rules:**
```
if elevation < 0.35:
    return WATER
else if elevation > 0.65 and moisture < 0.4:
    return SNOW
else:
    return GRASS
```

### 2. Chunk Management System

**Components:**
- `ChunkManager.cs` - Manages chunk lifecycle (load/unload)
- `Chunk.cs` - Represents a single chunk of the world
- `TileData.cs` - Data structure for individual tiles

**How it works:**
1. World is divided into 32x32 tile chunks
2. ChunkManager tracks player position and loads chunks within view distance
3. Chunks beyond unload distance are cleared and returned to object pool
4. Each chunk generates its tiles using BiomeGenerator
5. Chunks are reused via object pooling for performance

**Key Parameters:**
- `CHUNK_SIZE` (32) - Tiles per chunk dimension
- `viewDistance` (3) - Chunks to load around player
- `unloadDistance` (5) - Distance before unloading chunks

**Chunk Lifecycle:**
```
1. Player moves to new chunk position
2. ChunkManager calculates required chunks
3. Missing chunks are loaded from pool
4. Chunk.Generate() creates tiles using BiomeGenerator
5. HousePlacer adds houses to chunk
6. Distant chunks are cleared and returned to pool
```

**Performance Optimizations:**
- Object pooling prevents constant instantiation/destruction
- Only generates chunks within view distance
- Unloads chunks beyond buffer distance
- Reuses chunk GameObjects

### 3. Input System

**Components:**
- `VirtualJoystick.cs` - Touch-based analog joystick

**How it works:**
1. Detects touch in left half of screen
2. Shows joystick at touch position (dynamic mode)
3. Tracks drag distance and angle from center
4. Normalizes input to [-1, 1] range for both axes
5. Applies dead zone to prevent drift
6. Hides joystick on touch release

**Key Features:**
- **Dynamic positioning** - Joystick appears where you touch
- **Analog input** - Variable speed based on distance from center
- **Dead zone** - Prevents unintended movement
- **Screen zone limiting** - Only active on left half of screen

**Input Flow:**
```
Touch Down (left half) → Show Joystick → Track Drag → 
Calculate Direction & Distance → Normalize to [-1,1] → 
Apply Dead Zone → Send to PlayerController → Touch Up → Hide Joystick
```

### 4. Player System

**Components:**
- `PlayerController.cs` - High-level player control and coordination
- `PlayerMovement.cs` - Physics-based movement and collision

**How it works:**

**PlayerController:**
- Reads input from VirtualJoystick
- Passes input to PlayerMovement
- Updates visual direction (sprite flipping)
- Provides position get/set for save/load

**PlayerMovement:**
- Uses Rigidbody2D for physics-based movement
- Applies acceleration/deceleration for smooth feel
- Checks collision before moving (tile-based and physics-based)
- Implements sliding along walls (separate X/Y collision checks)
- Validates positions against ChunkManager for water collision

**Movement Algorithm:**
```
1. Receive input vector from joystick
2. Calculate target velocity (input * speed)
3. Smoothly interpolate current velocity toward target
4. Calculate new position (current + velocity * deltaTime)
5. Check if new position is valid:
   - Query ChunkManager for walkable terrain
   - Check Physics2D for collisions with houses
6. If valid, move to new position
7. If invalid, try horizontal and vertical separately (wall sliding)
8. Update Rigidbody2D position
```

**Collision Detection:**
- **Tile-based:** ChunkManager.IsPositionWalkable() checks biome
- **Physics-based:** Physics2D.OverlapCircleAll() checks for houses
- **Sliding:** Separate X and Y checks allow sliding along obstacles

### 5. Camera System

**Components:**
- `CameraFollow.cs` - Smooth camera tracking

**How it works:**
1. Tracks target (player) position
2. Applies smooth interpolation (lerp) for fluid movement
3. Maintains fixed Z offset for 2D orthographic view
4. Optional bounds clamping (disabled for infinite world)

**Key Parameters:**
- `smoothSpeed` (5.0) - How quickly camera follows player
- `offset` (0, 0, -10) - Camera position offset from player
- `orthographicSize` (8.0) - Zoom level (higher = more visible)

### 6. House Placement System

**Components:**
- `HousePlacer.cs` - Deterministic structure placement

**How it works:**
1. Each chunk gets a unique seed based on world seed + chunk position
2. Seeded random determines number of houses (0 to max based on density)
3. For each house:
   - Generate random position within chunk
   - Validate position (not water, not too close to other houses)
   - Instantiate house prefab if valid
4. Houses are stored in chunk and destroyed when chunk unloads

**Placement Rules:**
- Only on walkable terrain (not water)
- 3x3 area around house must be walkable
- Minimum distance between houses (8 tiles)
- Maximum attempts per house (10) to prevent infinite loops

**Determinism:**
```
chunkSeed = worldSeed * 31 + chunkX * 31 + chunkY
random = new Random(chunkSeed)
// All random calls use this seeded random
// Same seed + same chunk = same houses
```

### 7. Persistence System

**Components:**
- `SaveLoadManager.cs` - Handles save/load operations
- `GameData.cs` - Serializable data structure

**How it works:**
1. Uses Unity's PlayerPrefs for simple key-value storage
2. Saves on application pause and quit
3. Loads on application start
4. Stores minimal data (seed + position)

**Saved Data:**
- `worldSeed` (int) - Regenerates entire world
- `playerX` (float) - Player X position
- `playerY` (float) - Player Y position

**Save Triggers:**
- Application pause (mobile background)
- Application quit
- Manual save via GameManager

**Load Process:**
```
1. Check if save data exists
2. If yes: Load seed and position
3. If no: Generate new random seed, start at (0,0)
4. Initialize ChunkManager with seed
5. Set player position
6. World regenerates deterministically from seed
```

## Data Flow

### Game Initialization Flow

```
1. GameManager.Start()
   ↓
2. SaveLoadManager.LoadGame()
   ↓
3. Get worldSeed and playerPosition
   ↓
4. ChunkManager.Initialize(seed)
   ↓
5. BiomeGenerator created with seed
   ↓
6. HousePlacer created with seed
   ↓
7. PlayerController.SetPosition(savedPosition)
   ↓
8. CameraFollow.SetTarget(player)
   ↓
9. Game ready - chunks load as player moves
```

### Frame Update Flow

```
Every Frame:
1. VirtualJoystick detects touch input
   ↓
2. PlayerController reads joystick direction
   ↓
3. PlayerMovement.SetMovementInput(direction)
   ↓
4. PlayerMovement.FixedUpdate() moves player
   ↓
5. ChunkManager.Update() checks player chunk
   ↓
6. If new chunk: Load nearby chunks, unload distant
   ↓
7. CameraFollow.LateUpdate() follows player
```

### Chunk Generation Flow

```
1. Player moves to new chunk
   ↓
2. ChunkManager detects missing chunks
   ↓
3. Get chunk from pool (or create new)
   ↓
4. Chunk.Initialize(position, biomeGenerator, tilemap)
   ↓
5. Chunk.Generate(tiles)
   ↓
6. For each tile in 32x32 grid:
   - Calculate world position
   - BiomeGenerator.GetBiomeAt(x, y)
   - Set tile in Tilemap
   - Store TileData
   ↓
7. HousePlacer.PlaceHousesInChunk(chunk)
   ↓
8. For each potential house:
   - Generate random position (seeded)
   - Validate position
   - Instantiate house if valid
   ↓
9. Chunk active and visible
```

## Performance Considerations

### Target: 60 FPS on Mid-Range Mobile Devices

**Optimizations Implemented:**

1. **Object Pooling**
   - Chunks are reused instead of destroyed
   - Reduces garbage collection pressure
   - Prevents frame drops from instantiation

2. **Chunk-Based Loading**
   - Only generates visible chunks
   - Unloads distant chunks
   - Limits active chunk count

3. **Efficient Collision Detection**
   - Tile-based checks via ChunkManager (fast)
   - Physics checks only for houses (minimal)
   - Collision layers limit check scope

4. **Deterministic Generation**
   - No need to save/load entire world
   - Only seed + position stored
   - World regenerates on demand

5. **Static Batching**
   - Tilemap uses single draw call per layer
   - Houses can be batched if using same material
   - Reduces draw call overhead

**Performance Monitoring:**
- Target frame rate set to 60 FPS
- Use Unity Profiler to identify bottlenecks
- Monitor draw calls (target < 150)
- Monitor memory usage (target < 500MB)

**Potential Bottlenecks:**
- Chunk generation (if too many per frame)
- House instantiation (if too many houses)
- Tilemap updates (if updating too many tiles)
- Physics collision checks (if too many colliders)

**Mitigation Strategies:**
- Limit chunks generated per frame (1-2 max)
- Use coroutines for async generation
- Implement LOD for distant objects
- Use texture atlases to reduce draw calls
- Enable GPU instancing for repeated sprites

## Extensibility

### Adding New Biomes

1. Add new biome to `BiomeType` enum
2. Update `BiomeGenerator.GetBiomeAt()` with new rules
3. Create new tile asset in Unity
4. Add tile reference to ChunkManager
5. Update `Chunk.GetTileForBiome()` to handle new type

### Adding New Structures

1. Create new prefab (similar to House)
2. Create new placer class (similar to HousePlacer)
3. Add placer to ChunkManager initialization
4. Call placer in chunk generation

### Adding Player Abilities

1. Add new methods to PlayerController
2. Create new input handlers in VirtualJoystick or separate UI
3. Implement ability logic in new component
4. Hook up to player GameObject

### Adding Multiplayer

Current architecture is single-player only. For multiplayer:
1. Replace PlayerPrefs with server-based save system
2. Sync player positions across clients
3. Ensure deterministic world generation (already implemented)
4. Add network components to player and world objects
5. Implement client-side prediction for smooth movement

## Testing Recommendations

### Unit Testing
- BiomeGenerator: Test determinism (same seed = same output)
- ChunkManager: Test chunk loading/unloading logic
- HousePlacer: Test placement rules and determinism

### Integration Testing
- Test save/load cycle preserves world and position
- Test chunk streaming doesn't cause stutters
- Test collision detection works for all biomes and houses

### Performance Testing
- Profile on target devices (5-year-old phones)
- Test with extended play sessions (memory leaks)
- Test chunk loading at high movement speeds

### Gameplay Testing
- Verify controls feel responsive
- Ensure biomes form coherent regions
- Check houses never spawn in water
- Confirm collision works correctly

## Known Limitations

1. **No interior spaces** - Houses are decorative only
2. **Limited biome variety** - Only 3 biomes implemented
3. **Simple collision** - No complex pathfinding or AI
4. **No multiplayer** - Single-player only
5. **Basic persistence** - Only seed and position saved
6. **No progression** - No items, quests, or character advancement

## Future Enhancements

1. **More biomes** - Desert, forest, mountains, etc.
2. **Interactable structures** - Enter houses, shops, dungeons
3. **NPCs and enemies** - Add life to the world
4. **Items and inventory** - Collectibles and equipment
5. **Quests and objectives** - Give players goals
6. **Minimap** - Help with navigation
7. **Day/night cycle** - Visual variety and gameplay changes
8. **Weather effects** - Rain, snow, fog
9. **Procedural dungeons** - Instanced areas with challenges
10. **Multiplayer** - Co-op exploration

## Conclusion

This architecture provides a solid foundation for a 2D top-down mobile exploration game. The modular design allows for easy extension and modification. The chunk-based world system enables truly infinite exploration while maintaining good performance on mobile devices.

Key strengths:
- ✅ Deterministic world generation
- ✅ Efficient chunk streaming
- ✅ Smooth mobile controls
- ✅ Simple but effective persistence
- ✅ Modular and extensible design

The codebase is ready for further development and can serve as a base for more complex game features.
