import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/article.dart';

class FirestoreService {
  static void enableOfflineCache() {
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  }

  final _db = FirebaseFirestore.instance;

  Stream<List<Article>> getArticles({String? chapter}) {
    Query query = _db.collection('articles');
    if (chapter != null) {
      query = query.where('chapter', isEqualTo: chapter);
    }
    return query.snapshots().map((snap) {
      final articles = snap.docs.map((doc) => Article.fromFirestore(doc)).toList();
      articles.sort((a, b) => a.no.compareTo(b.no));
      return articles;
    });
  }

  Future<Article?> getArticle(String id) async {
    final doc = await _db.collection('articles').doc(id).get();
    if (!doc.exists) return null;
    return Article.fromFirestore(doc);
  }

  Future<void> markAsRead(String userId, String articleId) async {
    await _db
        .collection('user_progress')
        .doc(userId)
        .collection('read_articles')
        .doc(articleId)
        .set({'readAt': FieldValue.serverTimestamp()});
  }

  Future<Set<String>> getReadArticleIds(String userId) async {
    final snap = await _db
        .collection('user_progress')
        .doc(userId)
        .collection('read_articles')
        .get();
    return snap.docs.map((d) => d.id).toSet();
  }

  Future<void> updateQuestItem(String userId, String questId, String itemId, bool checked) async {
    await _db
        .collection('user_progress')
        .doc(userId)
        .collection('quests')
        .doc(questId)
        .set({itemId: checked}, SetOptions(merge: true));
  }

  Future<Map<String, bool>> getQuestProgress(String userId, String questId) async {
    final doc = await _db
        .collection('user_progress')
        .doc(userId)
        .collection('quests')
        .doc(questId)
        .get();
    if (!doc.exists) return {};
    return Map<String, bool>.from(doc.data() ?? {});
  }

  // 全記事のクエスト進捗を一括取得
  Future<Map<String, Map<String, bool>>> getAllQuestProgress(String userId) async {
    final snap = await _db
        .collection('user_progress')
        .doc(userId)
        .collection('quests')
        .get();

    final result = <String, Map<String, bool>>{};
    for (final doc in snap.docs) {
      result[doc.id] = Map<String, bool>.from(doc.data());
    }
    return result;
  }

  Future<void> resetArticleProgress(String userId, String articleId) async {
    final batch = _db.batch();

    final readRef = _db
        .collection('user_progress')
        .doc(userId)
        .collection('read_articles')
        .doc(articleId);
    batch.delete(readRef);

    final questRef = _db
        .collection('user_progress')
        .doc(userId)
        .collection('quests')
        .doc(articleId);
    batch.delete(questRef);

    await batch.commit();
  }
}
