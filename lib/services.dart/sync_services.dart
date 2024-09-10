
import 'package:note/services.dart/fireDB.dart';
import 'package:note/services.dart/firestore.dart';
import 'package:note/services.dart/sql.dart';

class SyncService {
  // Singleton pattern for SyncService
  static final SyncService _instance = SyncService._internal();
  
  factory SyncService() => _instance;
  
  SyncService._internal();
  
  // Function to synchronize notes between local database and Firebase
  Future<void> syncNotes() async {
    try {
      // Fetch notes from Firebase
      final firebaseNotes = await FireDB().getAllStoredNotes();

      // Fetch notes from local database
      final localNotes = await NotesDatabse.instance.readAllNotes();

      // Sync notes to local database from Firebase
      for (var note in firebaseNotes) {
        bool exists = localNotes.any((n) => n.id == note.id);
        if (!exists) {
          await NotesDatabse.instance.InsertEntry(note);
        }
      }

      // Sync notes to Firebase from local database
      for (var note in localNotes) {
        bool exists = firebaseNotes.any((n) => n.id == note.id);
        if (!exists) {
          await FireDb().addOrUpdateNote(note);
        }
      }
    } catch (e) {
      print("Error syncing notes: $e");
    }
  }
}
