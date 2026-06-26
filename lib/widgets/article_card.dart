import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../models/article.dart';

class ArticleCard extends StatelessWidget {
  final Article article;
  final VoidCallback onTap;
  final VoidCallback? onRelearn;
  final bool isRead;
  final bool isQuestDone;
  final bool isReviewDone;

  const ArticleCard({
    super.key,
    required this.article,
    required this.onTap,
    this.onRelearn,
    this.isRead = false,
    this.isQuestDone = false,
    this.isReviewDone = false,
  });

  @override
  Widget build(BuildContext context) {
    final allDone = isRead && isQuestDone && isReviewDone;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: allDone
                ? AppColors.primary.withOpacity(0.5)
                : AppColors.border,
            width: 1.5,
          ),
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
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.4),
                      width: 1,
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
                const Spacer(),
                ...List.generate(
                  5,
                  (i) => Icon(
                    Icons.star,
                    size: 13,
                    color: i < article.difficulty
                        ? AppColors.sunYellow
                        : AppColors.border,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              article.title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: allDone
                    ? AppColors.textSecondary
                    : AppColors.textPrimary,
              ),
            ),
            if (article.recommendedDives.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                '推奨本数：${article.recommendedDives}本',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                // 完了バッジ（左端）
                _badge(
                  icon: Icons.menu_book_outlined,
                  label: '読了',
                  done: isRead,
                  doneColor: AppColors.sunYellow,
                ),
                const SizedBox(width: 8),
                if (article.todaysQuest.isNotEmpty)
                  _badge(
                    icon: Icons.flag_outlined,
                    label: 'クエスト',
                    done: isQuestDone,
                    doneColor: const Color(0xFFFF8FAB),
                  ),
                if (article.todaysQuest.isNotEmpty)
                  const SizedBox(width: 8),
                if (article.reviewChecks.isNotEmpty)
                  _badge(
                    icon: Icons.check_circle_outline,
                    label: '振り返り',
                    done: isReviewDone,
                    doneColor: AppColors.sunsetOrange,
                  ),
                const Spacer(),
                // 学び直すボタン（右端）
                if (isRead)
                  GestureDetector(
                    onTap: onRelearn,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.navUnselected.withOpacity(0.5),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(
                            Icons.replay,
                            size: 13,
                            color: AppColors.textSecondary,
                          ),
                          SizedBox(width: 4),
                          Text(
                            '学び直す',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge({
    required IconData icon,
    required String label,
    required bool done,
    required Color doneColor,
  }) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: done ? doneColor : AppColors.background,
        border: Border.all(
          color: done
              ? doneColor
              : AppColors.navUnselected.withOpacity(0.5),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 17,
            color: done ? Colors.white : AppColors.navUnselected,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              color: done ? Colors.white : AppColors.navUnselected,
            ),
          ),
        ],
      ),
    );
  }
}
