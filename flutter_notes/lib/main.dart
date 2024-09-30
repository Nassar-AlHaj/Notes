import 'package:flutter/material.dart'; 
import './Pages/EditNote.dart';
import './Pages/HomeScreen.dart';
import './Pages/NewNote.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => HomeScreen(),
        '/new-note': (context) => NewNote(),
        '/edit-note': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map;
          return EditNote(note: args['note'], index: args['index']);
        },
      },
    );
  }
}
