import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MatchesOfDay {
  final List<dynamic> matches;

  MatchesOfDay(this.matches);

  factory MatchesOfDay.fromJson(List<dynamic> json) {
    return MatchesOfDay(json);
  }
}

Future<MatchesOfDay> fetchMatchesOfDay(String date, String timezone) async {
  final Uri uri = Uri.parse('${dotenv.env['API_URL']}/getMatch/$date');
  final Map<String, String> queryParams = {'timezone': timezone};
  final Uri uriWithParams = uri.replace(queryParameters: queryParams);

  final response = await http.get(uriWithParams);

  if (response.statusCode == 200) {
    return MatchesOfDay.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to load MatchesOfDay');
  }
}

Future<MatchesOfDay> parseMatchesOfDay(dynamic data) async {
  try {
    return MatchesOfDay.fromJson(data);
  } catch (e) {
    throw Exception('Failed to parse MatchesOfDay: $e');
  }
}
