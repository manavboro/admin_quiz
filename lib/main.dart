import 'package:admin_quiz/pages/login.dart';
import 'package:admin_quiz/pages/subjects_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'admin_home_page.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Enable Firestore Offline persistence
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true, // Enabling offline persistence
    cacheSizeBytes:
        Settings.CACHE_SIZE_UNLIMITED, // Optional: Increase cache size
  );
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(ProviderScope(child: MyApp())); // Wrap the app with ProviderScope
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Admin App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: FutureBuilder(
            future: _checkLoginStatus(),
            builder: (ctx, snapshoot) {
              if (snapshoot.connectionState == ConnectionState.done) {
                final bool result = snapshoot.data as bool;
                if (result) {
                return  SubjectListPage();
                } else {
                return  LoginPage();
                }
              }
              return Center(
                child: CircularProgressIndicator(),
              );
            }));
  }

  Future<bool> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('email');

    if (email != null) {
      return true;
    }
    return false; // No user logged in
  }
}
