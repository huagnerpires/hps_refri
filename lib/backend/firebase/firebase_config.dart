import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

Future initFirebase() async {
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: FirebaseOptions(
            apiKey: "AIzaSyC_0cbzkworbVDkJHbPFZcjHNRksD0neTw",
            authDomain: "h-p-s-modificado-emdcp0.firebaseapp.com",
            projectId: "h-p-s-modificado-emdcp0",
            storageBucket: "h-p-s-modificado-emdcp0.appspot.com",
            messagingSenderId: "864598419738",
            appId: "1:864598419738:web:734c7e98b6a9ddcb3fe4a3"));
  } else {
    await Firebase.initializeApp();
  }
}
