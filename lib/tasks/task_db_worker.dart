import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../utils.dart' as utils;
import 'task_model.dart';

class TasksDBWorker {
  TasksDBWorker._();
  static final TasksDBWorker db = TasksDBWorker._();

  Database? _db;

  Future get database async {
    if (_db == null) {
      _db = await init();
    }
    return _db;
  }

  Future<Database> init() async {
    final path = join(utils.docsDir!.path, 'tasks.db');
    final db = await openDatabase(
      path,
      version: 1,
      onOpen: (db) {},
      onCreate: (Database inDB, int inVersion) async {
        await inDB.execute(
          'CREATE TABLE IF NOT EXISTS tasks(' +
              'id INTEGER PRIMARY KEY,' +
              ' description TEXT,' +
              ' dueDate TEXT,' +
              ' completed TEXT)',
        );
      },
    );

    return db;
  }

  Future create(Task inTask) async {
    final db = await database;
    final val = await db.rawQuery('SELECT MAX(id) + 1 AS id FROM tasks');
    var id = val.first['id'] as int?;
    if (id == null) {
      id = 1;
    }

    return await db.rawInsert(
      'INSERT INTO tasks (id, description, dueDate, completed) '
      'VALUES ( ?, ?, ?, ?)',
      [id, inTask.description, inTask.dueDate, inTask.completed],
    );
  }

  Future<Task> get(int inID) async {
    final db = await database;
    final rec = await db.query(
      'tasks',
      where: 'id = ?',
      whereArgs: [inID],
    );
    return taskFromMap(rec.first);
  }

  Future<List> getAll() async {
    final db = await database;
    final recs = await db.query('tasks');
    final list =
        recs.isNotEmpty ? recs.map((e) => taskFromMap(e)).toList() : [];
    return list;
  }

  Future update(Task inTask) async {
    final db = await database;
    await db.update(
      'tasks',
      taskToMap(inTask),
      where: 'id = ?',
      whereArgs: [inTask.id],
    );
  }

  Future delete(int inID) async {
    final db = await database;
    return db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [inID],
    );
  }

  Task taskFromMap(Map<String, dynamic> inMap) {
    final task = Task();
    task.id = inMap['id'];
    task.description = inMap['description'];
    task.dueDate = inMap['dueDate'];
    task.completed = inMap['completed'];
    return task;
  }

  Map<String, dynamic> taskToMap(Task inTask) {
    final map = Map<String, dynamic>();
    map['id'] = inTask.id;
    map['description'] = inTask.description;
    map['dueDate'] = inTask.dueDate;
    map['completed'] = inTask.completed;
    return map;
  }
}
