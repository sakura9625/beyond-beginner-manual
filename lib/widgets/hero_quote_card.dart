import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_colors.dart';
import '../data/quotes.dart';
import '../models/diving_quote.dart';

class HeroQuoteCard extends StatefulWidget {
  const HeroQuoteCard({super.key});

  @override
  State<HeroQuoteCard> createState() => _HeroQuoteCardState();
}

class _HeroQuoteCardState extends State<HeroQuoteCard> {
  DivingQuote? _quote;

  @override
  void initState() {
    super.initState();
    _loadQuote();
  }

  Future<void> _loadQuote() async {
    final prefs = await SharedPreferences.getInstance();
    final lastIndex = prefs.getInt('last_quote_index') ?? -1;

    final available = List.generate(divingQuotes.length, (i) => i)
      ..removeWhere((i) => i == lastIndex);

    final newIndex = available[Random().nextInt(available.length)];
    await prefs.setInt('last_quote_index', newIndex);

    if (mounted) {
      setState(() => _quote = divingQuotes[newIndex]);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_quote == null) return const SizedBox(height: 140);

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 上部: 空エリア
          Container(
            width: double.infinity,
            color: AppColors.heroSky,
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
            child: Stack(
              children: [
                // 太陽ハロー
                Positioned(
                  top: -18,
                  right: 10,
                  child: Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.2),
                    ),
                  ),
                ),
                // 太陽
                Positioned(
                  top: -12,
                  right: 16,
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.heroSun,
                    ),
                  ),
                ),
                // コンテンツ
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ラベルタグ
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        '🤿 脱初心者への道',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // 名言テキスト
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        _quote!.text,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // 波エリア
          SizedBox(
            height: 38,
            width: double.infinity,
            child: CustomPaint(
              painter: _WavePainter(),
            ),
          ),
          // 下部: 海エリア
          Container(
            width: double.infinity,
            color: AppColors.heroOcean,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          ),
        ],
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 背景（空色）
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()..color = AppColors.heroSky,
    );

    // 波1層目: 白半透明20%
    final path1 = Path()
      ..moveTo(0, h * 0.16)
      ..cubicTo(w * 0.12, 0, w * 0.25, h * 0.34, w * 0.38, h * 0.16)
      ..cubicTo(w * 0.50, 0, w * 0.65, h * 0.34, w * 0.80, h * 0.16)
      ..cubicTo(w * 0.90, h * 0.05, w * 0.96, h * 0.24, w, h * 0.16)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(
      path1,
      Paint()..color = Colors.white.withOpacity(0.20),
    );

    // 波2層目: 白半透明14%
    final path2 = Path()
      ..moveTo(0, h * 0.37)
      ..cubicTo(w * 0.14, h * 0.16, w * 0.30, h * 0.53, w * 0.45, h * 0.34)
      ..cubicTo(w * 0.58, h * 0.18, w * 0.73, h * 0.53, w * 0.88, h * 0.34)
      ..cubicTo(w * 0.95, h * 0.24, w * 0.99, h * 0.40, w, h * 0.34)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(
      path2,
      Paint()..color = Colors.white.withOpacity(0.14),
    );

    // 波3層目: 海色ベタ
    final path3 = Path()
      ..moveTo(0, h * 0.63)
      ..cubicTo(w * 0.10, h * 0.42, w * 0.27, h * 0.79, w * 0.43, h * 0.58)
      ..cubicTo(w * 0.56, h * 0.39, w * 0.74, h * 0.79, w * 0.90, h * 0.58)
      ..cubicTo(w * 0.97, h * 0.45, w * 0.99, h * 0.61, w, h * 0.58)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(
      path3,
      Paint()..color = AppColors.heroOcean,
    );
  }

  @override
  bool shouldRepaint(_WavePainter oldDelegate) => false;
}
