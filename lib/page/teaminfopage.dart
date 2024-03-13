import 'package:flutter/material.dart';

class TeamInfoPage extends StatefulWidget {
  final Map team;
  const TeamInfoPage({super.key, required this.team});

  @override
  State<TeamInfoPage> createState() => _TeamInfoPageState();
}

class _TeamInfoPageState extends State<TeamInfoPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
    );
  }
}
