import 'package:flutter/foundation.dart';
import '../models/note.dart';

class NoteProvider extends ChangeNotifier {
  final List<Note> _notes = [
    Note(
      id: '1',
      title: 'Ghi chú mẫu',
      content: 'Đây là note demo để khỏi trống màn hình.',
      createdAt: DateTime.now(),
    ),
  ];

  List<Note> get notes {
    // trả bản sao để tránh sửa trực tiếp
    return [..._notes];
  }

  Note? findById(String id) {
    try {
      return _notes.firstWhere((n) => n.id == id);
    } catch (e) {
      return null;
    }
  }

  void addNote(String title, String content) {
    final newNote = Note(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      content: content,
      createdAt: DateTime.now(),
    );
    _notes.insert(0, newNote);
    notifyListeners();
  }

  void updateNote(String id, String title, String content) {
    final index = _notes.indexWhere((n) => n.id == id);
    if (index == -1) return;
    _notes[index].title = title;
    _notes[index].content = content;
    notifyListeners();
  }

  void deleteNote(String id) {
    _notes.removeWhere((n) => n.id == id);
    notifyListeners();
  }
}
