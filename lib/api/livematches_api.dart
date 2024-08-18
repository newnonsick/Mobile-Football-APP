import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class LiveMatches {
  final List<dynamic> matches;

  const LiveMatches(
    this.matches,
  );

  factory LiveMatches.fromJson(List<dynamic> json) {
    return LiveMatches(
      json,
    );
  }
}

Future<LiveMatches> fetchLiveMatches() async {
  final response = await http.get(Uri.parse(
      'https://corsproxy.io/?${dotenv.env['API_URL']}/getLiveMatches'));

  if (response.statusCode == 200) {
    return LiveMatches.fromJson(jsonDecode(response.body) as List<dynamic>);
  } else {
    throw Exception('Failed to load LiveMatches');
  }
}

Future<LiveMatches> parseLiveMatches(dynamic data) async {
  try {
    return LiveMatches.fromJson(data);
  } catch (e) {
    throw Exception('Failed to parse live matches: $e');
  }
}
