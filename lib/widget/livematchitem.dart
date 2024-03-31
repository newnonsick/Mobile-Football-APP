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

    return InkWell(
      onTap: () => {
        Get.to(
          () => MatchInfoPage(
            match: widget.match,
          ),
          transition: Transition.rightToLeft,
        )
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        color: Colors.white,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      const Text('LIVE',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Color.fromRGBO(0, 100, 0, 1))),
                      const SizedBox(width: 5.0),
                      Container(
                        height: 10.0,
                        width: 10.0,
                        decoration: BoxDecoration(
                            color: Colors.grey[100],
                            shape: BoxShape.circle),
                      )
                    ],
                  )
                      .animate(
                          onPlay: (controller) =>
                              controller.repeat(reverse: true))
                      .tint(
                          color: const Color.fromRGBO(0, 100, 0, 1),
                          delay: 1000.ms,
                          curve: Curves.easeInOut,
                          duration: 600.ms)
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        height: 10.0,
                      ),
                      SizedBox(
                          height: 90.0,
                          width: 90.0,
                          child: crestHomeWidget),
                      const SizedBox(height: 10.0),
                      Text(widget.match['homeTeam']['shortName'],
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold))
                    ]),
                Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.fromLTRB(2, 5, 2, 5),
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
                            ' ${widget.match['score']['fullTime']['home']} - ${widget.match['score']['fullTime']['away']} ',
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            )),
                      )
                    ]),
                Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        height: 10.0,
                      ),
                      SizedBox(
                          height: 90.0,
                          width: 90.0,
                          child: crestAwayWidget),
                      const SizedBox(height: 10.0),
                      Text(widget.match['awayTeam']['shortName'],
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold)),
                    ]),
              ],
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                widget.match['referees'].isEmpty
                    ? const Text('Referee: TBA')
                    : Text(
                        'Referee: ${widget.match['referees'][0]['name']}',
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 10.0),
          ],
        ),
      ),
    );
  }
}
