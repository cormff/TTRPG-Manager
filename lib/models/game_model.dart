class Game {
  final int? id;
  final String title;
  final String description;
  final int maxPlayers;
  final bool isPublic;
  final int gmId; // Oyunu kuran kişinin (GM) ID'si

  // --- İlerisi İçin Hazırlık ---
  final List<dynamic>? joinedPlayers; // Katılan oyuncuların bilgileri
  final List<dynamic>? maps; // Oyuna bağlı haritaların bilgileri

  Game({
    this.id,
    required this.title,
    required this.description,
    required this.maxPlayers,
    required this.isPublic,
    required this.gmId,
    this.joinedPlayers,
    this.maps,
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
      joinedPlayers: json['joinedPlayers'] ?? [],
      maps: json['maps'] ?? [],
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
    };
  }
}