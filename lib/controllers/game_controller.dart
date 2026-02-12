import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/cell.dart';
import '../models/difficulty.dart';
import '../models/game_state.dart';

class GameController extends ChangeNotifier {
  Difficulty _difficulty = Difficulty.beginner;
  List<List<Cell>> _board = [];
  GameState _gameState = GameState.ready;
  int _flagCount = 0;
  int _revealedCount = 0;
  int _elapsedSeconds = 0;
  Timer? _timer;
  bool _firstClick = true;
  int _hintsRemaining = 3;
  static const int _maxHints = 3;

  Difficulty get difficulty => _difficulty;
  List<List<Cell>> get board => _board;
  GameState get gameState => _gameState;
  int get flagCount => _flagCount;
  int get remainingMines => _difficulty.mines - _flagCount;
  int get elapsedSeconds => _elapsedSeconds;
  int get hintsRemaining => _hintsRemaining;
  bool get canUseHint => _hintsRemaining > 0 && 
                         _gameState == GameState.playing &&
                         !_firstClick;

  GameController() {
    _initializeBoard();
  }

  void setDifficulty(Difficulty difficulty) {
    _difficulty = difficulty;
    resetGame();
  }

  void _initializeBoard() {
    _board = List.generate(
      _difficulty.rows,
      (row) => List.generate(
        _difficulty.cols,
        (col) => Cell(row: row, col: col),
      ),
    );
  }

  void _placeMines(int excludeRow, int excludeCol) {
    final random = Random();
    int minesPlaced = 0;

    while (minesPlaced < _difficulty.mines) {
      final row = random.nextInt(_difficulty.rows);
      final col = random.nextInt(_difficulty.cols);

      if (!_board[row][col].isMine && 
          !(row == excludeRow && col == excludeCol)) {
        _board[row][col].isMine = true;
        minesPlaced++;
      }
    }

    _calculateAdjacentMines();
  }

  void _calculateAdjacentMines() {
    for (int row = 0; row < _difficulty.rows; row++) {
      for (int col = 0; col < _difficulty.cols; col++) {
        if (!_board[row][col].isMine) {
          _board[row][col].adjacentMines = _countAdjacentMines(row, col);
        }
      }
    }
  }

  int _countAdjacentMines(int row, int col) {
    int count = 0;
    for (int dr = -1; dr <= 1; dr++) {
      for (int dc = -1; dc <= 1; dc++) {
        if (dr == 0 && dc == 0) continue;
        final newRow = row + dr;
        final newCol = col + dc;
        if (_isValidCell(newRow, newCol) && _board[newRow][newCol].isMine) {
          count++;
        }
      }
    }
    return count;
  }

  bool _isValidCell(int row, int col) {
    return row >= 0 && row < _difficulty.rows && 
           col >= 0 && col < _difficulty.cols;
  }

  void revealCell(int row, int col) {
    if (_gameState == GameState.won || _gameState == GameState.lost) return;

    final cell = _board[row][col];
    if (cell.isRevealed || cell.isFlagged) return;

    if (_firstClick) {
      _placeMines(row, col);
      _firstClick = false;
      _startTimer();
      _gameState = GameState.playing;
    }

    if (cell.isMine) {
      _revealAllMines();
      _gameState = GameState.lost;
      _stopTimer();
      notifyListeners();
      return;
    }

    _revealCellRecursive(row, col);
    _checkWinCondition();
    notifyListeners();
  }

  void _revealCellRecursive(int row, int col) {
    if (!_isValidCell(row, col)) return;

    final cell = _board[row][col];
    if (cell.isRevealed || cell.isFlagged || cell.isMine) return;

    cell.isRevealed = true;
    _revealedCount++;

    if (cell.adjacentMines == 0) {
      for (int dr = -1; dr <= 1; dr++) {
        for (int dc = -1; dc <= 1; dc++) {
          if (dr == 0 && dc == 0) continue;
          _revealCellRecursive(row + dr, col + dc);
        }
      }
    }
  }

  void toggleFlag(int row, int col) {
    if (_gameState == GameState.won || _gameState == GameState.lost) return;

    final cell = _board[row][col];
    if (cell.isRevealed) return;

    if (_firstClick) {
      _firstClick = false;
      _startTimer();
      _gameState = GameState.playing;
    }

    cell.isFlagged = !cell.isFlagged;
    _flagCount += cell.isFlagged ? 1 : -1;
    
    _checkWinCondition();
    notifyListeners();
  }

  void _revealAllMines() {
    for (var row in _board) {
      for (var cell in row) {
        if (cell.isMine) {
          cell.isRevealed = true;
        }
      }
    }
  }

  void _checkWinCondition() {
    final totalCells = _difficulty.rows * _difficulty.cols;
    final nonMineCells = totalCells - _difficulty.mines;

    if (_revealedCount == nonMineCells) {
      _gameState = GameState.won;
      _stopTimer();
    }
  }

  void useHint() {
    if (!canUseHint) return;

    final safeCells = _findSafeCells();
    if (safeCells.isEmpty) return;

    Cell? bestCell = _selectBestHintCell(safeCells);
    if (bestCell != null) {
      _hintsRemaining--;
      bestCell.isHintRevealed = true;
      
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (bestCell.isRevealed) {
          bestCell.isHintRevealed = false;
          notifyListeners();
        }
      });
      
      revealCell(bestCell.row, bestCell.col);
    }
  }

  List<Cell> _findSafeCells() {
    final safeCells = <Cell>[];
    for (var row in _board) {
      for (var cell in row) {
        if (!cell.isMine && !cell.isRevealed && !cell.isFlagged) {
          safeCells.add(cell);
        }
      }
    }
    return safeCells;
  }

  Cell? _selectBestHintCell(List<Cell> safeCells) {
    if (safeCells.isEmpty) return null;

    final zeroCells = safeCells.where((cell) => cell.adjacentMines == 0).toList();
    if (zeroCells.isNotEmpty) {
      return zeroCells[Random().nextInt(zeroCells.length)];
    }

    safeCells.sort((a, b) => a.adjacentMines.compareTo(b.adjacentMines));
    final minAdjacentMines = safeCells.first.adjacentMines;
    final bestCells = safeCells.where((cell) => cell.adjacentMines == minAdjacentMines).toList();
    
    return bestCells[Random().nextInt(bestCells.length)];
  }

  void _startTimer() {
    _timer?.cancel();
    _elapsedSeconds = 0;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _elapsedSeconds++;
      notifyListeners();
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  void resetGame() {
    _stopTimer();
    _gameState = GameState.ready;
    _flagCount = 0;
    _revealedCount = 0;
    _elapsedSeconds = 0;
    _firstClick = true;
    _hintsRemaining = _maxHints;
    _initializeBoard();
    notifyListeners();
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }
}
