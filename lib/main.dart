import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyCsQ0bB9zNSNwXHyHpDXawG8xrDvlGXYWM",
      authDomain: "yoco-76ae7.firebaseapp.com",
      projectId: "yoco-76ae7",
      storageBucket: "yoco-76ae7.appspot.com",
      messagingSenderId: "862521546862",
      appId: "1:862521546862:web:dbe59081fbfafbc8b26e7f",
      measurementId: "G-5TSYW48SBH",
    ),
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yoco App',
      home: Scaffold(
        appBar: AppBar(title: Text("Yoco + Firebase")),
        body: Center(child: Text("Firebase connected!")),
      ),
    );
  }
}