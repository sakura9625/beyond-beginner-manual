import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return ios;
      default:
        return ios;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBtlztFwjjklhmAOy59TgBcUbDdL6FDlbw',
    appId: '1:426430338114:ios:57054960a441f0b04009db',
    messagingSenderId: '426430338114',
    projectId: 'beyond-beginner-manual',
    storageBucket: 'beyond-beginner-manual.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBtlztFwjjklhmAOy59TgBcUbDdL6FDlbw',
    appId: '1:426430338114:ios:57054960a441f0b04009db',
    messagingSenderId: '426430338114',
    projectId: 'beyond-beginner-manual',
    storageBucket: 'beyond-beginner-manual.firebasestorage.app',
    iosBundleId: 'com.beyondbeginner.manual',
  );
}
