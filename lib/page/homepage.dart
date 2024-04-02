import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/widget/finishedmatchitem.dart';
import 'package:project/widget/livematchitem.dart';
import 'package:project/widget/upcomingmatchitem.dart';
import 'allmatchpage.dart';
import '../api/upcomingmatches_api.dart';
import '../api/livematches_api.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late Future<LiveMatches> futureLiveMatches;
  late Future<UpcomingMatches> futureUpcomingMatches;
  late io.Socket socket;
  late AnimationController _loadingController;
  late Animation<Color?> _loadingAnimation;

  bool liveLoaded = false;
  bool upcomingLoaded = false;

  @override
  void initState() {
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _loadingAnimation = ColorTween(begin: Colors.white, end: Colors.grey[300])
        .animate(_loadingController);

    futureLiveMatches = fetchLiveMatches();
    futureUpcomingMatches = fetchUpcomingMatches();
    super.initState();

    socket = io.io('http://132.145.68.135:6010/', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket.on('connect', (_) {
      print('homepage connected');
    });

    socket.on('disconnect', (_) {
      print('homepage disconnected');
    });

    socket.on('update_live_matches', (data) {
      setState(() {
        futureLiveMatches = parseLiveMatches(data);
      });
    });

    socket.on('update_upcoming_matches', (data) {
      setState(() {
        futureUpcomingMatches = parseUpcomingMatches(data);
      });
    });

    socket.connect();
  }

  @override
  void dispose() {
    _loadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (FirebaseAuth.instance.currentUser != null) {
      print(FirebaseAuth.instance.currentUser?.uid);
    }

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          _buildLiveMatch(),
          const SizedBox(height: 10.0),
          _buildUpcomingMatch(),
        ],
      ),
    );
  }

  Widget _buildLoadingLiveMatch() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
      child: Container(
        color: Colors.white,
        height: 250.0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 20.0, right: 20.0),
              child: Text(
                'Live Match',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20.0,
                ),
              ),
            ),
            const SizedBox(height: 10.0),
            Expanded(
              child: PageView.builder(
                controller: PageController(
                  initialPage: 0,
                  viewportFraction: 0.85,
                ),
                itemCount: 2,
                itemBuilder: (context, index) {
                  return AnimatedBuilder(
                    animation: _loadingAnimation,
                    builder: (context, child) {
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        color: _loadingAnimation.value,
                        child: const SizedBox(
                          width: 300.0,
                          height: 280.0,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveMatch() {
    return FutureBuilder<LiveMatches>(
      future: futureLiveMatches,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingLiveMatch();
        } else if (snapshot.hasError) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Something went wrong',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    elevation: 0,
                    shadowColor: Colors.white),
                onPressed: () {
                  setState(() {
                    futureLiveMatches = fetchLiveMatches();
                    futureUpcomingMatches = fetchUpcomingMatches();
                  });
                },
                child: Text(
                  'Retry',
                  style: TextStyle(color: Colors.pink[800]),
                ),
              ),
            ],
          );
        } else if (snapshot.hasData) {
          if (snapshot.data!.matches.isEmpty) {
            return Container();
          } else {
            return Padding(
              padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
              child: Container(
                color: Colors.white,
                height: 270.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 20.0, right: 20.0),
                      child: Text(
                        'Live Match',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    Expanded(
                      child: PageView.builder(
                        controller: PageController(
                          initialPage: 0,
                          viewportFraction: 0.85,
                        ),
                        physics: const ClampingScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        itemCount: snapshot.data!.matches.length,
                        itemBuilder: (BuildContext context, int index) {
                          return LiveMatchItem(
                              match: snapshot.data!.matches[index]);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        } else {
          return const Text('No data available',
              style: TextStyle(fontWeight: FontWeight.bold));
        }
      },
    );
  }

  Widget _buildLoadingUpcomingMatch() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 20.0),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Matches',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20.0,
                    ),
                  ),
                  TextButton(
                      onPressed: () {
                        Get.to(() => const AllMatchPage(),
                            transition: Transition.rightToLeft);
                      },
                      child: Text('See All',
                          style:
                              TextStyle(color: Colors.pink[800], fontSize: 15)))
                ]),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              scrollDirection: Axis.vertical,
              children: List.generate(5, (int index) {
                return AnimatedBuilder(
                    animation: _loadingAnimation,
                    builder: (context, child) {
                      return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          color: _loadingAnimation.value,
                          child: const SizedBox(width: 300.0, height: 100.0));
                    });
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingMatch() {
    return FutureBuilder(
        future: futureUpcomingMatches,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingUpcomingMatch();
          } else if (snapshot.hasError) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Something went wrong',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      elevation: 0,
                      shadowColor: Colors.white),
                  onPressed: () {
                    setState(() {
                      futureUpcomingMatches = fetchUpcomingMatches();
                      futureLiveMatches = fetchLiveMatches();
                    });
                  },
                  child: Text(
                    'Retry',
                    style: TextStyle(color: Colors.pink[800]),
                  ),
                ),
              ],
            );
          } else if (snapshot.hasData) {
            if (snapshot.data!.matches.isEmpty) {
              return Container();
            } else {
              return Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Matches',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 20.0,
                              ),
                            ),
                            TextButton(
                                onPressed: () {
                                  Get.to(() => const AllMatchPage(),
                                      transition: Transition.rightToLeft);
                                },
                                child: Text('See All',
                                    style: TextStyle(
                                        color: Colors.pink[800], fontSize: 15)))
                          ]),
                    ),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        scrollDirection: Axis.vertical,
                        children: List.generate(
                          snapshot.data!.matches.length,
                          (int index) {
                            return snapshot.data!.matches[index]['status'] ==
                                    'FINISHED'
                                ? Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 0, 0, 5),
                                    child: FinishedMatchItem(
                                        match: snapshot.data!.matches[index]),
                                  )
                                : Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 0, 0, 5),
                                    child: UpcomingMatchesItem(
                                        match: snapshot.data!.matches[index]),
                                  );
                          },
                        ).toList(),
                      ),
                    )
                  ],
                ),
              );
            }
          } else {
            return const Text('No data available',
                style: TextStyle(fontWeight: FontWeight.bold));
          }
        });
  }
}
