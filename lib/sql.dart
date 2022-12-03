import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:uuid/uuid.dart';

final uuid = Uuid();

var user = "f5fed5cc-1fdc-40bf-a258-0b933459e637";

class NoteViewModel {
  static Future<void> createTables(sql.Database database) async {
    await database.execute("""CREATE TABLE items(
      id INTEGER PRIMARY KEY,
      pubid TEXT,
      time TEXT,
      subject TEXT,
      flag INTEGER,
      user TEXT,
      description TEXT)
    """);
  }

  static Future<sql.Database> db() async {
    return sql.openDatabase(
      'items.db',
      version: 1,
      onCreate: (sql.Database database, int version) async {
        await createTables(database);
      },
    );
  }

  static Future<int> createItem(String? subject, String? description) async {
    final db = await NoteViewModel.db();
    // UUID Key Generator
    final pubid = uuid.v4();
    int flag = 0;
    final now = DateTime.now().toString();
    final data = {
      'pubid': pubid,
      'time': now,
      'subject': subject,
      'description': description,
      'flag': flag,
      'user': user
    };
    final id = await db.insert('items', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  static Future<List<Map<String, dynamic>>> getNotes() async {
    final db = await NoteViewModel.db();
    return db.query('items', orderBy: "id");
  }

  static Future<List<Map<String, dynamic>>> getItem(int id) async {
    final db = await NoteViewModel.db();
    return db.query('items', where: "id = ?", whereArgs: [id], limit: 1);
  }

  static Future<int> updateItem(
      int id, String subject, String? descrption) async {
    final db = await NoteViewModel.db();

    final data = {
      'subject': subject,
      'description': descrption,
      'time': DateTime.now().toString()
    };

    final result =
        await db.update('items', data, where: "id = ?", whereArgs: [id]);
    return result;
  }

  static Future<void> deleteItem(int id) async {
    final db = await NoteViewModel.db();
    try {
      await db.delete("items", where: "id = ?", whereArgs: [id]);
    } catch (err) {
      debugPrint("Something went wrong when deleting an item: $err");
    }
  }

  static Future<void> dumpToJson() async {
    try {
      debugPrint("[DUMP]: Start to dump items to JSON Files.");
    } catch (err) {
      debugPrint("Something went wrong when dumping items: $err");
    }
  }
}
