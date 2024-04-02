import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:project/widget/betsystemitem.dart';
import 'package:project/widget/pictureliveandfinish.dart';
import 'package:project/widget/pictureupcoming.dart';
import 'package:project/widget/sharesheet.dart';

class MatchInfoPage extends StatefulWidget {
  final Map match;

  const MatchInfoPage({super.key, required this.match});

  @override
  State<MatchInfoPage> createState() => _MatchInfoPageState();
}

class _MatchInfoPageState extends State<MatchInfoPage> {
  late Future<bool> _isFollowingFuture;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _isFollowingFuture = _checkIfFollowing(widget.match['id']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        SafeArea(
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: Column(
                      children: [
                        widget.match['status'] == 'TIMED'
                            ? _buildUpcomingTopSection()
                            : _buildLiveAndFinishTopSection(),
                        const SizedBox(height: 20),
                        _buildMatchInfoSection(),
                        const SizedBox(height: 20),
                        _buildScoreSection(),
                        const SizedBox(height: 20),
                        BetSystem(match: widget.match),
                      ],
                    ),
                  ),
                ),
                _buildfooterSection()
              ],
            ),
          ),
        ),
        SafeArea(
          child: Opacity(
            opacity: 0.7,
            child: Container(
              margin: const EdgeInsets.only(left: 15),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(50),
              ),
              child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_rounded),
                  onPressed: () {
                    Get.back();
                  }),
            ),
          ),
        ),
      ],
    ));
  }

  Widget _buildLiveAndFinishTopSection() {
    String crestHomeUrl =
        'https://corsproxy.io/?${widget.match['homeTeam']['crest']}';
    Widget crestHomeWidget;
    String crestAwayUrl =
        'https://corsproxy.io/?${widget.match['awayTeam']['crest']}';
    Widget crestAwayWidget;

    if (crestHomeUrl.endsWith('.svg')) {
      crestHomeWidget = SvgPicture.network(
        crestHomeUrl,
        width: 110,
        height: 110,
        fit: BoxFit.contain,
      );
    } else {
      crestHomeWidget = Image.network(
        crestHomeUrl,
        width: 110,
        height: 110,
        fit: BoxFit.contain,
      );
    }

    if (crestAwayUrl.endsWith('.svg')) {
      crestAwayWidget = SvgPicture.network(
        crestAwayUrl,
        width: 110,
        height: 110,
        fit: BoxFit.contain,
      );
    } else {
      crestAwayWidget = Image.network(
        crestAwayUrl,
        width: 110,
        height: 110,
        fit: BoxFit.contain,
      );
    }

    bool isHomeWinner = widget.match['score']['fullTime']['home'] >
        widget.match['score']['fullTime']['away'];

    bool isAwayWinner = widget.match['score']['fullTime']['home'] <
        widget.match['score']['fullTime']['away'];

    bool isDraw = widget.match['score']['fullTime']['home'] ==
        widget.match['score']['fullTime']['away'];

    return Column(
      children: [
        Column(
          children: [
            Container(
              height: 290,
              decoration: BoxDecoration(
                  image: const DecorationImage(
                    image: AssetImage('assets/images/team_background.jpg'),
                    opacity: 0.9,
                    fit: BoxFit.cover,
                  ),
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 3,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ]),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                        width: 115,
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              isHomeWinner
                                  ? Image.asset('assets/images/crown.png',
                                      width: 50, height: 50)
                                  : isDraw
                                      ? Image.asset(
                                          'assets/images/home_broken_crown.png',
                                          width: 50,
                                          height: 50)
                                      : const SizedBox(width: 50, height: 50),
                              SizedBox(
                                  height: 110.0,
                                  width: 110.0,
                                  child: crestHomeWidget),
                              const SizedBox(height: 10.0),
                              Text(widget.match['homeTeam']['shortName'],
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold))
                            ]),
                      ),
                      Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              height: 20,
                            ),
                            RichText(
                                text: TextSpan(children: [
                              const TextSpan(
                                  text: '▶▶ ',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey,
                                      fontFamily: 'Kanit')),
                              TextSpan(
                                  text: widget.match['status'] == 'FINISHED'
                                      ? 'FT'
                                      : 'LIVE',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          widget.match['status'] == 'FINISHED'
                                              ? Colors.grey
                                              : Colors.green,
                                      fontFamily: 'Kanit')),
                              const TextSpan(
                                  text: ' ◀◀',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey,
                                      fontFamily: 'Kanit')),
                            ])),
                            RichText(
                                text: TextSpan(children: <TextSpan>[
                              TextSpan(
                                  text:
                                      '${widget.match['score']['fullTime']['home']}',
                                  style: TextStyle(
                                      fontSize: 45,
                                      fontWeight: FontWeight.bold,
                                      color: isHomeWinner
                                          ? Colors.pink[800]
                                          : Colors.black,
                                      fontFamily: 'Kanit')),
                              const TextSpan(
                                  text: ' - ',
                                  style: TextStyle(
                                      fontSize: 45,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      fontFamily: 'Kanit')),
                              TextSpan(
                                  text:
                                      '${widget.match['score']['fullTime']['away']}',
                                  style: TextStyle(
                                      fontSize: 45,
                                      fontWeight: FontWeight.bold,
                                      color: isAwayWinner
                                          ? Colors.pink[800]
                                          : Colors.black,
                                      fontFamily: 'Kanit')),
                            ])),
                            const Text(' ',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                    fontFamily: 'Kanit')),
                          ]),
                      SizedBox(
                        width: 115,
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              isAwayWinner
                                  ? Image.asset('assets/images/crown.png',
                                      width: 50, height: 50)
                                  : isDraw
                                      ? Image.asset(
                                          'assets/images/away_broken_crown.png',
                                          width: 50,
                                          height: 50)
                                      : const SizedBox(width: 50, height: 50),
                              SizedBox(
                                  height: 110.0,
                                  width: 110.0,
                                  child: crestAwayWidget),
                              const SizedBox(height: 10.0),
                              Text(widget.match['awayTeam']['shortName'],
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold)),
                            ]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10.0),
                  widget.match['referees'].isEmpty
                      ? const Text('Referee: TBA')
                      : Text('Referee: ${widget.match['referees'][0]['name']}',
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold)),
                  const Text('Premier League',
                      style:
                          TextStyle(color: Colors.black, fontFamily: 'Kanit')),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUpcomingTopSection() {
    DateTime utcDate = DateTime.parse(widget.match['utcDate']);
    String formattedDate = DateFormat('dd MMMM yyyy').format(utcDate.toLocal());
    String formattedTime = DateFormat('HH:mm').format(utcDate.toLocal());

    String crestHomeUrl =
        'https://corsproxy.io/?${widget.match['homeTeam']['crest']}';
    Widget crestHomeWidget;
    String crestAwayUrl =
        'https://corsproxy.io/?${widget.match['awayTeam']['crest']}';
    Widget crestAwayWidget;

    if (crestHomeUrl.endsWith('.svg')) {
      crestHomeWidget = SvgPicture.network(
        crestHomeUrl,
        width: 110,
        height: 110,
        fit: BoxFit.contain,
      );
    } else {
      crestHomeWidget = Image.network(
        crestHomeUrl,
        width: 110,
        height: 110,
        fit: BoxFit.contain,
      );
    }

    if (crestAwayUrl.endsWith('.svg')) {
      crestAwayWidget = SvgPicture.network(
        crestAwayUrl,
        width: 110,
        height: 110,
        fit: BoxFit.contain,
      );
    } else {
      crestAwayWidget = Image.network(
        crestAwayUrl,
        width: 110,
        height: 110,
        fit: BoxFit.contain,
      );
    }

    return Column(
      children: [
        Column(
          children: [
            Container(
              height: 290,
              decoration: BoxDecoration(
                  image: const DecorationImage(
                    image: AssetImage('assets/images/team_background.jpg'),
                    opacity: 0.9,
                    fit: BoxFit.cover,
                  ),
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 3,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ]),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Premier League',
                      style:
                          TextStyle(color: Colors.grey, fontFamily: 'Kanit')),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                        width: 115,
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                  height: 110.0,
                                  width: 110.0,
                                  child: crestHomeWidget),
                              const SizedBox(height: 10.0),
                              Text(widget.match['homeTeam']['shortName'],
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold))
                            ]),
                      ),
                      Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/images/vs.png',
                              width: 120,
                              height: 120,
                              fit: BoxFit.contain,
                            ),
                          ]),
                      SizedBox(
                        width: 115,
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                  height: 110.0,
                                  width: 110.0,
                                  child: crestAwayWidget),
                              const SizedBox(height: 10.0),
                              Text(widget.match['awayTeam']['shortName'],
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold)),
                            ]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text("$formattedDate $formattedTime",
                      style: const TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Kanit')),
                  widget.match['referees'].isEmpty
                      ? const Text('Referee: TBA',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold))
                      : Text('Referee: ${widget.match['referees'][0]['name']}',
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMatchInfoSection() {
    Map match = widget.match;
    DateTime utcDate = DateTime.parse(match['utcDate']);
    String formattedDate = DateFormat('dd MMMM yyyy').format(utcDate.toLocal());
    String formattedTime = DateFormat('HH:mm').format(utcDate.toLocal());

    String crestHomeUrl =
        'https://corsproxy.io/?${widget.match['homeTeam']['crest']}';
    Widget crestHomeWidget;
    String crestAwayUrl =
        'https://corsproxy.io/?${widget.match['awayTeam']['crest']}';
    Widget crestAwayWidget;

    if (crestHomeUrl.endsWith('.svg')) {
      crestHomeWidget = SvgPicture.network(
        crestHomeUrl,
        width: 30,
        height: 30,
        fit: BoxFit.contain,
      );
    } else {
      crestHomeWidget = Image.network(
        crestHomeUrl,
        width: 30,
        height: 30,
        fit: BoxFit.contain,
      );
    }

    if (crestAwayUrl.endsWith('.svg')) {
      crestAwayWidget = SvgPicture.network(
        crestAwayUrl,
        width: 30,
        height: 30,
        fit: BoxFit.contain,
      );
    } else {
      crestAwayWidget = Image.network(
        crestAwayUrl,
        width: 30,
        height: 30,
        fit: BoxFit.contain,
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Match Information',
                style: TextStyle(
                    color: Colors.pink[800],
                    fontSize: 25,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Text(
                    'Home: ',
                    style: TextStyle(color: Colors.black, fontSize: 20),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    "${match['homeTeam']['shortName']} (${match['homeTeam']['tla']})",
                    style: const TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 10),
                  crestHomeWidget,
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Text(
                    'Away: ',
                    style: TextStyle(color: Colors.black, fontSize: 20),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    "${match['awayTeam']['shortName']} (${match['awayTeam']['tla']})",
                    style: const TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 10),
                  crestAwayWidget,
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Text(
                    'Competition: ',
                    style: TextStyle(color: Colors.black, fontSize: 20),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    "${match['competition']['name']}",
                    style: const TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 10),
                  Image.network(
                      "https://corsproxy.io/?${match['competition']['emblem']}",
                      width: 30,
                      height: 30),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Text(
                    'Referee: ',
                    style: TextStyle(color: Colors.black, fontSize: 20),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    "${match['referees'].isEmpty ? 'TBA' : match['referees'][0]['name']}",
                    style: const TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Text(
                    'Date: ',
                    style: TextStyle(color: Colors.black, fontSize: 20),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    formattedDate,
                    style: const TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Text(
                    'Time: ',
                    style: TextStyle(color: Colors.black, fontSize: 20),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    formattedTime,
                    style: const TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScoreSection() {
    Map match = widget.match;

    bool isHomeWinner = (widget.match['score']['fullTime']['home'] ?? 0) >
        (widget.match['score']['fullTime']['away'] ?? 0);

    bool isAwayWinner = (widget.match['score']['fullTime']['home'] ?? 0) <
        (widget.match['score']['fullTime']['away'] ?? 0);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Score',
                style: TextStyle(
                    color: Colors.pink[800],
                    fontSize: 25,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const SizedBox(
                    width: 90,
                    child: Text(
                      'Haft time: ',
                      style: TextStyle(color: Colors.black, fontSize: 20),
                    ),
                  ),
                  const SizedBox(width: 5),
                  RichText(
                      text: TextSpan(children: <TextSpan>[
                    TextSpan(
                        text: '${match['homeTeam']['tla']} ',
                        style: const TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                    TextSpan(
                        text: '${match['score']['halfTime']['home']}',
                        style: TextStyle(
                            color:
                                isHomeWinner ? Colors.pink[800] : Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                    const TextSpan(
                        text: ' - ',
                        style: TextStyle(color: Colors.black, fontSize: 20)),
                    TextSpan(
                        text: '${match['score']['halfTime']['away']}',
                        style: TextStyle(
                            color:
                                isAwayWinner ? Colors.pink[800] : Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                    TextSpan(
                        text: ' ${match['awayTeam']['tla']}',
                        style: const TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                  ]))
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const SizedBox(
                    width: 90,
                    child: Text(
                      'Full time: ',
                      style: TextStyle(color: Colors.black, fontSize: 20),
                    ),
                  ),
                  const SizedBox(width: 5),
                  RichText(
                      text: TextSpan(children: <TextSpan>[
                    TextSpan(
                        text: '${match['homeTeam']['tla']} ',
                        style: const TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                    TextSpan(
                        text: '${match['score']['fullTime']['home']}',
                        style: TextStyle(
                            color:
                                isHomeWinner ? Colors.pink[800] : Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                    const TextSpan(
                        text: ' - ',
                        style: TextStyle(color: Colors.black, fontSize: 20)),
                    TextSpan(
                        text: '${match['score']['fullTime']['away']}',
                        style: TextStyle(
                            color:
                                isAwayWinner ? Colors.pink[800] : Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                    TextSpan(
                        text: ' ${match['awayTeam']['tla']}',
                        style: const TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                  ]))
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildfooterSection() {
    Map match = widget.match;
    return FutureBuilder<bool>(
      future: _isFollowingFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          final isFollowing = snapshot.data ?? false;
          return Row(children: [
            Expanded(
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    backgroundColor: match['status'] == 'FINISHED'
                        ? Colors.grey
                        : Colors.pink[800],
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    if (match['status'] == 'FINISHED') {
                      return;
                    }

                    if (isFollowing) {
                      FirebaseFirestore.instance
                          .collection('followedMatch')
                          .where('matchId', isEqualTo: match['id'])
                          .get()
                          .then((value) async {
                        if (value.docs.isNotEmpty) {
                          final querySnapshot = await FirebaseFirestore.instance
                              .collection('followedMatch')
                              .where('matchId', isEqualTo: match['id'])
                              .get();

                          final documents = querySnapshot.docs;

                          for (var document in documents) {
                            if (document['uid'].contains(
                                FirebaseAuth.instance.currentUser!.uid)) {
                              await FirebaseFirestore.instance
                                  .collection('followedMatch')
                                  .doc(document.id)
                                  .delete();
                              break;
                            }
                          }
                        }
                      }).then((value) {
                        setState(() {
                          _isFollowingFuture = _checkIfFollowing(match['id']);
                        });
                      });
                    } else {
                      FirebaseFirestore.instance
                          .collection('followedMatch')
                          .add({
                        'matchId': match['id'],
                        'homeTeamId': match['homeTeam']['id'],
                        'awayTeamId': match['awayTeam']['id'],
                        'uid': FirebaseAuth.instance.currentUser!.uid,
                        'byUser': true,
                      }).then((value) {
                        setState(() {
                          _isFollowingFuture = _checkIfFollowing(match['id']);
                        });
                      });
                    }
                  },
                  child: isFollowing
                      ? const Text('Unfollow Match',
                          style: TextStyle(fontSize: 20))
                      : const Text('Follow Match',
                          style: TextStyle(fontSize: 20))),
            ),
            IconButton(
              onPressed: () {
                showModalBottomSheet(
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    context: context,
                    builder: (context) => match['status'] == 'TIMED'
                        ? ShareSheet(child: PictureUpcoming(match: match))
                        : ShareSheet(
                            child: PictureLiveAndFinish(match: match)));
              },
              icon: const Icon(Icons.share),
              color: Colors.pink[800],
              iconSize: 30,
            )
          ]);
        }
      },
    );
  }

  Future<bool> _checkIfFollowing(int matchId) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('followedMatch')
        .where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .where('matchId', isEqualTo: matchId)
        .get();

    return querySnapshot.docs.isNotEmpty;
  }
}
