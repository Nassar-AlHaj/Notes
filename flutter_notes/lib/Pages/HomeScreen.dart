import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import './EditNote.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, String>> notes = [];

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  void _loadNotes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedNotes = prefs.getString('notes');
    if (storedNotes != null) {
      setState(() {
        notes = List<Map<String, String>>.from(
          json.decode(storedNotes).map((note) => Map<String, String>.from(note))
        );
      });
    }
  }

  void _saveNotes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('notes', json.encode(notes));
  }

  void _navigateToNewNote() async {
    final result = await Navigator.pushNamed(context, '/new-note');
    if (result != null) {
      setState(() {
        notes.add(result as Map<String, String>);
        _saveNotes();
      });
    }
  }

  void _viewNote(int index) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditNote(note: notes[index], index: index),
      ),
    );

    if (result != null) {
      if (result.containsKey('deleted') && result['deleted'] == true) {
        setState(() {
          notes.removeAt(result['index']);
          _saveNotes();
        });
      } else if (result.containsKey('updatedNote')) {
        setState(() {
          notes[result['index']] = result['updatedNote'];
          _saveNotes();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          'Notes',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        child: notes.isEmpty
            ? Center(
                child: Text(
                  'No notes yet. Create some!',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              )
            : MasonryGridView.count(
                crossAxisCount: 2, 
                mainAxisSpacing: 8.0,
                crossAxisSpacing: 8.0,
                itemCount: notes.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => _viewNote(index),
                    child: Card(
                      color: Colors.blueGrey[50],
                      elevation: 2,
                      margin: EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              notes[index]['title']!,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 8.0),
                            Text(
                              notes[index]['content']!,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.black54),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToNewNote,
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
