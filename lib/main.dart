import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:project/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:project/myhomepage.dart';
import 'package:project/page/loginpage.dart';
import 'package:project/page/setusernamepage.dart';
import 'package:project/provider/coins_provider.dart';
import 'package:provider/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeFirebase();
  await dotenv.load(fileName: '.env');
  runApp(const MyApp());
}

Future<void> initializeFirebase() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  @override
  void initState() {
    super.initState();
    _firebaseMessaging.requestPermission();

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      setState(() {});
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showLocalNotification(message);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CoinModel>(
      create: (context) => CoinModel(),
      child: GetMaterialApp(
        theme: ThemeData(fontFamily: 'Kanit'),
        home: _isUserLoggedIn() == false
            ? const LoginPage()
            : _isUserAlreadySetUsername() == false
                ? const SetUsernamePage()
                : const MyHomePage(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }

  bool _isUserLoggedIn() {
    return FirebaseAuth.instance.currentUser != null;
  }

  bool _isUserAlreadySetUsername() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return user.displayName != null && user.displayName!.isNotEmpty;
    }
    return false;
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    await flutterLocalNotificationsPlugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
    );

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'LIVE_SCORE_CHANNEL_ID',
      'LIVE_SCORE_CHANNEL_NAME',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    DarwinNotificationDetails iOSPlatformChannelSpecifics =
        const DarwinNotificationDetails();

    NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      message.notification?.title ?? '',
      message.notification?.body ?? '',
      platformChannelSpecifics,
    );
  }
}
