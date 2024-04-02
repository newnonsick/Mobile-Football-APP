import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:project/page/matchinfopage.dart';

class LiveMatchItem extends StatefulWidget {
  final Map match;
  const LiveMatchItem({super.key, required this.match});

  @override
  State<LiveMatchItem> createState() => _LiveMatchItemState();
}

class _LiveMatchItemState extends State<LiveMatchItem> {
  @override
  Widget build(BuildContext context) {
    String crestHomeUrl =
        'https://corsproxy.io/?${widget.match['homeTeam']['crest']}';
    Widget crestHomeWidget;
    String crestAwayUrl =
        'https://corsproxy.io/?${widget.match['awayTeam']['crest']}';
    Widget crestAwayWidget;

    if (crestHomeUrl.endsWith('.svg')) {
      crestHomeWidget = SvgPicture.network(
        crestHomeUrl,
        width: 90,
        height: 90,
        fit: BoxFit.contain,
      );
    } else {
      crestHomeWidget = Image.network(
        crestHomeUrl,
        width: 90,
        height: 90,
        fit: BoxFit.contain,
      );
    }

    if (crestAwayUrl.endsWith('.svg')) {
      crestAwayWidget = SvgPicture.network(
        crestAwayUrl,
        width: 90,
        height: 90,
        fit: BoxFit.contain,
      );
    } else {
      crestAwayWidget = Image.network(
        crestAwayUrl,
        width: 90,
        height: 90,
        fit: BoxFit.contain,
      );
    }

    bool isHomeWinner = widget.match['score']['fullTime']['home'] >
        widget.match['score']['fullTime']['away'];

    bool isAwayWinner = widget.match['score']['fullTime']['home'] <
        widget.match['score']['fullTime']['away'];

    return InkWell(
      onTap: () => {
        Get.to(
          () => MatchInfoPage(
            match: widget.match,
          ),
          transition: Transition.rightToLeft,
        )
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(0, 0, 10, 0),
        decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(color: Colors.grey[300]!),
            image: const DecorationImage(
                image: AssetImage('assets/images/team_background.jpg'),
                fit: BoxFit.cover,
                opacity: 0.9)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        const Text('Premier League',
                            style: TextStyle(
                                color: Colors.grey, fontFamily: 'Kanit')),
                        const SizedBox(width: 60.0),
                        const Text('LIVE',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: Color.fromRGBO(0, 100, 0, 1))),
                        const SizedBox(width: 5.0),
                        Icon(Icons.circle, size: 10, color: Colors.grey[100])
                            .animate(
                                onPlay: (controller) =>
                                    controller.repeat(reverse: true))
                            .tint(
                                color: const Color.fromRGBO(0, 100, 0, 1),
                                delay: 1000.ms,
                                curve: Curves.easeInOut,
                                duration: 600.ms)
                      ],
                    )
                  ],
                )),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const SizedBox(
                    height: 10.0,
                  ),
                  SizedBox(height: 90.0, width: 90.0, child: crestHomeWidget),
                  const SizedBox(height: 10.0),
                  Text(widget.match['homeTeam']['shortName'],
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold))
                ]),
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  RichText(
                      text: TextSpan(children: <TextSpan>[
                    TextSpan(
                        text: '${widget.match['score']['fullTime']['home']}',
                        style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color:
                                isHomeWinner ? Colors.pink[800] : Colors.black,
                            fontFamily: 'Kanit')),
                    const TextSpan(
                        text: ' - ',
                        style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontFamily: 'Kanit')),
                    TextSpan(
                        text: '${widget.match['score']['fullTime']['away']}',
                        style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color:
                                isAwayWinner ? Colors.pink[800] : Colors.black,
                            fontFamily: 'Kanit')),
                  ])),
                ]),
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const SizedBox(
                    height: 10.0,
                  ),
                  SizedBox(height: 90.0, width: 90.0, child: crestAwayWidget),
                  const SizedBox(height: 10.0),
                  Text(widget.match['awayTeam']['shortName'],
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold)),
                ]),
              ],
            ),
            const SizedBox(height: 15.0),
            widget.match['referees'].isEmpty
                ? const Text('Referee: TBA')
                : Text('Referee: ${widget.match['referees'][0]['name']}',
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15.0),
          ],
        ),
      ),
    );
  }
}
