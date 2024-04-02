import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:project/provider/coins_provider.dart';
import 'package:provider/provider.dart';

class BetSystem extends StatefulWidget {
  final Map match;
  const BetSystem({super.key, required this.match});

  @override
  State<BetSystem> createState() => _BetSystemState();
}

class _BetSystemState extends State<BetSystem> {
  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance
        .collection('guesses')
        .where('matchId', isEqualTo: widget.match['id'])
        .snapshots()
        .listen((event) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: fecthMatchGuess(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              padding: const EdgeInsets.all(20),
              height: 510,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else if (snapshot.hasError) {
            return Container(
                padding: const EdgeInsets.all(20),
                height: 510,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
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
                        setState(() {});
                      },
                      child: Text(
                        'Retry',
                        style: TextStyle(color: Colors.pink[800]),
                      ),
                    ),
                  ],
                ));
          } else {
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
                      Row(
                        children: [
                          Text(
                            'Bet 1X2',
                            style: TextStyle(
                                color: Colors.pink[800],
                                fontSize: 25,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 5,
                                  spreadRadius: 0.5,
                                ),
                              ],
                            ),
                            child: Consumer<CoinModel>(
                              builder: (context, model, child) => Text(
                                '${model.coins}',
                                style: TextStyle(
                                  color: Colors.pink[800],
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          const Text('coins',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              )),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Haft time',
                        style: TextStyle(
                            color: Colors.pink[800],
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 70,
                            child: Text(
                              "${widget.match['homeTeam']['tla']}: ",
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          SizedBox(
                            height: 30,
                            width: MediaQuery.of(context).size.width * 0.5,
                            child: LinearPercentIndicator(
                              lineHeight: 15,
                              percent: snapshot.data!['totalHafttimeGuess'] == 0
                                  ? 0
                                  : snapshot.data!['totalHafttimeHomeGuess'] /
                                      snapshot.data!['totalHafttimeGuess'],
                              progressColor: Colors.pink[800],
                              backgroundColor: Colors.grey[300],
                              animation: true,
                              animationDuration: 1000,
                              barRadius: const Radius.circular(20),
                            ),
                          ),
                          Text(
                            _formatCoins(
                                snapshot.data!['totalHafttimeHomeGuess']),
                            style: const TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const SizedBox(
                            width: 70,
                            child: Text(
                              "DRAW: ",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          SizedBox(
                            height: 30,
                            width: MediaQuery.of(context).size.width * 0.5,
                            child: LinearPercentIndicator(
                              lineHeight: 15,
                              percent: snapshot.data!['totalHafttimeGuess'] == 0
                                  ? 0
                                  : snapshot.data!['totalHafttimeDrawGuess'] /
                                      snapshot.data!['totalHafttimeGuess'],
                              progressColor: Colors.pink[800],
                              backgroundColor: Colors.grey[300],
                              animation: true,
                              animationDuration: 1000,
                              barRadius: const Radius.circular(20),
                            ),
                          ),
                          Text(
                            _formatCoins(
                                snapshot.data!['totalHafttimeDrawGuess']),
                            style: const TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 70,
                            child: Text(
                              "${widget.match['awayTeam']['tla']}: ",
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          SizedBox(
                            height: 30,
                            width: MediaQuery.of(context).size.width * 0.5,
                            child: LinearPercentIndicator(
                              lineHeight: 15,
                              percent: snapshot.data!['totalHafttimeGuess'] == 0
                                  ? 0
                                  : snapshot.data!['totalHafttimeAwayGuess'] /
                                      snapshot.data!['totalHafttimeGuess'],
                              progressColor: Colors.pink[800],
                              backgroundColor: Colors.grey[300],
                              animation: true,
                              animationDuration: 1000,
                              barRadius: const Radius.circular(20),
                            ),
                          ),
                          Text(
                            _formatCoins(
                                snapshot.data!['totalHafttimeAwayGuess']),
                            style: const TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            'Your Bet: ',
                            style: TextStyle(
                                color: Colors.pink[800],
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            _formatCoins(snapshot.data!['userHalfTimeGuess']),
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
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              backgroundColor: ((snapshot
                                                  .data!['userGuessHafttime'] ==
                                              'home' ||
                                          snapshot.data!['userGuessHafttime'] ==
                                              '') &&
                                      widget.match['status'] == 'TIMED')
                                  ? Colors.pink[800]
                                  : Colors.grey,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () {
                              if ((snapshot.data!['userGuessHafttime'] ==
                                          'home' ||
                                      snapshot.data!['userGuessHafttime'] ==
                                          '') &&
                                  widget.match['status'] == 'TIMED') {
                                _showDialog(context, 'hafttime', 'home');
                              }
                            },
                            child: Text(
                              widget.match['homeTeam']['tla'],
                              style: const TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              backgroundColor: ((snapshot
                                                  .data!['userGuessHafttime'] ==
                                              'draw' ||
                                          snapshot.data!['userGuessHafttime'] ==
                                              '') &&
                                      widget.match['status'] == 'TIMED')
                                  ? Colors.pink[800]
                                  : Colors.grey,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () {
                              if ((snapshot.data!['userGuessHafttime'] ==
                                          'draw' ||
                                      snapshot.data!['userGuessHafttime'] ==
                                          '') &&
                                  widget.match['status'] == 'TIMED') {
                                _showDialog(context, 'hafttime', 'draw');
                              }
                            },
                            child: const Text(
                              'DRAW',
                              style: TextStyle(fontSize: 15),
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              backgroundColor: ((snapshot
                                                  .data!['userGuessHafttime'] ==
                                              'away' ||
                                          snapshot.data!['userGuessHafttime'] ==
                                              '') &&
                                      widget.match['status'] == 'TIMED')
                                  ? Colors.pink[800]
                                  : Colors.grey,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () {
                              if ((snapshot.data!['userGuessHafttime'] ==
                                          'away' ||
                                      snapshot.data!['userGuessHafttime'] ==
                                          '') &&
                                  widget.match['status'] == 'TIMED') {
                                _showDialog(context, 'hafttime', 'away');
                              }
                            },
                            child: Text(
                              widget.match['awayTeam']['tla'],
                              style: const TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Full time',
                        style: TextStyle(
                            color: Colors.pink[800],
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 70,
                            child: Text(
                              "${widget.match['homeTeam']['tla']}: ",
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          SizedBox(
                            height: 30,
                            width: MediaQuery.of(context).size.width * 0.5,
                            child: LinearPercentIndicator(
                              lineHeight: 15,
                              percent: snapshot.data!['totalFulltimeGuess'] == 0
                                  ? 0
                                  : snapshot.data!['totalFulltimeHomeGuess'] /
                                      snapshot.data!['totalFulltimeGuess'],
                              progressColor: Colors.pink[800],
                              backgroundColor: Colors.grey[300],
                              animation: true,
                              animationDuration: 1000,
                              barRadius: const Radius.circular(20),
                            ),
                          ),
                          Text(
                            _formatCoins(
                                snapshot.data!['totalFulltimeHomeGuess']),
                            style: const TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const SizedBox(
                            width: 70,
                            child: Text(
                              "DRAW: ",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          SizedBox(
                            height: 30,
                            width: MediaQuery.of(context).size.width * 0.5,
                            child: LinearPercentIndicator(
                              lineHeight: 15,
                              percent: snapshot.data!['totalFulltimeGuess'] == 0
                                  ? 0
                                  : snapshot.data!['totalFulltimeDrawGuess'] /
                                      snapshot.data!['totalFulltimeGuess'],
                              progressColor: Colors.pink[800],
                              backgroundColor: Colors.grey[300],
                              animation: true,
                              animationDuration: 1000,
                              barRadius: const Radius.circular(20),
                            ),
                          ),
                          Text(
                            _formatCoins(
                                snapshot.data!['totalFulltimeDrawGuess']),
                            style: const TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 70,
                            child: Text(
                              "${widget.match['awayTeam']['tla']}: ",
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          SizedBox(
                            height: 30,
                            width: MediaQuery.of(context).size.width * 0.5,
                            child: LinearPercentIndicator(
                              lineHeight: 15,
                              percent: snapshot.data!['totalFulltimeGuess'] == 0
                                  ? 0
                                  : snapshot.data!['totalFulltimeAwayGuess'] /
                                      snapshot.data!['totalFulltimeGuess'],
                              progressColor: Colors.pink[800],
                              backgroundColor: Colors.grey[300],
                              animation: true,
                              animationDuration: 1000,
                              barRadius: const Radius.circular(20),
                            ),
                          ),
                          Text(
                            _formatCoins(
                                snapshot.data!['totalFulltimeAwayGuess']),
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
                          Text(
                            'Your Bet: ',
                            style: TextStyle(
                                color: Colors.pink[800],
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            _formatCoins(snapshot.data!['userFullTimeGuess']),
                            style: const TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              backgroundColor: ((snapshot
                                                  .data!['userGuessFulltime'] ==
                                              'home' ||
                                          snapshot.data!['userGuessFulltime'] ==
                                              '') &&
                                      widget.match['status'] == 'TIMED')
                                  ? Colors.pink[800]
                                  : Colors.grey,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () {
                              if ((snapshot.data!['userGuessFulltime'] ==
                                          'home' ||
                                      snapshot.data!['userGuessFulltime'] ==
                                          '') &&
                                  widget.match['status'] == 'TIMED') {
                                _showDialog(context, 'fulltime', 'home');
                              }
                            },
                            child: Text(
                              widget.match['homeTeam']['tla'],
                              style: const TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              backgroundColor: ((snapshot
                                                  .data!['userGuessFulltime'] ==
                                              'draw' ||
                                          snapshot.data!['userGuessFulltime'] ==
                                              '') &&
                                      widget.match['status'] == 'TIMED')
                                  ? Colors.pink[800]
                                  : Colors.grey,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () {
                              if ((snapshot.data!['userGuessFulltime'] ==
                                          'draw' ||
                                      snapshot.data!['userGuessFulltime'] ==
                                          '') &&
                                  widget.match['status'] == 'TIMED') {
                                _showDialog(context, 'fulltime', 'draw');
                              }
                            },
                            child: const Text(
                              'DRAW',
                              style: TextStyle(fontSize: 15),
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              backgroundColor: ((snapshot
                                                  .data!['userGuessFulltime'] ==
                                              'away' ||
                                          snapshot.data!['userGuessFulltime'] ==
                                              '') &&
                                      widget.match['status'] == 'TIMED')
                                  ? Colors.pink[800]
                                  : Colors.grey,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () async {
                              if ((snapshot.data!['userGuessFulltime'] ==
                                          'away' ||
                                      snapshot.data!['userGuessFulltime'] ==
                                          '') &&
                                  widget.match['status'] == 'TIMED') {
                                await _showDialog(context, 'fulltime', 'away');
                              }
                            },
                            child: Text(
                              widget.match['awayTeam']['tla'],
                              style: const TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            );
          }
        });
  }

  Future<Map<String, dynamic>> fecthMatchGuess() async {
    final guessData = await FirebaseFirestore.instance
        .collection('guesses')
        .where('matchId', isEqualTo: widget.match['id'])
        .get()
        .then((value) => value.docs);

    int totalHafttimeHomeGuess = 0;
    int totalHafttimeAwayGuess = 0;
    int totalHafttimeDrawGuess = 0;
    int totalFulltimeHomeGuess = 0;
    int totalFulltimeAwayGuess = 0;
    int totalFulltimeDrawGuess = 0;
    int userHalfTimeGuess = 0;
    int userFullTimeGuess = 0;

    String userGuessHafttime = '';
    String userGuessFulltime = '';

    for (var guess in guessData) {
      if (guess['choice'] == 'hafttime') {
        if (guess['result'] == 'home') {
          totalHafttimeHomeGuess += guess['amount'] as int;
        } else if (guess['result'] == 'away') {
          totalHafttimeAwayGuess += guess['amount'] as int;
        } else if (guess['result'] == 'draw') {
          totalHafttimeDrawGuess += guess['amount'] as int;
        }
      } else if (guess['choice'] == 'fulltime') {
        if (guess['result'] == 'home') {
          totalFulltimeHomeGuess += guess['amount'] as int;
        } else if (guess['result'] == 'away') {
          totalFulltimeAwayGuess += guess['amount'] as int;
        } else if (guess['result'] == 'draw') {
          totalFulltimeDrawGuess += guess['amount'] as int;
        }
      }
    }

    var datauserguess = guessData.where(
        (element) => element['uid'] == FirebaseAuth.instance.currentUser!.uid);

    for (var guess in datauserguess) {
      if (guess['choice'] == 'hafttime') {
        userGuessHafttime = guess['result'];
        userHalfTimeGuess = guess['amount'] as int;
      } else if (guess['choice'] == 'fulltime') {
        userGuessFulltime = guess['result'];
        userFullTimeGuess = guess['amount'] as int;
      }
    }

    return {
      'totalHafttimeGuess': totalHafttimeHomeGuess +
          totalHafttimeAwayGuess +
          totalHafttimeDrawGuess,
      'totalHafttimeHomeGuess': totalHafttimeHomeGuess,
      'totalHafttimeAwayGuess': totalHafttimeAwayGuess,
      'totalHafttimeDrawGuess': totalHafttimeDrawGuess,
      'totalFulltimeGuess': totalFulltimeHomeGuess +
          totalFulltimeAwayGuess +
          totalFulltimeDrawGuess,
      'totalFulltimeHomeGuess': totalFulltimeHomeGuess,
      'totalFulltimeAwayGuess': totalFulltimeAwayGuess,
      'totalFulltimeDrawGuess': totalFulltimeDrawGuess,
      'userGuessHafttime': userGuessHafttime,
      'userGuessFulltime': userGuessFulltime,
      'userHalfTimeGuess': userHalfTimeGuess,
      'userFullTimeGuess': userFullTimeGuess,
    };
  }

  String _formatCoins(int coins) {
    if (coins >= 100000000000000) {
      return '${(coins / 1000000000000).toStringAsFixed(1)}T';
    } else if (coins >= 10000000000000) {
      return '${(coins / 1000000000000).toStringAsFixed(0)}T';
    } else if (coins >= 1000000000000) {
      return '${(coins / 1000000000000).toStringAsFixed(1)}T';
    } else if (coins >= 10000000000) {
      return '${(coins / 1000000000).toStringAsFixed(0)}B';
    } else if (coins >= 1000000000) {
      return '${(coins / 1000000000).toStringAsFixed(1)}B';
    } else if (coins >= 10000000) {
      return '${(coins / 1000000).toStringAsFixed(0)}M';
    } else if (coins >= 1000000) {
      return '${(coins / 1000000).toStringAsFixed(1)}M';
    } else if (coins >= 10000) {
      return '${(coins / 1000).toStringAsFixed(0)}K';
    } else if (coins >= 1000) {
      return '${(coins / 1000).toStringAsFixed(1)}K';
    } else {
      return '$coins';
    }
  }

  Future<void> guessMatch(
      int matchId, String choice, String result, int amount) async {
    var data = await FirebaseFirestore.instance
        .collection('guesses')
        .where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .where('choice', isEqualTo: choice)
        .where('result', isEqualTo: result)
        .where('matchId', isEqualTo: matchId)
        .get()
        .then((value) => value.docs);

    if (data.isEmpty) {
      var db = FirebaseFirestore.instance.collection('guesses');
      await db.add({
        'amount': amount,
        "choice": choice,
        'result': result,
        'uid': FirebaseAuth.instance.currentUser!.uid,
        'matchId': matchId,
        'status': 'active'
      });
    } else {
      var db = data[0].reference;
      await db.update({'amount': data[0]['amount'] + amount});
    }

    Provider.of<CoinModel>(context, listen: false).decrement(amount);
  }

  Future _showDialog(BuildContext context, String choice, String result) async {
    final TextEditingController amountController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return showDialog(
        context: context,
        builder: (context) {
          return Consumer<CoinModel>(
            builder: (context, model, child) => AlertDialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              title: const Text('Bet'),
              content: Form(
                key: formKey,
                child: TextFormField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter amount';
                    }
                    if (int.parse(value) > model.coins) {
                      return 'Not enough coins';
                    }
                    return null;
                  },
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Get.back();
                  },
                  child: const Text('Cancel',
                      style: TextStyle(color: Colors.black)),
                ),
                TextButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      await guessMatch(widget.match['id'], choice, result,
                          int.parse(amountController.text));
                      Get.back();
                      setState(() {});
                    }
                  },
                  child: Text('Bet', style: TextStyle(color: Colors.pink[800])),
                ),
              ],
            ),
          );
        });
  }
}
