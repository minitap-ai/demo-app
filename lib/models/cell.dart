class Cell {
  final int row;
  final int col;
  bool isMine;
  bool isRevealed;
  bool isFlagged;
  int adjacentMines;

  Cell({
    required this.row,
    required this.col,
    this.isMine = false,
    this.isRevealed = false,
    this.isFlagged = false,
    this.adjacentMines = 0,
  });

  void reset() {
    isMine = false;
    isRevealed = false;
    isFlagged = false;
    adjacentMines = 0;
  }
}
