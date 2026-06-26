import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/device_id_service.dart';
import '../../core/services/firestore_service.dart';
import '../../models/article.dart';
import '../../widgets/article_card.dart';
import 'article_detail_screen.dart';

class ArticleListScreen extends StatefulWidget {
  const ArticleListScreen({super.key});

  @override
  State<ArticleListScreen> createState() => _ArticleListScreenState();
}

class _ArticleListScreenState extends State<ArticleListScreen> {
  final _service = FirestoreService();
  String? _selectedChapter;
  String _userId = '';
  Set<String> _readIds = {};
  Map<String, Map<String, bool>> _questProgressMap = {};
  List<Article> _articles = [];
  bool _loading = true;

  final _chapters = [
    {'key': null, 'label': 'すべて'},
    {'key': '0', 'label': 'はじめに'},
    {'key': '1', 'label': '心構え'},
    {'key': '2', 'label': '耳抜き・潜行'},
    {'key': '3', 'label': 'エア消費'},
    {'key': '4', 'label': '中性浮力'},
    {'key': '5', 'label': '器材'},
    {'key': '6', 'label': '海での実践'},
    {'key': '7', 'label': '写真'},
    {'key': '8', 'label': '優雅に泳ぐ'},
    {'key': '9', 'label': '安全'},
  ];

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() => _loading = true);

    final id = await DeviceIdService.getUserId();
    final articles = await _service.getArticles().first;
    final readIds = await _service.getReadArticleIds(id);

    final map = <String, Map<String, bool>>{};
    for (final article in articles) {
      final progress = await _service.getQuestProgress(id, article.id);
      map[article.id] = progress;
    }

    if (mounted) {
      setState(() {
        _userId = id;
        _articles = articles;
        _readIds = readIds;
        _questProgressMap = map;
        _loading = false;
      });
    }
  }

  List<Article> get _filteredArticles {
    if (_selectedChapter == null) return _articles;
    return _articles.where((a) => a.chapter == _selectedChapter).toList();
  }

  bool _isQuestDone(Article article) {
    if (article.todaysQuest.isEmpty) return true;
    final progress = _questProgressMap[article.id] ?? {};
    return article.todaysQuest.every((q) => progress['quest_$q'] == true);
  }

  bool _isReviewDone(Article article) {
    if (article.reviewChecks.isEmpty) return true;
    final progress = _questProgressMap[article.id] ?? {};
    return article.reviewChecks.every((r) => progress['review_$r'] == true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('記事'),
        backgroundColor: AppColors.surface,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Chapterフィルター
                SizedBox(
                  height: 48,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    itemCount: _chapters.length,
                    itemBuilder: (context, i) {
                      final chapter = _chapters[i];
                      final selected = chapter['key'] == _selectedChapter;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(chapter['label']!),
                          selected: selected,
                          onSelected: (_) => setState(() {
                            _selectedChapter = chapter['key'] as String?;
                          }),
                          selectedColor: AppColors.primary,
                          backgroundColor: Colors.white,
                          side: BorderSide(
                            color: selected
                                ? AppColors.primary
                                : AppColors.border,
                            width: 1.2,
                          ),
                          labelStyle: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: selected ? Colors.white : AppColors.textSecondary,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                        ),
                      );
                    },
                  ),
                ),
                // 記事一覧
                Expanded(
                  child: _filteredArticles.isEmpty
                      ? const Center(
                          child: Text('記事がありません',
                              style:
                                  TextStyle(color: AppColors.textSecondary)),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredArticles.length,
                          itemBuilder: (context, i) {
                            final article = _filteredArticles[i];
                            return ArticleCard(
                              article: article,
                              isRead: _readIds.contains(article.id),
                              isQuestDone: _isQuestDone(article),
                              isReviewDone: _isReviewDone(article),
                              onRelearn: () async {
                                await _service.resetArticleProgress(_userId, article.id);
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ArticleDetailScreen(
                                      article: article,
                                      userId: _userId,
                                    ),
                                  ),
                                );
                                await _loadAll();
                              },
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ArticleDetailScreen(
                                      article: article,
                                      userId: _userId,
                                    ),
                                  ),
                                );
                                await _loadAll();
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
