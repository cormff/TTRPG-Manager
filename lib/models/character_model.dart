enum CharacterType { player, npc }

enum CharacterAlignment {
  lawfulGood,
  lawfulNeutral,
  lawfulEvil,
  neutralGood,
  trueNeutral,
  neutralEvil,
  chaoticGood,
  chaoticNeutral,
  chaoticEvil,
}

/// D&D 5e Player's Handbook standart ırkları
class DndRaces {
  static const List<String> all = [
    'Human',
    'Elf',
    'Dwarf',
    'Halfling',
    'Dragonborn',
    'Gnome',
    'Half-Elf',
    'Half-Orc',
    'Tiefling',
  ];
}

/// D&D 5e Player's Handbook standart sınıfları
class DndClasses {
  static const List<String> all = [
    'Barbarian',
    'Bard',
    'Cleric',
    'Druid',
    'Fighter',
    'Monk',
    'Paladin',
    'Ranger',
    'Rogue',
    'Sorcerer',
    'Warlock',
    'Wizard',
    'Artificer',
  ];
}

/// D&D 5e Player's Handbook standart background'ları
class DndBackgrounds {
  static const List<String> all = [
    'Acolyte',
    'Charlatan',
    'Criminal',
    'Entertainer',
    'Folk Hero',
    'Guild Artisan',
    'Hermit',
    'Noble',
    'Outlander',
    'Sage',
    'Sailor',
    'Soldier',
    'Urchin',
  ];
}

/// D&D 5e Alignment label'ları
class DndAlignments {
  static const Map<CharacterAlignment, String> labels = {
    CharacterAlignment.lawfulGood: 'Lawful Good',
    CharacterAlignment.lawfulNeutral: 'Lawful Neutral',
    CharacterAlignment.lawfulEvil: 'Lawful Evil',
    CharacterAlignment.neutralGood: 'Neutral Good',
    CharacterAlignment.trueNeutral: 'True Neutral',
    CharacterAlignment.neutralEvil: 'Neutral Evil',
    CharacterAlignment.chaoticGood: 'Chaotic Good',
    CharacterAlignment.chaoticNeutral: 'Chaotic Neutral',
    CharacterAlignment.chaoticEvil: 'Chaotic Evil',
  };
}

class CharacterModel {
  final int? id;
  final String name;
  final String race;
  final String charClass;
  final int level;
  final int userId;
  final int? gameId;
  final CharacterType type;
  final String background;
  final CharacterAlignment alignment;

  // D&D 5e Ability Scores
  final int strength;
  final int dexterity;
  final int constitution;
  final int intelligence;
  final int wisdom;
  final int charisma;

  // Combat Stats
  final int hitPoints;
  final int armorClass;
  final int speed;

  // Serbest hikaye metni
  final String backstory;

  // İsteğe bağlı avatar
  final String avatarUrl;

  CharacterModel({
    this.id,
    required this.name,
    required this.race,
    required this.charClass,
    required this.level,
    required this.userId,
    this.gameId,
    required this.type,
    required this.background,
    required this.alignment,
    this.strength = 10,
    this.dexterity = 10,
    this.constitution = 10,
    this.intelligence = 10,
    this.wisdom = 10,
    this.charisma = 10,
    this.hitPoints = 10,
    this.armorClass = 10,
    this.speed = 30,
    this.backstory = '',
    this.avatarUrl = '',
  });

  factory CharacterModel.fromJson(Map<String, dynamic> json) {
    final rawType = (json['characterType'] ?? 'PLAYER')
        .toString()
        .toUpperCase();
    final rawAlignment = (json['alignment'] ?? 'TRUE_NEUTRAL')
        .toString()
        .toUpperCase();

    return CharacterModel(
      id: json['id'],
      name: (json['name'] ?? '').toString(),
      race: (json['race'] ?? '').toString(),
      charClass: (json['charClass'] ?? '').toString(),
      level: (json['level'] ?? 1) as int,
      userId: (json['userId'] ?? 0) as int,
      gameId: json['gameId'] as int?,
      type: rawType == 'NPC' ? CharacterType.npc : CharacterType.player,
      background: (json['background'] ?? '').toString(),
      alignment: _fromBackendAlignment(rawAlignment),
      strength: (json['strength'] ?? 10) as int,
      dexterity: (json['dexterity'] ?? 10) as int,
      constitution: (json['constitution'] ?? 10) as int,
      intelligence: (json['intelligence'] ?? 10) as int,
      wisdom: (json['wisdom'] ?? 10) as int,
      charisma: (json['charisma'] ?? 10) as int,
      hitPoints: (json['hitPoints'] ?? 10) as int,
      armorClass: (json['armorClass'] ?? 10) as int,
      speed: (json['speed'] ?? 30) as int,
      backstory: (json['backstory'] ?? '').toString(),
      avatarUrl: (json['avatarUrl'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'race': race,
      'charClass': charClass,
      'level': level,
      'userId': userId,
      'gameId': gameId,
      'characterType': type == CharacterType.npc ? 'NPC' : 'PLAYER',
      'background': background,
      'alignment': _toBackendAlignment(alignment),
      'strength': strength,
      'dexterity': dexterity,
      'constitution': constitution,
      'intelligence': intelligence,
      'wisdom': wisdom,
      'charisma': charisma,
      'hitPoints': hitPoints,
      'armorClass': armorClass,
      'speed': speed,
      'backstory': backstory,
      'avatarUrl': avatarUrl,
    };
  }

  static CharacterAlignment _fromBackendAlignment(String alignment) {
    return switch (alignment) {
      'LAWFUL_GOOD' => CharacterAlignment.lawfulGood,
      'LAWFUL_NEUTRAL' => CharacterAlignment.lawfulNeutral,
      'LAWFUL_EVIL' => CharacterAlignment.lawfulEvil,
      'NEUTRAL_GOOD' => CharacterAlignment.neutralGood,
      'TRUE_NEUTRAL' => CharacterAlignment.trueNeutral,
      'NEUTRAL_EVIL' => CharacterAlignment.neutralEvil,
      'CHAOTIC_GOOD' => CharacterAlignment.chaoticGood,
      'CHAOTIC_NEUTRAL' => CharacterAlignment.chaoticNeutral,
      'CHAOTIC_EVIL' => CharacterAlignment.chaoticEvil,
      _ => CharacterAlignment.trueNeutral,
    };
  }

  static String _toBackendAlignment(CharacterAlignment alignment) {
    return switch (alignment) {
      CharacterAlignment.lawfulGood => 'LAWFUL_GOOD',
      CharacterAlignment.lawfulNeutral => 'LAWFUL_NEUTRAL',
      CharacterAlignment.lawfulEvil => 'LAWFUL_EVIL',
      CharacterAlignment.neutralGood => 'NEUTRAL_GOOD',
      CharacterAlignment.trueNeutral => 'TRUE_NEUTRAL',
      CharacterAlignment.neutralEvil => 'NEUTRAL_EVIL',
      CharacterAlignment.chaoticGood => 'CHAOTIC_GOOD',
      CharacterAlignment.chaoticNeutral => 'CHAOTIC_NEUTRAL',
      CharacterAlignment.chaoticEvil => 'CHAOTIC_EVIL',
    };
  }
}
