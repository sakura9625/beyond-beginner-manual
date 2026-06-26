import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ゲーム'),
        backgroundColor: AppColors.surface,
      ),
      body: const Center(
        child: Text('ゲーム（実装予定）', style: TextStyle(color: AppColors.textPrimary)),
      ),
    );
  }
}
