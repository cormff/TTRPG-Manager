import 'dart:convert';
import 'package:http/http.dart' as http;

class GameService {
  final String baseUrl = "http://10.0.2.2:8080/api/games";

// game_service.dart içindeki createGame metodu
  Future<bool> createGame(String title, String description, int maxPlayers, bool isPublic, int gmId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/create'), // Java API adresine göre değiştir
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "title": title,
          "description": description,
          "maxPlayers": maxPlayers,
          "isPublic": isPublic,
          "gmId": gmId // <--- BURAYI DA JSON'A EKLEDİK
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print("Oyun oluşturulurken hata: $e");
      return false;
    }
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