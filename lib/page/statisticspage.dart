import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:project/api/topscorers_api.dart';
import 'package:project/page/playerpage.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage>
    with SingleTickerProviderStateMixin {
  late Future<TopScorers> futureTopScorers;
  late io.Socket socket;
  late AnimationController _loadingController;
  late Animation<Color?> _loadingAnimation;

  @override
  void initState() {
    super.initState();
    futureTopScorers = fetchTopScorers();

    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _loadingAnimation = ColorTween(begin: Colors.white, end: Colors.grey[300])
        .animate(_loadingController);

    socket = io.io('http://132.145.68.135:6010', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket.on('connect', (_) {
      print('connected');
    });

    socket.on('update_top_scorers', (data) {
      setState(() {
        futureTopScorers = parseTopScorers(data);
      });
    });

    socket.connect();
  }

  @override
  void dispose() {
    socket.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildTopScorers();
  }

  Widget _buildTopScorers() {
    List goals = [];

    return FutureBuilder(
      future: futureTopScorers,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return AnimatedBuilder(
              animation: _loadingAnimation,
              builder: (context, child) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10.0),
                        Padding(
                          padding:
                              const EdgeInsets.only(left: 20.0, right: 20.0),
                          child: Text(
                            'Top 10 Scorers',
                            style: TextStyle(
                              color: Colors.pink[800],
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10.0),
                        Padding(
                          padding:
                              const EdgeInsets.only(left: 20.0, right: 20.0),
                          child: Column(children: [
                            Card(
                              color: _loadingAnimation.value,
                              child: SizedBox(
                                  height: 150,
                                  width: MediaQuery.of(context).size.width),
                            )
                          ]),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.only(left: 20.0, right: 20.0),
                          child: Column(
                            children: [
                              for (int i = 0; i < 10; i++)
                                Card(
                                  color: _loadingAnimation.value,
                                  child: SizedBox(
                                      height: 100,
                                      width: MediaQuery.of(context).size.width),
                                )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                );
              });
        } else if (snapshot.hasError) {
          return dataHasError();
        } else if (snapshot.hasData) {
          List mostGoalScorers = snapshot.data!.scorers.where((element) {
            return element['goals'] == snapshot.data?.scorers[0]['goals'];
          }).toList();
          int mostGoalScorerCount = mostGoalScorers.length;
          List topGoalScorers = snapshot.data!.scorers
              .where((element) =>
                  element['goals'] != snapshot.data?.scorers[0]['goals'])
              .toList();
          return Padding(
            padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10.0),
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                    child: Text(
                      'Top 10 Scorers',
                      style: TextStyle(
                        color: Colors.pink[800],
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  // most goal scorers
                  _buildMostScorer(mostGoalScorers),
                  // top goal scorers
                  Column(
                      children: [
                            for (var scorer in topGoalScorers)
                              _buildTopScorersItem(
                                  scorer, goals, mostGoalScorerCount)
                          ])
                ],
              ),
            ),
          );
        } else {
          return const Text('No data available',
              style: TextStyle(fontWeight: FontWeight.bold));
        }
      },
    );
  }

  Widget _buildMostScorer(List scorers) {
    return Column(
        children: [for (var scorer in scorers) _buildMostScorerItem(scorer)]);
  }

  Widget _buildMostScorerItem(dynamic scorer) {
    return FutureBuilder<PaletteGenerator>(
        future: PaletteGenerator.fromImageProvider(
          NetworkImage(
            'https://corsproxy.io/?https://resources.premierleague.com/premierleague/photos/players/110x140/${scorer['moreInfo']['altIds']['opta']}.png',
          ),
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return AnimatedBuilder(
                animation: _loadingAnimation,
                builder: (context, child) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                    child: Card(
                      color: _loadingAnimation.value,
                      child: SizedBox(
                          height: 150,
                          width: MediaQuery.of(context).size.width),
                    ),
                  );
                });
          } else if (snapshot.hasError) {
            print(snapshot.error);
            return SizedBox(
              height: 150.0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
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
                        futureTopScorers = fetchTopScorers();
                      });
                    },
                    child: Text(
                      'Retry',
                      style: TextStyle(color: Colors.pink[800]),
                    ),
                  ),
                ],
              ),
            );
          } else if (snapshot.hasData) {
            Color imageColor = snapshot.data!.dominantColor!.color;
            return Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20.0),
              child: InkWell(
                onTap: () {
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) => PlayerPage(
                  //       player: scorer['moreInfo'],
                  //     ),
                  //   ),
                  // );
                  Get.to(() => PlayerPage(player: scorer['moreInfo']), transition: Transition.rightToLeft);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: imageColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20.0),
                      topRight: Radius.circular(20.0),
                      bottomRight: Radius.circular(20.0),
                      bottomLeft: Radius.circular(20.0),
                    ),
                    image: const DecorationImage(
                      image: AssetImage(
                        'assets/images/background2.png',
                      ),
                      fit: BoxFit.cover,
                      opacity: 0.5,
                    ),
                  ),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '1',
                                style: TextStyle(
                                    color: imageColor == Colors.white
                                        ? Colors.black
                                        : Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(scorer['player']['name'],
                                  style: TextStyle(
                                      color: imageColor == Colors.white
                                          ? Colors.black
                                          : Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold)),
                              Row(
                                children: [
                                  scorer['team']['crest'].endsWith('.svg')
                                      ? SvgPicture.network(
                                          "https://corsproxy.io/?${scorer['team']['crest']}",
                                          width: 25,
                                          height: 25,
                                          fit: BoxFit.contain)
                                      : Image.network(
                                          "https://corsproxy.io/?${scorer['team']['crest']}",
                                          width: 25,
                                          height: 25,
                                          fit: BoxFit.contain),
                                  const SizedBox(width: 5),
                                  Text(
                                    scorer['team']['shortName'],
                                    style: TextStyle(
                                      color: imageColor == Colors.white
                                          ? Colors.black
                                          : Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Text(scorer['goals'].toString(),
                                  style: TextStyle(
                                      color: imageColor == Colors.white
                                          ? Colors.black
                                          : Colors.white,
                                      fontSize: 40,
                                      fontWeight: FontWeight.bold))
                            ],
                          ),
                        ),
                        Image.network(
                          'https://corsproxy.io/?https://resources.premierleague.com/premierleague/photos/players/110x140/${scorer['moreInfo']['altIds']['opta']}.png',
                          fit: BoxFit.contain,
                          height: 150,
                          width: 150,
                        ),
                      ]),
                ),
              ),
            );
          } else {
            return const Text('No data available',
                style: TextStyle(fontWeight: FontWeight.bold));
          }
        });
  }

  Widget _buildTopScorersItem(
      dynamic scorers, List goals, int mostGoalScorerCount) {
    goals.add(scorers['goals']);
    return Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: InkWell(
          onTap: () {
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(
            //     builder: (context) => PlayerPage(
            //       player: scorers['moreInfo'],
            //     ),
            //   ),
            // );
            Get.to(() => PlayerPage(player: scorers['moreInfo']), transition: Transition.rightToLeft);
          },
          child: Card(
            color: Colors.white,
            child: SizedBox(
                height: 100,
                child: Row(children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 5, 0),
                    child: Text(
                        getIndex(goals, scorers['goals']) +
                                    mostGoalScorerCount +
                                    1 <
                                10
                            ? '${getIndex(goals, scorers['goals']) + mostGoalScorerCount + 1}  '
                            : '${getIndex(goals, scorers['goals']) + mostGoalScorerCount + 1}',
                        style: const TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                    child: CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.pink[800],
                      child: Image.network(
                        'https://corsproxy.io/?https://resources.premierleague.com/premierleague/photos/players/250x250/${scorers['moreInfo']['altIds']['opta']}.png',
                        fit: BoxFit.contain,
                        height: 60,
                        width: 60,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          scorers['player']['name'],
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                              fontWeight: FontWeight.bold),
                        ),
                        Row(
                          children: [
                            scorers['team']['crest'].endsWith('.svg')
                                ? SvgPicture.network(
                                    "https://corsproxy.io/?${scorers['team']['crest']}",
                                    width: 20,
                                    height: 20,
                                    fit: BoxFit.contain)
                                : Image.network(
                                    "https://corsproxy.io/?${scorers['team']['crest']}",
                                    width: 20,
                                    height: 20,
                                    fit: BoxFit.contain),
                            const SizedBox(width: 5),
                            Text(
                              scorers['team']['shortName'],
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Expanded(
                    child: SizedBox(),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(5, 0, 20, 0),
                    child: Text(
                      '  ${scorers['goals']}',
                      style: const TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                  )
                ])),
          ),
        ));
  }

  int getIndex(List goals, int goal) {
    int index = 0;
    for (var element in goals) {
      if (element == goal) {
        return index;
      }
      index++;
    }
    return -1;
  }

  Widget dataHasError() {
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
              futureTopScorers = fetchTopScorers();
            });
          },
          child: Text(
            'Retry',
            style: TextStyle(color: Colors.pink[800]),
          ),
        ),
      ],
    );
  }

  Widget dataWaiting() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Platform.isIOS
            ? const CupertinoActivityIndicator()
            : const CircularProgressIndicator()
      ],
    );
  }
}
