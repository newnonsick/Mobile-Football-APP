import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class PictureLiveAndFinish extends StatelessWidget {
  final Map<dynamic, dynamic> match;
  const PictureLiveAndFinish({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    String crestHomeUrl = 'https://corsproxy.io/?${match['homeTeam']['crest']}';
    Widget crestHomeWidget;
    String crestAwayUrl = 'https://corsproxy.io/?${match['awayTeam']['crest']}';
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
    bool isHomeWinner =
        match['score']['fullTime']['home'] > match['score']['fullTime']['away'];

    bool isAwayWinner =
        match['score']['fullTime']['home'] < match['score']['fullTime']['away'];

    bool isDraw = match['score']['fullTime']['home'] ==
        match['score']['fullTime']['away'];

    return Stack(
      children: [
        Container(
            width: 420,
            height: 290,
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: const AssetImage(
                        'assets/images/team_background.jpg'),
                    fit: BoxFit.cover,
                    opacity: 0.9
                        )),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SizedBox(
                      width: 108,
                      child: Column(
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
                    Column(
                      children: [
                        const SizedBox(height: 30),
                        Text(
                            '▶▶ ${match['status'] == 'FINISHED' ? 'FT' : 'LIVE'} ◀◀',
                            style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                                fontFamily: 'Kanit')),
                        RichText(
                            text: TextSpan(children: <TextSpan>[
                          TextSpan(
                              text: '${match['score']['fullTime']['home']}',
                              style: TextStyle(
                                  fontSize: 50,
                                  fontWeight: FontWeight.bold,
                                  color: isHomeWinner
                                      ? Colors.pink[800]
                                      : Colors.black,
                                  fontFamily: 'Kanit')),
                          const TextSpan(
                              text: ' - ',
                              style: TextStyle(
                                  fontSize: 50,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontFamily: 'Kanit')),
                          TextSpan(
                              text: '${match['score']['fullTime']['away']}',
                              style: TextStyle(
                                  fontSize: 50,
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
                      ],
                    ),
                    SizedBox(
                      width: 108,
                      child: Column(
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
                const SizedBox(height: 10),
                const Text('Premier League',
                    style: TextStyle(color: Colors.black, fontFamily: 'Kanit')),
                const SizedBox(height: 10),
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
                    style: TextStyle(color: Colors.grey, fontSize: 10, fontFamily: 'Kanit')),
                const Text('LiveScore ',
                    style: TextStyle(color: Colors.pink, fontSize: 10, fontFamily: 'Kanit')),
                Image.asset('assets/images/logo.png',
                    width: 15, height: 15, fit: BoxFit.contain)
              ],
            ))
      ],
    );
  }
}
