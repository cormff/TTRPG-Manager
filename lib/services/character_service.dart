import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/character_model.dart';
import 'api_config.dart';

class CharacterService {
  final String baseUrl = 'http://${ApiConfig.host}:8080/api/characters';

  Future<CharacterModel?> createCharacter(CharacterModel character) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/create'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(character.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return CharacterModel.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      debugPrint('Karakter oluşturma hatası: $e');
      return null;
    }
  }

  Future<List<CharacterModel>> getUserCharacters(
    int userId, {
    CharacterType? type,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/user/$userId').replace(
        queryParameters: type == null
            ? null
            : {'type': type == CharacterType.npc ? 'NPC' : 'PLAYER'},
      );

      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => CharacterModel.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Kullanıcı karakterlerini çekerken hata: $e');
      return [];
    }
  }

  Future<List<CharacterModel>> getGameCharacters(
    int gameId, {
    CharacterType? type,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/game/$gameId').replace(
        queryParameters: type == null
            ? null
            : {'type': type == CharacterType.npc ? 'NPC' : 'PLAYER'},
      );

      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => CharacterModel.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Oyun karakterlerini çekerken hata: $e');
      return [];
    }
  }
}
