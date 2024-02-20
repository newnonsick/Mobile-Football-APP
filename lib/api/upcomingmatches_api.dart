import 'dart:convert';
import 'package:http/http.dart' as http;

class UpcomingMatches {
  final List<dynamic> matches;

  const UpcomingMatches(this.matches);

  factory UpcomingMatches.fromJson(List<dynamic> json) {
    return UpcomingMatches(json);
  }
}

Future<UpcomingMatches> fetchUpcomingMatches() async {
  final response =
      await http.get(Uri.parse('http://132.145.68.135:6010/getUpcomingMatches'));

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
