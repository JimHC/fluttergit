// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
    apiKey: 'AIzaSyC1gVS9-gF8bKz4XKtzAXq9i3ID3Jc6rlA',
    appId: '1:188019558358:web:475f539185cbd3760f0677',
    messagingSenderId: '188019558358',
    projectId: 'masterttv2',
    authDomain: 'masterttv2.firebaseapp.com',
    storageBucket: 'masterttv2.appspot.com',
    measurementId: 'G-7XYWTGW8QD',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDFZ5oaUX_B7K-tRTWanQqe0yXd9vJ5H5Q',
    appId: '1:188019558358:android:8b88fd1543cf1c410f0677',
    messagingSenderId: '188019558358',
    projectId: 'masterttv2',
    storageBucket: 'masterttv2.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBZyhHlyX7AlOBeKIRk7cfx-yMEqAEbc5g',
    appId: '1:188019558358:ios:143844064d9738200f0677',
    messagingSenderId: '188019558358',
    projectId: 'masterttv2',
    storageBucket: 'masterttv2.appspot.com',
    iosClientId: '188019558358-rl0e03qvgk74actajv1f134njib439q9.apps.googleusercontent.com',
    iosBundleId: 'com.example.milistav2',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBZyhHlyX7AlOBeKIRk7cfx-yMEqAEbc5g',
    appId: '1:188019558358:ios:292a19b99564f8620f0677',
    messagingSenderId: '188019558358',
    projectId: 'masterttv2',
    storageBucket: 'masterttv2.appspot.com',
    iosClientId: '188019558358-duv19nfndqrlaho9bo75ao81388c6663.apps.googleusercontent.com',
    iosBundleId: 'com.example.milistav2.RunnerTests',
  );
}
