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

  // YENİ: Halka açık (Player'ların katılabileceği) oyunları getirir
  Future<List<dynamic>> getPublicGames() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/public'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      print("Halka açık oyunları çekerken hata: $e");
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
      print("Katılınan oyunları çekerken hata: $e");
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
        return {"success": true, "message": "Oyuna başarıyla katıldınız!"};
      } else {
        return {"success": false, "message": response.body}; // Backend'den gelen hata mesajı (örn: "Oda dolu")
      }
    } catch (e) {
      print("Oyuna katılırken hata: $e");
      return {"success": false, "message": "Bağlantı hatası oluştu."};
    }
  }
  // YENİ: Davet koduyla oyuna katılma isteği
  Future<Map<String, dynamic>> joinGameByCode(String inviteCode, int playerId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/join-by-code/$inviteCode/$playerId'),
      );

      if (response.statusCode == 200) {
        return {"success": true, "message": "Oyuna başarıyla katıldınız!"};
      } else {
        return {"success": false, "message": response.body};
      }
    } catch (e) {
      print("Davet koduyla katılırken hata: $e");
      return {"success": false, "message": "Bağlantı hatası oluştu."};
    }
  }
}