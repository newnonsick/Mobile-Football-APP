import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MatchByID {
  final List<dynamic> matches;

  MatchByID(this.matches);

  factory MatchByID.fromJson(List<dynamic> json) {
    return MatchByID(json);
  }
}

Future<MatchByID> fetchMatchByID(List<int> matchIdList) async {
  final Uri uri = Uri.parse('${dotenv.env['API_URL']}/getMatchById');

  final jsonBody = json.encode({'list_match_id': matchIdList});

  final response = await http.post(uri, body: jsonBody, headers: {
    'Content-Type': 'application/json',
  });

  if (response.statusCode == 200) {
    return MatchByID.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to load MatchByID');
  }
}

Future<MatchByID> parseMatchByID(dynamic data) async {
  try {
    return MatchByID.fromJson(data);
  } catch (e) {
    throw Exception('Failed to parse MatchByID: $e');
  }
}
