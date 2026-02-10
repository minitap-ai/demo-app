import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/game_controller.dart';
import 'cell_widget.dart';

class BoardWidget extends StatelessWidget {
  const BoardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameController>(
      builder: (context, controller, child) {
        final board = controller.board;
        final difficulty = controller.difficulty;
        
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;
        
        final maxWidth = screenWidth - 32;
        final maxHeight = screenHeight - 300;
        
        final cellWidth = maxWidth / difficulty.cols;
        final cellHeight = maxHeight / difficulty.rows;
        final cellSize = (cellWidth < cellHeight ? cellWidth : cellHeight).clamp(20.0, 40.0);

        return Center(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                key: const Key('game_board'),
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  difficulty.rows,
                  (row) => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      difficulty.cols,
                      (col) => CellWidget(
                        key: Key('cell_${row}_$col'),
                        cell: board[row][col],
                        size: cellSize,
                        onTap: () => controller.revealCell(row, col),
                        onLongPress: () => controller.toggleFlag(row, col),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
