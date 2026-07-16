// Firebase configuration for each platform.
// Android values are from google-services.json.
// Windows values are placeholders — Firebase is skipped on Windows.
import 'dart:io' show Platform;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (!kIsWeb && Platform.isAndroid) return android;
    return windows;
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBGVQP8Iqyqp8Q9pQtdx5kZOZP3VYAaE38',
    appId: '1:876548377875:android:c5cef3abf48fd4b6d25ee6',
    messagingSenderId: '876548377875',
    projectId: 'zetaidle-20260602-01',
    storageBucket: 'zetaidle-20260602-01.firebasestorage.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'YOUR_API_KEY',
    appId: 'YOUR_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_STORAGE_BUCKET',
    authDomain: null,
    measurementId: null,
  );
}
