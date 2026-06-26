import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/article_cache_service.dart';
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
  final _scrollController = ScrollController();
  static const _pageSize = 20;

  String? _selectedChapter;
  String _userId = '';
  Set<String> _readIds = {};
  Map<String, Map<String, bool>> _questProgressMap = {};
  List<Article> _allArticles = [];
  List<Article> _displayedArticles = [];
  bool _loading = true;
  bool _loadingMore = false;

  final _chapters = [
    {'key': null, 'label': 'すべて'},
    {'key': 'はじめに', 'label': 'はじめに'},
    {'key': '心構え', 'label': '心構え'},
    {'key': '私の体験談', 'label': '私の体験談'},
    {'key': '上達論', 'label': '上達論'},
    {'key': '耳抜き・潜降', 'label': '耳抜き・潜降'},
    {'key': '呼吸', 'label': '呼吸'},
    {'key': '中性浮力', 'label': '中性浮力'},
    {'key': 'エア消費', 'label': 'エア消費'},
    {'key': '姿勢・フィンキック', 'label': '姿勢・フィンキック'},
    {'key': '優雅に泳ぐ', 'label': '優雅に泳ぐ'},
    {'key': '器材', 'label': '器材'},
    {'key': '中性浮力 Vol.2', 'label': '中性浮力 Vol.2'},
    {'key': 'メンタル', 'label': 'メンタル'},
    {'key': 'エントリー・浮上', 'label': 'エントリー・浮上'},
    {'key': 'ボートダイビング', 'label': 'ボートダイビング'},
    {'key': 'ドライスーツ', 'label': 'ドライスーツ'},
    {'key': '写真', 'label': '写真'},
    {'key': '生物', 'label': '生物'},
    {'key': '安全', 'label': '安全'},
    {'key': 'マナー', 'label': 'マナー'},
  ];

  @override
  void initState() {
    super.initState();
    _loadAll();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _loadAll() async {
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

    if (mounted) {
      setState(() {
        _userId = id;
        _allArticles = articles;
        _readIds = readIds;
        _questProgressMap = questProgressMap;
        _loading = false;
      });
      _resetDisplayed();
    }
  }

  List<Article> get _filteredArticles {
    if (_selectedChapter == null) return _allArticles;
    return _allArticles
        .where((a) => a.chapterName == _selectedChapter)
        .toList();
  }

  void _resetDisplayed() {
    final filtered = _filteredArticles;
    setState(() {
      _displayedArticles = filtered.take(_pageSize).toList();
    });
  }

  void _loadMore() {
    if (_loadingMore) return;
    final filtered = _filteredArticles;
    if (_displayedArticles.length >= filtered.length) return;

    setState(() => _loadingMore = true);
    final next = filtered
        .skip(_displayedArticles.length)
        .take(_pageSize)
        .toList();
    setState(() {
      _displayedArticles.addAll(next);
      _loadingMore = false;
    });
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('記事'),
        backgroundColor: Colors.white,
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
                          onSelected: (_) {
                            setState(() {
                              _selectedChapter =
                                  chapter['key'] as String?;
                            });
                            _resetDisplayed();
                          },
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
                            color: selected
                                ? Colors.white
                                : AppColors.textSecondary,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                        ),
                      );
                    },
                  ),
                ),
                // 件数表示
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 4),
                  child: Row(
                    children: [
                      Text(
                        '${_displayedArticles.length} / ${_filteredArticles.length}件',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                // 記事一覧
                Expanded(
                  child: _filteredArticles.isEmpty
                      ? const Center(
                          child: Text('記事がありません',
                              style: TextStyle(
                                  color: AppColors.textSecondary)),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: _displayedArticles.length +
                              (_loadingMore ? 1 : 0),
                          itemBuilder: (context, i) {
                            if (i == _displayedArticles.length) {
                              return const Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(
                                    child: CircularProgressIndicator()),
                              );
                            }
                            final article = _displayedArticles[i];
                            return ArticleCard(
                              article: article,
                              isRead: _readIds.contains(article.id),
                              isQuestDone: _isQuestDone(article),
                              isReviewDone: _isReviewDone(article),
                              onRelearn: () async {
                                await _service.resetArticleProgress(
                                    _userId, article.id);
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
