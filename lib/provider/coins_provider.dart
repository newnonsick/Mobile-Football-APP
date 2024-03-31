import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CoinModel extends ChangeNotifier {
  int _coins = 0;

  int get coins => _coins;

  Future<void> fetchCoin() async {
    try {
      var snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .get();

      if (snapshot.docs.isNotEmpty) {
        _coins = snapshot.docs[0].data()['coins'] as int;
        notifyListeners();
      }
    } catch (error) {
      print('Error fetching coin data: $error');
    }
  }

  void increment() {
    _coins++;
    notifyListeners();
  }

  void decrement(int value) {
    if (_coins >= value) {
      _coins -= value;
      notifyListeners();
    } else {
      print('Not enough coins to decrement');
      // Handle the case where there are not enough coins
    }
  }

  void setCoins(int value) {
    _coins = value;
    notifyListeners();
  }


}
