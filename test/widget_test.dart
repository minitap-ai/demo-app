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

    testWidgets('should display hint button with initial count of 3', (tester) async {
      await tester.pumpWidget(const MinesweeperApp());

      expect(find.byKey(const Key('hint_button_container')), findsOneWidget);
      expect(find.byIcon(Icons.lightbulb), findsOneWidget);
      expect(find.byKey(const Key('hint_counter_text')), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('should disable hint button before game starts', (tester) async {
      await tester.pumpWidget(const MinesweeperApp());

      final hintContainer = tester.widget<Container>(
        find.byKey(const Key('hint_button_container')),
      );
      final decoration = hintContainer.decoration as BoxDecoration;
      expect(decoration.color, Colors.grey[600]);
    });

    testWidgets('should enable hint button after game starts', (tester) async {
      await tester.pumpWidget(const MinesweeperApp());

      final cells = find.byType(GestureDetector);
      await tester.tap(cells.at(5));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final hintContainer = tester.widget<Container>(
        find.byKey(const Key('hint_button_container')),
      );
      final decoration = hintContainer.decoration as BoxDecoration;
      expect(decoration.color, Colors.amber[700]);
    });

    testWidgets('should decrease hint count when hint button is tapped', (tester) async {
      await tester.pumpWidget(const MinesweeperApp());

      final cells = find.byType(GestureDetector);
      await tester.tap(cells.at(5));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('3'), findsWidgets);

      await tester.tap(find.byIcon(Icons.lightbulb));
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));

      expect(find.text('2'), findsWidgets);
    });

    testWidgets('should reveal a cell when hint is used', (tester) async {
      await tester.pumpWidget(const MinesweeperApp());

      final cells = find.byType(GestureDetector);
      await tester.tap(cells.at(5));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.byIcon(Icons.lightbulb));
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));

      expect(find.text('2'), findsWidgets);
    });

    testWidgets('should disable hint button when no hints remaining', (tester) async {
      await tester.pumpWidget(const MinesweeperApp());

      final cells = find.byType(GestureDetector);
      await tester.tap(cells.at(5));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.byIcon(Icons.lightbulb));
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));
      await tester.tap(find.byIcon(Icons.lightbulb));
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));
      await tester.tap(find.byIcon(Icons.lightbulb));
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));

      expect(find.text('0'), findsWidgets);

      final hintContainer = tester.widget<Container>(
        find.byKey(const Key('hint_button_container')),
      );
      final decoration = hintContainer.decoration as BoxDecoration;
      expect(decoration.color, Colors.grey[600]);
    });

    testWidgets('should reset hint count to 3 when game is reset', (tester) async {
      await tester.pumpWidget(const MinesweeperApp());

      final cells = find.byType(GestureDetector);
      await tester.tap(cells.at(5));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.byIcon(Icons.lightbulb));
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));

      expect(find.text('2'), findsWidgets);

      await tester.tap(find.byKey(const Key('reset_button')));
      await tester.pump();

      expect(find.text('3'), findsWidgets);
    });

    testWidgets('should reset hint count when difficulty is changed', (tester) async {
      await tester.pumpWidget(const MinesweeperApp());

      final cells = find.byType(GestureDetector);
      await tester.tap(cells.at(5));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.byIcon(Icons.lightbulb));
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));

      expect(find.text('2'), findsWidgets);

      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Intermediate'));
      await tester.pumpAndSettle();

      expect(find.text('3'), findsWidgets);
    });

    testWidgets('should display hint button with lightbulb icon', (tester) async {
      await tester.pumpWidget(const MinesweeperApp());

      expect(find.byIcon(Icons.lightbulb), findsOneWidget);
    });

    testWidgets('should have hint button between timer and reset button', (tester) async {
      await tester.pumpWidget(const MinesweeperApp());

      expect(find.byIcon(Icons.timer), findsOneWidget);
      expect(find.byKey(const Key('hint_button_container')), findsOneWidget);
      expect(find.byKey(const Key('reset_button')), findsOneWidget);
    });
  });
}
