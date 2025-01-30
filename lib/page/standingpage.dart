import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:project/api/standings_api.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class StandingPage extends StatefulWidget {
  const StandingPage({super.key});

  @override
  State<StandingPage> createState() => _StandingPageState();
}

class _StandingPageState extends State<StandingPage> {
  late Future<Standings> futureStandings;
  late io.Socket socket;

  @override
  void initState() {
    super.initState();
    futureStandings = fetchStandings();

    socket = io.io('${dotenv.env['API_URL']}', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    // socket.on('connect', (_) {
    //   print('standing connected');
    // });

    // socket.on('disconnect', (_) {
    //   print('standing disconnected');
    // });

    socket.on('update_table', (data) {
      setState(() {
        futureStandings = parseStandings(data);
      });
    });

    socket.connect();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: FutureBuilder(
        future: futureStandings,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Platform.isIOS
                  ? const CupertinoActivityIndicator()
                  : const CircularProgressIndicator(),
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
                    shadowColor: Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      futureStandings = fetchStandings();
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
            return SingleChildScrollView(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: MediaQuery.of(context).size.width < 585
                      ? 15
                      : MediaQuery.of(context).size.width / 14.1,
                  columns: const [
                    DataColumn(
                      label: Text('Club',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    DataColumn(
                      label: Text('Played',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      numeric: true,
                    ),
                    DataColumn(
                      label: Text('Won',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      numeric: true,
                    ),
                    DataColumn(
                      label: Text('Draw',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      numeric: true,
                    ),
                    DataColumn(
                      label: Text('Lost',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      numeric: true,
                    ),
                    DataColumn(
                      label: Text('GF',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      numeric: true,
                    ),
                    DataColumn(
                      label: Text('GA',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      numeric: true,
                    ),
                    DataColumn(
                      label: Text('GD',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      numeric: true,
                    ),
                    DataColumn(
                      label: Text('Points',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      numeric: true,
                    ),
                  ],
                  rows: [
                    for (var club in snapshot.data!.standings[0]['table'])
                      DataRow(
                        cells: [
                          DataCell(Row(
                            children: [
                              SizedBox(
                                width: 20,
                                child: Text(
                                    club['position'] < 10
                                        ? '  ${club['position']}'
                                        : '${club['position']}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(width: 10),
                              SizedBox(
                                width: 30,
                                height: 30,
                                child: club['team']['crest'].endsWith('.svg')
                                    ? SvgPicture.network(
                                        "${club['team']['crest']}",
                                        width: 30,
                                        height: 30,
                                        fit: BoxFit.contain)
                                    : Image.network("${club['team']['crest']}",
                                        width: 30,
                                        height: 30,
                                        fit: BoxFit.contain),
                              ),
                              const SizedBox(width: 10),
                              Text(club['team']['shortName'],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold))
                            ],
                          )),
                          DataCell(Text(club['playedGames'].toString())),
                          DataCell(Text(club['won'].toString())),
                          DataCell(Text(club['draw'].toString())),
                          DataCell(Text(club['lost'].toString())),
                          DataCell(Text(club['goalsFor'].toString())),
                          DataCell(Text(club['goalsAgainst'].toString())),
                          DataCell(Text(club['goalDifference'].toString())),
                          DataCell(Text(
                            club['points'].toString(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          )),
                        ],
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
      ),
    );
  }
}
