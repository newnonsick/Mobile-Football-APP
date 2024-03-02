import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
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

    socket = io.io('http://132.145.68.135:6010', <String, dynamic>{
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
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                ),
                scrollDirection: Axis.horizontal,
                children: List.generate(2, (int index) {
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
                          ));
                    },
                  );
                }),
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
                      child: ListView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                        ),
                        scrollDirection: Axis.horizontal,
                        children: List.generate(snapshot.data!.matches.length,
                            (int index) {
                          return _buildLiveMatchItem(
                              snapshot.data!.matches[index]);
                        }),
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
      onTap: () => {print('Live Match')},
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
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Home',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 13)),
                            const SizedBox(height: 5.0),
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
                            Card(
                              color: Colors.white,
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Text(
                                    '${match['score']['fullTime']['home']} - ${match['score']['fullTime']['away']}',
                                    style: const TextStyle(
                                        fontSize: 25,
                                        fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ]),
                      Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Away',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 13)),
                            const SizedBox(height: 5.0),
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
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                    'Upcoming Matchs',
                    style: TextStyle(
                      color: Colors.pink[800],
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                      onPressed: () {
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) => const AllMatchPage(),
                        //   ),
                        // ).then((value) {
                        //   setState(() {
                        //     futureUpcomingMatches = fetchUpcomingMatches();
                        //     futureLiveMatches = fetchLiveMatches();
                        //   });
                        // });
                        Get.to(() => const AllMatchPage(),
                            transition: Transition.rightToLeft);
                      },
                      child: const Text('See All',
                          style: TextStyle(color: Colors.black, fontSize: 15)))
                ]),
          ),
          const SizedBox(height: 10.0),
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
            print(snapshot.error);
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
                              'Upcoming Matchs',
                              style: TextStyle(
                                color: Colors.pink[800],
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton(
                                onPressed: () {
                                  // Navigator.push(
                                  //   context,
                                  //   MaterialPageRoute(
                                  //     builder: (context) =>
                                  //         const AllMatchPage(),
                                  //   ),
                                  // ).then((value) {
                                  //   setState(() {
                                  //     futureUpcomingMatches =
                                  //         fetchUpcomingMatches();
                                  //     futureLiveMatches = fetchLiveMatches();
                                  //   });
                                  // });
                                  Get.to(() => const AllMatchPage(),
                                      transition: Transition.rightToLeft);
                                },
                                child: const Text('See All',
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 15)))
                          ]),
                    ),
                    const SizedBox(height: 10.0),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        scrollDirection: Axis.vertical,
                        children: List.generate(snapshot.data!.matches.length,
                                (int index) {
                              return _buildUpcomingMatchItem(
                                  snapshot.data!.matches[index]);
                            }) +
                            const [SizedBox(height: 100.0)],
                      ),
                    ),
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

  Widget _buildUpcomingMatchItem(Map<String, dynamic> match) {
    DateTime utcDate = DateTime.parse(match['utcDate']);
    String formattedDate = DateFormat('dd MMM yyyy').format(utcDate.toLocal());
    String formattedTime = DateFormat('HH:mm').format(utcDate.toLocal());

    String crestHomeUrl = 'https://corsproxy.io/?${match['homeTeam']['crest']}';
    Widget crestHomeWidget;
    String crestAwayUrl = 'https://corsproxy.io/?${match['awayTeam']['crest']}';
    Widget crestAwayWidget;

    if (crestHomeUrl.endsWith('.svg')) {
      crestHomeWidget = SvgPicture.network(
        crestHomeUrl,
        width: 55,
        height: 55,
        fit: BoxFit.contain,
      );
    } else {
      crestHomeWidget = Image.network(
        crestHomeUrl,
        width: 55,
        height: 55,
        fit: BoxFit.contain,
      );
    }

    if (crestAwayUrl.endsWith('.svg')) {
      crestAwayWidget = SvgPicture.network(
        crestAwayUrl,
        width: 55,
        height: 55,
        fit: BoxFit.contain,
      );
    } else {
      crestAwayWidget = Image.network(
        crestAwayUrl,
        width: 55,
        height: 55,
        fit: BoxFit.contain,
      );
    }

    return InkWell(
      onTap: () => {print('Upcoming Match')},
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        color: Colors.white,
        child: SizedBox(
          width: 300.0,
          height: 100.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                width: 105,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(width: 55, height: 55, child: crestHomeWidget),
                    const SizedBox(height: 5.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          match['homeTeam']['shortName'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('VS',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text(
                    formattedDate,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    formattedTime,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(
                width: 105,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(width: 55, height: 55, child: crestAwayWidget),
                    const SizedBox(height: 5.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          match['awayTeam']['shortName'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
