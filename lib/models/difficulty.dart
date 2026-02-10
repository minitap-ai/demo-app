class Difficulty {
  final String name;
  final int rows;
  final int cols;
  final int mines;

  const Difficulty({
    required this.name,
    required this.rows,
    required this.cols,
    required this.mines,
  });

  static const beginner = Difficulty(
    name: 'Beginner',
    rows: 9,
    cols: 9,
    mines: 10,
  );

  static const intermediate = Difficulty(
    name: 'Intermediate',
    rows: 16,
    cols: 16,
    mines: 40,
  );

  static const expert = Difficulty(
    name: 'Expert',
    rows: 16,
    cols: 30,
    mines: 99,
  );

  static const List<Difficulty> all = [beginner, intermediate, expert];
}
