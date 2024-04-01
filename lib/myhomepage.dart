import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project/page/homepage.dart';
import 'package:project/page/infopage.dart';
import 'package:project/page/profilepage.dart';
import 'package:project/provider/coins_provider.dart';
import 'package:project/widget/custom_navigationbar.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  int _selectedIndex = 0;
  late Timer _timer;
  late io.Socket socket;

  @override
  void initState() {
    super.initState();
    startCoinsTimer();
    WidgetsBinding.instance.addObserver(this);
    socket = io.io('http://132.145.68.135:6010/', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket.on('sync_coin', (data) {
      Provider.of<CoinModel>(context, listen: false).updateCoinsInFirestore();
    });

    socket.on('update_coin', (data) {
      if (data['uid'] == FirebaseAuth.instance.currentUser!.uid) {
        Provider.of<CoinModel>(context, listen: false).addCoins(data['amount']);
      }
    });

    socket.on('connect', (_) => print('myhome connect'));

    socket.on('disconnect', (_) => print('myhome disconnect'));

    socket.connect();
  }

  @override
  Future<void> dispose() async {
    _timer.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      await Provider.of<CoinModel>(context, listen: false)
          .updateCoinsInFirestore();
      _timer.cancel();
    } else if (state == AppLifecycleState.resumed) {
      await startCoinsTimer();
    }
  }

  Future<void> startCoinsTimer() async {
    await Provider.of<CoinModel>(context, listen: false).fetchCoin();
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _addCoins();
    });
  }

  // Future<void> _updateCoinsInFirestore() async {
  //   try {
  //     final coinsModel = Provider.of<CoinModel>(context, listen: false);
  //     final coins = coinsModel.coins;

  //     final dbUser = await FirebaseFirestore.instance
  //         .collection('users')
  //         .where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
  //         .get();

  //     if (dbUser.docs.isNotEmpty) {
  //       await dbUser.docs[0].reference.update({'coins': coins});
  //     }
  //   } catch (error) {
  //     print('Error updating coin count in Firestore: $error');
  //   }
  // }

  void _addCoins() {
    Provider.of<CoinModel>(context, listen: false).increment();
  }

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  final List<Widget> _pages = [
    const HomePage(),
    const InfoPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text(
          'LiveScore',
          style: TextStyle(
            color: Colors.pink[800],
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      // body: _selectedIndex == 0 ? _useStack() : _useColumn(),
      body: _useColumn(),
    );
  }

  // Widget _useStack() {
  //   return Stack(
  //     children: [
  //       Column(
  //         crossAxisAlignment: CrossAxisAlignment.stretch,
  //         children: [
  //           Expanded(
  //             child: _pages[_selectedIndex],
  //           ),
  //         ],
  //       ),
  //       Positioned(
  //         left: 10,
  //         right: 10,
  //         bottom: 10,
  //         child: Container(
  //           decoration: BoxDecoration(
  //             color: Colors.white,
  //             borderRadius: BorderRadius.circular(20),
  //             boxShadow: [
  //               BoxShadow(
  //                 color: Colors.black.withOpacity(0.1),
  //                 blurRadius: 20,
  //                 spreadRadius: 3,
  //               ),
  //             ],
  //           ),
  //           child: CustomNavigationBar(
  //             selectedIndex: _selectedIndex,
  //             onItemTapped: _onItemTapped,
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }

  Widget _useColumn() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: _pages[_selectedIndex],
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: 3,
                ),
              ],
            ),
            child: CustomNavigationBar(
              selectedIndex: _selectedIndex,
              onItemTapped: _onItemTapped,
            ),
          ),
        ],
      ),
    );
  }
}
