import 'package:flutter/material.dart';

enum Mood {
  happy,
  calm,
  anxious,
  sad,
  neutral,
}

extension MoodExtension on Mood {
  String get label {
    switch (this) {
      case Mood.happy:
        return 'Happy';
      case Mood.calm:
        return 'Calm';
      case Mood.anxious:
        return 'Anxious';
      case Mood.sad:
        return 'Sad';
      case Mood.neutral:
        return 'Neutral';
    }
  }

  Color get color {
    switch (this) {
      case Mood.happy:
        return Colors.green;
      case Mood.calm:
        return Colors.blue;
      case Mood.anxious:
        return Colors.orange;
      case Mood.sad:
        return Colors.purple;
      case Mood.neutral:
        return Colors.grey;
    }
  }

  IconData get icon {
    switch (this) {
      case Mood.happy:
        return Icons.sentiment_very_satisfied;
      case Mood.calm:
        return Icons.self_improvement;
      case Mood.anxious:
        return Icons.sentiment_dissatisfied;
      case Mood.sad:
        return Icons.sentiment_very_dissatisfied;
      case Mood.neutral:
        return Icons.sentiment_neutral;
    }
  }
}
