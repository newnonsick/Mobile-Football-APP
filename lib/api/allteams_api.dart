import 'dart:convert';
import 'package:http/http.dart' as http;

class AllTeams {
  final int count;
  final Map<String, dynamic> competition;
  final Map<String, dynamic> season;
  final List<dynamic> teams;

  AllTeams(this.count, this.competition, this.season, this.teams);

  factory AllTeams.fromJson(Map<String, dynamic> json) {
    return AllTeams(
      json['count'] as int,
      json['competition'] as Map<String, dynamic>,
      json['season'] as Map<String, dynamic>,
      json['teams'] as List<dynamic>,
    );
  }
}

Future<AllTeams> fetchAllTeams() async {
  final response =
      await http.get(Uri.parse('http://132.145.68.135:6010/getAllTeams'));

  if (response.statusCode == 200) {
    return AllTeams.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  } else {
    throw Exception('Failed to load AllTeams');
  }
}

Future<AllTeams> parseAllTeams(dynamic data) async {
  try {
    return AllTeams.fromJson(data);
  } catch (e) {
    throw Exception('Failed to parse Standings: $e');
  }
}
