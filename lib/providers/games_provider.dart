import 'package:flutter/material.dart';
import '../models/game_model.dart';
import '../services/game_service.dart';

class GamesProvider with ChangeNotifier {
  final GameService _gameService = GameService();

  List<Game> _gmGames = [];
  List<Game> _playerGames = []; // Oyuncunun katıldığı oyunlar
  List<Game> _publicGames = []; // Katılabileceği Halka Açık oyunlar

  bool _isLoading = false;

  List<Game> get gmGames => _gmGames;
  List<Game> get playerGames => _playerGames;
  List<Game> get publicGames => _publicGames;
  bool get isLoading => _isLoading;

  // --- GM OYUNLARINI ÇEK ---
  Future<void> fetchGMGames(int gmId) async {
    _isLoading = true;
    notifyListeners();

    final rawGames = await _gameService.getMyGames(gmId);
    _gmGames = rawGames.map((g) => Game.fromJson(g)).toList();

    _isLoading = false;
    notifyListeners();
  }

  // --- YENİ: OYUNCUNUN KATILDIĞI OYUNLARI ÇEK ---
  Future<void> fetchPlayerGames(int playerId) async {
    _isLoading = true;
    notifyListeners();

    final rawGames = await _gameService.getJoinedGames(playerId);
    _playerGames = rawGames.map((g) => Game.fromJson(g)).toList();

    _isLoading = false;
    notifyListeners();
  }

  // --- YENİ: HALKA AÇIK OYUNLARI ÇEK ---
  Future<void> fetchPublicGames() async {
    _isLoading = true;
    notifyListeners();

    final rawGames = await _gameService.getPublicGames();
    _publicGames = rawGames.map((g) => Game.fromJson(g)).toList();

    _isLoading = false;
    notifyListeners();
  }

  // --- YENİ: OYUNA KATIL (Player) ---
  Future<String?> joinGame(int gameId, int playerId) async {
    final result = await _gameService.joinGame(gameId, playerId);

    if (result['success'] == true) {
      // Katılma başarılıysa listeleri güncelle
      await fetchPlayerGames(playerId);
      await fetchPublicGames(); // Belki kapasite doldu, public listesi de yenilenmeli
      return null; // Null dönmesi hatasız başarılı demek
    } else {
      return result['message']; // String dönerse hata var demektir, UI'da göster
    }
  }

  // --- OYUN OLUŞTUR (GM) ---
  Future<bool> createGame(String title, String description, int maxPlayers, bool isPublic, int gmId) async {
    final success = await _gameService.createGame(title, description, maxPlayers, isPublic, gmId);

    if (success) {
      // Oyun başarıyla veritabanına eklendiyse, GM'in oyun listesini yeniden çekiyoruz
      await fetchGMGames(gmId);
    }
    return success;
  }

  // --- OYUN GÜNCELLE (GM) ---
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
          joinedPlayerIds: oldGame.joinedPlayerIds, // Modelde güncellediğimiz isim
          maps: oldGame.maps,
        );
        notifyListeners(); // Ekranı tetikle
      }
    }
    return success;
  }

  // YENİ: DAVET KODU İLE KATIL (Player)
  Future<String?> joinGameByCode(String inviteCode, int playerId) async {
    final result = await _gameService.joinGameByCode(inviteCode, playerId);

    if (result['success'] == true) {
      // Başarılıysa oyuncunun oyunlarını yenile
      await fetchPlayerGames(playerId);
      return null;
    } else {
      return result['message'];
    }
  }

  void clearData() {
    _gmGames.clear();
    _playerGames.clear();
    _publicGames.clear();
    _isLoading = false;
    notifyListeners();
  }
}