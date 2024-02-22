import 'package:flutter/material.dart';
import 'package:project/page/standingpage.dart';

class StatPage extends StatefulWidget {
  const StatPage({Key? key}) : super(key: key);

  @override
  State<StatPage> createState() => _StatPageState();
}

class _StatPageState extends State<StatPage> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
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
            ],
          ),
          const Expanded(
            child: TabBarView(
              children: [
                StandingPage(),
                Center(
                  child: Text('Statistics'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}
