import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final CollectionReference songs =
      FirebaseFirestore.instance.collection('Songs');

  void _deleteSong(String id) {
    songs.doc(id).delete();
  }

  void _editSong(String id, String currentTitle, String currentArtist,
      String currentGenre) {
    TextEditingController titleController =
        TextEditingController(text: currentTitle);
    TextEditingController artistController =
        TextEditingController(text: currentArtist);
    TextEditingController genreController =
        TextEditingController(text: currentGenre);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Song'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: titleController,
                  decoration: InputDecoration(labelText: 'Title')),
              TextField(
                  controller: artistController,
                  decoration: InputDecoration(labelText: 'Artist')),
              TextField(
                  controller: genreController,
                  decoration: InputDecoration(labelText: 'Genre')),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                songs.doc(id).update({
                  'title': titleController.text,
                  'artist': artistController.text,
                  'genre': genreController.text,
                });
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _addSong() {
    TextEditingController titleController = TextEditingController();
    TextEditingController artistController = TextEditingController();
    TextEditingController genreController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Song'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: titleController,
                  decoration: InputDecoration(labelText: 'Title')),
              TextField(
                  controller: artistController,
                  decoration: InputDecoration(labelText: 'Artist')),
              TextField(
                  controller: genreController,
                  decoration: InputDecoration(labelText: 'Genre')),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                songs.add({
                  'title': titleController.text,
                  'artist': artistController.text,
                  'genre': genreController.text,
                });
                Navigator.pop(context);
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text('Song List', style: TextStyle(color: Colors.white)),
        ),
        backgroundColor: Colors.blueAccent,
      ),
      body: StreamBuilder(
        stream: songs.orderBy('title').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final songDocs = snapshot.data?.docs ?? [];

          return ListView.builder(
            itemCount: songDocs.length,
            itemBuilder: (context, index) {
              final doc = songDocs[index];
              final data = doc.data() as Map<String, dynamic>;
              return Card(
                margin: EdgeInsets.zero,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.transparent, width: 0),
                  borderRadius: BorderRadius.zero,
                ),
                child: ExpansionTile(
                  title: Text(
                    data['title'] ?? '',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text("Artist: ${data['artist'] ?? ''}",
                      style: TextStyle(fontSize: 16)),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _editSong(
                              doc.id,
                              data['title'] ?? '',
                              data['artist'] ?? '',
                              data['genre'] ?? '',
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteSong(doc.id),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addSong,
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        child: Icon(Icons.add),
      ),
    );
  }
}
