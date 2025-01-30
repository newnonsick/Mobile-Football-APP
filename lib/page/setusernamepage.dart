import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:project/myhomepage.dart';
import 'package:project/utils/showtoast.dart';

class SetUsernamePage extends StatefulWidget {
  const SetUsernamePage({super.key});

  @override
  _SetUsernamePageState createState() => _SetUsernamePageState();
}

class _SetUsernamePageState extends State<SetUsernamePage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController usernameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'LiveScore',
          style: TextStyle(
            color: Colors.pink[800],
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(45, 0, 45, 0),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Choose a username',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              Text(
                'This username will be displayed to other users in the app',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              TextFormField(
                controller: usernameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a username';
                  }
                  if (value.length < 3) {
                    return 'Username must be at least 3 characters';
                  }
                  if (value.length > 20) {
                    return 'Username must be at most 20 characters';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[100],
                  hintText: 'Username',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey[500]!),
                    borderRadius: const BorderRadius.all(Radius.circular(5)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey[500]!),
                    borderRadius: const BorderRadius.all(Radius.circular(5)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey[500]!),
                    borderRadius: const BorderRadius.all(Radius.circular(5)),
                  ),
                ),
              ),
              const SizedBox(height: 80),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      if (await _isUsernameAlreadyExists(
                          usernameController.text)) {
                        ShowToast.show('Username already exists', Colors.red,
                            Colors.white, ToastGravity.BOTTOM);
                      } else {
                        await FirebaseAuth.instance.currentUser!
                            .updateDisplayName(usernameController.text);
                        await FirebaseFirestore.instance
                            .collection('users')
                            .where('uid',
                                isEqualTo:
                                    FirebaseAuth.instance.currentUser!.uid)
                            .get()
                            .then((value) {
                          if (value.docs.isNotEmpty) {
                            value.docs[0].reference
                                .update({'username': usernameController.text});
                          }
                        });

                        Get.offAll(() => const MyHomePage());
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink[800],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 5,
                    shadowColor: Colors.pink[800],
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _isUsernameAlreadyExists(String username) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: username)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking username: $e');
      return true;
    }
  }
}
