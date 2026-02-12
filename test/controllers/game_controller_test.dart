import 'package:flutter_test/flutter_test.dart';
import 'package:minesweeper/controllers/game_controller.dart';
import 'package:minesweeper/models/cell.dart';
import 'package:minesweeper/models/difficulty.dart';
import 'package:minesweeper/models/game_state.dart';

void main() {
  group('GameController', () {
    late GameController controller;

    setUp(() {
      controller = GameController();
    });

    tearDown(() {
      controller.dispose();
    });

    group('Initialization', () {
      test('should initialize with beginner difficulty', () {
        expect(controller.difficulty, Difficulty.beginner);
      });

      test('should initialize board with correct dimensions', () {
        expect(controller.board.length, Difficulty.beginner.rows);
        expect(controller.board[0].length, Difficulty.beginner.cols);
      });

      test('should initialize with ready game state', () {
        expect(controller.gameState, GameState.ready);
      });

      test('should initialize with zero flags', () {
        expect(controller.flagCount, 0);
      });

      test('should initialize with zero elapsed time', () {
        expect(controller.elapsedSeconds, 0);
      });

      test('should initialize remaining mines equal to total mines', () {
        expect(controller.remainingMines, Difficulty.beginner.mines);
      });

      test('should initialize all cells as not revealed', () {
        for (var row in controller.board) {
          for (var cell in row) {
            expect(cell.isRevealed, false);
            expect(cell.isFlagged, false);
            expect(cell.isMine, false);
          }
        }
      });
    });

    group('Difficulty Management', () {
      test('should change difficulty to intermediate', () {
        controller.setDifficulty(Difficulty.intermediate);

        expect(controller.difficulty, Difficulty.intermediate);
        expect(controller.board.length, Difficulty.intermediate.rows);
        expect(controller.board[0].length, Difficulty.intermediate.cols);
      });

      test('should change difficulty to expert', () {
        controller.setDifficulty(Difficulty.expert);

        expect(controller.difficulty, Difficulty.expert);
        expect(controller.board.length, Difficulty.expert.rows);
        expect(controller.board[0].length, Difficulty.expert.cols);
      });

      test('should reset game when changing difficulty', () {
        controller.revealCell(0, 0);
        expect(controller.gameState, GameState.playing);

        controller.setDifficulty(Difficulty.intermediate);

        expect(controller.gameState, GameState.ready);
        expect(controller.flagCount, 0);
        expect(controller.elapsedSeconds, 0);
      });
    });

    group('Mine Placement', () {
      test('should place correct number of mines after first click', () {
        controller.revealCell(0, 0);

        int mineCount = 0;
        for (var row in controller.board) {
          for (var cell in row) {
            if (cell.isMine) mineCount++;
          }
        }

        expect(mineCount, Difficulty.beginner.mines);
      });

      test('should not place mine on first clicked cell', () {
        controller.revealCell(4, 4);

        expect(controller.board[4][4].isMine, false);
      });

      test('should calculate adjacent mines correctly', () {
        controller.revealCell(0, 0);

        for (int row = 0; row < controller.board.length; row++) {
          for (int col = 0; col < controller.board[row].length; col++) {
            final cell = controller.board[row][col];
            if (!cell.isMine) {
              int actualAdjacentMines = 0;
              for (int dr = -1; dr <= 1; dr++) {
                for (int dc = -1; dc <= 1; dc++) {
                  if (dr == 0 && dc == 0) continue;
                  final newRow = row + dr;
                  final newCol = col + dc;
                  if (newRow >= 0 && newRow < controller.board.length &&
                      newCol >= 0 && newCol < controller.board[0].length &&
                      controller.board[newRow][newCol].isMine) {
                    actualAdjacentMines++;
                  }
                }
              }
              expect(cell.adjacentMines, actualAdjacentMines,
                  reason: 'Cell at ($row, $col) has incorrect adjacent mine count');
            }
          }
        }
      });
    });

    group('Cell Revealing', () {
      test('should change game state to playing on first reveal', () {
        expect(controller.gameState, GameState.ready);

        controller.revealCell(0, 0);

        expect(controller.gameState, GameState.playing);
      });

      test('should reveal cell when clicked', () {
        controller.revealCell(0, 0);

        expect(controller.board[0][0].isRevealed, true);
      });

      test('should not reveal flagged cell', () {
        controller.toggleFlag(0, 0);
        controller.revealCell(0, 0);

        expect(controller.board[0][0].isRevealed, false);
      });

      test('should not reveal cell when game is won', () {
        controller.revealCell(0, 0);
        
        for (var row in controller.board) {
          for (var cell in row) {
            if (!cell.isMine && !cell.isRevealed) {
              cell.isRevealed = true;
            }
          }
        }
        
        controller.revealCell(1, 1);
        final wasRevealed = controller.board[1][1].isRevealed;
        
        controller.revealCell(2, 2);
        
        expect(controller.board[2][2].isRevealed, wasRevealed);
      });

      test('should reveal all mines when mine is clicked', () {
        controller.revealCell(0, 0);

        Cell? mineCell;
        for (var row in controller.board) {
          for (var cell in row) {
            if (cell.isMine) {
              mineCell = cell;
              break;
            }
          }
          if (mineCell != null) break;
        }

        if (mineCell != null) {
          controller.revealCell(mineCell.row, mineCell.col);

          for (var row in controller.board) {
            for (var cell in row) {
              if (cell.isMine) {
                expect(cell.isRevealed, true);
              }
            }
          }
        }
      });

      test('should set game state to lost when mine is revealed', () {
        controller.revealCell(0, 0);

        Cell? mineCell;
        for (var row in controller.board) {
          for (var cell in row) {
            if (cell.isMine) {
              mineCell = cell;
              break;
            }
          }
          if (mineCell != null) break;
        }

        if (mineCell != null) {
          controller.revealCell(mineCell.row, mineCell.col);
          expect(controller.gameState, GameState.lost);
        }
      });

      test('should recursively reveal adjacent cells when cell has no adjacent mines', () {
        controller.revealCell(0, 0);

        final cell = controller.board[0][0];
        if (cell.adjacentMines == 0 && !cell.isMine) {
          int revealedCount = 0;
          for (var row in controller.board) {
            for (var c in row) {
              if (c.isRevealed) revealedCount++;
            }
          }
          expect(revealedCount, greaterThan(1));
        }
      });
    });

    group('Flag Management', () {
      test('should toggle flag on cell', () {
        controller.toggleFlag(0, 0);

        expect(controller.board[0][0].isFlagged, true);
        expect(controller.flagCount, 1);
      });

      test('should untoggle flag on cell', () {
        controller.toggleFlag(0, 0);
        controller.toggleFlag(0, 0);

        expect(controller.board[0][0].isFlagged, false);
        expect(controller.flagCount, 0);
      });

      test('should update remaining mines count when flagging', () {
        final initialRemaining = controller.remainingMines;
        controller.toggleFlag(0, 0);

        expect(controller.remainingMines, initialRemaining - 1);
      });

      test('should update remaining mines count when unflagging', () {
        controller.toggleFlag(0, 0);
        final afterFlag = controller.remainingMines;
        controller.toggleFlag(0, 0);

        expect(controller.remainingMines, afterFlag + 1);
      });

      test('should not flag revealed cell', () {
        controller.revealCell(0, 0);
        controller.toggleFlag(0, 0);

        expect(controller.board[0][0].isFlagged, false);
      });

      test('should change game state to playing on first flag', () {
        expect(controller.gameState, GameState.ready);

        controller.toggleFlag(0, 0);

        expect(controller.gameState, GameState.playing);
      });

      test('should allow multiple flags', () {
        controller.toggleFlag(0, 0);
        controller.toggleFlag(0, 1);
        controller.toggleFlag(1, 0);

        expect(controller.flagCount, 3);
        expect(controller.board[0][0].isFlagged, true);
        expect(controller.board[0][1].isFlagged, true);
        expect(controller.board[1][0].isFlagged, true);
      });
    });

    group('Win Condition', () {
      test('should win when all non-mine cells are revealed', () {
        controller.revealCell(0, 0);

        int revealedCount = 0;
        for (var row in controller.board) {
          for (var cell in row) {
            if (cell.isRevealed) revealedCount++;
          }
        }

        final totalCells = controller.difficulty.rows * controller.difficulty.cols;
        final nonMineCells = totalCells - controller.difficulty.mines;

        for (var row in controller.board) {
          for (var cell in row) {
            if (!cell.isMine && !cell.isRevealed && !cell.isFlagged) {
              controller.revealCell(cell.row, cell.col);
            }
          }
        }

        expect(controller.gameState, GameState.won);
      });

      test('should not win if any non-mine cell is unrevealed', () {
        controller.revealCell(0, 0);

        int unrevealedNonMine = 0;
        for (var row in controller.board) {
          for (var cell in row) {
            if (!cell.isMine && !cell.isRevealed) {
              unrevealedNonMine++;
            }
          }
        }

        if (unrevealedNonMine > 0) {
          expect(controller.gameState, isNot(GameState.won));
        }
      });
    });

    group('Game Reset', () {
      test('should reset game state', () {
        controller.revealCell(0, 0);
        controller.toggleFlag(1, 1);

        controller.resetGame();

        expect(controller.gameState, GameState.ready);
        expect(controller.flagCount, 0);
        expect(controller.elapsedSeconds, 0);
      });

      test('should reset board', () {
        controller.revealCell(0, 0);

        controller.resetGame();

        for (var row in controller.board) {
          for (var cell in row) {
            expect(cell.isRevealed, false);
            expect(cell.isFlagged, false);
            expect(cell.isMine, false);
          }
        }
      });

      test('should maintain difficulty after reset', () {
        controller.setDifficulty(Difficulty.intermediate);
        controller.revealCell(0, 0);

        controller.resetGame();

        expect(controller.difficulty, Difficulty.intermediate);
        expect(controller.board.length, Difficulty.intermediate.rows);
        expect(controller.board[0].length, Difficulty.intermediate.cols);
      });
    });

    group('Timer', () {
      test('should start timer on first click', () async {
        controller.revealCell(0, 0);
        await Future.delayed(const Duration(milliseconds: 1100));

        expect(controller.elapsedSeconds, greaterThan(0));
      });

      test('should start timer on first flag', () async {
        controller.toggleFlag(0, 0);
        await Future.delayed(const Duration(milliseconds: 1100));

        expect(controller.elapsedSeconds, greaterThan(0));
      });

      test('should stop timer when game is lost', () async {
        controller.revealCell(0, 0);

        Cell? mineCell;
        for (var row in controller.board) {
          for (var cell in row) {
            if (cell.isMine) {
              mineCell = cell;
              break;
            }
          }
          if (mineCell != null) break;
        }

        if (mineCell != null) {
          controller.revealCell(mineCell.row, mineCell.col);
          final timeAtLoss = controller.elapsedSeconds;
          await Future.delayed(const Duration(milliseconds: 1100));

          expect(controller.elapsedSeconds, timeAtLoss);
        }
      });

      test('should reset timer on game reset', () async {
        controller.revealCell(0, 0);
        await Future.delayed(const Duration(milliseconds: 1100));

        controller.resetGame();

        expect(controller.elapsedSeconds, 0);
      });
    });

    group('Edge Cases', () {
      test('should handle corner cell reveals', () {
        controller.revealCell(0, 0);
        expect(controller.board[0][0].isRevealed, true);

        controller.resetGame();
        controller.revealCell(
          Difficulty.beginner.rows - 1,
          Difficulty.beginner.cols - 1,
        );
        expect(
          controller.board[Difficulty.beginner.rows - 1]
              [Difficulty.beginner.cols - 1].isRevealed,
          true,
        );
      });

      test('should handle edge cell reveals', () {
        controller.revealCell(0, 4);
        expect(controller.board[0][4].isRevealed, true);

        controller.resetGame();
        controller.revealCell(4, 0);
        expect(controller.board[4][0].isRevealed, true);
      });

      test('should handle revealing already revealed cell', () {
        controller.revealCell(0, 0);
        final firstRevealState = controller.gameState;

        controller.revealCell(0, 0);

        expect(controller.gameState, firstRevealState);
      });

      test('should handle flagging and unflagging same cell multiple times', () {
        for (int i = 0; i < 5; i++) {
          controller.toggleFlag(0, 0);
          expect(controller.board[0][0].isFlagged, true);
          expect(controller.flagCount, 1);

          controller.toggleFlag(0, 0);
          expect(controller.board[0][0].isFlagged, false);
          expect(controller.flagCount, 0);
        }
      });
    });

    group('Notification', () {
      test('should notify listeners on reveal', () {
        int notificationCount = 0;
        controller.addListener(() => notificationCount++);

        controller.revealCell(0, 0);

        expect(notificationCount, greaterThan(0));
      });

      test('should notify listeners on flag toggle', () {
        int notificationCount = 0;
        controller.addListener(() => notificationCount++);

        controller.toggleFlag(0, 0);

        expect(notificationCount, greaterThan(0));
      });

      test('should notify listeners on reset', () {
        int notificationCount = 0;
        controller.addListener(() => notificationCount++);

        controller.resetGame();

        expect(notificationCount, greaterThan(0));
      });
    });
  });
}
