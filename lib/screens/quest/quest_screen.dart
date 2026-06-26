import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class QuestScreen extends StatelessWidget {
  const QuestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('クエスト'),
        backgroundColor: AppColors.surface,
      ),
      body: const Center(
        child: Text('クエスト（実装予定）', style: TextStyle(color: AppColors.textPrimary)),
      ),
    );
  }
}
