import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Standings {
  final Map<String, dynamic> area;
  final Map<String, dynamic> competition;
  final Map<String, dynamic> filters;
  final Map<String, dynamic> season;
  final List<dynamic> standings;

  const Standings(
      this.competition, this.filters, this.standings, this.season, this.area);

  factory Standings.fromJson(Map<String, dynamic> json) {
    return Standings(
      json['competition'] as Map<String, dynamic>,
      json['filters'] as Map<String, dynamic>,
      json['standings'] as List<dynamic>,
      json['season'] as Map<String, dynamic>,
      json['area'] as Map<String, dynamic>,
    );
  }
}

Future<Standings> fetchStandings() async {
  final response =
      await http.get(Uri.parse('http://${dotenv.env['API_URL']}/getStandings'));

  if (response.statusCode == 200) {
    return Standings.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  } else {
    throw Exception('Failed to load Standings');
  }

}

Future<Standings> parseStandings(dynamic data) async {
  try {
    return Standings.fromJson(data);
  } catch (e) {
    throw Exception('Failed to parse Standings: $e');
  }
}

