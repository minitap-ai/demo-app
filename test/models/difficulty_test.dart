import 'package:flutter_test/flutter_test.dart';
import 'package:minesweeper/models/difficulty.dart';

void main() {
  group('Difficulty', () {
    test('should create custom difficulty', () {
      const difficulty = Difficulty(
        name: 'Custom',
        rows: 10,
        cols: 10,
        mines: 15,
      );

      expect(difficulty.name, 'Custom');
      expect(difficulty.rows, 10);
      expect(difficulty.cols, 10);
      expect(difficulty.mines, 15);
    });

    group('Beginner', () {
      test('should have correct values', () {
        expect(Difficulty.beginner.name, 'Beginner');
        expect(Difficulty.beginner.rows, 9);
        expect(Difficulty.beginner.cols, 9);
        expect(Difficulty.beginner.mines, 10);
      });

      test('should have valid mine density', () {
        final totalCells = Difficulty.beginner.rows * Difficulty.beginner.cols;
        final mineDensity = Difficulty.beginner.mines / totalCells;
        expect(mineDensity, lessThan(0.5));
      });
    });

    group('Intermediate', () {
      test('should have correct values', () {
        expect(Difficulty.intermediate.name, 'Intermediate');
        expect(Difficulty.intermediate.rows, 16);
        expect(Difficulty.intermediate.cols, 16);
        expect(Difficulty.intermediate.mines, 40);
      });

      test('should have valid mine density', () {
        final totalCells = Difficulty.intermediate.rows * Difficulty.intermediate.cols;
        final mineDensity = Difficulty.intermediate.mines / totalCells;
        expect(mineDensity, lessThan(0.5));
      });

      test('should be harder than beginner', () {
        expect(Difficulty.intermediate.mines, greaterThan(Difficulty.beginner.mines));
        final beginnerCells = Difficulty.beginner.rows * Difficulty.beginner.cols;
        final intermediateCells = Difficulty.intermediate.rows * Difficulty.intermediate.cols;
        expect(intermediateCells, greaterThan(beginnerCells));
      });
    });

    group('Expert', () {
      test('should have correct values', () {
        expect(Difficulty.expert.name, 'Expert');
        expect(Difficulty.expert.rows, 16);
        expect(Difficulty.expert.cols, 30);
        expect(Difficulty.expert.mines, 99);
      });

      test('should have valid mine density', () {
        final totalCells = Difficulty.expert.rows * Difficulty.expert.cols;
        final mineDensity = Difficulty.expert.mines / totalCells;
        expect(mineDensity, lessThan(0.5));
      });

      test('should be hardest difficulty', () {
        expect(Difficulty.expert.mines, greaterThan(Difficulty.intermediate.mines));
        final intermediateCells = Difficulty.intermediate.rows * Difficulty.intermediate.cols;
        final expertCells = Difficulty.expert.rows * Difficulty.expert.cols;
        expect(expertCells, greaterThan(intermediateCells));
      });
    });

    group('all', () {
      test('should contain all three difficulty levels', () {
        expect(Difficulty.all.length, 3);
        expect(Difficulty.all, contains(Difficulty.beginner));
        expect(Difficulty.all, contains(Difficulty.intermediate));
        expect(Difficulty.all, contains(Difficulty.expert));
      });

      test('should be in order of increasing difficulty', () {
        expect(Difficulty.all[0], Difficulty.beginner);
        expect(Difficulty.all[1], Difficulty.intermediate);
        expect(Difficulty.all[2], Difficulty.expert);
      });
    });
  });
}
