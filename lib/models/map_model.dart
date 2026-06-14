class GameMap {
  final int? id;
  final String name;
  final String imageUrl;
  final int? gameId;
  final int? ownerId; // YENİ EKLENDİ

  GameMap({
    this.id,
    required this.name,
    required this.imageUrl,
    this.gameId,
    this.ownerId, // YENİ
  });

  factory GameMap.fromJson(Map<String, dynamic> json) {
    return GameMap(
      id: json['id'],
      name: json['name'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      gameId: json['gameId'],
      ownerId: json['ownerId'], // YENİ
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'imageUrl': imageUrl,
      'gameId': gameId,
      'ownerId': ownerId, // YENİ
    };
  }
}