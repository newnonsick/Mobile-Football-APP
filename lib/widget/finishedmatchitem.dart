import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:project/page/matchinfopage.dart';
import 'package:project/widget/pictureliveandfinish.dart';
import 'package:project/widget/sharesheet.dart';

class FinishedMatchItem extends StatefulWidget {
  final Map match;
  const FinishedMatchItem({super.key, required this.match});

  @override
  State<FinishedMatchItem> createState() => _FinishedMatchItemState();
}

class _FinishedMatchItemState extends State<FinishedMatchItem> {
  @override
  Widget build(BuildContext context) {
    DateTime utcDate = DateTime.parse(widget.match['utcDate']);
    String formattedDate = DateFormat('dd MMM yyyy').format(utcDate.toLocal());

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
    return Slidable(
      endActionPane: ActionPane(motion: const StretchMotion(), children: [
        SlidableAction(
          onPressed: (context) {
            showModalBottomSheet(
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                context: context,
                builder: (context) => ShareSheet(
                    child: PictureLiveAndFinish(match: widget.match)));
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
                color: Colors.grey[300]!,
                width: 5,
              ),
            ),
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
                    SizedBox(width: 55, height: 55, child: crestHomeWidget),
                    const SizedBox(height: 5.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.match['homeTeam']['shortName'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('FT',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey)),
                  Container(
                    padding: const EdgeInsets.fromLTRB(2, 0, 2, 0),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
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
                            fontSize: 25, fontWeight: FontWeight.bold)),
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
                width: 108,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(width: 55, height: 55, child: crestAwayWidget),
                    const SizedBox(height: 5.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.match['awayTeam']['shortName'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
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

  Widget _buildPictureWidget() {
    return Container();
  }
}
