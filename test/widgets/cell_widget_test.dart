import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minesweeper/models/cell.dart';
import 'package:minesweeper/widgets/cell_widget.dart';

void main() {
  group('CellWidget', () {
    testWidgets('should display empty cell when not revealed', (tester) async {
      final cell = Cell(row: 0, col: 0);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CellWidget(
              cell: cell,
              onTap: () {},
              onLongPress: () {},
            ),
          ),
        ),
      );

      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('should display flag icon when flagged', (tester) async {
      final cell = Cell(row: 0, col: 0, isFlagged: true);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CellWidget(
              cell: cell,
              onTap: () {},
              onLongPress: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.flag), findsOneWidget);
    });

    testWidgets('should display mine icon when revealed mine', (tester) async {
      final cell = Cell(row: 0, col: 0, isMine: true, isRevealed: true);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CellWidget(
              cell: cell,
              onTap: () {},
              onLongPress: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.circle), findsOneWidget);
    });

    testWidgets('should display adjacent mine count when revealed', (tester) async {
      final cell = Cell(row: 0, col: 0, isRevealed: true, adjacentMines: 3);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CellWidget(
              cell: cell,
              onTap: () {},
              onLongPress: () {},
            ),
          ),
        ),
      );

      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('should not display number when adjacent mines is 0', (tester) async {
      final cell = Cell(row: 0, col: 0, isRevealed: true, adjacentMines: 0);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CellWidget(
              cell: cell,
              onTap: () {},
              onLongPress: () {},
            ),
          ),
        ),
      );

      expect(find.text('0'), findsNothing);
    });

    testWidgets('should call onTap when tapped', (tester) async {
      final cell = Cell(row: 0, col: 0);
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CellWidget(
              cell: cell,
              onTap: () => tapped = true,
              onLongPress: () {},
            ),
          ),
        ),
      );

      await tester.tap(find.byType(CellWidget));
      expect(tapped, true);
    });

    testWidgets('should call onLongPress when long pressed', (tester) async {
      final cell = Cell(row: 0, col: 0);
      bool longPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CellWidget(
              cell: cell,
              onTap: () {},
              onLongPress: () => longPressed = true,
            ),
          ),
        ),
      );

      await tester.longPress(find.byType(CellWidget));
      expect(longPressed, true);
    });

    testWidgets('should have different colors for different mine counts', (tester) async {
      for (int i = 1; i <= 8; i++) {
        final cell = Cell(row: 0, col: 0, isRevealed: true, adjacentMines: i);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CellWidget(
                cell: cell,
                onTap: () {},
                onLongPress: () {},
              ),
            ),
          ),
        );

        expect(find.text('$i'), findsOneWidget);
        await tester.pumpWidget(Container());
      }
    });

    testWidgets('should display amber color when hint revealed', (tester) async {
      final cell = Cell(row: 0, col: 0, isHintRevealed: true);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CellWidget(
              cell: cell,
              onTap: () {},
              onLongPress: () {},
            ),
          ),
        ),
      );

      final container = tester.widget<AnimatedContainer>(
        find.byType(AnimatedContainer),
      );

      expect(container.decoration, isA<BoxDecoration>());
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, Colors.amber[200]);
    });

    testWidgets('should have amber border when hint revealed', (tester) async {
      final cell = Cell(row: 0, col: 0, isHintRevealed: true);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CellWidget(
              cell: cell,
              onTap: () {},
              onLongPress: () {},
            ),
          ),
        ),
      );

      final container = tester.widget<AnimatedContainer>(
        find.byType(AnimatedContainer),
      );

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.border, isA<Border>());
      final border = decoration.border as Border;
      expect(border.top.color, Colors.amber[700]);
      expect(border.top.width, 2);
    });

    testWidgets('should have box shadow when hint revealed', (tester) async {
      final cell = Cell(row: 0, col: 0, isHintRevealed: true);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CellWidget(
              cell: cell,
              onTap: () {},
              onLongPress: () {},
            ),
          ),
        ),
      );

      final container = tester.widget<AnimatedContainer>(
        find.byType(AnimatedContainer),
      );

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.boxShadow, isNotNull);
      expect(decoration.boxShadow!.length, 1);
      expect(decoration.boxShadow![0].blurRadius, 8);
      expect(decoration.boxShadow![0].spreadRadius, 2);
    });

    testWidgets('should not have box shadow when not hint revealed', (tester) async {
      final cell = Cell(row: 0, col: 0, isRevealed: true);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CellWidget(
              cell: cell,
              onTap: () {},
              onLongPress: () {},
            ),
          ),
        ),
      );

      final container = tester.widget<AnimatedContainer>(
        find.byType(AnimatedContainer),
      );

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.boxShadow, isNull);
    });

    testWidgets('should use AnimatedContainer for hint animation', (tester) async {
      final cell = Cell(row: 0, col: 0);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CellWidget(
              cell: cell,
              onTap: () {},
              onLongPress: () {},
            ),
          ),
        ),
      );

      expect(find.byType(AnimatedContainer), findsOneWidget);
      
      final container = tester.widget<AnimatedContainer>(
        find.byType(AnimatedContainer),
      );
      expect(container.duration, const Duration(milliseconds: 300));
    });

    testWidgets('should display hint revealed cell with content', (tester) async {
      final cell = Cell(
        row: 0,
        col: 0,
        isHintRevealed: true,
        isRevealed: true,
        adjacentMines: 2,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CellWidget(
              cell: cell,
              onTap: () {},
              onLongPress: () {},
            ),
          ),
        ),
      );

      expect(find.text('2'), findsOneWidget);
      
      final container = tester.widget<AnimatedContainer>(
        find.byType(AnimatedContainer),
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, Colors.amber[200]);
    });
  });
}
