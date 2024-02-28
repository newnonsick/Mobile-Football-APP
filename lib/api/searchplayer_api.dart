import 'dart:convert';
import 'package:http/http.dart' as http;

class SearchPlayer {
  final Map<String, dynamic> hits;
  final dynamic facets;

  const SearchPlayer(this.hits, this.facets);

  factory SearchPlayer.fromJson(Map<String, dynamic> json) {
    return SearchPlayer(
      json['hits'] as Map<String, dynamic>,
      json['facets'] as dynamic,
    );
  }
}

Future<SearchPlayer> fetchSearchPlayer(String playerName) async {
  if (playerName == 'd') {
    return SearchPlayer.fromJson(
        {"hits":{"cursor":null,"found":0,"hit":[],"start":0},"facets":{}});
  }

  final Map<String, String> headers = {
    'authority': 'footballapi.pulselive.com',
    'accept': '*/*',
    'accept-language': 'en-US,en;q=0.5',
    'content-type': 'application/x-www-form-urlencoded; charset=UTF-8',
    'origin': 'https://www.premierleague.com',
    'referer': 'https://www.premierleague.com/',
    'sec-ch-ua': '"Not A(Brand";v="99", "Brave";v="121", "Chromium";v="121"',
    'sec-ch-ua-mobile': '?0',
    'sec-ch-ua-platform': '"Windows"',
    'sec-fetch-dest': 'empty',
    'sec-fetch-mode': 'cors',
    'sec-fetch-site': 'cross-site',
    'sec-gpc': '1',
    'user-agent':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.36'
  };

  final response = await http.get(
    Uri.parse(
        'https://footballapi.pulselive.com/search/PremierLeague/?terms=$playerName,$playerName*&type=player&size=10&start=0&fullObjectResponse=true'),
    headers: headers,
  );

  if (response.statusCode == 200) {
    return SearchPlayer.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  } else {
    throw Exception('Failed to SearchPlayer');
  }
}
