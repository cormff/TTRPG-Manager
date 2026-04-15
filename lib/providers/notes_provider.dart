import 'package:flutter/material.dart';
import '../models/note_model.dart';

class NotesProvider with ChangeNotifier {
  final List<Note> _notes = [];

  List<Note> get gmNotes => _notes.where((note) => note.type == NoteType.gm).toList();
  List<Note> get playerNotes => _notes.where((note) => note.type == NoteType.player).toList();

  void addNote(String title, String content, NoteType type, {String? tag}) {
    final newNote = Note(
      id: DateTime.now().toString(),
      title: title,
      content: content,
      createdAt: DateTime.now(),
      type: type,
      tag: tag,
    );
    _notes.add(newNote);
    notifyListeners();
  }

  void deleteNote(String id) {
    _notes.removeWhere((note) => note.id == id);
    notifyListeners();
  }

  void updateNote(String id, String title, String content, {String? tag}) {
    final index = _notes.indexWhere((note) => note.id == id);
    if (index != -1) {
      final oldNote = _notes[index];
      _notes[index] = Note(
        id: oldNote.id,
        title: title,
        content: content,
        createdAt: oldNote.createdAt,
        type: oldNote.type,
        tag: tag,
      );
      notifyListeners();
    }
  }
}
