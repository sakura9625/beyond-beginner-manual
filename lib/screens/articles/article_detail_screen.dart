import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/firestore_service.dart';
import '../../models/article.dart';

class ArticleDetailScreen extends StatefulWidget {
  final Article article;
  final String userId;

  const ArticleDetailScreen({
    super.key,
    required this.article,
    required this.userId,
  });

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  final _service = FirestoreService();
  Map<String, bool> _questProgress = {};
  bool _isRead = false;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final progress = await _service.getQuestProgress(
      widget.userId,
      widget.article.id,
    );
    final readIds = await _service.getReadArticleIds(widget.userId);
    setState(() {
      _questProgress = progress;
      _isRead = readIds.contains(widget.article.id);
    });
  }

  Future<void> _markAsRead() async {
    await _service.markAsRead(widget.userId, widget.article.id);
    setState(() => _isRead = true);
  }

  Future<void> _toggleQuest(String itemId, bool value) async {
    await _service.updateQuestItem(
      widget.userId,
      widget.article.id,
      itemId,
      value,
    );
    setState(() => _questProgress[itemId] = value);
  }

  @override
  Widget build(BuildContext context) {
    final article = widget.article;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(article.chapterName),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // タイトルエリア（左グリーンアクセントバー）
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
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
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 左グリーンアクセントバー
                    Container(
                      width: 4,
                      decoration: const BoxDecoration(
                        color: Color(0xFF7BBF00),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12),
                          bottomLeft: Radius.circular(12),
                        ),
                      ),
                    ),
                    // コンテンツ
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: AppColors.primary.withOpacity(0.4),
                                    ),
                                  ),
                                  child: Text(
                                    article.chapterName,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  article.no,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const Spacer(),
                                ...List.generate(
                                  5,
                                  (i) => Icon(
                                    Icons.star,
                                    size: 14,
                                    color: i < article.difficulty
                                        ? AppColors.sunYellow
                                        : AppColors.border,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              article.title,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            if (article.recommendedDives.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text(
                                '推奨本数：${article.recommendedDives}本',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // あの日の私
            if (article.myStory.isNotEmpty)
              _contentCard(
                label: '📖 あの日の私',
                content: article.myStory,
              ),

            // なぜそうなった？
            if (article.whyItHappened.isNotEmpty)
              _contentCard(
                label: '🤔 なぜそうなった？',
                content: article.whyItHappened,
              ),

            // 改善方法
            if (article.improvement.isNotEmpty)
              _contentCard(
                label: '💡 改善方法',
                content: article.improvement,
              ),

            const SizedBox(height: 4),

            // 読了ボタン（カードなし）
            _isRead
                ? Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.check_circle,
                            color: AppColors.primary, size: 20),
                        SizedBox(width: 8),
                        Text(
                          '読了済み',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: FilledButton(
                      onPressed: _markAsRead,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.sunYellow,
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        '読了',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),

            const SizedBox(height: 12),

            // 今日のクエスト
            if (article.todaysQuest.isNotEmpty)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0F4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFFF8FAB).withOpacity(0.4),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '🎯 今日のクエスト',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFC42B5A),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '次のダイブで試してみよう',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFFC42B5A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...article.todaysQuest.map((quest) {
                      final key = 'quest_$quest';
                      final checked = _questProgress[key] ?? false;
                      return GestureDetector(
                        onTap: () => _toggleQuest(key, !checked),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: checked
                                  ? const Color(0xFFFF8FAB).withOpacity(0.6)
                                  : const Color(0xFFFF8FAB).withOpacity(0.2),
                              width: 1.2,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: checked
                                      ? const Color(0xFFFF8FAB)
                                      : Colors.white,
                                  border: Border.all(
                                    color: checked
                                        ? const Color(0xFFFF8FAB)
                                        : const Color(0xFFB0CDD5),
                                    width: 2,
                                  ),
                                ),
                                child: checked
                                    ? const Icon(Icons.check,
                                        size: 13, color: Colors.white)
                                    : null,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  quest,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: checked
                                        ? AppColors.textSecondary
                                        : AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),

            // 振り返りチェック
            if (article.reviewChecks.isNotEmpty)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0E0),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.sunsetOrange.withOpacity(0.4),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '✅ 振り返りチェック',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFC45A00),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'ダイブ後に確認しよう',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFFC45A00),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...article.reviewChecks.map((check) {
                      final key = 'review_$check';
                      final checked = _questProgress[key] ?? false;
                      return GestureDetector(
                        onTap: () => _toggleQuest(key, !checked),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: checked
                                  ? AppColors.sunsetOrange.withOpacity(0.6)
                                  : AppColors.sunsetOrange.withOpacity(0.2),
                              width: 1.2,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: checked
                                      ? AppColors.sunsetOrange
                                      : Colors.white,
                                  border: Border.all(
                                    color: checked
                                        ? AppColors.sunsetOrange
                                        : const Color(0xFFB0CDD5),
                                    width: 2,
                                  ),
                                ),
                                child: checked
                                    ? const Icon(Icons.check,
                                        size: 13, color: Colors.white)
                                    : null,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  check,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: checked
                                        ? AppColors.textSecondary
                                        : AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
      child: child,
    );
  }

  Widget _contentCard({
    required String label,
    required String content,
  }) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.textPrimary,
              height: 1.8,
            ),
          ),
        ],
      ),
    );
  }
}
