import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';

class PlayerPage extends StatefulWidget {
  final Map player;

  const PlayerPage({Key? key, required this.player}) : super(key: key);

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text(
          'LiveScore',
          style: TextStyle(
            color: Colors.pink[800],
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: FutureBuilder<PaletteGenerator>(
        future: PaletteGenerator.fromImageProvider(
          NetworkImage(
              'https://corsproxy.io/?https://resources.premierleague.com/premierleague/photos/players/110x140/${widget.player['altIds']['opta']}.png',
              scale: 0.5),
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            Color backgroundColor = snapshot.data!.dominantColor!.color;
            return SingleChildScrollView(
              child: Column(
                children: [
                  _buildTopScreen(backgroundColor),
                  _buildPersonalInfo(),
                  _buildPersonalStat(),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildTopScreen(Color backgroundColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: backgroundColor,
          // boxShadow: [
          //   BoxShadow(
          //     color: Colors.grey.withOpacity(0.3),
          //     spreadRadius: 2,
          //     blurRadius: 10,
          //     offset: const Offset(0, 3),
          //   ),
          // ],
          image: const DecorationImage(
            image: AssetImage(
              'assets/images/background2.png',
            ),
            fit: BoxFit.cover,
            opacity: 0.5,
          ),
        ),
        height: 225,
        child: SizedBox(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
                    child: Row(
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.player['name']['display']
                                  .toString()
                                  .split(' ')[0],
                              style: TextStyle(
                                color: backgroundColor == Colors.white
                                    ? Colors.black
                                    : Colors.white,
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            widget.player['name']['display']
                                        .toString()
                                        .split(' ')
                                        .length >
                                    1
                                ? Text(
                                    widget.player['name']['display']
                                        .toString()
                                        .split(' ')[1],
                                    style: TextStyle(
                                      color: backgroundColor == Colors.white
                                          ? Colors.black
                                          : Colors.white,
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : const SizedBox(),
                            Row(
                              children: [
                                Image.network(
                                    "https://corsproxy.io/?https://resources.premierleague.com/premierleague/badges/50/${widget.player['currentTeam']['altIds']['opta']}@x2.png",
                                    width: 25,
                                    height: 25,
                                    fit: BoxFit.contain),
                                const SizedBox(width: 5),
                                Text(
                                  widget.player['currentTeam']['club']
                                      ['shortName'],
                                  style: TextStyle(
                                    color: backgroundColor == Colors.white
                                        ? Colors.black
                                        : Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              widget.player['info']['shirtNum'].toString(),
                              style: TextStyle(
                                color: backgroundColor == Colors.white
                                    ? Colors.black
                                    : Colors.white,
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Center(
                    child: Image.network(
                      'https://corsproxy.io/?https://resources.premierleague.com/premierleague/photos/players/250x250/${widget.player['altIds']['opta']}.png',
                      height: 200,
                      width: 200,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPersonalInfo() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
          border: Border.all(
            color: Colors.grey.withOpacity(0.3),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
              child: Row(
                children: [
                  Text(
                    'Personal Informatons',
                    style: TextStyle(
                        color: Colors.pink[800],
                        fontSize: 25,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Weight',
                    style: TextStyle(fontSize: 20),
                  ),
                  Text('${widget.player['weight']} kg',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold))
                ],
              ),
            ),
            Divider(
              color: Colors.grey.withOpacity(0.3),
              height: 10,
              thickness: 1,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Height',
                    style: TextStyle(fontSize: 20),
                  ),
                  Text('${widget.player['height']} cm',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold))
                ],
              ),
            ),
            Divider(
              color: Colors.grey.withOpacity(0.3),
              height: 10,
              thickness: 1,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Date of Birth',
                    style: TextStyle(fontSize: 20),
                  ),
                  Text('${widget.player['birth']['date']['label']}',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold))
                ],
              ),
            ),
            Divider(
              color: Colors.grey.withOpacity(0.3),
              height: 10,
              thickness: 1,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Age',
                    style: TextStyle(fontSize: 20),
                  ),
                  Text('${widget.player['age']}',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold))
                ],
              ),
            ),
            Divider(
              color: Colors.grey.withOpacity(0.3),
              height: 10,
              thickness: 1,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Nationality',
                    style: TextStyle(fontSize: 20),
                  ),
                  Text('${widget.player['nationalTeam']['country']}',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold))
                ],
              ),
            ),
            Divider(
              color: Colors.grey.withOpacity(0.3),
              height: 10,
              thickness: 1,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Club',
                    style: TextStyle(fontSize: 20),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Image.network(
                          "https://corsproxy.io/?https://resources.premierleague.com/premierleague/badges/50/${widget.player['currentTeam']['altIds']['opta']}@x2.png",
                          width: 25,
                          height: 25,
                          fit: BoxFit.contain),
                      const SizedBox(width: 5),
                      Text('${widget.player['currentTeam']['name']}',
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                    ],
                  )
                ],
              ),
            ),
            Divider(
              color: Colors.grey.withOpacity(0.3),
              height: 10,
              thickness: 1,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Position',
                    style: TextStyle(fontSize: 20),
                  ),
                  Text(
                      widget.player['info']['position'] == 'F'
                          ? 'Forward'
                          : widget.player['info']['position'] == 'M'
                              ? 'Midfielder'
                              : widget.player['info']['position'] == 'D'
                                  ? 'Defender'
                                  : 'Goalkeeper',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold))
                ],
              ),
            ),
            Divider(
              color: Colors.grey.withOpacity(0.3),
              height: 10,
              thickness: 1,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 5, 10, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Shirt Number',
                    style: TextStyle(fontSize: 20),
                  ),
                  Text('${widget.player['info']['shirtNum']}',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold))
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildPersonalStat() {
     return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
          border: Border.all(
            color: Colors.grey.withOpacity(0.3),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
              child: Row(
                children: [
                  Text(
                    'Personal Statistics',
                    style: TextStyle(
                        color: Colors.pink[800],
                        fontSize: 25,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Appearances',
                    style: TextStyle(fontSize: 20),
                  ),
                  Text('${widget.player['appearances']}',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold))
                ],
              ),
            ),
            Divider(
              color: Colors.grey.withOpacity(0.3),
              height: 10,
              thickness: 1,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Shots',
                    style: TextStyle(fontSize: 20),
                  ),
                  Text('${widget.player['shots']}',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold))
                ],
              ),
            ),
            Divider(
              color: Colors.grey.withOpacity(0.3),
              height: 10,
              thickness: 1,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Goals',
                    style: TextStyle(fontSize: 20),
                  ),
                  Text('${widget.player['goals']}',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold))
                ],
              ),
            ),
            Divider(
              color: Colors.grey.withOpacity(0.3),
              height: 10,
              thickness: 1,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Assists',
                    style: TextStyle(fontSize: 20),
                  ),
                  Text('${widget.player['assists']}',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold))
                ],
              ),
            ),
            Divider(
              color: Colors.grey.withOpacity(0.3),
              height: 10,
              thickness: 1,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Tackles',
                    style: TextStyle(fontSize: 20),
                  ),
                  Text('${widget.player['tackles']}',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold))
                ],
              ),
            ),
            Divider(
              color: Colors.grey.withOpacity(0.3),
              height: 10,
              thickness: 1,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 5, 10, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'KeyPasses',
                    style: TextStyle(fontSize: 20),
                  ),
                  Text('${widget.player['keyPasses']}',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold))
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
