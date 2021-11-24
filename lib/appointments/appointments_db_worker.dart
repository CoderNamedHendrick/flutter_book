import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'appointments_model.dart';
import '../utils.dart' as utils;

class AppointmentsDBWorker {
  AppointmentsDBWorker._();
  static final AppointmentsDBWorker db = AppointmentsDBWorker._();

  Database? _db;

  Future get database async {
    if (_db == null) {
      _db = await init();
    }
    return _db;
  }

  Future<Database> init() async {
    final path = join(utils.docsDir!.path, 'appointments.db');
    final db = await openDatabase(
      path,
      version: 1,
      onOpen: (db) {},
      onCreate: (Database inDB, int inVersion) async {
        await inDB.execute(
          'CREATE TABLE IF NOT EXISTS appointments (' +
              'id INTEGER PRIMARY KEY, ' +
              'title TEXT, ' +
              'description TEXT, ' +
              'apptDate TEXT, ' +
              'apptTime TEXT' +
              ')',
        );
      },
    );
    return db;
  }

  Future create(Appointment inAppointment) async {
    final db = await database;
    final val = await db.rawQuery('SELECT MAX(id) + 1 AS id FROM appointments');
    var id = val.first['id'] as int?;
    if (id == null) {
      id = 1;
    }

    return await db.rawInsert(
      'INSERT INTO appointments (id, title, description, apptDate, apptTime) '
      'VALUES (?, ?, ?, ?, ?)',
      [
        id,
        inAppointment.title,
        inAppointment.description,
        inAppointment.apptDate,
        inAppointment.apptTime
      ],
    );
  }

  Future<Appointment> get(int inID) async {
    final db = await database;
    final rec = await db.query(
      'appointments',
      where: 'id = ?',
      whereArgs: [inID],
    );
    return appointmentFromMap(rec.first);
  }

  Future<List> getAll() async {
    final db = await database;
    final recs = await db.query('appointments');
    final list =
        recs.isNotEmpty ? recs.map((e) => appointmentFromMap(e)).toList() : [];
    return list;
  }

  Future update(Appointment inAppointment) async {
    final db = await database;
    return db.update(
      'appointments',
      appointmentToMap(inAppointment),
      where: 'id = ?',
      whereArgs: [inAppointment.id],
    );
  }

  Future delete(int inID) async {
    final db = await database;
    return db.delete(
      'appointments',
      where: 'id = ?',
      whereArgs: [inID],
    );
  }

  Appointment appointmentFromMap(Map<String, dynamic> inMap) {
    final appointment = Appointment();
    appointment.id = inMap['id'];
    appointment.title = inMap['title'];
    appointment.description = inMap['description'];
    appointment.apptDate = inMap['apptDate'];
    appointment.apptTime = inMap['apptTime'];
    return appointment;
  }

  Map<String, dynamic> appointmentToMap(Appointment inAppointment) {
    final map = Map<String, dynamic>();
    map['id'] = inAppointment.id;
    map['title'] = inAppointment.title;
    map['description'] = inAppointment.description;
    map['apptDate'] = inAppointment.apptDate;
    map['apptTime'] = inAppointment.apptTime;
    return map;
  }
}
