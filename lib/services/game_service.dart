import 'dart:convert';
import 'package:http/http.dart' as http;

class GameService {
  final String baseUrl = "http://10.0.2.2:8080/api/games";

  Future<bool> createGame(String title, String desc, int players, bool isPublic) async {
    final response = await http.post(
      Uri.parse('$baseUrl/create'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "title": title,
        "description": desc,
        "maxPlayers": players,
        "isPublic": isPublic,
        "gmId": 1 // Şimdilik login olanın ID'sini 1 varsayıyoruz
      }),
    );
    return response.statusCode == 200;
  }

  Future<List<dynamic>> getMyGames(int gmId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/my-games/$gmId'),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return [];
  }
}