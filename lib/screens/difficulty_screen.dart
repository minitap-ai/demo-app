import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/game_controller.dart';
import '../models/difficulty.dart';

class DifficultyScreen extends StatelessWidget {
  const DifficultyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text('Select Difficulty'),
        centerTitle: true,
        backgroundColor: Colors.grey[800],
        foregroundColor: Colors.white,
      ),
      body: Consumer<GameController>(
        builder: (context, controller, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: Difficulty.all.map((difficulty) {
              final isSelected = controller.difficulty == difficulty;
              return Card(
                key: Key('difficulty_${difficulty.name.toLowerCase()}'),
                margin: const EdgeInsets.only(bottom: 16),
                elevation: isSelected ? 8 : 2,
                color: isSelected ? Colors.blue[100] : Colors.white,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(
                    difficulty.name,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.blue[900] : Colors.black,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      '${difficulty.rows} × ${difficulty.cols} grid\n${difficulty.mines} mines',
                      style: TextStyle(
                        fontSize: 14,
                        color: isSelected ? Colors.blue[700] : Colors.grey[700],
                      ),
                    ),
                  ),
                  trailing: isSelected
                      ? Icon(Icons.check_circle, color: Colors.blue[900], size: 32)
                      : Icon(Icons.circle_outlined, color: Colors.grey[400], size: 32),
                  onTap: () {
                    controller.setDifficulty(difficulty);
                    Navigator.pop(context);
                  },
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
