import 'package:flutter/material.dart';
import 'package:project/page/allteamspage.dart';
import 'package:project/page/searchplayerpage.dart';
import 'package:project/page/standingpage.dart';
import 'package:project/page/statisticspage.dart';

class InfoPage extends StatefulWidget {
  const InfoPage({Key? key}) : super(key: key);

  @override
  State<InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Column(
        children: [
          TabBar(
            indicatorColor: Colors.pink[800],
            tabs: [
              Tab(
                icon: Icon(
                  Icons.table_chart,
                  color: Colors.pink[800],
                ),
              ),
              Tab(
                icon: Icon(
                  Icons.star,
                  color: Colors.pink[800],
                ),
              ),
              Tab(
                child: Text('Clubs', style: TextStyle(color: Colors.pink[800], fontWeight: FontWeight.bold),),),
              Tab(
                icon: Icon(
                  Icons.search,
                  color: Colors.pink[800],
                ),
              ),
            ],
          ),
          const Expanded(
            child: TabBarView(
              children: [
                StandingPage(),
                StatisticsPage(),
                AllTeamsPage(),
                SearchPlayerPage(),
              ],
            ),
          ),
        ],
      ),
    );
  }

}
