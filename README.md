# Minesweeper Mobile Game

A functional and minimalist mobile Minesweeper game built with Flutter, working on both Android and iOS.

## Features

- **Classic Minesweeper Gameplay**: Reveal cells, flag mines, and clear the board
- **Three Difficulty Levels**:
  - Beginner: 9×9 grid with 10 mines
  - Intermediate: 16×16 grid with 40 mines
  - Expert: 16×30 grid with 99 mines
- **Game Mechanics**:
  - First click is always safe
  - Tap to reveal cells
  - Long-press to flag suspected mines
  - Auto-reveal adjacent cells when clicking empty cells
  - Numbers indicate adjacent mine count
  - **Hint System**: Get help with 3 hints per game that reveal safe cells
- **UI Features**:
  - Mine counter showing remaining mines
  - Timer tracking game duration
  - Hint button with counter (💡) - reveals a safe cell with visual feedback
  - Reset button with game state indicator (😊/😄/☹️)
  - Clean, minimalist design
  - Responsive layout for different screen sizes

## Getting Started

### Prerequisites

- Flutter SDK (3.38.9 or later)
- Android Studio / Xcode for mobile development

### Installation

1. Clone the repository
2. Install dependencies:
   ```bash
   flutter pub get
   ```

### Running the App

```bash
flutter run
```

## Project Structure

```
lib/
├── main.dart                    # App entry point
├── models/
│   ├── cell.dart               # Cell data model
│   ├── difficulty.dart         # Difficulty levels
│   └── game_state.dart         # Game state enum
├── controllers/
│   └── game_controller.dart    # Game logic and state management
├── widgets/
│   ├── cell_widget.dart        # Individual cell UI
│   └── board_widget.dart       # Game board UI
└── screens/
    ├── game_screen.dart        # Main game screen
    └── difficulty_screen.dart  # Difficulty selection
```

## How to Play

1. **Start a Game**: Tap any cell to begin
2. **Reveal Cells**: Tap on cells to reveal them
3. **Flag Mines**: Long-press on cells to flag suspected mines
4. **Use Hints**: Tap the lightbulb button (💡) to reveal a safe cell (3 hints per game)
   - Hints prioritize cells that will reveal larger areas
   - Hint-revealed cells are highlighted with an amber glow
   - Hints are only available after the game starts
5. **Win**: Reveal all non-mine cells
6. **Lose**: Reveal a mine
7. **Reset**: Tap the face button to start a new game
8. **Change Difficulty**: Tap the settings icon to select a different difficulty level

## Technical Details

- **Framework**: Flutter 3.38.9
- **State Management**: Provider
- **Architecture**: MVC pattern
- **Platforms**: Android, iOS, Web, Windows, macOS, Linux
