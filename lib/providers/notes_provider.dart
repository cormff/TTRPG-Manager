import 'package:flutter/material.dart';
import '../models/note_model.dart';
import '../services/note_service.dart';

class NotesProvider with ChangeNotifier {
  final NoteService _noteService = NoteService();

  List<Note> _gmNotes = [];
  List<Note> _playerNotes = [];
  bool _isLoading = false;

  List<Note> get gmNotes => _gmNotes;
  List<Note> get playerNotes => _playerNotes;
  bool get isLoading => _isLoading;

  List<Note> _currentGameNotes = []; // Aktif oyunun notları
  List<Note> get currentGameNotes => _currentGameNotes;

// Artık fetchAllNotes metoduna userId'yi dışarıdan parametre olarak alıyoruz
  Future<void> fetchAllNotes(int userId) async {
    _isLoading = true;
    notifyListeners();

    _gmNotes = await _noteService.fetchNotes(userId, 'GM');
    _playerNotes = await _noteService.fetchNotes(userId, 'PLAYER');

    _isLoading = false;
    notifyListeners();
  }

  // YENİ: Seçilen oyunun notlarını hafızaya alır
  Future<void> fetchGameNotes(int gameId) async {
    _isLoading = true;
    notifyListeners();

    _currentGameNotes = await _noteService.fetchNotesByGameId(gameId);

    _isLoading = false;
    notifyListeners();
  }

  // YENİ: Havuzdan seçilen notu oyuna kopyalar ve listeyi günceller
  Future<bool> cloneNoteToGame(int noteId, int gameId) async {
    final clonedNote = await _noteService.cloneNoteToGame(noteId, gameId);
    if (clonedNote != null) {
      _currentGameNotes.add(clonedNote); // Ekranda anında görünmesi için listeye ekle
      notifyListeners();
      return true;
    }
    return false;
  }

// addNote metodunda da userId'yi kullanıyoruz
  Future<void> addNote(String title, String content, NoteType type, int userId, {String? tag, String? subTag}) async {
    final newNote = Note(
      title: title, content: content, tag: tag, subTag: subTag,
      type: type, userId: userId, // Parametre gelen userId
    );

    final savedNote = await _noteService.createNote(newNote);
    if (savedNote != null) {
      if (type == NoteType.gm) {
        _gmNotes.add(savedNote);
      } else {
        _playerNotes.add(savedNote);
      }
      notifyListeners(); // Ekranı güncelle
    }
  }

  Future<void> updateNote(int id, String title, String content, {String? tag, String? subTag}) async {
    final allNotes = [..._gmNotes, ..._playerNotes];
    final existingNote = allNotes.firstWhere((n) => n.id == id);

    final updatedNote = Note(
      id: id,
      title: title,
      content: content,
      tag: tag,
      subTag: subTag,
      type: existingNote.type,
      userId: existingNote.userId,
    );

    final success = await _noteService.updateNote(id, updatedNote);
    if (success) {
      if (existingNote.type == NoteType.gm) {
        final index = _gmNotes.indexWhere((n) => n.id == id);
        if (index != -1) _gmNotes[index] = updatedNote;
      } else {
        final index = _playerNotes.indexWhere((n) => n.id == id);
        if (index != -1) _playerNotes[index] = updatedNote;
      }
      notifyListeners();
    }
  }

  Future<void> deleteNote(int id) async {
    final success = await _noteService.deleteNote(id);
    if (success) {
      _gmNotes.removeWhere((n) => n.id == id);
      _playerNotes.removeWhere((n) => n.id == id);
      notifyListeners();
    }
  }

  // Çıkış (Logout) yapıldığında RAM'deki eski verileri silmek için kullanılır
  void clearData() {
    _gmNotes.clear();
    _playerNotes.clear();
    _isLoading = false;
    notifyListeners(); // Arayüze "Veriler sıfırlandı" bilgisini gönder
  }
}