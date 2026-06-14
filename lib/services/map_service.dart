import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/map_model.dart';
import 'api_config.dart';

class MapService {
  final String baseUrl = 'http://${ApiConfig.host}:8080/api/maps';

  // 1. Oyuna Ait Haritaları Getir
  Future<List<GameMap>> getMapsByGame(int gameId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/game/$gameId'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => GameMap.fromJson(json)).toList();
      }
    } catch (e) {
      print("Oyuna ait haritaları çekerken hata: $e");
    }
    return [];
  }

// DEĞİŞTİRİLEN: Kişiye özel havuzu getir
  Future<List<GameMap>> getAllMaps(int ownerId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/all/$ownerId')); // ownerId eklendi
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => GameMap.fromJson(json)).toList();
      }
    } catch (e) {
      print("Tüm haritaları çekerken hata: $e");
    }
    return [];
  }

  // 3. Yeni Harita Oluştur ve Veritabanına Kaydet (YENİ EKLENDİ)
  Future<bool> createMap(GameMap map) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/create'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(map.toJson()),
      );
      return response.statusCode ==
          200; // 200 OK dönerse başarıyla kaydedildi demektir
    } catch (e) {
      print("Harita oluştururken hata: $e");
      return false;
    }
  }
}
