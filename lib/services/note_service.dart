import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/note_model.dart';

class NoteService {
  final String baseUrl = "http://10.0.2.2:8080/api/notes";

  // Veritabanından notları çekme
  Future<List<Note>> fetchNotes(int userId, String noteType) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/$userId/$noteType'));
      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((dynamic item) => Note.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print("Notları çekerken hata: $e");
      return [];
    }
  }

  // Yeni not kaydetme
  Future<Note?> createNote(Note note) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/create'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(note.toJson()),
      );
      if (response.statusCode == 200) {
        return Note.fromJson(jsonDecode(response.body)); // Eklenen notu ID'siyle geri alıyoruz
      }
      return null;
    } catch (e) {
      print("Not eklerken hata: $e");
      return null;
    }
  }

  // Not Güncelleme
  Future<bool> updateNote(int id, Note note) async {
    final response = await http.put(
      Uri.parse('$baseUrl/update/$id'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(note.toJson()),
    );
    return response.statusCode == 200;
  }

  // Not Silme
  Future<bool> deleteNote(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/delete/$id'));
    return response.statusCode == 200;
  }

  // YENİ: Spesifik bir oyuna ait kopyalanmış notları çeker
  Future<List<Note>> fetchNotesByGameId(int gameId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/game/$gameId'));
      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((dynamic item) => Note.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print("Oyun notlarını çekerken hata: $e");
      return [];
    }
  }

  // YENİ: Havuzdaki bir notu belirtilen oyuna kopyalar
  Future<Note?> cloneNoteToGame(int noteId, int gameId) async {
    try {
      final response = await http.post(Uri.parse('$baseUrl/clone/$noteId/to-game/$gameId'));
      if (response.statusCode == 200) {
        return Note.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      print("Not kopyalanırken hata: $e");
      return null;
    }
  }
}