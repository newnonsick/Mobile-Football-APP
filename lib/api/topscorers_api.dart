import 'dart:convert';
import 'package:http/http.dart' as http;

class TopScorers {
  final Map<String, dynamic> competition;
  final dynamic count;
  final Map<String, dynamic> filters;
  final List<dynamic> scorers;
  final Map<String, dynamic> season;


  const TopScorers(
      this.competition, this.filters, this.scorers, this.season, this.count);

  factory TopScorers.fromJson(Map<String, dynamic> json) {
    return TopScorers(
      json['competition'] as Map<String, dynamic>,
      json['filters'] as Map<String, dynamic>,
      json['scorers'] as List<dynamic>,
      json['season'] as Map<String, dynamic>,
      json['count'] as dynamic,
    );
  }
}

Future<TopScorers> fetchTopScorers() async {
  final response =
      await http.get(Uri.parse('http://132.145.68.135:6010/getTopScorers'));

  if (response.statusCode == 200) {
    return TopScorers.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  } else {
    throw Exception('Failed to load TopScorers');
  }
}
