import 'package:flutter/material.dart';
import 'package:project/widget/custom_navigationbar.dart';
import 'package:project/page/homepage.dart';
import 'package:project/page/profilepage.dart';
import 'package:project/page/infopage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

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
    ProfilePage(),
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
      body: _useStack(),
    );
  }

  Widget _useStack() {
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: _pages[_selectedIndex],
            ),
          ],
        ),
        Positioned(
          left: 10,
          right: 10,
          bottom: 10,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
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
        ),
      ],
    );
  }

  // Widget _useColumn() {
  //   return Center(
  //     child: Column(
  //       mainAxisAlignment: MainAxisAlignment.end,
  //       children: [
  //         Expanded(
  //           child: _pages[_selectedIndex],
  //         ),
  //         Container(
  //           decoration: BoxDecoration(
  //             color: Colors.white,
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
  //       ],
  //     ),
  //   );
  // }
}
