import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/game_controller.dart';
import '../models/game_state.dart';
import '../widgets/board_widget.dart';
import 'difficulty_screen.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  IconData _getResetIcon(GameState state) {
    switch (state) {
      case GameState.won:
        return Icons.sentiment_very_satisfied;
      case GameState.lost:
        return Icons.sentiment_very_dissatisfied;
      default:
        return Icons.sentiment_satisfied;
    }
  }

  Color _getResetIconColor(GameState state) {
    switch (state) {
      case GameState.won:
        return Colors.green;
      case GameState.lost:
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text('Minesweeper'),
        centerTitle: true,
        backgroundColor: Colors.grey[800],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            key: const Key('settings_button'),
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DifficultyScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Consumer<GameController>(
              builder: (context, controller, child) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        key: const Key('mine_counter'),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.flag,
                              color: Colors.red,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${controller.remainingMines}',
                              key: const Key('mine_counter_text'),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        key: const Key('hint_button_container'),
                        decoration: BoxDecoration(
                          color: controller.canUseHint 
                              ? Colors.amber[700] 
                              : Colors.grey[600],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: controller.canUseHint 
                                ? controller.useHint 
                                : null,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.lightbulb,
                                    color: controller.canUseHint 
                                        ? Colors.white 
                                        : Colors.grey[400],
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${controller.hintsRemaining}',
                                    key: const Key('hint_counter_text'),
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: controller.canUseHint 
                                          ? Colors.white 
                                          : Colors.grey[400],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        key: const Key('reset_button'),
                        icon: Icon(
                          _getResetIcon(controller.gameState),
                          size: 40,
                        ),
                        color: _getResetIconColor(controller.gameState),
                        onPressed: controller.resetGame,
                      ),
                      Container(
                        key: const Key('timer'),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.timer,
                              color: Colors.blue,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${controller.elapsedSeconds}',
                              key: const Key('timer_text'),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(8),
                child: const BoardWidget(),
              ),
            ),
            Consumer<GameController>(
              builder: (context, controller, child) {
                if (controller.gameState == GameState.won) {
                  return Container(
                    key: const Key('win_message'),
                    padding: const EdgeInsets.all(16),
                    child: const Text(
                      '🎉 You Won! 🎉',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  );
                } else if (controller.gameState == GameState.lost) {
                  return Container(
                    key: const Key('game_over_message'),
                    padding: const EdgeInsets.all(16),
                    child: const Text(
                      '💥 Game Over 💥',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  );
                }
                return const SizedBox(height: 56);
              },
            ),
          ],
        ),
      ),
    );
  }
}
