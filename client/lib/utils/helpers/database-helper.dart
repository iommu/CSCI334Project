import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static Future<Database> getDatabase() async {
    return openDatabase(
      join(await getDatabasesPath(), 'visits_database.db'),
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE visits(id INTEGER PRIMARY KEY, datetime TEXT, location TEXT)",
        );
      },
    );
  }

  static Future<void> insertVisit(Visit visit) async {
    final Database db = await getDatabase();
    await db.insert(
      'visits',
      visit.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}

class Visit {
  final int id; // dummy id for primary key
  final String datetime; // iso8601
  final String location; // iso6709

  Visit(this.id, this.datetime, this.location);

  Map<String, dynamic> toMap() {
    return {'id': id, 'datetime': datetime, 'location': location};
  }

  @override
  String toString() {
    return "id:${id.toString()} datetime:$datetime location:$location";
  }
}
