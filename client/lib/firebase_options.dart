// File generated for NutriCare Firebase integration.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for NutriCare platform.
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
      default:
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAbq3O-djKPmpT2HSwvk7Dgq05u0ugLx9I',
    appId: '1:650630561254:web:fbc5688a1d73af8a37aa27',
    messagingSenderId: '650630561254',
    projectId: 'nutricare-5cf9d',
    authDomain: 'nutricare-5cf9d.firebaseapp.com',
    storageBucket: 'nutricare-5cf9d.firebasestorage.app',
    measurementId: 'G-C957HEN06F',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAbq3O-djKPmpT2HSwvk7Dgq05u0ugLx9I',
    appId: '1:650630561254:web:fbc5688a1d73af8a37aa27',
    messagingSenderId: '650630561254',
    projectId: 'nutricare-5cf9d',
    authDomain: 'nutricare-5cf9d.firebaseapp.com',
    storageBucket: 'nutricare-5cf9d.firebasestorage.app',
    measurementId: 'G-C957HEN06F',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAbq3O-djKPmpT2HSwvk7Dgq05u0ugLx9I',
    appId: '1:650630561254:web:fbc5688a1d73af8a37aa27',
    messagingSenderId: '650630561254',
    projectId: 'nutricare-5cf9d',
    authDomain: 'nutricare-5cf9d.firebaseapp.com',
    storageBucket: 'nutricare-5cf9d.firebasestorage.app',
    measurementId: 'G-C957HEN06F',
  );
}
