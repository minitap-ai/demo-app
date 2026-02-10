import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minesweeper/main.dart';
import 'package:minesweeper/models/difficulty.dart';

void main() {
  group('Minesweeper App Integration Tests', () {
    testWidgets('should display game screen on launch', (tester) async {
      await tester.pumpWidget(const MinesweeperApp());

      expect(find.text('Minesweeper'), findsOneWidget);
      expect(find.byIcon(Icons.flag), findsOneWidget);
      expect(find.byIcon(Icons.timer), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);
    });

    testWidgets('should show mine counter with initial value', (tester) async {
      await tester.pumpWidget(const MinesweeperApp());

      expect(find.text('10'), findsOneWidget);
    });

    testWidgets('should show timer starting at 0', (tester) async {
      await tester.pumpWidget(const MinesweeperApp());

      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('should have reset button with satisfied icon', (tester) async {
      await tester.pumpWidget(const MinesweeperApp());

      expect(find.byIcon(Icons.sentiment_satisfied), findsOneWidget);
    });

    testWidgets('should navigate to difficulty screen when settings tapped', (tester) async {
      await tester.pumpWidget(const MinesweeperApp());

      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      expect(find.text('Select Difficulty'), findsOneWidget);
      expect(find.text('Beginner'), findsOneWidget);
      expect(find.text('Intermediate'), findsOneWidget);
      expect(find.text('Expert'), findsOneWidget);
    });

    testWidgets('should display all three difficulty options in settings', (tester) async {
      await tester.pumpWidget(const MinesweeperApp());

      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      expect(find.text('Beginner'), findsOneWidget);
      expect(find.textContaining('9 × 9 grid'), findsOneWidget);
      
      expect(find.text('Intermediate'), findsOneWidget);
      expect(find.textContaining('16 × 16 grid'), findsOneWidget);
      
      expect(find.text('Expert'), findsOneWidget);
      expect(find.textContaining('16 × 30 grid'), findsOneWidget);
    });

    testWidgets('should change difficulty when selected', (tester) async {
      await tester.pumpWidget(const MinesweeperApp());

      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Intermediate'));
      await tester.pumpAndSettle();

      expect(find.text('40'), findsOneWidget);
    });

    testWidgets('should display board with cells', (tester) async {
      await tester.pumpWidget(const MinesweeperApp());

      final totalCells = Difficulty.beginner.rows * Difficulty.beginner.cols;
      expect(find.byType(GestureDetector), findsAtLeast(totalCells));
    });
  });
}
