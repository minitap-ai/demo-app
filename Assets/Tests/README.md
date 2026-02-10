# Test Suite for Mobile Game MVP

This directory contains comprehensive unit and integration tests for the mobile game MVP implementation.

## Test Structure

### EditMode Tests (Unit Tests)
Located in `Assets/Tests/EditMode/`

These tests run in Unity's Edit Mode and test individual components without requiring a running game:

- **BiomeGeneratorTests.cs** (12 tests)
  - Determinism verification
  - Biome type validation
  - Walkability logic
  - Edge cases (negative coordinates, large coordinates)
  - Distribution testing

- **GameDataTests.cs** (11 tests)
  - Constructor validation
  - Serialization/deserialization
  - Position handling
  - Edge cases

- **HousePlacerTests.cs** (9 tests)
  - Seed generation consistency
  - Placement validation logic
  - Distance checking
  - Water avoidance

**Total EditMode Tests: 32**

### PlayMode Tests (Integration Tests)
Located in `Assets/Tests/PlayMode/`

These tests run in Unity's Play Mode and test system integration:

- **GameSystemsIntegrationTests.cs** (8 tests)
  - World generation consistency
  - Save/load persistence
  - Data round-trip verification
  - Biome distribution analysis
  - System integration

**Total PlayMode Tests: 8**

## Running the Tests

### Prerequisites
- Unity 2022.3.10f1 LTS or compatible version
- Unity Test Framework package (should be included by default)

### In Unity Editor

1. **Open Test Runner Window**
   - Go to `Window > General > Test Runner`

2. **Run EditMode Tests**
   - Click the "EditMode" tab
   - Click "Run All" to run all unit tests
   - Or click individual test classes/methods to run specific tests

3. **Run PlayMode Tests**
   - Click the "PlayMode" tab
   - Click "Run All" to run all integration tests
   - Note: PlayMode tests will enter Play Mode automatically

### Via Command Line

#### Run All Tests
```bash
# Windows
"C:\Program Files\Unity\Hub\Editor\2022.3.10f1\Editor\Unity.exe" -runTests -batchmode -projectPath . -testResults ./TestResults.xml -testPlatform EditMode,PlayMode

# macOS
/Applications/Unity/Hub/Editor/2022.3.10f1/Unity.app/Contents/MacOS/Unity -runTests -batchmode -projectPath . -testResults ./TestResults.xml -testPlatform EditMode,PlayMode

# Linux
~/Unity/Hub/Editor/2022.3.10f1/Editor/Unity -runTests -batchmode -projectPath . -testResults ./TestResults.xml -testPlatform EditMode,PlayMode
```

#### Run Only EditMode Tests
```bash
Unity -runTests -batchmode -projectPath . -testResults ./TestResults.xml -testPlatform EditMode
```

#### Run Only PlayMode Tests
```bash
Unity -runTests -batchmode -projectPath . -testResults ./TestResults.xml -testPlatform PlayMode
```

## Test Coverage

### Covered Components
✅ BiomeGenerator - Full coverage of core logic
✅ GameData - Full coverage of data structure
✅ HousePlacer - Coverage of placement logic
✅ SaveLoadManager - Integration testing of persistence
✅ System Integration - Cross-component testing

### Not Covered (Requires Unity Scene)
❌ PlayerController - Requires scene setup
❌ PlayerMovement - Requires physics simulation
❌ VirtualJoystick - Requires UI and input
❌ CameraFollow - Requires camera and scene
❌ ChunkManager - Requires Tilemap and scene
❌ GameManager - Requires full scene setup

These components require a fully configured Unity scene with:
- Tilemaps and tile assets
- Sprite assets
- Prefabs
- UI Canvas
- Input system configuration

They should be tested manually in the Unity Editor after scene setup is complete (see SETUP_INSTRUCTIONS.md).

## Test Results Interpretation

### Success Criteria
- All EditMode tests should pass (32/32)
- All PlayMode tests should pass (8/8)
- No errors or warnings in console
- Total: 40 tests passing

### Common Issues

**Issue: "Assembly not found"**
- Solution: Ensure .asmdef files are properly configured
- Reimport the Tests folder in Unity

**Issue: "Type or namespace not found"**
- Solution: Check that all scripts compile without errors
- Verify namespace declarations match

**Issue: PlayMode tests timeout**
- Solution: Increase timeout in Test Runner settings
- Check for infinite loops in test code

**Issue: Random test failures**
- Solution: Some tests use randomness; re-run to verify
- Check for race conditions in async tests

## Continuous Integration

To integrate with CI/CD pipelines:

1. Use Unity's command-line test runner (see above)
2. Parse the TestResults.xml file for results
3. Fail the build if any tests fail
4. Generate coverage reports if needed

Example CI script:
```yaml
test:
  script:
    - unity-editor -runTests -batchmode -projectPath . -testResults ./TestResults.xml -testPlatform EditMode,PlayMode
    - cat TestResults.xml
  artifacts:
    reports:
      junit: TestResults.xml
```

## Adding New Tests

### For EditMode Tests
1. Create a new .cs file in `Assets/Tests/EditMode/`
2. Use namespace `MobileGameMVP.Tests.EditMode`
3. Add `[TestFixture]` attribute to class
4. Add `[Test]` attribute to test methods
5. Use NUnit assertions

### For PlayMode Tests
1. Create a new .cs file in `Assets/Tests/PlayMode/`
2. Use namespace `MobileGameMVP.Tests.PlayMode`
3. Add `[TestFixture]` attribute to class
4. Use `[UnityTest]` attribute and return `IEnumerator`
5. Use `yield return null` for frame delays
6. Clean up created GameObjects

## Test Maintenance

- Run tests before committing changes
- Update tests when modifying game logic
- Add tests for new features
- Keep test execution time reasonable (< 30 seconds total)
- Document complex test scenarios

## Performance Considerations

- EditMode tests are fast (< 1 second total)
- PlayMode tests are slower (5-10 seconds total)
- Avoid unnecessary `yield return` statements
- Use `yield return null` sparingly
- Clean up resources to prevent memory leaks

## Further Reading

- [Unity Test Framework Documentation](https://docs.unity3d.com/Packages/com.unity.test-framework@latest)
- [NUnit Documentation](https://docs.nunit.org/)
- [Unity Testing Best Practices](https://unity.com/how-to/unity-test-framework-tutorial)
