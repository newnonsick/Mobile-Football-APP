import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _isFollowingFuture = _checkIfFollowing(widget.match['id']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
          child: Column(
            children: [
              _buildTopSection(),
              const SizedBox(height: 10),
              const Spacer(),
              _buildfooterSection()
            ],
          ),
        ));
  }

  Widget _buildTopSection() {
    return Column(
      children: [
        Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height / 3,
              decoration: const BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20))),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildfooterSection() {
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
                    backgroundColor: widget.match['status'] == 'FINISHED'
                        ? Colors.grey
                        : Colors.pink[800],
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    if (widget.match['status'] == 'FINISHED') {
                      return;
                    }

                    if (isFollowing) {
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
                        setState(() {
                          _isFollowingFuture =
                              _checkIfFollowing(widget.match['id']);
                        });
                      });
                    } else {
                      FirebaseFirestore.instance
                          .collection('followedMatch')
                          .add({
                        'matchId': widget.match['id'],
                        'homeTeamId': widget.match['homeTeam']['id'],
                        'awayTeamId': widget.match['awayTeam']['id'],
                        'uid': FirebaseAuth.instance.currentUser!.uid,
                        'byUser': true,
                      }).then((value) {
                        setState(() {
                          _isFollowingFuture =
                              _checkIfFollowing(widget.match['id']);
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
                    builder: (context) => widget.match['status'] == 'TIMED'
                        ? ShareSheet(
                            child: PictureUpcoming(match: widget.match))
                        : ShareSheet(
                            child: PictureLiveAndFinish(match: widget.match)));
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
