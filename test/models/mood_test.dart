import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minesweeper/models/mood.dart';

void main() {
  group('Mood', () {
    test('should have all expected enum values', () {
      expect(Mood.values.length, 5);
      expect(Mood.values, contains(Mood.happy));
      expect(Mood.values, contains(Mood.calm));
      expect(Mood.values, contains(Mood.anxious));
      expect(Mood.values, contains(Mood.sad));
      expect(Mood.values, contains(Mood.neutral));
    });

    group('label extension', () {
      test('should return correct label for happy', () {
        expect(Mood.happy.label, 'Happy');
      });

      test('should return correct label for calm', () {
        expect(Mood.calm.label, 'Calm');
      });

      test('should return correct label for anxious', () {
        expect(Mood.anxious.label, 'Anxious');
      });

      test('should return correct label for sad', () {
        expect(Mood.sad.label, 'Sad');
      });

      test('should return correct label for neutral', () {
        expect(Mood.neutral.label, 'Neutral');
      });
    });

    group('color extension', () {
      test('should return green for happy', () {
        expect(Mood.happy.color, Colors.green);
      });

      test('should return blue for calm', () {
        expect(Mood.calm.color, Colors.blue);
      });

      test('should return orange for anxious', () {
        expect(Mood.anxious.color, Colors.orange);
      });

      test('should return purple for sad', () {
        expect(Mood.sad.color, Colors.purple);
      });

      test('should return grey for neutral', () {
        expect(Mood.neutral.color, Colors.grey);
      });
    });

    group('icon extension', () {
      test('should return sentiment_very_satisfied for happy', () {
        expect(Mood.happy.icon, Icons.sentiment_very_satisfied);
      });

      test('should return self_improvement for calm', () {
        expect(Mood.calm.icon, Icons.self_improvement);
      });

      test('should return sentiment_dissatisfied for anxious', () {
        expect(Mood.anxious.icon, Icons.sentiment_dissatisfied);
      });

      test('should return sentiment_very_dissatisfied for sad', () {
        expect(Mood.sad.icon, Icons.sentiment_very_dissatisfied);
      });

      test('should return sentiment_neutral for neutral', () {
        expect(Mood.neutral.icon, Icons.sentiment_neutral);
      });
    });

    group('enum name', () {
      test('should have correct name property for serialization', () {
        expect(Mood.happy.name, 'happy');
        expect(Mood.calm.name, 'calm');
        expect(Mood.anxious.name, 'anxious');
        expect(Mood.sad.name, 'sad');
        expect(Mood.neutral.name, 'neutral');
      });
    });
  });
}
