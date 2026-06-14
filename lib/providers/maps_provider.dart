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

// DEĞİŞTİRİLEN: Parametre eklendi
  Future<void> fetchAllMaps(int ownerId) async {
    _isLoading = true;
    notifyListeners();
    _allMaps = await _mapService.getAllMaps(ownerId);
    _isLoading = false;
    notifyListeners();
  }

  // DEĞİŞTİRİLEN: Haritayı kimin oluşturduğu parametresi eklendi
  Future<bool> createMap(String name, String imageUrl, int ownerId, {int? gameId}) async {
    final newMap = GameMap(name: name, imageUrl: imageUrl, ownerId: ownerId, gameId: gameId);

    final success = await _mapService.createMap(newMap);

    if (success) {
      await fetchAllMaps(ownerId); // Havuzu yenilerken kendi ID'mizi veriyoruz
      if (gameId != null) {
        await fetchMapsForGame(gameId);
      }
    }
    return success;
  }
}