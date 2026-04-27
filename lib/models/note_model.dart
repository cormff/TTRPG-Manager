enum NoteType { gm, player }

class Note {
  final int? id; // Artık veritabanından geleceği için int (Java'daki Long karşılığı)
  final String title;
  final String content;
  final String? tag;
  final String? subTag;
  final NoteType type;
  final int userId;

  Note({
    this.id,
    required this.title,
    required this.content,
    this.tag,
    this.subTag,
    required this.type,
    required this.userId,
  });

  // Java'dan gelen JSON'ı Flutter nesnesine çevirme
  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      tag: json['tag'],
      subTag: json['subTag'],
      type: json['noteType'] == 'GM' ? NoteType.gm : NoteType.player,
      userId: json['userId'],
    );
  }

  // Flutter nesnesini Java'ya JSON olarak gönderme
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'tag': tag,
      'subTag': subTag,
      'noteType': type == NoteType.gm ? 'GM' : 'PLAYER',
      'userId': userId,
    };
  }
}