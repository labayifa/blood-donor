import 'package:blood_app/screens/splash_screen.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';

bool USE_FIRESTORE_EMULATOR = false;

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  if (USE_FIRESTORE_EMULATOR) {
    FirebaseFirestore.instance.settings = const Settings(
      host: 'localhost:8080',
      sslEnabled: false,
      persistenceEnabled: false,
    );
  }
  runApp(BloodApp());
}

class BloodApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mon Sang, Des Vies',
      theme: ThemeData(
        primarySwatch: Colors.red,
        accentColor: Colors.pink,
      ),
      home:SplashScreen(),
    );
  }
}