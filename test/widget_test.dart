import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minesweeper/main.dart';

void main() {
  testWidgets('Minesweeper app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MinesweeperApp());

    expect(find.text('Minesweeper'), findsOneWidget);
    expect(find.byIcon(Icons.flag), findsOneWidget);
    expect(find.byIcon(Icons.timer), findsOneWidget);
  });
}
