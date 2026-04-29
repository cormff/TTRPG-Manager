import 'dart:convert';
import 'package:http/http.dart' as http;

class GameService {
  final String baseUrl = 'http://10.0.2.2:8080/api/games';

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
    try {
      final url = '$baseUrl/my-games/$gmId';
      print(">>> İstek atılan URL: $url");

      final response = await http.get(Uri.parse(url));

      print(">>> Sunucu Cevap Kodu: ${response.statusCode}");
      print(">>> Sunucudan Gelen Cevap: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print(">>> HATA: Sunucu 200 OK döndürmedi!");
        return [];
      }
    } catch (e) {
      print(">>> KRİTİK HATA: $e");
      return [];
    }
  }

  Future<bool> updateGame(int gameId, String title, String description, int maxPlayers, bool isPublic, int gmId) async {
    try {
      final response = await http.put(
        // URL KISMINA DİKKAT: Java'da /api/games/{id} şeklinde karşılayacağımız için burası böyle olmalı.
        // Eğer Java'da @PutMapping("/update/{id}") yapsaydın, burası da '$baseUrl/update/$gameId' olmalıydı.
        Uri.parse('$baseUrl/$gameId'),
        headers: {"Content-Type": "application/json"},
        // updateGame ve createGame metotları içinde
        body: jsonEncode({
          "title": title,
          "description": description,
          "maxPlayers": maxPlayers,
          "publicGame": isPublic, // Key değişti, değer aynı kalabilir
          "gmId": gmId
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print("Oyun güncellenirken hata: $e");
      return false;
    }
  }
}