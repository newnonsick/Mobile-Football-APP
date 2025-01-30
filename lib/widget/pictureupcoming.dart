import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

class PictureUpcoming extends StatelessWidget {
  final Map match;
  const PictureUpcoming({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    DateTime utcDate = DateTime.parse(match['utcDate']);
    String formattedDate = DateFormat('dd MMMM yyyy').format(utcDate.toLocal());
    String formattedTime = DateFormat('HH:mm').format(utcDate.toLocal());

    String crestHomeUrl = '${match['homeTeam']['crest']}';
    Widget crestHomeWidget;
    String crestAwayUrl = '${match['awayTeam']['crest']}';
    Widget crestAwayWidget;

    if (crestHomeUrl.endsWith('.svg')) {
      crestHomeWidget = SvgPicture.network(
        crestHomeUrl,
        width: 100,
        height: 100,
        fit: BoxFit.contain,
      );
    } else {
      crestHomeWidget = Image.network(
        crestHomeUrl,
        width: 100,
        height: 100,
        fit: BoxFit.contain,
      );
    }

    if (crestAwayUrl.endsWith('.svg')) {
      crestAwayWidget = SvgPicture.network(
        crestAwayUrl,
        width: 100,
        height: 100,
        fit: BoxFit.contain,
      );
    } else {
      crestAwayWidget = Image.network(
        crestAwayUrl,
        width: 100,
        height: 100,
        fit: BoxFit.contain,
      );
    }

    return Stack(
      children: [
        Container(
            width: 420,
            height: 290,
            decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('assets/images/team_background.jpg'),
                    fit: BoxFit.cover,
                    opacity: 0.9)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SizedBox(
                      width: 108,
                      child: Column(
                        children: [
                          crestHomeWidget,
                          const SizedBox(height: 10),
                          Text(match['homeTeam']['shortName'],
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Kanit')),
                        ],
                      ),
                    ),
                    Image.asset(
                      'assets/images/vs.png',
                      width: 100,
                      height: 100,
                      fit: BoxFit.contain,
                      color: Colors.black,
                    ),
                    SizedBox(
                      width: 108,
                      child: Column(
                        children: [
                          crestAwayWidget,
                          const SizedBox(height: 10),
                          Text(match['awayTeam']['shortName'],
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Kanit')),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(formattedDate,
                        style: const TextStyle(
                            color: Colors.black,
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Kanit')),
                    const SizedBox(width: 10),
                    Text(formattedTime,
                        style: TextStyle(
                            color: Colors.pink[800],
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Kanit')),
                  ],
                ),
                const Text('Premier League',
                    style: TextStyle(color: Colors.black, fontFamily: 'Kanit')),
              ],
            )),
        Positioned(
            right: 10,
            left: 10,
            bottom: 10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Powered by ',
                    style: TextStyle(
                        color: Colors.grey, fontSize: 10, fontFamily: 'Kanit')),
                const Text('LiveScore ',
                    style: TextStyle(
                        color: Colors.pink, fontSize: 10, fontFamily: 'Kanit')),
                Image.asset('assets/images/logo.png',
                    width: 15, height: 15, fit: BoxFit.contain)
              ],
            ))
      ],
    );
  }
}
