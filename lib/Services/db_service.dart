import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart' as path;
import 'package:sqflite/sqlite_api.dart';

class DBHelper {
  static Future<Database> database() async {
    final dbPath = await sql.getDatabasesPath();
    return sql.openDatabase(path.join(dbPath, 'blinks.db'),
        onCreate: (db, version) {
      return db.execute(
          'CREATE TABLE blinks(id TEXT PRIMARY KEY,blinkCount integer,time TEXT)');
    }, version: 1);
  }

  static Future<void> insert(String table, Map<String, dynamic> data) async {
    final db = await DBHelper.database();
    db.insert(table, data, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<List<Map<String, Object?>>> getBlink(String table) async {
    final db = await DBHelper.database();
    return await db.query(table);
  }
}
