
import 'package:note/model/note_model.dart';
import 'package:note/services.dart/firestore.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class NotesDatabse {
  static final NotesDatabse instance = NotesDatabse._init();
  static Database? _database;

  NotesDatabse._init();

  Future<Database?> get database async {
    if (_database != null) return _database;
    _database = await _initializeDB('Notes.db');
    return _database;
  }

  //initiliases the database
  Future<Database> _initializeDB(String filepath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filepath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  //creates the notes database
  Future _createDB(Database db, int version) async {
    final idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    final boolType = ' BOOLEAN NOT NULL';
    final textType = 'TEXT NOT NULL';
    await db.execute('''
    CREATE TABLE Notes(
      ${NotesImpNames.id} $idType,
      ${NotesImpNames.uniqueID} $textType,
      ${NotesImpNames.pin} $boolType,
      ${NotesImpNames.isArchived} $boolType,
      ${NotesImpNames.title} $textType,
      ${NotesImpNames.content} $textType,
      ${NotesImpNames.createdTime} $textType
    )
    ''');
  }

  //inserts a note
  Future<Note?> InsertEntry(Note note) async {
    final db = await instance.database;
    final id = await db!.insert(NotesImpNames.TableName, note.toJson());
    await FireDB().createNewNoteFirestore(note);
    return note.copy(id: id);
  }

  //retrieves all the notes
  Future<List<Note>> readAllNotes() async {
    final db = await instance.database;
    final orderBy = '${NotesImpNames.createdTime} ASC';
    final query_result =
        await db!.query(NotesImpNames.TableName, orderBy: orderBy);
    return query_result.map((json) => Note.fromJson(json)).toList();
  }

  //retrieves archived notes 
  Future<List<Note>> readArchivedNotes() async {
    final db = await instance.database;
    final orderBy = '${NotesImpNames.createdTime} ASC';
    final query_result =
    await db!.query(NotesImpNames.TableName, orderBy: orderBy, where: '${NotesImpNames.isArchived} = 1' );
    return query_result.map((json) => Note.fromJson(json)).toList();
  }

  //retrieves the note from database using the ID
  Future<Note?> readOneNote(int id) async {
    final db = await instance.database;
    final map = await db!.query(NotesImpNames.TableName,
        columns: NotesImpNames.values,
        where: '${NotesImpNames.id} = ?',
        whereArgs: [id]);
    if (map.isNotEmpty) {
      return Note.fromJson(map.first);
    } else {
      return null;
    }
  }

  //pins the note
  Future pinNote(Note? note) async {
    final db = await instance.database;
    await db!.update(NotesImpNames.TableName, {NotesImpNames.pin : !note!.pin ? 1 : 0},
        where: '${NotesImpNames.id} = ?', whereArgs: [note!.id]);
  }

  //toggles the archive note
  Future aechivedNote(Note? note) async {
    final db = await instance.database;
    await db!.update(NotesImpNames.TableName, {NotesImpNames.isArchived : !note!.isArchived ? 1 : 0},
        where: '${NotesImpNames.id} = ?', whereArgs: [note!.id]);
  }

  //updates the note
  Future updateNote(Note note) async {
    await FireDB().updateNoteFirestore(note);
    final db = await instance.database;
    await db!.update(NotesImpNames.TableName, note.toJson(),
        where: '${NotesImpNames.id} = ?', whereArgs: [note.id]);
  }

  //deletes the note
  Future delteNote(Note? note) async {
    await FireDB().deleteNoteFirestore(note!);
    final db = await instance.database;
    await db!.delete(NotesImpNames.TableName,
        where: '${NotesImpNames.id}= ?', whereArgs: [note.id]);
  }

  //searches the note
  Future<List<int>> getNoteString(String query) async {
    final db = await instance.database;
    if (db == null) {
      // Handle the case where the database is null
      return [];
    }

    final result = await db.query(NotesImpNames.TableName);
    List<int> resultIds = [];
    result.forEach((element) {
      if (element["title"].toString().toLowerCase().contains(query) ||
          element["content"].toString().toLowerCase().contains(query)) {
        resultIds.add(element["id"] as int);
      }
    });

    return resultIds;
  }

  Future closeDB() async {
    final db = await instance.database;
    db!.close();
  }
}
