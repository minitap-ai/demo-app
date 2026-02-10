import 'package:flutter_test/flutter_test.dart';
import 'package:minesweeper/models/cell.dart';

void main() {
  group('Cell', () {
    test('should initialize with default values', () {
      final cell = Cell(row: 0, col: 0);

      expect(cell.row, 0);
      expect(cell.col, 0);
      expect(cell.isMine, false);
      expect(cell.isRevealed, false);
      expect(cell.isFlagged, false);
      expect(cell.adjacentMines, 0);
    });

    test('should initialize with custom values', () {
      final cell = Cell(
        row: 5,
        col: 3,
        isMine: true,
        isRevealed: true,
        isFlagged: true,
        adjacentMines: 4,
      );

      expect(cell.row, 5);
      expect(cell.col, 3);
      expect(cell.isMine, true);
      expect(cell.isRevealed, true);
      expect(cell.isFlagged, true);
      expect(cell.adjacentMines, 4);
    });

    test('should reset cell to default state', () {
      final cell = Cell(
        row: 2,
        col: 2,
        isMine: true,
        isRevealed: true,
        isFlagged: true,
        adjacentMines: 3,
      );

      cell.reset();

      expect(cell.row, 2);
      expect(cell.col, 2);
      expect(cell.isMine, false);
      expect(cell.isRevealed, false);
      expect(cell.isFlagged, false);
      expect(cell.adjacentMines, 0);
    });

    test('should allow modifying mutable properties', () {
      final cell = Cell(row: 1, col: 1);

      cell.isMine = true;
      cell.isRevealed = true;
      cell.isFlagged = true;
      cell.adjacentMines = 2;

      expect(cell.isMine, true);
      expect(cell.isRevealed, true);
      expect(cell.isFlagged, true);
      expect(cell.adjacentMines, 2);
    });
  });
}
