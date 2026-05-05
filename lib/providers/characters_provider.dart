import 'package:flutter/material.dart';

import '../models/character_model.dart';
import '../services/character_service.dart';

class CharactersProvider with ChangeNotifier {
  final CharacterService _characterService = CharacterService();

  List<CharacterModel> _playerCharacters = [];
  List<CharacterModel> _npcCharacters = [];
  bool _isLoading = false;

  List<CharacterModel> get playerCharacters => _playerCharacters;
  List<CharacterModel> get npcCharacters => _npcCharacters;
  bool get isLoading => _isLoading;

  Future<void> fetchPlayerCharacters(int userId) async {
    _isLoading = true;
    notifyListeners();

    _playerCharacters = await _characterService.getUserCharacters(
      userId,
      type: CharacterType.player,
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchNpcCharacters(int gmId) async {
    _isLoading = true;
    notifyListeners();

    _npcCharacters = await _characterService.getUserCharacters(
      gmId,
      type: CharacterType.npc,
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addPlayerCharacter({
    required int userId,
    required String name,
    required String race,
    required String charClass,
    required int level,
    required String background,
    required CharacterAlignment alignment,
    int? gameId,
    int strength = 10,
    int dexterity = 10,
    int constitution = 10,
    int intelligence = 10,
    int wisdom = 10,
    int charisma = 10,
    int hitPoints = 10,
    int armorClass = 10,
    int speed = 30,
    String backstory = '',
    String avatarUrl = '',
  }) async {
    final newCharacter = CharacterModel(
      name: name,
      race: race,
      charClass: charClass,
      level: level,
      userId: userId,
      gameId: gameId,
      type: CharacterType.player,
      background: background,
      alignment: alignment,
      strength: strength,
      dexterity: dexterity,
      constitution: constitution,
      intelligence: intelligence,
      wisdom: wisdom,
      charisma: charisma,
      hitPoints: hitPoints,
      armorClass: armorClass,
      speed: speed,
      backstory: backstory,
      avatarUrl: avatarUrl,
    );

    final saved = await _characterService.createCharacter(newCharacter);
    if (saved != null) {
      _playerCharacters.add(saved);
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> addNpcCharacter({
    required int gmId,
    required String name,
    required String race,
    required String charClass,
    required int level,
    required String background,
    required CharacterAlignment alignment,
    int? gameId,
    int strength = 10,
    int dexterity = 10,
    int constitution = 10,
    int intelligence = 10,
    int wisdom = 10,
    int charisma = 10,
    int hitPoints = 10,
    int armorClass = 10,
    int speed = 30,
    String backstory = '',
    String avatarUrl = '',
  }) async {
    final newCharacter = CharacterModel(
      name: name,
      race: race,
      charClass: charClass,
      level: level,
      userId: gmId,
      gameId: gameId,
      type: CharacterType.npc,
      background: background,
      alignment: alignment,
      strength: strength,
      dexterity: dexterity,
      constitution: constitution,
      intelligence: intelligence,
      wisdom: wisdom,
      charisma: charisma,
      hitPoints: hitPoints,
      armorClass: armorClass,
      speed: speed,
      backstory: backstory,
      avatarUrl: avatarUrl,
    );

    final saved = await _characterService.createCharacter(newCharacter);
    if (saved != null) {
      _npcCharacters.add(saved);
      notifyListeners();
      return true;
    }
    return false;
  }

  void clearData() {
    _playerCharacters.clear();
    _npcCharacters.clear();
    _isLoading = false;
    notifyListeners();
  }
}
