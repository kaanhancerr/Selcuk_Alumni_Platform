// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBbGUyFJ-manLqSmQktDw_q5IaLr_f_W-U',
    appId: '1:511562029102:web:ddad89d5aef6f2f1b6e7bf',
    messagingSenderId: '511562029102',
    projectId: 'bitirme-73590',
    authDomain: 'bitirme-73590.firebaseapp.com',
    storageBucket: 'bitirme-73590.firebasestorage.app',
    measurementId: 'G-4C74G5S7LY',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDfkn6G7q8joV_vtSdzrZVcHghGD6rbtME',
    appId: '1:511562029102:ios:e6a23927d17c76c5b6e7bf',
    messagingSenderId: '511562029102',
    projectId: 'bitirme-73590',
    storageBucket: 'bitirme-73590.firebasestorage.app',
    iosBundleId: 'com.example.suMezuntakip',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDfkn6G7q8joV_vtSdzrZVcHghGD6rbtME',
    appId: '1:511562029102:ios:e6a23927d17c76c5b6e7bf',
    messagingSenderId: '511562029102',
    projectId: 'bitirme-73590',
    storageBucket: 'bitirme-73590.firebasestorage.app',
    iosBundleId: 'com.example.suMezuntakip',
  );
}
