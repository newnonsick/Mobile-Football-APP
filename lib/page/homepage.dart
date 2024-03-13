import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:project/page/matchinfopage.dart';
import 'package:project/widget/finishedmatchitem.dart';
import 'package:project/widget/upcomingmatchitem.dart';
import 'all_match_page.dart';
import '../api/upcomingmatches_api.dart';
import '../api/livematches_api.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
      print('connected');
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
    socket.disconnect();
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
            Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20.0),
              child: Text(
                'Live Match',
                style: TextStyle(
                  color: Colors.pink[800],
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
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
                          height: 250.0,
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
                height: 250.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                      child: Text(
                        'Live Match',
                        style: TextStyle(
                            color: Colors.pink[800],
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold),
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
                          return _buildLiveMatchItem(
                              snapshot.data!.matches[index]);
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

  Widget _buildLiveMatchItem(Map<String, dynamic> match) {
    String crestHomeUrl = 'https://corsproxy.io/?${match['homeTeam']['crest']}';
    Widget crestHomeWidget;
    String crestAwayUrl = 'https://corsproxy.io/?${match['awayTeam']['crest']}';
    Widget crestAwayWidget;

    if (crestHomeUrl.endsWith('.svg')) {
      crestHomeWidget = SvgPicture.network(
        crestHomeUrl,
        width: 90,
        height: 90,
        fit: BoxFit.contain,
      );
    } else {
      crestHomeWidget = Image.network(
        crestHomeUrl,
        width: 90,
        height: 90,
        fit: BoxFit.contain,
      );
    }

    if (crestAwayUrl.endsWith('.svg')) {
      crestAwayWidget = SvgPicture.network(
        crestAwayUrl,
        width: 90,
        height: 90,
        fit: BoxFit.contain,
      );
    } else {
      crestAwayWidget = Image.network(
        crestAwayUrl,
        width: 90,
        height: 90,
        fit: BoxFit.contain,
      );
    }

    return InkWell(
      onTap: () => {
        Get.to(
          () => MatchInfoPage(
            match: match,
          ),
          transition: Transition.rightToLeft,
        )
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        color: Colors.white,
        child: SizedBox(
            width: 300.0,
            height: 250.0,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 20, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          const Text('LIVE',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: Color.fromRGBO(0, 100, 0, 1))),
                          const SizedBox(width: 5.0),
                          Container(
                            height: 10.0,
                            width: 10.0,
                            decoration: BoxDecoration(
                                color: Colors.grey[100],
                                shape: BoxShape.circle),
                          )
                        ],
                      )
                          .animate(
                              onPlay: (controller) =>
                                  controller.repeat(reverse: true))
                          .tint(
                              color: const Color.fromRGBO(0, 100, 0, 1),
                              delay: 1000.ms,
                              curve: Curves.easeInOut,
                              duration: 600.ms)
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            height: 10.0,
                          ),
                          SizedBox(
                              height: 90.0,
                              width: 90.0,
                              child: crestHomeWidget),
                          const SizedBox(height: 10.0),
                          Text(match['homeTeam']['shortName'],
                              style: const TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold))
                        ]),
                    Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.fromLTRB(2, 5, 2, 5),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  spreadRadius: 1,
                                  blurRadius: 2,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Text(
                                ' ${match['score']['fullTime']['home']} - ${match['score']['fullTime']['away']} ',
                                style: const TextStyle(
                                    fontSize: 25, fontWeight: FontWeight.bold)),
                          )
                        ]),
                    Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            height: 10.0,
                          ),
                          SizedBox(
                              height: 90.0,
                              width: 90.0,
                              child: crestAwayWidget),
                          const SizedBox(height: 10.0),
                          Text(match['awayTeam']['shortName'],
                              style: const TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold)),
                        ]),
                  ],
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    match['referees'].isEmpty
                        ? const Text('Referee: TBA')
                        : Text('Referee: ${match['referees'][0]['name']}',
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 10.0),
              ],
            )),
      ),
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
                  Text(
                    'Matches',
                    style: TextStyle(
                      color: Colors.pink[800],
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                      onPressed: () {
                        Get.to(() => const AllMatchPage(),
                            transition: Transition.rightToLeft);
                      },
                      child: const Text('See All',
                          style: TextStyle(color: Colors.black, fontSize: 15)))
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
                            Text(
                              'Matches',
                              style: TextStyle(
                                color: Colors.pink[800],
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton(
                                onPressed: () {
                                  Get.to(() => const AllMatchPage(),
                                      transition: Transition.rightToLeft);
                                },
                                child: const Text('See All',
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 15)))
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
                                ? FinishedMatchItem(
                                    match: snapshot.data!.matches[index])
                                : UpcomingMatchesItem(
                                    match: snapshot.data!.matches[index]);
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
