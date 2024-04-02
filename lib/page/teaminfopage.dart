import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:url_launcher/link.dart';

class TeamInfoPage extends StatefulWidget {
  final Map team;
  const TeamInfoPage({super.key, required this.team});

  @override
  State<TeamInfoPage> createState() => _TeamInfoPageState();
}

class _TeamInfoPageState extends State<TeamInfoPage> {
  late PaletteGenerator _paletteGenerator;
  Color _backgroundColor = Colors.black;

  @override
  void initState() {
    super.initState();
    _generatePalette();
  }

  Future<void> _generatePalette() async {
    final imageProvider =
        NetworkImage("https://corsproxy.io/?${widget.team['crest']}");

    _paletteGenerator = await PaletteGenerator.fromImageProvider(
      imageProvider,
      size: const Size(200, 200),
    );

    setState(() {
      _backgroundColor = _paletteGenerator.dominantColor?.color ?? Colors.black;
    });
  }

  @override
  Widget build(BuildContext context) {
    String crestTeamUrl = 'https://corsproxy.io/?${widget.team['crest']}';
    Widget crestTeamWidget;

    if (crestTeamUrl.endsWith('.svg')) {
      crestTeamWidget = SvgPicture.network(
        crestTeamUrl,
        width: 100,
        height: 100,
        fit: BoxFit.contain,
      );
    } else {
      crestTeamWidget = Image.network(
        crestTeamUrl,
        width: 100,
        height: 100,
        fit: BoxFit.contain,
      );
    }

    var team = widget.team;
    Color invertedColor =
        _backgroundColor.computeLuminance() > 0.5 ? Colors.black : Colors.white;
    Color textColor =
        _backgroundColor.computeLuminance() > 0.5 ? Colors.white : Colors.black;

    return Scaffold(
        body: Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            image: const DecorationImage(
                image: AssetImage('assets/images/background2.png'),
                fit: BoxFit.cover,
                opacity: 0.3),
            color: _backgroundColor,
          ),
          height: MediaQuery.of(context).size.height,
          child: SingleChildScrollView(
            child: Column(children: [
              const SizedBox(height: 40),
              Row(
                children: [
                  Container(
                      height: 150,
                      width: 150,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: _backgroundColor.computeLuminance() > 0.5
                            ? Colors.black
                            : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: crestTeamWidget),
                  const SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 2.1,
                        child: Text(
                          team['shortName'],
                          style: TextStyle(
                              color: invertedColor,
                              fontSize: 30,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 2.1,
                        child: Text(
                          team['venue'],
                          style: TextStyle(color: invertedColor, fontSize: 20),
                        ),
                      ),
                      Text(
                        'Est: ${team['founded']}',
                        style: TextStyle(color: invertedColor, fontSize: 20),
                      ),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: invertedColor,
                  borderRadius: const BorderRadius.all(Radius.circular(20)),
                ),
                child: SingleChildScrollView(
                  child: Row(
                    children: [
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Team Info',
                              style: TextStyle(
                                  color: Colors.pink[800],
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Text(
                                  'Name: ',
                                  style:
                                      TextStyle(color: textColor, fontSize: 20),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  "${team['shortName']} (${team['tla']})",
                                  style: TextStyle(
                                      color: textColor,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Text(
                                  'Stadium: ',
                                  style:
                                      TextStyle(color: textColor, fontSize: 20),
                                ),
                                const SizedBox(width: 5),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width / 1.8,
                                  child: Text(
                                    team['venue'],
                                    style: TextStyle(
                                        color: textColor,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Text(
                                  'Area: ',
                                  style:
                                      TextStyle(color: textColor, fontSize: 20),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  team['area']['name'],
                                  style: TextStyle(
                                      color: textColor,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(width: 10),
                                SvgPicture.network(
                                  'https://corsproxy.io/?${team['area']['flag']}',
                                  width: 20,
                                  height: 20,
                                  fit: BoxFit.contain,
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Text(
                                  'ClubColors: ',
                                  style:
                                      TextStyle(color: textColor, fontSize: 20),
                                ),
                                const SizedBox(width: 5),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width / 1.9,
                                  child: Text(
                                    team['clubColors'].toString(),
                                    style: TextStyle(
                                        color: textColor,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Text(
                                  'Website: ',
                                  style:
                                      TextStyle(color: textColor, fontSize: 20),
                                ),
                                const SizedBox(width: 5),
                                Link(
                                    uri: Uri.parse(team['website']),
                                    builder: (context, followLink) {
                                      return InkWell(
                                        onTap: followLink,
                                        child: SizedBox(
                                          width: MediaQuery.of(context).size.width / 1.8,
                                          child: Text(
                                            team['website'],
                                            style: TextStyle(
                                                color: Colors.blue[800],
                                                fontSize: 17,
                                                fontWeight: FontWeight.bold,
                                                decoration:
                                                    TextDecoration.underline),
                                          ),
                                        ),
                                      );
                                    }),
                              ],
                            ),
                          ]),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: invertedColor,
                  borderRadius: const BorderRadius.all(Radius.circular(20)),
                ),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Manager',
                        style: TextStyle(
                            color: Colors.pink[800],
                            fontSize: 25,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Text('Name: ',
                              style: TextStyle(color: textColor, fontSize: 20)),
                          const SizedBox(width: 5),
                          Text(team['coach']['name'],
                              style: TextStyle(
                                  color: textColor,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Text('contract: ',
                              style: TextStyle(color: textColor, fontSize: 20)),
                          const SizedBox(width: 5),
                          Text(
                              '${team['coach']['contract']['start']} to ${team['coach']['contract']['until']}',
                              style: TextStyle(
                                  color: textColor,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ]),
              ),
              const SizedBox(height: 20),
              Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: invertedColor,
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Running Competitions',
                        style: TextStyle(
                            color: Colors.pink[800],
                            fontSize: 25,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      for (var competition in team['runningCompetitions'])
                        Row(
                          children: [
                            Text('- ',
                                style:
                                    TextStyle(color: textColor, fontSize: 20)),
                            const SizedBox(width: 5),
                            Text(competition['name'],
                                style: TextStyle(
                                    color: textColor,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(width: 10),
                            Container(
                              color: textColor == Colors.white
                                  ? Colors.white
                                  : Colors.transparent,
                              child: Image.network(
                                'https://corsproxy.io/?${competition['emblem']}',
                                width: 30,
                                height: 30,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ))
            ]),
          ),
        ),
        SafeArea(
          child: Opacity(
            opacity: 0.7,
            child: Container(
              margin: const EdgeInsets.only(left: 15),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(50),
              ),
              child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_rounded),
                  onPressed: () {
                    Get.back();
                  }),
            ),
          ),
        ),
      ],
    ));
  }
}
