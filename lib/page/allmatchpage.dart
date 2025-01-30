import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:project/page/matchinfopage.dart';
import 'package:project/widget/finishedmatchitem.dart';
import 'package:project/widget/pictureliveandfinish.dart';
import 'package:project/widget/sharesheet.dart';
import 'package:project/widget/upcomingmatchitem.dart';
import '../api/matchesofday_api.dart';
// import 'api/allmatches_api.dart';

class AllMatchPage extends StatefulWidget {
  const AllMatchPage({super.key});

  @override
  State<AllMatchPage> createState() => _AllMatchPageState();
}

class _AllMatchPageState extends State<AllMatchPage>
    with SingleTickerProviderStateMixin {
  late DateTime selectedDate;
  // late Future<AllMatches> futureAllMatches;
  late Future<MatchesOfDay> futureMatchesOfDay;
  late AnimationController _loadingController;
  late Animation<Color?> _loadingAnimation;

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
    // futureAllMatches = fetchAllMatches();
    futureMatchesOfDay = fetchMatchesOfDay(
        DateFormat('yyyy-MM-dd').format(selectedDate),
        selectedDate.timeZoneOffset.toString());

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

  Future<void> _showDatePicker(BuildContext context) async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(DateTime.now().year - 1),
      lastDate: DateTime(DateTime.now().year + 1),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.pink[800]!,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (date != null) {
      setState(() {
        selectedDate = date;
        futureMatchesOfDay = fetchMatchesOfDay(
            DateFormat('yyyy-MM-dd').format(selectedDate),
            selectedDate.timeZoneOffset.toString());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text(
          'All Matches',
          style: TextStyle(
            color: Colors.pink[800],
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Matches',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20.0,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        DateFormat('dd MMM yyyy').format(selectedDate),
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                        ),
                      ),
                      TextButton(
                        onPressed: () => _showDatePicker(context),
                        child: Text(
                          'Select Date',
                          style:
                              TextStyle(color: Colors.pink[800], fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10.0),
              _buildAllMatches(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAllMatches() {
    return FutureBuilder(
      future: futureMatchesOfDay,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Expanded(
            child: ListView.builder(
              itemCount: 5,
              itemBuilder: (context, index) {
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
              },
            ),
          );
        } else if (snapshot.hasError) {
          return Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
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
                          futureMatchesOfDay = fetchMatchesOfDay(
                              DateFormat('yyyy-MM-dd').format(selectedDate),
                              selectedDate.timeZoneOffset.toString());
                          // futureAllMatches = fetchAllMatches();
                        });
                      },
                      child: Text(
                        'Retry',
                        style: TextStyle(color: Colors.pink[800]),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        } else if (snapshot.hasData) {
          if (snapshot.data!.matches.isEmpty) {
            return Container();
          } else {
            return Expanded(
              child: ListView.builder(
                itemCount: snapshot.data!.matches.length,
                itemBuilder: (context, index) {
                  return snapshot.data!.matches[index]['status'] == 'FINISHED'
                      ? Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
                          child: FinishedMatchItem(
                              match: snapshot.data!.matches[index]),
                        )
                      : ['LIVE', 'IN_PLAY', 'PAUSED']
                              .contains(snapshot.data!.matches[index]['status'])
                          ? Padding(
                              padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
                              child: _buildLiveMatchItem(
                                  snapshot.data!.matches[index]),
                            )
                          : [
                              'SCHEDULED',
                              'TIMED'
                            ].contains(snapshot.data!.matches[index]['status'])
                              ? Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 0, 0, 5),
                                  child: UpcomingMatchesItem(
                                      match: snapshot.data!.matches[index]),
                                )
                              : const SizedBox.shrink();
                },
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
    DateTime utcDate = DateTime.parse(match['utcDate']);
    String formattedDate = DateFormat('dd MMM yyyy').format(utcDate.toLocal());

    String crestHomeUrl = '${match['homeTeam']['crest']}';
    Widget crestHomeWidget;
    String crestAwayUrl = '${match['awayTeam']['crest']}';
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

    return FutureBuilder(
        future: _checkIfFollowing(match['id']),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
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
          } else {
            return Slidable(
                endActionPane:
                    ActionPane(motion: const StretchMotion(), children: [
                  SlidableAction(
                    onPressed: (context) {
                      if (snapshot.data == true) {
                        FirebaseFirestore.instance
                            .collection('followedMatch')
                            .where('matchId', isEqualTo: match['id'])
                            .get()
                            .then((value) async {
                          if (value.docs.isNotEmpty) {
                            final querySnapshot = await FirebaseFirestore
                                .instance
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
                          setState(() {});
                        });
                      } else {
                        FirebaseFirestore.instance
                            .collection('followedMatch')
                            .add({
                          'matchId': match['id'],
                          'uid': FirebaseAuth.instance.currentUser!.uid,
                          'homeTeamId': match['homeTeam']['id'],
                          'awayTeamId': match['awayTeam']['id'],
                          'byUser': true,
                        }).then((value) {
                          setState(() {});
                        });
                      }
                    },
                    backgroundColor:
                        snapshot.data == true ? Colors.red : Colors.green,
                    icon: snapshot.data == true
                        ? Icons.notifications_off
                        : Icons.notification_add,
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  SlidableAction(
                    onPressed: (context) {
                      showModalBottomSheet(
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          context: context,
                          builder: (context) => ShareSheet(
                              child: PictureLiveAndFinish(match: match)));
                    },
                    backgroundColor: Colors.blue,
                    icon: Icons.share,
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ]),
                child: InkWell(
                  onTap: () => {
                    Get.to(
                      () => MatchInfoPage(
                        match: match,
                      ),
                      transition: Transition.rightToLeft,
                    )
                  },
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(2, 5, 2, 5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0),
                      border: const Border(
                        top: BorderSide(
                          color: Colors.green,
                          width: 5,
                        ),
                      ),
                      color: Colors.white,
                    ),
                    width: double.infinity,
                    height: 100.0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(
                          width: 105,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                  width: 55,
                                  height: 55,
                                  child: crestHomeWidget),
                              const SizedBox(height: 5.0),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    match['homeTeam']['shortName'],
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('LIVE',
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white))
                                .animate(
                                    onPlay: (controller) =>
                                        controller.repeat(reverse: true))
                                .tint(
                                    color: const Color.fromRGBO(0, 100, 0, 1),
                                    delay: 2000.ms,
                                    curve: Curves.easeInOut,
                                    duration: 600.ms),
                            Container(
                              padding: const EdgeInsets.fromLTRB(2, 0, 2, 0),
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
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(height: 5.0),
                            Text(
                              formattedDate,
                              style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey),
                            ),
                          ],
                        ),
                        SizedBox(
                          width: 105,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                  width: 55,
                                  height: 55,
                                  child: crestAwayWidget),
                              const SizedBox(height: 5.0),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    match['awayTeam']['shortName'],
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ));
          }
        });
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
