import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AllMatches {
  final Map<String, dynamic> competition;
  final Map<String, dynamic> filters;
  final List<dynamic> matches;
  final Map<String, dynamic> resultSet;

  const AllMatches(
      this.competition, this.filters, this.matches, this.resultSet);

  factory AllMatches.fromJson(Map<String, dynamic> json) {
    return AllMatches(
      json['competition'] as Map<String, dynamic>,
      json['filters'] as Map<String, dynamic>,
      json['matches'] as List<dynamic>,
      json['resultSet'] as Map<String, dynamic>,
    );
  }
}

Future<AllMatches> fetchAllMatches() async {
  final response = await http.get(Uri.parse(
      '${dotenv.env['API_URL']}/getAllMatches'));

  if (response.statusCode == 200) {
    return AllMatches.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  } else {
    throw Exception('Failed to load AllMatches');
  }
}
