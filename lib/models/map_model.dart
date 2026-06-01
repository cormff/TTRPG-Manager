class GameMap {
  final int? id;
  final String name;
  final String imageUrl;
  final int? gameId;

  GameMap({
    this.id,
    required this.name,
    required this.imageUrl,
    this.gameId,
  });

  factory GameMap.fromJson(Map<String, dynamic> json) {
    return GameMap(
      id: json['id'],
      name: json['name'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      gameId: json['gameId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'imageUrl': imageUrl,
      'gameId': gameId,
    };
  }
}