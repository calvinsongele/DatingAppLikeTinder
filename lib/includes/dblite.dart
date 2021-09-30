import 'dart:async';
import 'dart:io' as io;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
class DbLite {
  static Database _database;
  static const String DBNAME = 'users';
   /// DbLite();

    Future<Database> get db async {
      if (_database != null ) {
        return _database;
      }
      _database = await initdatabse();
      return _database;
    }
    initdatabse() async {
      io.Directory documentdirectory = await getApplicationDocumentsDirectory();
      String path = join(documentdirectory.path, DBNAME);
      return await openDatabase(path, version:1, onCreate: _onCreate);
    }
    _onCreate(Database db, int version) async {
     // String sql = "CREATE $TABLE (us) "
     // await db.execute(sql);
    }

    insert() {
     // String sql = "SELECT * FROM users WHERE ";
    }

    delete() {

    }

    update() {

    }

    _tablexists() {

    }
    _createtable() {

    }
}