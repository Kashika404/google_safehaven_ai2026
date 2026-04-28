import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for android - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // ✅ YOUR DASHBOARD RUNS AS WEB — THIS IS WHAT MATTERS
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAJ9yHIX3FWi65f80iPoaCdlbkkOiQxt0Q',
    appId:
        '1:1006617423802:web:eef288ba9e842587dcf783', // ← only thing you need
    messagingSenderId: '1006617423802',
    projectId: 'safehavensolution-2026',
    authDomain: 'safehavensolution-2026.firebaseapp.com',
    databaseURL: 'https://safehavensolution-2026-default-rtdb.firebaseio.com',
    storageBucket: 'safehavensolution-2026.firebasestorage.app',
  );

  // Android/iOS not used for your web dashboard — keeping for safety
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAJ9yHIX3FWi65f80iPoaCdlbkkOiQxt0Q',
    appId: '1:1006617423802:web:eef288ba9e842587dcf783', // same is fine for now
    messagingSenderId: '1006617423802',
    projectId: 'safehavensolution-2026',
    databaseURL: 'https://safehavensolution-2026-default-rtdb.firebaseio.com',
    storageBucket: 'safehavensolution-2026.firebasestorage.app',
    iosBundleId: 'com.example.safehavenDashboard',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAJ9yHIX3FWi65f80iPoaCdlbkkOiQxt0Q',
    appId: '1:1006617423802:web:eef288ba9e842587dcf783', // same is fine for now
    messagingSenderId: '1006617423802',
    projectId: 'safehavensolution-2026',
    databaseURL: 'https://safehavensolution-2026-default-rtdb.firebaseio.com',
    storageBucket: 'safehavensolution-2026.firebasestorage.app',
    iosBundleId: 'com.example.safehavenDashboard',
  );
}
