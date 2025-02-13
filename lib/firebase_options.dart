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
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
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
    apiKey: 'AIzaSyAPNSbJ6hMCfc8Fz5KzB4S4mIiYU-bgXog',
    appId: '1:1053523762235:web:8933a213dc9eede991101e',
    messagingSenderId: '1053523762235',
    projectId: 'quiz-app-d90ea',
    authDomain: 'quiz-app-d90ea.firebaseapp.com',
    storageBucket: 'quiz-app-d90ea.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB6DIjrkEVrzK1xSOBgoCM9zD5WCxTfaKs',
    appId: '1:1053523762235:android:ceb6429da55aea6591101e',
    messagingSenderId: '1053523762235',
    projectId: 'quiz-app-d90ea',
    storageBucket: 'quiz-app-d90ea.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC-nDXQ_sH_zbow20M6hqOXxGsTcHGAyI4',
    appId: '1:1053523762235:ios:abbff0fa5339a79d91101e',
    messagingSenderId: '1053523762235',
    projectId: 'quiz-app-d90ea',
    storageBucket: 'quiz-app-d90ea.firebasestorage.app',
    iosBundleId: 'aaronai.in.admin.adminQuiz',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyC-nDXQ_sH_zbow20M6hqOXxGsTcHGAyI4',
    appId: '1:1053523762235:ios:abbff0fa5339a79d91101e',
    messagingSenderId: '1053523762235',
    projectId: 'quiz-app-d90ea',
    storageBucket: 'quiz-app-d90ea.firebasestorage.app',
    iosBundleId: 'aaronai.in.admin.adminQuiz',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAPNSbJ6hMCfc8Fz5KzB4S4mIiYU-bgXog',
    appId: '1:1053523762235:web:243948c6fd6b5aeb91101e',
    messagingSenderId: '1053523762235',
    projectId: 'quiz-app-d90ea',
    authDomain: 'quiz-app-d90ea.firebaseapp.com',
    storageBucket: 'quiz-app-d90ea.firebasestorage.app',
  );
}
