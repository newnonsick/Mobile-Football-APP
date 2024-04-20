import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class UpcomingMatches {
  final List<dynamic> matches;

  const UpcomingMatches(this.matches);

  factory UpcomingMatches.fromJson(List<dynamic> json) {
    return UpcomingMatches(json);
  }
}

Future<UpcomingMatches> fetchUpcomingMatches() async {
  final response = await http
      .get(Uri.parse('http://${dotenv.env['API_URL']}/getUpcomingMatches'));

  if (response.statusCode == 200) {
    return UpcomingMatches.fromJson(jsonDecode(response.body) as List<dynamic>);
  } else {
    throw Exception('Failed to load UpcomingMatches');
  }
}

Future<UpcomingMatches> parseUpcomingMatches(dynamic data) async {
  try {
    return UpcomingMatches.fromJson(data);
  } catch (e) {
    throw Exception('Failed to parse upcoming matches: $e');
  }
}
