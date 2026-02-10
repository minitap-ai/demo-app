# Mobile Game MVP - Setup Instructions

## Prerequisites

- **Unity 2022.3.10f1 or later** (LTS version recommended)
- **Unity 2D Template** support
- **Android Build Support** and/or **iOS Build Support** modules installed

## Opening the Project

1. Open Unity Hub
2. Click "Add" and select this project folder
3. Open the project with Unity 2022.3 LTS or later

## Initial Setup Steps

### 1. Create the Main Scene

1. In Unity, go to `File > New Scene`
2. Select "2D" template
3. Save the scene as `Assets/Scenes/MainGame.unity`

### 2. Set Up the Tilemap

1. In the Hierarchy, right-click and select `2D Object > Tilemap > Rectangular`
2. This creates a Grid with a Tilemap child
3. Rename the Tilemap to "WorldTilemap"
4. Add a `Tilemap Collider 2D` component to the Tilemap
5. Set the Tilemap layer to "Ground" (create this layer if needed)

### 3. Create Tile Assets

You need to create three tile assets for the biomes:

1. Import sprite images for grass, water, and snow into `Assets/Sprites/Tiles/`
2. For each sprite:
   - Select the sprite in the Project window
   - Set Texture Type to "Sprite (2D and UI)"
   - Set Pixels Per Unit to 16 (or your preferred tile size)
   - Click Apply
3. Create tiles:
   - Right-click in Project window
   - Select `Create > 2D > Tiles > Tile`
   - Name them "GrassTile", "WaterTile", "SnowTile"
   - Assign the corresponding sprites to each tile

### 4. Set Up the Player

1. Create an empty GameObject named "Player"
2. Add a `Sprite Renderer` component
3. Import a player sprite to `Assets/Sprites/Player/`
4. Assign the sprite to the Sprite Renderer
5. Add a `Circle Collider 2D` component (radius ~0.3)
6. Add a `Rigidbody 2D` component:
   - Body Type: Dynamic
   - Gravity Scale: 0
   - Constraints: Freeze Rotation Z
7. Add the `PlayerController` script component
8. Add the `PlayerMovement` script component
9. Set the Player layer to "Player" (create if needed)

### 5. Create the Virtual Joystick UI

1. Create a Canvas: `Right-click Hierarchy > UI > Canvas`
2. Set Canvas Scaler to "Scale With Screen Size"
3. Reference Resolution: 1920x1080
4. Create the joystick:
   - Right-click Canvas > `UI > Image` (name it "JoystickArea")
   - Set it to cover the full screen
   - Set color alpha to 0 (transparent)
   - Add the `VirtualJoystick` script component
5. Create joystick background:
   - Right-click JoystickArea > `UI > Image` (name it "JoystickBackground")
   - Set size to 150x150
   - Set color to semi-transparent gray
   - Make it circular (use a circle sprite or UI mask)
6. Create joystick handle:
   - Right-click JoystickBackground > `UI > Image` (name it "JoystickHandle")
   - Set size to 60x60
   - Set color to white or light gray
   - Make it circular
7. Configure VirtualJoystick script:
   - Assign JoystickBackground to the background field
   - Assign JoystickHandle to the handle field
   - Set Handle Range to 50
   - Enable Dynamic Joystick

### 6. Set Up the Camera

1. Select the Main Camera
2. Set Projection to "Orthographic"
3. Set Size to 8 (adjust for desired zoom level)
4. Add the `CameraFollow` script component
5. Assign the Player transform to the Target field

### 7. Create the Chunk Manager

1. Create an empty GameObject named "ChunkManager"
2. Add the `ChunkManager` script component
3. Configure the script:
   - Assign the WorldTilemap to the Tilemap field
   - Assign the Player transform to the Player field
   - Assign the three tiles (Grass, Water, Snow) to their respective fields
   - Set View Distance to 3
   - Set Unload Distance to 5

### 8. Create the Game Manager

1. Create an empty GameObject named "GameManager"
2. Add the `GameManager` script component
3. Configure the script:
   - Assign ChunkManager
   - Assign PlayerController
   - Assign CameraFollow
   - Set Default World Seed (or leave as 12345)
   - Enable Load Saved Game

### 9. Create House Prefab

