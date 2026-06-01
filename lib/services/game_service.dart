import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class GameService {
  final String baseUrl = 'http://${ApiConfig.host}:8080/api/games';

  // game_service.dart içindeki createGame metodu
  Future<bool> createGame(
    String title,
    String description,
    int maxPlayers,
    bool isPublic,
    int gmId,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/create'), // Java API adresine göre değiştir
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "title": title,
          "description": description,
          "maxPlayers": maxPlayers,
          "isPublic": isPublic,
          "gmId": gmId, // <--- BURAYI DA JSON'A EKLEDİK
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print("Error while creating the game: $e");
      return false;
    }
  }

  Future<List<dynamic>> getMyGames(int gmId) async {
    try {
      final url = '$baseUrl/my-games/$gmId';
      print(">>> Wanted URL: $url");

      final response = await http.get(Uri.parse(url));

      print(">>> Server Responso Code: ${response.statusCode}");
      print(">>> Server Response: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print(">>> ERROR: Server did not return 200 OK!");
        return [];
      }
    } catch (e) {
      print(">>> CRITICAL ERROR: $e");
      return [];
    }
  }

  Future<bool> updateGame(
    int gameId,
    String title,
    String description,
    int maxPlayers,
    bool isPublic,
    int gmId,
  ) async {
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
          "gmId": gmId,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print("Error while updating the game: $e");
      return false;
    }
  }

  // YENİ: Halka açık (Player'ların katılabileceği) oyunları getirir
  Future<List<dynamic>> getPublicGames() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/public'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      print("Error while pulling public games: $e");
      return [];
    }
  }

  // YENİ: Oyuncunun (Player) daha önce katıldığı kendi oyunlarını getirir
  Future<List<dynamic>> getJoinedGames(int playerId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/joined/$playerId'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      print("Error while pulling joined games: $e");
      return [];
    }
  }

  // YENİ: Bir oyuncuyu bir oyuna dahil etme (Katılma) isteği atar
  Future<Map<String, dynamic>> joinGame(int gameId, int playerId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/$gameId/join/$playerId'),
        // Body göndermemize gerek yok, verileri URL'den (PathVariable) veriyoruz
      );

      if (response.statusCode == 200) {
        return {"success": true, "message": "Succesfully joined to game!"};
      } else {
        return {
          "success": false,
          "message": response.body,
        }; // Backend'den gelen hata mesajı (örn: "Oda dolu")
      }
    } catch (e) {
      print("Error while joining: $e");
      return {"success": false, "message": "Connection Error"};
    }
  }

  // YENİ: Davet koduyla oyuna katılma isteği
  Future<Map<String, dynamic>> joinGameByCode(
    String inviteCode,
    int playerId,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/join-by-code/$inviteCode/$playerId'),
      );

      if (response.statusCode == 200) {
        return {"success": true, "message": "Succesfully joined to game!"};
      } else {
        return {"success": false, "message": response.body};
      }
    } catch (e) {
      print("Error while joining via code: $e");
      return {"success": false, "message": "Connection Error"};
    }
  }

  // YENİ: Oyunu bitirme (Arşivleme) isteği
  Future<bool> finishGame(int gameId) async {
    try {
      final response = await http.put(Uri.parse('$baseUrl/$gameId/finish'));
      return response.statusCode == 200;
    } catch (e) {
      print("Error while ending the game: $e");
      return false;
    }
  }

  // YENİ: Oyuncu ID'lerinden İsimleri Çeken Metot
  Future<Map<int, String>> getUsernames(List<int> userIds) async {
    if (userIds.isEmpty) return {};
    try {
      final response = await http.post(
        Uri.parse('http://${ApiConfig.host}:8080/api/users/usernames'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(userIds),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> rawData = jsonDecode(response.body);
        // JSON'dan gelen String anahtarları (key) int'e çeviriyoruz
        return rawData.map((key, value) => MapEntry(int.parse(key), value.toString()));
      }
      return {};
    } catch (e) {
      print("Error while pulling player names: $e");
      return {};
    }
  }

  // YENİ: Spesifik bir oyuna ait notları çeken metot
  Future<List<dynamic>> getGameNotes(int gameId) async {
    try {
      final response = await http.get(Uri.parse('http://${ApiConfig.host}:8080/api/notes/game/$gameId'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      print("Error while pulling game notes: $e");
      return [];
    }
  }
}
