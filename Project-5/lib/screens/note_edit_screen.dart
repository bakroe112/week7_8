import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/note_provider.dart';
import '../models/note.dart';

class NoteEditScreen extends StatefulWidget {
  final String? noteId;

  const NoteEditScreen({super.key, this.noteId});

  @override
  State<NoteEditScreen> createState() => _NoteEditScreenState();
}

class _NoteEditScreenState extends State<NoteEditScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  Note? _editedNote;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.noteId != null && _editedNote == null) {
      final note = Provider.of<NoteProvider>(context, listen: false)
          .findById(widget.noteId!);
      if (note != null) {
        _editedNote = note;
        _titleController.text = note.title;
        _contentController.text = note.content;
      }
    }
  }

  void _saveNote() {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty && content.isEmpty) {
      // không lưu note rỗng
      Navigator.of(context).pop();
      return;
    }

    final noteProvider = Provider.of<NoteProvider>(context, listen: false);

    if (_editedNote == null) {
      noteProvider.addNote(title, content);
    } else {
      noteProvider.updateNote(_editedNote!.id, title, content);
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.noteId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Sửa ghi chú' : 'Tạo ghi chú'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveNote,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Tiêu đề',
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: TextField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'Nội dung',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
                maxLines: null,
                expands: true,
                keyboardType: TextInputType.multiline,
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _saveNote,
        child: const Icon(Icons.check),
      ),
    );
  }
}
