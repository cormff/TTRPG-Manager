enum NoteType { gm, player }

class Note {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final NoteType type;
  final String? tag; // D&D specific tags like 'NPC', 'Quest', 'Loot', etc.

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.type,
    this.tag,
  });
}
