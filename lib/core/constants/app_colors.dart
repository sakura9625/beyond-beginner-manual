import 'package:flutter/material.dart';

class AppColors {
  // ベースカラー
  static const primary = Color(0xFF4EC8E8);
  static const background = Color(0xFFF9FEFF);
  static const surface = Colors.white;
  static const textPrimary = Color(0xFF1A3A4A);
  static const textSecondary = Color(0xFF6B8FA0);
  static const border = Color(0xFFE8F8FC);

  // アクセント
  static const sunYellow = Color(0xFFFFD233);
  static const sunsetOrange = Color(0xFFFF9340);

  // ステータス
  static const alertOrange = Color(0xFFFF9340);
  static const alertRed = Color(0xFFFF5B5B);

  // ナビ非選択
  static const navUnselected = Color(0xFFB0CDD5);

  // ヒーローカード
  static const heroSky   = Color(0xFF4EC8E8);
  static const heroOcean = Color(0xFF20B8C8);
  static const heroSun   = Color(0xFFFFD233);

  // 後方互換（既存コードが参照している箇所用）
  static const secondary = Color(0xFF4EC8E8);
  static const star = Color(0xFFFFD233);
  static const textPrimaryDark = Color(0xFF1A3A4A);
}
