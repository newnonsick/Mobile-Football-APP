import 'package:flutter/material.dart';
import 'package:project/api/searchplayer_api.dart';
import 'package:project/page/playerpage.dart';

class SearchPlayerPage extends StatefulWidget {
  const SearchPlayerPage({super.key});

  @override
  State<SearchPlayerPage> createState() => _SearchPlayerPageState();
}

class _SearchPlayerPageState extends State<SearchPlayerPage> {
  final TextEditingController _searchController = TextEditingController();
  late Future<SearchPlayer> futureSearchPlayer;

  @override
  void initState() {
    super.initState();
    futureSearchPlayer = fetchSearchPlayer('Harry');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Column(
          children: [
            TextField(
                controller: _searchController,
                onEditingComplete: () {
                  if (_searchController.text.isEmpty) {
                    return;
                  }
      
                  FocusScope.of(context).unfocus();
                  setState(() {
                    futureSearchPlayer =
                        fetchSearchPlayer(_searchController.text);
                  });
                  _searchController.clear();
                },
                decoration: const InputDecoration(
                  hintText: 'Search Player',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  labelText: 'Search Player',
                  labelStyle: TextStyle(color: Colors.black),
                ),
                cursorColor: Colors.pink[800],
                style: const TextStyle(color: Colors.black, fontSize: 20)),
            const SizedBox(height: 20),
            FutureBuilder<SearchPlayer>(
              future: futureSearchPlayer,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Column(
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
                          setState(() {
                            futureSearchPlayer = fetchSearchPlayer(' ');
                          });
                        },
                        child: Text(
                          'Retry',
                          style: TextStyle(color: Colors.pink[800]),
                        ),
                      ),
                    ],
                  );
                } else if (snapshot.hasData) {
                  if (snapshot.data!.hits['found'] == 0) {
                    return const Center(
                      child: Text('No Data Found'),
                    );
                  }

                  return Expanded(
                      child: ListView(
                    children: [
                      for (var player in snapshot.data!.hits['hit'])
                        _buildPlayerItem(player['response']),
                    ],
                  ));
                } else {
                  return const Text('No Data Found');
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerItem(Map player) {
    bool findImage = true;
    bool findTeamImage = true;

    Widget image = Image.network(
      'https://resources.premierleague.com/premierleague/photos/players/250x250/${player['altIds']['opta']}.png',
      fit: BoxFit.contain,
      height: 60,
      width: 60,
      errorBuilder: (context, error, stackTrace) {
        findImage = false;
        return Image.asset(
          'assets/images/unknwon_person.png',
          fit: BoxFit.contain,
          height: 60,
          width: 60,
        );
      },
    );
    Widget teamImage = Image.asset(
      'assets/images/q.png',
      fit: BoxFit.contain,
      height: 20,
      width: 20,
    );

    if (player['currentTeam'] != null) {
      teamImage = Image.network(
          "https://resources.premierleague.com/premierleague/badges/20/${player['currentTeam']['altIds']['opta']}@x2.png",
          width: 20,
          height: 20,
          fit: BoxFit.contain, errorBuilder: (context, error, stackTrace) {
        findTeamImage = false;
        return Image.asset(
          'assets/images/q.png',
          fit: BoxFit.contain,
          height: 20,
          width: 20,
        );
      });
    }

    return InkWell(
      onTap: () {
        if (findImage && player['currentTeam'] != null && findTeamImage) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PlayerPage(
                player: player,
              ),
            ),
          );
        }
      },
      child: Hero(
        tag: player['altIds']['opta'],
        child: Card(
          color: Colors.white,
          child: SizedBox(
              height: 100,
              child: Row(children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 10, 0),
                  child: CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.pink[800],
                      child: image),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        player['name']['display'],
                        style: const TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                            fontWeight: FontWeight.bold),
                      ),
                      player['currentTeam'] != null
                          ? Row(
                              children: [
                                teamImage,
                                const SizedBox(width: 5),
                                Text(
                                  player['currentTeam']['shortName'],
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            )
                          : const SizedBox(),
                    ],
                  ),
                ),
              ])),
        ),
      ),
    );
  }
}
