import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeviceIdService {
  static const _userIdKey = 'user_id';

  static Future<String> getUserId() async {
    // まずローカルに保存済みのUIDを確認
    final prefs = await SharedPreferences.getInstance();
    final savedId = prefs.getString(_userIdKey);
    if (savedId != null) return savedId;

    // 匿名認証でサインイン
    final auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    if (user == null) {
      final credential = await auth.signInAnonymously();
      user = credential.user;
    }

    final uid = user!.uid;
    await prefs.setString(_userIdKey, uid);
    return uid;
  }
}
