import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:note/model/note_model.dart';

class FireDb {

  Future<void> addOrUpdateNote(Note note) async {
    try {
      // Check if the note exists
      var document = await FirebaseFirestore.instance.collection('notes').doc(note.id.toString()).get();

      if (document.exists) {
        // Update existing note
        await FirebaseFirestore.instance.collection('notes').doc(note.id.toString()).update(note.toJson());
      } else {
        // Add new note
        await FirebaseFirestore.instance.collection('notes').doc(note.id.toString()).set(note.toJson());
      }
    } catch (e) {
      print("Error in addOrUpdateNote: $e");
    }
  }
}
