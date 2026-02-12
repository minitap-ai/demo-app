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
    Color cellColor;
    if (cell.isHintRevealed) {
      cellColor = Colors.amber[200]!;
    } else if (cell.isRevealed) {
      cellColor = cell.isMine ? Colors.red[300]! : Colors.grey[300]!;
    } else {
      cellColor = Colors.grey[400]!;
    }

    return GestureDetector(
      key: key,
      onTap: onTap,
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: size,
        height: size,
        margin: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: cellColor,
          border: Border.all(
            color: cell.isHintRevealed 
                ? Colors.amber[700]! 
                : (cell.isRevealed ? Colors.grey[400]! : Colors.grey[600]!),
            width: cell.isHintRevealed ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(2),
          boxShadow: cell.isHintRevealed
              ? [
                  BoxShadow(
                    color: Colors.amber.withOpacity(0.5),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Center(child: _buildCellContent()),
      ),
    );
  }
}
