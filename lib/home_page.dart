import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';

import 'firebase_services.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController controller = TextEditingController();
  FirestoreServices firestoreServices = FirestoreServices();
  void showNoteBox(String? textToedit, String? docId, Timestamp? time) {
    showDialog(
      context: context,
      builder: (context) {
        if (textToedit != null) {
          controller.text = textToedit;
        }
        return AlertDialog(
          title: Text(
            "Add note",
            style: GoogleFonts.alexandria(fontSize: 16),
          ),
          content: TextField(
            decoration: InputDecoration(hintText: 'Note here...'),
            style: GoogleFonts.alexandria(),
            controller: controller,
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                if (docId == null) {
                  firestoreServices.addNote(controller.text,"Mani Sohaan");
                } else {
                  firestoreServices.updateNotes(docId, controller.text, time!);
                }
                controller.clear();
                Navigator.pop(context);
              },
              child: Text(
                'add',
                style: GoogleFonts.alexandria(),
              ),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple[50],
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.purple[50],
        title: Text(
          "Mani C R U D",
          style: GoogleFonts.alexandria(),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.purple[100],
        label: Text(
          'add',
          style: GoogleFonts.alexandria(fontSize: 18),
        ),
        icon: Icon(Icons.add),
        onPressed: () async {
          showNoteBox(null, null, null);
        },
      ),
      body: StreamBuilder(
        stream: FirestoreServices().showNotes(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List noteList = snapshot.data!.docs;
            return ListView.builder(
              itemCount: noteList.length,
              itemBuilder: (context, index) {
                DocumentSnapshot document = noteList[index];
                String docId = document.id;
                Map<String, dynamic> data =
                document.data() as Map<String, dynamic>;
                String note = data['note'];
                String noteBy = data['author'];
                Timestamp time = data['timestamp'];
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        tileColor: Colors.purple[100],
                        title: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                note,
                                style: GoogleFonts.alexandria(
                                    textStyle: TextStyle(
                                        color: Colors.black, fontSize: 16)),
                              ),
                              SizedBox(height: 8),
                              Text(
                                noteBy,
                                style: GoogleFonts.alexandria(
                                    textStyle: TextStyle(
                                        color: Colors.red, fontSize: 14)),
                              ),
                            ],
                          ),
                        ),
                        trailing: Column(
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  color: Colors.purple[400],
                                  icon: Icon(Icons.edit),
                                  onPressed: () {
                                    showNoteBox(note, docId, time);
                                  },
                                ),
                                IconButton(
                                    color: Colors.purple[400],
                                    onPressed: () {
                                      firestoreServices.deleteNote(docId);
                                    },
                                    icon: Icon(Icons.delete))
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            time.toDate().hour.toString(),
                            style: const TextStyle(
                                color: Colors.purple,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(":"),
                          Text(
                            time.toDate().minute.toString(),
                            style: const TextStyle(
                                color: Colors.purple,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    )
                  ],
                );
              },
            );
          } else {
            return Center(
              child: Text("Nothing to show...add notes"),
            );
          }
        },
      ),
    );
  }
}