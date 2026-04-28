import 'package:flutter/material.dart';
import '../models/game_model.dart';
import '../services/game_service.dart';

class GamesProvider with ChangeNotifier {
  final GameService _gameService = GameService();

  List<Game> _gmGames = [];
  List<Game> _playerGames = [];
  bool _isLoading = false;

  List<Game> get gmGames => _gmGames;
  List<Game> get playerGames => _playerGames;
  bool get isLoading => _isLoading;

  Future<void> fetchGMGames(int gmId) async {
    _isLoading = true;
    notifyListeners();

    final rawGames = await _gameService.getMyGames(gmId);
    _gmGames = rawGames.map((g) => Game.fromJson(g)).toList();

    _isLoading = false;
    notifyListeners();
  }

  // --- YENİ EKLENEN METOT ---
  Future<bool> createGame(String title, String description, int maxPlayers, bool isPublic, int gmId) async {
    final success = await _gameService.createGame(title, description, maxPlayers, isPublic, gmId);

    if (success) {
      // Oyun başarıyla veritabanına eklendiyse, GM'in oyun listesini yeniden çekiyoruz
      await fetchGMGames(gmId);
    }
    return success;
  }

  // --- OYUN GÜNCELLEME METODU ---
  Future<bool> updateGame(int gameId, String title, String description, int maxPlayers, bool isPublic, int gmId) async {
    final success = await _gameService.updateGame(gameId, title, description, maxPlayers, isPublic, gmId);

    if (success) {
      // Başarılı olursa, lokaldeki listeyi de güncelle ki arayüz anında değişsin
      final index = _gmGames.indexWhere((g) => g.id == gameId);
      if (index != -1) {
        final oldGame = _gmGames[index];
        _gmGames[index] = Game(
          id: oldGame.id,
          title: title,
          description: description,
          maxPlayers: maxPlayers,
          isPublic: isPublic,
          gmId: oldGame.gmId,
          joinedPlayers: oldGame.joinedPlayers,
          maps: oldGame.maps,
        );
        notifyListeners(); // Ekranı tetikle
      }
    }
    return success;
  }

  void clearData() {
    _gmGames.clear();
    _playerGames.clear();
    _isLoading = false;
    notifyListeners();
  }
}