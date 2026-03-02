import 'package:flutter_test/flutter_test.dart';
import 'package:minesweeper/models/mood.dart';
import 'package:minesweeper/models/user.dart';

void main() {
  group('User', () {
    test('should initialize with all required properties', () {
      final user = User(
        id: '123',
        name: 'John Doe',
        avatarUrl: 'https://example.com/avatar.jpg',
        currentMood: Mood.happy,
      );

      expect(user.id, '123');
      expect(user.name, 'John Doe');
      expect(user.avatarUrl, 'https://example.com/avatar.jpg');
      expect(user.currentMood, Mood.happy);
    });

    group('copyWith', () {
      test('should create a copy with updated id', () {
        final user = User(
          id: '123',
          name: 'John Doe',
          avatarUrl: 'https://example.com/avatar.jpg',
          currentMood: Mood.happy,
        );

        final updated = user.copyWith(id: '456');

        expect(updated.id, '456');
        expect(updated.name, 'John Doe');
        expect(updated.avatarUrl, 'https://example.com/avatar.jpg');
        expect(updated.currentMood, Mood.happy);
      });

      test('should create a copy with updated name', () {
        final user = User(
          id: '123',
          name: 'John Doe',
          avatarUrl: 'https://example.com/avatar.jpg',
          currentMood: Mood.happy,
        );

        final updated = user.copyWith(name: 'Jane Smith');

        expect(updated.id, '123');
        expect(updated.name, 'Jane Smith');
        expect(updated.avatarUrl, 'https://example.com/avatar.jpg');
        expect(updated.currentMood, Mood.happy);
      });

      test('should create a copy with updated avatarUrl', () {
        final user = User(
          id: '123',
          name: 'John Doe',
          avatarUrl: 'https://example.com/avatar.jpg',
          currentMood: Mood.happy,
        );

        final updated = user.copyWith(avatarUrl: 'https://example.com/new-avatar.jpg');

        expect(updated.id, '123');
        expect(updated.name, 'John Doe');
        expect(updated.avatarUrl, 'https://example.com/new-avatar.jpg');
        expect(updated.currentMood, Mood.happy);
      });

      test('should create a copy with updated currentMood', () {
        final user = User(
          id: '123',
          name: 'John Doe',
          avatarUrl: 'https://example.com/avatar.jpg',
          currentMood: Mood.happy,
        );

        final updated = user.copyWith(currentMood: Mood.sad);

        expect(updated.id, '123');
        expect(updated.name, 'John Doe');
        expect(updated.avatarUrl, 'https://example.com/avatar.jpg');
        expect(updated.currentMood, Mood.sad);
      });

      test('should create a copy with multiple updated properties', () {
        final user = User(
          id: '123',
          name: 'John Doe',
          avatarUrl: 'https://example.com/avatar.jpg',
          currentMood: Mood.happy,
        );

        final updated = user.copyWith(
          name: 'Jane Smith',
          currentMood: Mood.calm,
        );

        expect(updated.id, '123');
        expect(updated.name, 'Jane Smith');
        expect(updated.avatarUrl, 'https://example.com/avatar.jpg');
        expect(updated.currentMood, Mood.calm);
      });

      test('should create a copy with no changes when no parameters provided', () {
        final user = User(
          id: '123',
          name: 'John Doe',
          avatarUrl: 'https://example.com/avatar.jpg',
          currentMood: Mood.happy,
        );

        final updated = user.copyWith();

        expect(updated.id, '123');
        expect(updated.name, 'John Doe');
        expect(updated.avatarUrl, 'https://example.com/avatar.jpg');
        expect(updated.currentMood, Mood.happy);
      });
    });

    group('toJson', () {
      test('should serialize to JSON correctly', () {
        final user = User(
          id: '123',
          name: 'John Doe',
          avatarUrl: 'https://example.com/avatar.jpg',
          currentMood: Mood.happy,
        );

        final json = user.toJson();

        expect(json, {
          'id': '123',
          'name': 'John Doe',
          'avatarUrl': 'https://example.com/avatar.jpg',
          'currentMood': 'happy',
        });
      });

      test('should serialize all mood types correctly', () {
        final moods = [Mood.happy, Mood.calm, Mood.anxious, Mood.sad, Mood.neutral];
        final expectedMoodNames = ['happy', 'calm', 'anxious', 'sad', 'neutral'];

        for (var i = 0; i < moods.length; i++) {
          final user = User(
            id: '123',
            name: 'Test User',
            avatarUrl: 'https://example.com/avatar.jpg',
            currentMood: moods[i],
          );

          final json = user.toJson();
          expect(json['currentMood'], expectedMoodNames[i]);
        }
      });
    });

    group('fromJson', () {
      test('should deserialize from JSON correctly', () {
        final json = {
          'id': '123',
          'name': 'John Doe',
          'avatarUrl': 'https://example.com/avatar.jpg',
          'currentMood': 'happy',
        };

        final user = User.fromJson(json);

        expect(user.id, '123');
        expect(user.name, 'John Doe');
        expect(user.avatarUrl, 'https://example.com/avatar.jpg');
        expect(user.currentMood, Mood.happy);
      });

      test('should deserialize all mood types correctly', () {
        final moodNames = ['happy', 'calm', 'anxious', 'sad', 'neutral'];
        final expectedMoods = [Mood.happy, Mood.calm, Mood.anxious, Mood.sad, Mood.neutral];

        for (var i = 0; i < moodNames.length; i++) {
          final json = {
            'id': '123',
            'name': 'Test User',
            'avatarUrl': 'https://example.com/avatar.jpg',
            'currentMood': moodNames[i],
          };

          final user = User.fromJson(json);
          expect(user.currentMood, expectedMoods[i]);
        }
      });

      test('should default to neutral mood for invalid mood string', () {
        final json = {
          'id': '123',
          'name': 'John Doe',
          'avatarUrl': 'https://example.com/avatar.jpg',
          'currentMood': 'invalid_mood',
        };

        final user = User.fromJson(json);

        expect(user.currentMood, Mood.neutral);
      });

      test('should round-trip serialize and deserialize correctly', () {
        final original = User(
          id: '123',
          name: 'John Doe',
          avatarUrl: 'https://example.com/avatar.jpg',
          currentMood: Mood.anxious,
        );

        final json = original.toJson();
        final deserialized = User.fromJson(json);

        expect(deserialized.id, original.id);
        expect(deserialized.name, original.name);
        expect(deserialized.avatarUrl, original.avatarUrl);
        expect(deserialized.currentMood, original.currentMood);
      });
    });

    group('equality', () {
      test('should be equal when all properties match', () {
        final user1 = User(
          id: '123',
          name: 'John Doe',
          avatarUrl: 'https://example.com/avatar.jpg',
          currentMood: Mood.happy,
        );

        final user2 = User(
          id: '123',
          name: 'John Doe',
          avatarUrl: 'https://example.com/avatar.jpg',
          currentMood: Mood.happy,
        );

        expect(user1, equals(user2));
        expect(user1.hashCode, equals(user2.hashCode));
      });

      test('should not be equal when id differs', () {
        final user1 = User(
          id: '123',
          name: 'John Doe',
          avatarUrl: 'https://example.com/avatar.jpg',
          currentMood: Mood.happy,
        );

        final user2 = User(
          id: '456',
          name: 'John Doe',
          avatarUrl: 'https://example.com/avatar.jpg',
          currentMood: Mood.happy,
        );

        expect(user1, isNot(equals(user2)));
      });

      test('should not be equal when name differs', () {
        final user1 = User(
          id: '123',
          name: 'John Doe',
          avatarUrl: 'https://example.com/avatar.jpg',
          currentMood: Mood.happy,
        );

        final user2 = User(
          id: '123',
          name: 'Jane Smith',
          avatarUrl: 'https://example.com/avatar.jpg',
          currentMood: Mood.happy,
        );

        expect(user1, isNot(equals(user2)));
      });

      test('should not be equal when avatarUrl differs', () {
        final user1 = User(
          id: '123',
          name: 'John Doe',
          avatarUrl: 'https://example.com/avatar.jpg',
          currentMood: Mood.happy,
        );

        final user2 = User(
          id: '123',
          name: 'John Doe',
          avatarUrl: 'https://example.com/different.jpg',
          currentMood: Mood.happy,
        );

        expect(user1, isNot(equals(user2)));
      });

      test('should not be equal when currentMood differs', () {
        final user1 = User(
          id: '123',
          name: 'John Doe',
          avatarUrl: 'https://example.com/avatar.jpg',
          currentMood: Mood.happy,
        );

        final user2 = User(
          id: '123',
          name: 'John Doe',
          avatarUrl: 'https://example.com/avatar.jpg',
          currentMood: Mood.sad,
        );

        expect(user1, isNot(equals(user2)));
      });

      test('should be equal to itself (identical)', () {
        final user = User(
          id: '123',
          name: 'John Doe',
          avatarUrl: 'https://example.com/avatar.jpg',
          currentMood: Mood.happy,
        );

        expect(user, equals(user));
      });
    });

    group('toString', () {
      test('should return string representation with all properties', () {
        final user = User(
          id: '123',
          name: 'John Doe',
          avatarUrl: 'https://example.com/avatar.jpg',
          currentMood: Mood.happy,
        );

        final string = user.toString();

        expect(string, contains('123'));
        expect(string, contains('John Doe'));
        expect(string, contains('https://example.com/avatar.jpg'));
        expect(string, contains('Mood.happy'));
      });
    });
  });
}
