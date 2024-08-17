import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:project/api/allteams_api.dart';
import 'package:project/page/teaminfopage.dart';
import 'package:project/provider/coins_provider.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AllTeamsPage extends StatefulWidget {
  const AllTeamsPage({super.key});

  @override
  State<AllTeamsPage> createState() => _AllTeamsPageState();
}

class _AllTeamsPageState extends State<AllTeamsPage>
    with SingleTickerProviderStateMixin {
  late io.Socket socket;
  late Future<AllTeams> futureAllTeams;
  late Animation<Color?> _loadingAnimation;
  late AnimationController _loadingController;

  @override
  void initState() {
    super.initState();
    futureAllTeams = fetchAllTeams();

    socket = io.io('${dotenv.env['API_URL']}', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    // socket.on('connect', (_) {
    //   print('allteam connected');
    // });

    // socket.on('disconnect', (_) {
    //   print('allteam disconnected');
    // });

    socket.on('update_all_teams', (data) {
      setState(() {
        futureAllTeams = parseAllTeams(data);
      });
    });

    socket.on('update_coin', (data) {
      if (data['uid'] == FirebaseAuth.instance.currentUser!.uid) {
        Provider.of<CoinModel>(context, listen: false).addCoins(data['amount']);
      }
    });

    socket.connect();

    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _loadingAnimation = ColorTween(begin: Colors.white, end: Colors.grey[300])
        .animate(_loadingController);
  }

  @override
  void dispose() {
    _loadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: futureAllTeams,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return dataHasError();
          } else {
            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
                childAspectRatio:
                    MediaQuery.of(context).size.width > 360 ? 0.84 : 0.51,
              ),
              itemCount: snapshot.data?.teams.length,
              itemBuilder: (context, index) {
                return _buildAllTeamsItem(snapshot.data?.teams[index]);
              },
            );
          }
        });
  }

  Widget _buildAllTeamsItem(dynamic team) {
    String crestTeamUrl = 'https://corsproxy.io/?${team['crest']}';
    Widget crestTeamWidget;

    if (crestTeamUrl.endsWith('.svg')) {
      crestTeamWidget = SvgPicture.network(
        crestTeamUrl,
        width: 120,
        height: 120,
        fit: BoxFit.contain,
      );
    } else {
      crestTeamWidget = Image.network(
        crestTeamUrl,
        width: 120,
        height: 120,
        fit: BoxFit.contain,
      );
    }

    return FutureBuilder(
        future: _checkUserFavoriteTeam(team['id']),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return AnimatedBuilder(
                animation: _loadingAnimation,
                builder: (context, child) {
                  return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      color: _loadingAnimation.value);
                });
          } else {
            return InkWell(
              onTap: () {
                Get.to(() => TeamInfoPage(team: team),
                    transition: Transition.rightToLeft);
              },
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                color: const Color.fromARGB(255, 255, 255, 255),
                child: Container(
                  decoration: BoxDecoration(
                    image: const DecorationImage(
                      image: AssetImage('assets/images/background2.png'),
                      fit: BoxFit.cover,
                      opacity: 0.5,
                    ),
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  padding: const EdgeInsets.all(10.0),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(15.0),
                          child: crestTeamWidget,
                        ),
                        const SizedBox(height: 10.0),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                team['shortName'],
                                style: const TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5.0),
                              IconButton(
                                  onPressed: () {
                                    if (snapshot.data == true) {
                                      FirebaseFirestore.instance
                                          .collection('favoritedTeam')
                                          .where('uid',
                                              isEqualTo: FirebaseAuth
                                                  .instance.currentUser!.uid)
                                          .where('teamId',
                                              isEqualTo: team['id'])
                                          .get()
                                          .then((snapshot) {
                                        for (DocumentSnapshot doc
                                            in snapshot.docs) {
                                          doc.reference.delete();
                                        }
                                      }).then((value) => FirebaseFirestore
                                              .instance
                                              .collection('followedMatch')
                                              .where('awayTeamId',
                                                  isEqualTo: team['id'])
                                              .where('uid',
                                                  isEqualTo: FirebaseAuth
                                                      .instance
                                                      .currentUser!
                                                      .uid)
                                              .where('byUser', isEqualTo: false)
                                              .get()
                                              .then((snapshot) async {
                                                for (DocumentSnapshot doc
                                                    in snapshot.docs) {
                                                  final check =
                                                      await _checkUserFavoriteTeam(
                                                          doc['homeTeamId']);
                                                  if (check != true) {
                                                    doc.reference.delete();
                                                  }
                                                }
                                              })
                                              .then((value) => FirebaseFirestore.instance
                                                      .collection(
                                                          'followedMatch')
                                                      .where('homeTeamId',
                                                          isEqualTo: team['id'])
                                                      .where('uid',
                                                          isEqualTo: FirebaseAuth
                                                              .instance
                                                              .currentUser!
                                                              .uid)
                                                      .where('byUser', isEqualTo: false)
                                                      .get()
                                                      .then((snapshot) async {
                                                    for (DocumentSnapshot doc
                                                        in snapshot.docs) {
                                                      final check =
                                                          await _checkUserFavoriteTeam(
                                                              doc['awayTeamId']);
                                                      if (check != true) {
                                                        doc.reference.delete();
                                                      }
                                                    }
                                                  }))
                                              .then((value) => setState(() {})));
                                    } else {
                                      FirebaseFirestore.instance
                                          .collection('favoritedTeam')
                                          .add({
                                            'uid': FirebaseAuth
                                                .instance.currentUser!.uid,
                                            'teamId': team['id'],
                                          })
                                          .then((value) =>
                                              FirebaseFirestore.instance.collection('matches').where('awayTeamId', isEqualTo: team['id']).where('status', isEqualTo: 'TIMED').get().then(
                                                  (snapshot) async {
                                                for (DocumentSnapshot doc
                                                    in snapshot.docs) {
                                                  final check =
                                                      await _checkUserFollowedMatch(
                                                          doc['id']);
                                                  if (check != true) {
                                                    FirebaseFirestore.instance
                                                        .collection(
                                                            'followedMatch')
                                                        .add({
                                                      'matchId': doc['id'],
                                                      'homeTeamId':
                                                          doc['homeTeamId'],
                                                      'awayTeamId':
                                                          doc['awayTeamId'],
                                                      'uid': FirebaseAuth
                                                          .instance
                                                          .currentUser!
                                                          .uid,
                                                      'byUser': false,
                                                    });
                                                  }
                                                }
                                              }).then((value) => FirebaseFirestore.instance
                                                      .collection('matches')
                                                      .where('homeTeamId',
                                                          isEqualTo: team['id'])
                                                      .where('status',
                                                          isEqualTo: 'TIMED')
                                                      .get()
                                                      .then((snapshot) async {
                                                    for (DocumentSnapshot doc
                                                        in snapshot.docs) {
                                                      final check =
                                                          await _checkUserFollowedMatch(
                                                              doc['id']);
                                                      if (check != true) {
                                                        FirebaseFirestore
                                                            .instance
                                                            .collection(
                                                                'followedMatch')
                                                            .add({
                                                          'matchId': doc['id'],
                                                          'homeTeamId':
                                                              doc['homeTeamId'],
                                                          'awayTeamId':
                                                              doc['awayTeamId'],
                                                          'uid': FirebaseAuth
                                                              .instance
                                                              .currentUser!
                                                              .uid,
                                                          'byUser': false,
                                                        });
                                                      }
                                                    }
                                                  })))
                                          .then((value) => FirebaseFirestore.instance
                                                  .collection('matches')
                                                  .where('awayTeamId',
                                                      isEqualTo: team['id'])
                                                  .where('status',
                                                      isEqualTo: 'LIVE')
                                                  .get()
                                                  .then((snapshot) async {
                                                for (DocumentSnapshot doc
                                                    in snapshot.docs) {
                                                  final check =
                                                      await _checkUserFollowedMatch(
                                                          doc['id']);
                                                  if (check != true) {
                                                    FirebaseFirestore.instance
                                                        .collection(
                                                            'followedMatch')
                                                        .add({
                                                      'matchId': doc['id'],
                                                      'homeTeamId':
                                                          doc['homeTeamId'],
                                                      'awayTeamId':
                                                          doc['awayTeamId'],
                                                      'uid': FirebaseAuth
                                                          .instance
                                                          .currentUser!
                                                          .uid,
                                                      'byUser': false,
                                                    });
                                                  }
                                                }
                                              }).then(
                                                      (value) => FirebaseFirestore.instance
                                                              .collection('matches')
                                                              .where('homeTeamId', isEqualTo: team['id'])
                                                              .where('status', isEqualTo: 'LIVE')
                                                              .get()
                                                              .then((snapshot) async {
                                                            for (DocumentSnapshot doc
                                                                in snapshot
                                                                    .docs) {
                                                              final check =
                                                                  await _checkUserFollowedMatch(
                                                                      doc['id']);
                                                              if (check !=
                                                                  true) {
                                                                FirebaseFirestore
                                                                    .instance
                                                                    .collection(
                                                                        'followedMatch')
                                                                    .add({
                                                                  'matchId':
                                                                      doc['id'],
                                                                  'homeTeamId':
                                                                      doc['homeTeamId'],
                                                                  'awayTeamId':
                                                                      doc['awayTeamId'],
                                                                  'uid': FirebaseAuth
                                                                      .instance
                                                                      .currentUser!
                                                                      .uid,
                                                                  'byUser':
                                                                      false,
                                                                });
                                                              }
                                                            }
                                                          })))
                                          .then((value) => setState(() {}));
                                    }
                                  },
                                  icon: snapshot.data == true
                                      ? const Icon(
                                          Icons.favorite,
                                        )
                                      : const Icon(Icons.favorite_border),
                                  color: Colors.pink[800],
                                  iconSize: 30)
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            );
          }
        });
  }

  Future<bool> _checkUserFollowedMatch(int matchId) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('followedMatch')
        .where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .where('matchId', isEqualTo: matchId)
        .get();

    return querySnapshot.docs.isNotEmpty;
  }

  Future<bool> _checkUserFavoriteTeam(int teamId) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('favoritedTeam')
        .where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .where('teamId', isEqualTo: teamId)
        .get();

    return querySnapshot.docs.isNotEmpty;
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
              futureAllTeams = fetchAllTeams();
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
}
