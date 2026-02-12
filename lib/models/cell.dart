class Cell {
  final int row;
  final int col;
  bool isMine;
  bool isRevealed;
  bool isFlagged;
  bool isHintRevealed;
  int adjacentMines;

  Cell({
    required this.row,
    required this.col,
    this.isMine = false,
    this.isRevealed = false,
    this.isFlagged = false,
    this.isHintRevealed = false,
    this.adjacentMines = 0,
  });

  void reset() {
    isMine = false;
    isRevealed = false;
    isFlagged = false;
    isHintRevealed = false;
    adjacentMines = 0;
  }
}
