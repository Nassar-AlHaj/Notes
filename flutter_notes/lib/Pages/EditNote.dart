import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class EditNote extends StatefulWidget {
  final Map<String, String> note; // Expecting a Map<String, String>
  final int index;

  const EditNote({
    Key? key,
    required this.note,
    required this.index,
  }) : super(key: key);

  @override
  _EditNoteState createState() => _EditNoteState();
}

class _EditNoteState extends State<EditNote> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.note['title']!;
    _contentController.text = widget.note['content']!;
  }

  Future<void> _saveChanges() async {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title and content cannot be empty!')),
      );
      return;
    }

    final updatedNote = {
      'title': _titleController.text,
      'content': _contentController.text,
    };

    final prefs = await SharedPreferences.getInstance();
    final notesString = prefs.getString('notes');
    final List<dynamic> decodedNotes = notesString != null ? json.decode(notesString) : [];

    // Convert each dynamic item to a Map<String, String>
    final notes = decodedNotes.map((note) {
      return {
        'title': note['title'] as String,
        'content': note['content'] as String,
      };
    }).toList();

    // Update the specific note in the list
    notes[widget.index] = updatedNote;

    // Save the updated list back to SharedPreferences
    await prefs.setString('notes', json.encode(notes));

    // Return the updated note and the index
    Navigator.pop(context, {
      'updatedNote': updatedNote,
      'index': widget.index,
    });
  }

  Future<void> _deleteNote() async {
    final prefs = await SharedPreferences.getInstance();
    final notesString = prefs.getString('notes');
    final List<dynamic> decodedNotes = notesString != null ? json.decode(notesString) : [];

    // Convert each dynamic item to a Map<String, String>
    final notes = decodedNotes.map((note) {
      return {
        'title': note['title'] as String,
        'content': note['content'] as String,
      };
    }).toList();

    // Remove the note from the list
    notes.removeAt(widget.index);

    // Save the updated list back to SharedPreferences
    await prefs.setString('notes', json.encode(notes));

    // Return the deletion result
    Navigator.pop(context, {
      'deleted': true,
      'index': widget.index,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Note'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              _deleteNote(); // Call delete function
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(labelText: 'Content'),
              maxLines: 5,
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _saveChanges,
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
