import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../utils.dart' as utils;
import '../models/notes_model.dart';

class NotesDBWorker {
  NotesDBWorker._();
  static final NotesDBWorker db = NotesDBWorker._();

  Database? _db;

  Future get database async {
    if (_db == null) {
      _db = await init();
    }
    return _db;
  }

  Future<Database> init() async {
    final path = join(utils.docsDir!.path, 'notes.db');
    final db = await openDatabase(
      path,
      version: 1,
      onOpen: (db) {},
      onCreate: (Database inDB, int inVersion) async {
        await inDB.execute(
          'CREATE TABLE IF NOT EXISTS notes ('
          'id INTEGER PRIMARY KEY,'
          ' title TEXT,'
          ' content TEXT,'
          ' color TEXT'
          ')',
        );
      },
    );
    return db;
  }

  Future create(Note inNote) async {
    final db = await database;
    final val = await db.rawQuery('SELECT MAX(id) + 1 AS id FROM notes');
    var id = val.first['id'] as int?;
    if (id == null) {
      id = 1;
    }

    return await db.rawInsert(
      'INSERT INTO notes (id, title, content, color) '
      'VALUES (?, ?, ?, ?)',
      [id, inNote.title, inNote.content, inNote.color],
    );
  }

  Future<Note> get(int inID) async {
    final db = await database;
    final rec = await db.query(
      'notes',
      where: 'id = ?',
      whereArgs: [inID],
    );
    return noteFromMap(rec.first);
  }

  Future<List> getAll() async {
    final db = await database;
    final recs = await db.query('notes');
    final list =
        recs.isNotEmpty ? recs.map((e) => noteFromMap(e)).toList() : [];
    return list;
  }

  Future update(Note inNote) async {
    final db = await database;
    return db.update(
      'notes',
      noteToMap(inNote),
      where: 'id = ?',
      whereArgs: [inNote.id],
    );
  }

  Future delete(int inID) async {
    final db = await database;
    return db.delete(
      'notes',
      where: 'id = ?',
      whereArgs: [inID],
    );
  }

  Note noteFromMap(Map<String, dynamic> inMap) {
    final note = Note();
    note.id = inMap['id'];
    note.title = inMap['title'];
    note.content = inMap['content'];
    note.color = inMap['color'];
    return note;
  }

  Map<String, dynamic> noteToMap(Note inNote) {
    final map = Map<String, dynamic>();
    map['id'] = inNote.id;
    map['title'] = inNote.title;
    map['content'] = inNote.content;
    map['color'] = inNote.color;
    return map;
  }
}
