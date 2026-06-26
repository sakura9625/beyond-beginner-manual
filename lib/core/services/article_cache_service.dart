import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/article.dart';

class ArticleCacheService {
  static const _articlesKey = 'cached_articles';
  static const _cacheTimeKey = 'articles_cache_time';
  static const _cacheDuration = Duration(hours: 24);

  // キャッシュに保存
  static Future<void> saveArticles(List<Article> articles) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = articles.map((a) => a.toJson()).toList();
    await prefs.setString(_articlesKey, jsonEncode(jsonList));
    await prefs.setInt(_cacheTimeKey, DateTime.now().millisecondsSinceEpoch);
  }

  // キャッシュから取得
  static Future<List<Article>?> loadArticles() async {
    final prefs = await SharedPreferences.getInstance();
    final cacheTime = prefs.getInt(_cacheTimeKey);
    if (cacheTime == null) return null;

    // 24時間以上経過していたらキャッシュ無効
    final elapsed = DateTime.now().millisecondsSinceEpoch - cacheTime;
    if (elapsed > _cacheDuration.inMilliseconds) return null;

    final jsonStr = prefs.getString(_articlesKey);
    if (jsonStr == null) return null;

    try {
      final jsonList = jsonDecode(jsonStr) as List;
      return jsonList.map((j) => Article.fromJson(j)).toList();
    } catch (e) {
      return null;
    }
  }

  // キャッシュをクリア
  static Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_articlesKey);
    await prefs.remove(_cacheTimeKey);
  }
}
