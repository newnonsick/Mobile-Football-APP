import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:project/page/matchinfopage.dart';
import 'package:project/widget/pictureupcoming.dart';
import 'package:project/widget/sharesheet.dart';

class UpcomingMatchesItem extends StatefulWidget {
  final Map match;
  const UpcomingMatchesItem({super.key, required this.match});

  @override
  State<UpcomingMatchesItem> createState() => _UpcomingMatchesItemState();
}

class _UpcomingMatchesItemState extends State<UpcomingMatchesItem>
    with SingleTickerProviderStateMixin {
  late Animation<Color?> _loadingAnimation;
  late AnimationController _loadingController;

  @override
  void initState() {
    super.initState();
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
    DateTime utcDate = DateTime.parse(widget.match['utcDate']);
    String formattedDate = DateFormat('dd MMM yyyy').format(utcDate.toLocal());
    String formattedTime = DateFormat('HH:mm').format(utcDate.toLocal());

    String crestHomeUrl = '${widget.match['homeTeam']['crest']}';
    Widget crestHomeWidget;
    String crestAwayUrl = '${widget.match['awayTeam']['crest']}';
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
      future: _checkIfFollowing(widget.match['id']),
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
            endActionPane: ActionPane(motion: const StretchMotion(), children: [
              SlidableAction(
                onPressed: (context) {
                  if (snapshot.data == true) {
                    FirebaseFirestore.instance
                        .collection('followedMatch')
                        .where('matchId', isEqualTo: widget.match['id'])
                        .get()
                        .then((value) async {
                      if (value.docs.isNotEmpty) {
                        final querySnapshot = await FirebaseFirestore.instance
                            .collection('followedMatch')
                            .where('matchId', isEqualTo: widget.match['id'])
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
                    FirebaseFirestore.instance.collection('followedMatch').add({
                      'matchId': widget.match['id'],
                      'uid': FirebaseAuth.instance.currentUser!.uid,
                      'homeTeamId': widget.match['homeTeam']['id'],
                      'awayTeamId': widget.match['awayTeam']['id'],
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
                          child: PictureUpcoming(match: widget.match)));
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
                    match: widget.match,
                  ),
                  transition: Transition.rightToLeft,
                )
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0),
                  border: Border(
                    top: BorderSide(
                      color: Colors.pink[800]!,
                      width: 5,
                    ),
                  ),
                  color: Colors.white,
                ),
                width: double.infinity,
                height: 105.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      width: 108,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                              width: 55, height: 55, child: crestHomeWidget),
                          const SizedBox(height: 5.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                widget.match['homeTeam']['shortName'],
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
                        const Text('VS',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
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
                      width: 108,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                              width: 55, height: 55, child: crestAwayWidget),
                          const SizedBox(height: 5.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                widget.match['awayTeam']['shortName'],
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
            ),
          );
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

  Widget _buildPictureWidget() {
    return Container();
  }
}
