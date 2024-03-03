import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:project/page/loginpage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: IconButton(
        icon: const Icon(Icons.logout),
        onPressed: () {
          FirebaseAuth.instance.signOut();
          SharedPreferences.getInstance().then((prefs) {
            prefs.remove('userUid');
          });
          Get.offAll(() => const LoginPage(), curve: Curves.easeIn);
        },
      ),
    );
  }
}
