import 'package:flutter/material.dart';
import '../models/map_model.dart';
import '../services/map_service.dart';

class MapsProvider with ChangeNotifier {
  final MapService _mapService = MapService();

  List<GameMap> _currentGameMaps = [];
  List<GameMap> _allMaps = []; // Havuzdaki tüm haritaları burada tutacağız
  bool _isLoading = false;

  List<GameMap> get currentGameMaps => _currentGameMaps;
  List<GameMap> get allMaps => _allMaps;
  bool get isLoading => _isLoading;

  // 1. Oyuna Özel Haritalar
  Future<void> fetchMapsForGame(int gameId) async {
    _isLoading = true;
    notifyListeners();
    _currentGameMaps = await _mapService.getMapsByGame(gameId);
    _isLoading = false;
    notifyListeners();
  }

  // 2. Tüm Havuzu Getir
  Future<void> fetchAllMaps() async {
    _isLoading = true;
    notifyListeners();
    _allMaps = await _mapService.getAllMaps();
    _isLoading = false;
    notifyListeners();
  }

  // 3. Harita Kaydet ve Havuzu Yenile
  Future<bool> createMap(String name, String imageUrl, {int? gameId}) async {
    // Modelimizi oluşturuyoruz
    final newMap = GameMap(name: name, imageUrl: imageUrl, gameId: gameId);

    // Servise yolluyoruz
    final success = await _mapService.createMap(newMap);

    if (success) {
      // Eğer başarılıysa havuzu hemen güncelle ki ekrana yansısın
      await fetchAllMaps();
      if (gameId != null) {
        await fetchMapsForGame(gameId);
      }
    }
    return success;
  }
}