1. Create an empty GameObject named "House"
2. Add a `Sprite Renderer` component
3. Import a house sprite to `Assets/Sprites/Buildings/`
4. Assign the sprite to the Sprite Renderer
5. Add a `Box Collider 2D` component
6. Adjust the collider size to match the house
7. Set the layer to "Buildings" (create if needed)
8. Drag the House GameObject to `Assets/Prefabs/` to create a prefab
9. Delete the House from the scene
10. In ChunkManager script, you'll need to assign this prefab via code (see note below)

**Note:** The HousePlacer needs the house prefab assigned. You'll need to add a public field in ChunkManager to expose this:

```csharp
[SerializeField] private GameObject housePrefab;
```

Then in the Initialize method, assign it to the HousePlacer:

```csharp
housePlacer.housePrefab = housePrefab;
```

### 10. Configure Collision Layers

1. Go to `Edit > Project Settings > Tags and Layers`
2. Create these layers:
   - Ground
   - Player
   - Buildings
3. Go to `Edit > Project Settings > Physics 2D`
4. Configure Layer Collision Matrix:
   - Player should collide with: Ground, Buildings
   - Buildings should collide with: Player

### 11. Configure Build Settings

1. Go to `File > Build Settings`
2. Add the MainGame scene to "Scenes In Build"
3. Select Android or iOS platform
4. Click "Switch Platform"
5. Go to `Edit > Project Settings > Player`
6. Verify these settings:
   - Company Name: Your company name
   - Product Name: Mobile Game MVP
   - Default Orientation: Landscape Left
   - Auto-rotation: Landscape Left and Right only
   - Target API Level (Android): 22 or higher

## Testing in Unity Editor

1. Press Play in the Unity Editor
2. Use WASD or Arrow keys to move (joystick works on mobile only)
3. Verify:
   - World generates around the player
   - Different biomes are visible
   - Water blocks movement
   - Houses appear and block movement
   - Camera follows the player smoothly

## Building for Mobile

### Android

1. Go to `File > Build Settings`
2. Select Android
3. Click "Player Settings"
4. Configure:
   - Package Name: com.yourcompany.mobilegamemvp
   - Minimum API Level: 22
   - Target API Level: Automatic (highest installed)
5. Click "Build" or "Build And Run"

### iOS

1. Go to `File > Build Settings`
2. Select iOS
3. Click "Player Settings"
4. Configure:
   - Bundle Identifier: com.yourcompany.mobilegamemvp
   - Target minimum iOS Version: 11.0
5. Click "Build"
6. Open the generated Xcode project
7. Configure signing and build in Xcode

## Troubleshooting

### Joystick Not Working

- Ensure the VirtualJoystick script is attached to the JoystickArea
- Verify the background and handle are assigned
- Check that the Canvas has a GraphicRaycaster component

### Player Not Moving

- Verify PlayerController has reference to the joystick
- Check that PlayerMovement is initialized with ChunkManager
- Ensure Rigidbody2D is set to Dynamic with Gravity Scale 0

### World Not Generating

- Verify ChunkManager has all tile references assigned
- Check that the Tilemap is assigned
- Ensure the Player transform is assigned to ChunkManager

### Collision Not Working

- Verify collision layers are set up correctly
- Check that Tilemap has Tilemap Collider 2D
- Ensure houses have Box Collider 2D components

### Performance Issues

- Reduce View Distance in ChunkManager (try 2 instead of 3)
- Ensure Static Batching is enabled in Player Settings
- Use texture atlases for sprites
- Enable GPU Instancing on materials

## Next Steps

1. Import or create better sprites for tiles, player, and houses
2. Add animations for the player
3. Tune biome generation parameters for better visuals
4. Add sound effects and music
5. Implement additional features (items, NPCs, etc.)

## Asset Recommendations

### Free Asset Sources

- **Kenney.nl** - Excellent free 2D assets
  - Top-Down Tanks Redux (for player sprites)
  - Tiny Town (for building sprites)
  - Abstract Platformer (for tile sprites)
- **Unity Asset Store** - Search for "2D top-down" and filter by "Free"
- **OpenGameArt.org** - Community-created assets

### Recommended Packages

- **2D Sprite** package (should be included)
- **Cinemachine** (optional, for advanced camera control)
- **Universal Render Pipeline** (optional, for better graphics)

## Support

For issues or questions, refer to:
- Unity Documentation: https://docs.unity3d.com/
- Unity Forums: https://forum.unity.com/
- This project's README.md
