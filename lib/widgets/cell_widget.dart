import 'package:flutter/material.dart';
import '../models/cell.dart';

class CellWidget extends StatelessWidget {
  final Cell cell;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final double size;

  const CellWidget({
    super.key,
    required this.cell,
    required this.onTap,
    required this.onLongPress,
    this.size = 40.0,
  });

  Color _getNumberColor(int number) {
    switch (number) {
      case 1:
        return Colors.blue;
      case 2:
        return Colors.green;
      case 3:
        return Colors.red;
      case 4:
        return Colors.purple;
      case 5:
        return Colors.orange;
      case 6:
        return Colors.cyan;
      case 7:
        return Colors.black;
      case 8:
        return Colors.grey;
      default:
        return Colors.black;
    }
  }

  Widget _buildCellContent() {
    if (cell.isFlagged) {
      return const Icon(Icons.flag, color: Colors.red, size: 20);
    }

    if (!cell.isRevealed) {
      return Container();
    }

    if (cell.isMine) {
      return const Icon(Icons.circle, color: Colors.black, size: 20);
    }

    if (cell.adjacentMines > 0) {
      return Text(
        '${cell.adjacentMines}',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: _getNumberColor(cell.adjacentMines),
        ),
      );
    }

    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        width: size,
        height: size,
        margin: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: cell.isRevealed
              ? (cell.isMine ? Colors.red[300] : Colors.grey[300])
              : Colors.grey[400],
          border: Border.all(
            color: cell.isRevealed ? Colors.grey[400]! : Colors.grey[600]!,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(2),
        ),
        child: Center(child: _buildCellContent()),
      ),
    );
  }
}
