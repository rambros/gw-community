import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

Future initFirebase() async {
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: "AIzaSyD5_nPEBzr1t9QGZC0dGGIr69iSbOKeqNw",
            authDomain: "good-wishes-project.firebaseapp.com",
            projectId: "good-wishes-project",
            storageBucket: "good-wishes-project.appspot.com",
            messagingSenderId: "875067654858",
            appId: "1:875067654858:web:cb5a6a7f84cf6abbe9aa33",
            measurementId: "G-LYGLDNNY4M"));
  } else {
    await Firebase.initializeApp();
  }
}
