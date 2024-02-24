import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:project/api/topscorers_api.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  late Future<TopScorers> futureTopScorers;
  late io.Socket socket;

  @override
  void initState() {
    super.initState();
    futureTopScorers = fetchTopScorers();

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildTopScorers();
  }

  Widget _buildTopScorers() {
    Set goals = {};

    return FutureBuilder(
      future: futureTopScorers,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Platform.isIOS
                  ? const CupertinoActivityIndicator()
                  : const CircularProgressIndicator()
            ],
          );
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
        } else if (snapshot.hasData) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
            child: Container(
              color: Colors.white,
              height: 250.0,
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
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.pink[800],
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20.0),
                            topRight: Radius.circular(20.0),
                            bottomRight: Radius.circular(20.0),
                            bottomLeft: Radius.circular(20.0),
                          )),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '1',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                      snapshot.data?.scorers[0]['player']
                                          ['name'],
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold)),
                                  Row(
                                    children: [
                                      snapshot.data?.scorers[0]['team']['crest']
                                              .endsWith('.svg')
                                          ? SvgPicture.network(
                                              "https://corsproxy.io/?${snapshot.data?.scorers[0]['team']['crest']}",
                                              width: 25,
                                              height: 25,
                                              fit: BoxFit.contain)
                                          : Image.network(
                                              "https://corsproxy.io/?${snapshot.data?.scorers[0]['team']['crest']}",
                                              width: 25,
                                              height: 25,
                                              fit: BoxFit.contain),
                                      const SizedBox(width: 5),
                                      Text(
                                        snapshot.data?.scorers[0]['team']
                                            ['shortName'],
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                      snapshot.data!.scorers[0]['goals']
                                          .toString(),
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 40,
                                          fontWeight: FontWeight.bold))
                                ],
                              ),
                            ),
                            Image.network(
                              'https://resources.premierleague.com/premierleague/photos/players/110x140/${snapshot.data!.scorers[0]['moreInfo']['altIds']['opta']}.png',
                              fit: BoxFit.contain,
                              height: 150,
                              width: 150,
                            ),
                          ]),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: snapshot.data!.scorers.length - 1,
                      itemBuilder: (context, index) {
                        return _buildTopScorersItem(
                            snapshot.data?.scorers[index + 1], goals);
                      },
                    ),
                  ),
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

  Widget _buildTopScorersItem(dynamic scorers, Set goals) {
    goals.add(scorers['goals']);
    return Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: Card(
          color: Colors.white,
          child: SizedBox(
              height: 100,
              child: Row(children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 5, 0),
                  child: Text(
                      getIndex(goals, scorers['goals']) + 1 < 10
                          ? '${getIndex(goals, scorers['goals']) + 2}  '
                          : '${getIndex(goals, scorers['goals']) + 2}',
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
                      'https://resources.premierleague.com/premierleague/photos/players/250x250/${scorers['moreInfo']['altIds']['opta']}.png',
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
        ));
  }

  int getIndex(Set goals, int goal) {
    int index = 0;
    for (var element in goals) {
      if (element == goal) {
        return index;
      }
      index++;
    }
    return -1; // Return -1 if not found
  }
}
