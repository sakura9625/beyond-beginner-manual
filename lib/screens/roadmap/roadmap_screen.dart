import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class RoadmapScreen extends StatelessWidget {
  const RoadmapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ロードマップ'),
        backgroundColor: AppColors.surface,
      ),
      body: const Center(
        child: Text('ロードマップ（実装予定）', style: TextStyle(color: AppColors.textPrimary)),
      ),
    );
  }
}
