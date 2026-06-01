class Game {
  final int? id;
  final String title;
  final String description;
  final int maxPlayers;
  final bool isPublic;
  final int gmId; // Oyunu kuran kişinin (GM) ID'si

  final String? inviteCode; // YENİ: Davet kodu eklendi

  // 1. Değişkeni ekle (diğer final değişkenlerin altına)
  final bool isFinished;

// YENİ: Artık backend'den sadece katılan oyuncuların ID'leri dönüyor
  final List<int> joinedPlayerIds;
  final List<dynamic>? maps;

  Game({
    this.id,
    required this.title,
    required this.description,
    required this.maxPlayers,
    required this.isPublic,
    required this.gmId,
    this.inviteCode, // YENİ
    this.joinedPlayerIds = const [], // Varsayılan boş liste
    this.maps,
    this.isFinished = false, // YENİ
  });

  // JSON'dan Dart nesnesine çevirme (Backend'den veri çekerken)
  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      id: json['id'],
      title: json['title'] ?? 'Adsız Oyun',
      description: json['description'] ?? '',
      maxPlayers: json['maxPlayers'] ?? 4,
      isPublic: json['publicGame'] ?? false, // JSON'dan publicGame olarak oku
      gmId: json['gmId'] ?? 0,
      inviteCode: json['inviteCode'], // YENİ: JSON'dan oku
      // YENİ: JSON'dan gelen listeyi int listesine çeviriyoruz
      joinedPlayerIds: json['joinedPlayerIds'] != null
          ? List<int>.from(json['joinedPlayerIds'])
          : [],
      maps: json['maps'] ?? [],
      isFinished: json['isFinished'] ?? false, // YENİ
    );
  }

  // Dart nesnesinden JSON'a çevirme (Backend'e veri gönderirken)
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'description': description,
      'maxPlayers': maxPlayers,
      'publicGame': isPublic, // JSON'a publicGame olarak yaz
      'gmId': gmId,
      'isFinished': isFinished, // YENİ
    };
  }
}