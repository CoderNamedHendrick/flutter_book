import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../utils.dart' as utils;
import 'contacts_model.dart' show Contact;

class ContactsDBWorker {
  ContactsDBWorker._();
  static final ContactsDBWorker db = ContactsDBWorker._();

  Database? _db;

  Future get database async {
    if (_db == null) {
      _db = await init();
    }
    return _db;
  }

  Future<Database> init() async {
    final path = join(utils.docsDir!.path, 'contacts.db');
    final db = await openDatabase(
      path,
      version: 1,
      onOpen: (db) {},
      onCreate: (Database inDB, int inVersion) {
        inDB.execute(
          'CREATE TABLE IF NOT EXIST contacts (' +
              'id INTEGER PRIMARY KEY, ' +
              'name TEXT, ' +
              'email TEXT, ' +
              'phone TEXT, ' +
              'birthday TEXT' +
              ')',
        );
      },
    );
    return db;
  }

  Future create(Contact inContact) async {
    final db = await database;
    final val = await db.rawQuery('SELECT MAX(id) + 1 AS id FROM contacts');
    var id = val.first['id'] as int?;
    if (id == null) {
      id = 1;
    }

    return await db.rawInsert(
      'INSERT INTO contacts (id, name, email, phone, birthday) '
      'VALUES(?, ?, ?, ?, ?)',
      [
        id,
        inContact.name,
        inContact.email,
        inContact.phone,
        inContact.birthday,
      ],
    );
  }

  Future<Contact> get(int inID) async {
    final db = await database;
    final rec = await db.query(
      'contacts',
      where: 'id = ?',
      whereArgs: [inID],
    );
    return contactFromMap(rec.first);
  }

  Future<List> getAll() async {
    final db = await database;
    final recs = await db.query('contacts');
    final list =
        recs.isNotEmpty ? recs.map((e) => contactFromMap(e)).toList() : [];
    return list;
  }

  Future update(Contact inContact) async {
    final db = await database;
    return db.update(
      'contacts',
      where: 'id = ?',
      whereArgs: [inContact.id],
    );
  }

  Future delete(int inID) async {
    final db = await database;
    return db.delete(
      'contacts',
      where: 'id = ?',
      whereArgs: [inID],
    );
  }

  Contact contactFromMap(Map<String, dynamic> inMap) {
    final contact = Contact();
    contact.id = inMap['id'];
    contact.name = inMap['name'];
    contact.email = inMap['email'];
    contact.phone = inMap['phone'];
    contact.birthday = inMap['birthday'];
    return contact;
  }

  Map<String, dynamic> contactToMap(Contact inContact) {
    final map = Map<String, dynamic>();
    map['id'] = inContact.id;
    map['name'] = inContact.name;
    map['email'] = inContact.email;
    map['phone'] = inContact.phone;
    map['birthday'] = inContact.birthday;
    return map;
  }
}
