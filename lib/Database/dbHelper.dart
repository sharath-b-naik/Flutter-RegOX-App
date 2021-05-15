import 'dart:io';

import 'package:assign/Models/models.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  Database _database;

  DBHelper._();
  static final DBHelper instance = DBHelper._();

  Future<Database> get db async {
    if (_database != null) {
      return _database;
    }
    _database = await _initDB();
    return _database;
  }

  _initDB() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + "assignment.db";
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  _onCreate(Database database, int version) async {
    await database.execute(
        "CREATE TABLE assignment (id INTEGER PRIMARY KEY AUTOINCREMENT, fullName TEXT, phoneNumber INTEGER, productType TEXT, amount TEXT, amountType TEXT, profileImagePath TEXT, date TEXT)");
  }

  Future<List<Client>> getAllData() async {
    Database dbC = await db;
    List<Map> maps =
        await dbC.rawQuery("SELECT * FROM assignment ORDER BY date");

    List<Client> listOfData = [];
    if (maps.length != null) {
      for (var i in maps) {
        listOfData.add(Client.fromMap(i));
      }
    }
    return listOfData;
  }

  Future<int> insertRegister(Client client) async {
    Database dbC = await db;
    return await dbC.insert("assignment", client.toMap());
  }
}
