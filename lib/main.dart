import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:project/myhomepage.dart';
import 'package:project/page/loginpage.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeFirebase();
  runApp(const MyApp());
}

Future<void> initializeFirebase() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _isUserLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else {
          return GetMaterialApp(
            home:
                snapshot.data == true ? const MyHomePage() : const LoginPage(),
            debugShowCheckedModeBanner: false,
          );
        }
      },
    );
  }

  Future<bool> _isUserLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final userUid = prefs.getString('userUid');
    return userUid != null;
  }
}
