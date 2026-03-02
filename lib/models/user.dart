import 'mood.dart';

class User {
  final String id;
  final String name;
  final String avatarUrl;
  final Mood currentMood;

  const User({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.currentMood,
  });

  User copyWith({
    String? id,
    String? name,
    String? avatarUrl,
    Mood? currentMood,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      currentMood: currentMood ?? this.currentMood,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatarUrl': avatarUrl,
      'currentMood': currentMood.name,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      avatarUrl: json['avatarUrl'] as String,
      currentMood: Mood.values.firstWhere(
        (mood) => mood.name == json['currentMood'],
        orElse: () => Mood.neutral,
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User &&
        other.id == id &&
        other.name == name &&
        other.avatarUrl == avatarUrl &&
        other.currentMood == currentMood;
  }

  @override
  int get hashCode {
    return Object.hash(id, name, avatarUrl, currentMood);
  }

  @override
  String toString() {
    return 'User(id: $id, name: $name, avatarUrl: $avatarUrl, currentMood: $currentMood)';
  }
}
