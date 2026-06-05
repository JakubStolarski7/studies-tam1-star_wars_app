import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    throw UnsupportedError(
      'DefaultFirebaseOptions są skonfigurowane tylko dla platformy Web.',
    );
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyCMRGTt5J_wEFWeFDr1o5CCUQMxgSj21zc",
    authDomain: "star-wars-project-a9071.firebaseapp.com",
    projectId: "star-wars-project-a9071",
    storageBucket: "star-wars-project-a9071.firebasestorage.app",
    messagingSenderId: "1056127477631",
    appId: "1:1056127477631:web:a5229e49e95033a3941c4a",
  );
}