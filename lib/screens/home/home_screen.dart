import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/device_id_service.dart';
import '../../core/services/firestore_service.dart';
import '../../models/article.dart';
import '../../core/services/article_cache_service.dart';
import '../../widgets/hero_quote_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _service = FirestoreService();
  String _userId = '';
  List<Article> _articles = [];
  Set<String> _readIds = {};
  Map<String, Map<String, bool>> _questProgressMap = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final id = await DeviceIdService.getUserId();

    List<Article>? cachedArticles = await ArticleCacheService.loadArticles();
    List<Article> articles;

    if (cachedArticles != null) {
      articles = cachedArticles;
    } else {
      articles = await _service.getArticles().first;
      await ArticleCacheService.saveArticles(articles);
    }

    final readIds = await _service.getReadArticleIds(id);
    final questProgressMap = await _service.getAllQuestProgress(id);

    print('総記事数: ${articles.length}');
    print('Chapter一覧: ${articles.map((a) => a.chapterName).toSet().toList()}');

    if (mounted) {
      setState(() {
        _userId = id;
        _articles = articles;
        _readIds = readIds;
        _questProgressMap = questProgressMap;
        _loading = false;
      });
    }
  }

  bool _isArticleComplete(Article article) {
    if (!_readIds.contains(article.id)) return false;
    final progress = _questProgressMap[article.id] ?? {};
    final questDone = article.todaysQuest.isEmpty ||
        article.todaysQuest.every((q) => progress['quest_$q'] == true);
    final reviewDone = article.reviewChecks.isEmpty ||
        article.reviewChecks.every((r) => progress['review_$r'] == true);
    return questDone && reviewDone;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final total = _articles.length;
    final completed = _articles.where(_isArticleComplete).length;
    final progress = total > 0 ? completed / total : 0.0;

    // chapterMapの生成（_articlesから動的に作成）
    final chapterMap = <String, Map<String, dynamic>>{};
    for (final article in _articles) {
      final ch = article.chapterName;
      if (!chapterMap.containsKey(ch)) {
        chapterMap[ch] = {
          'total': 0,
          'completed': 0,
        };
      }
      chapterMap[ch]!['total'] = (chapterMap[ch]!['total'] as int) + 1;
      if (_isArticleComplete(article)) {
        chapterMap[ch]!['completed'] = (chapterMap[ch]!['completed'] as int) + 1;
      }
    }

    // Chapter表示順を固定
    const chapterOrder = [
      'はじめに', '心構え', '私の体験談', '上達論',
      '耳抜き・潜降', '呼吸', '中性浮力', 'エア消費',
      '姿勢・フィンキック', '優雅に泳ぐ', '器材',
      'メンタル', 'エントリー・浮上',
      'ボートダイビング', 'ドライスーツ', '写真', '生物',
      '安全', 'マナー',
    ];

    final sortedChapters = chapterOrder
        .where((ch) => chapterMap.containsKey(ch))
        .map((ch) => MapEntry(ch, chapterMap[ch]!))
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('脱初心者ダイバー'),
        backgroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const HeroQuoteCard(),
              const SizedBox(height: 20),

              // 全体進捗メーター
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    vertical: 24, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border, width: 1.5),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      '全体の進捗',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: 200,
                      height: 200,
                      child: CustomPaint(
                        painter: _GaugePainter(progress: progress),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 24),
                              Text(
                                '$completed',
                                style: const TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                              Text(
                                '/ $total 記事完了',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              Text(
                                '${(progress * 100).toInt()}%',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Chapter別進捗
              const Text(
                'Chapterごとの進捗',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),

              ...sortedChapters.map((entry) {
                final ch = entry.value;
                final chTotal = ch['total'] as int;
                final chCompleted = ch['completed'] as int;
                final chProgress = chTotal > 0 ? chCompleted / chTotal : 0.0;

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border, width: 1.5),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            entry.key,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '$chCompleted / $chTotal',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: LinearProgressIndicator(
                          value: chProgress,
                          backgroundColor: AppColors.border,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.sunYellow,
                          ),
                          minHeight: 24,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double progress;

  const _GaugePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2 + 10);
    final radius = size.width / 2 - 16;

    const startAngle = 135.0 * pi / 180;
    const sweepAngle = 270.0 * pi / 180;

    final trackPaint = Paint()
      ..color = AppColors.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = AppColors.sunsetOrange
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromCircle(center: center, radius: radius);

    canvas.drawArc(rect, startAngle, sweepAngle, false, trackPaint);

    if (progress > 0) {
      canvas.drawArc(
          rect, startAngle, sweepAngle * progress, false, progressPaint);
    }
  }

  @override
  bool shouldRepaint(_GaugePainter oldDelegate) =>
      oldDelegate.progress != progress;
}
