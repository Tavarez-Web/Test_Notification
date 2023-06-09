import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'notification_model.dart';

class DatabaseHelper {
  //Create a private constructor
  DatabaseHelper._();

  static const databaseName = 'notifications_push_v2.db';

  static final DatabaseHelper instance = DatabaseHelper._();
  static late Database _database;
  static final columnId = 'id';

  Future<Database> get database async {
    if (_database == null) {
      return await initializeDatabase();
    }
    return _database;
  }

  initializeDatabase() async {
    var r = await openDatabase(join(await getDatabasesPath(), databaseName),
        version: 1, onCreate: (Database db, int version) async {
      await db.execute(
          "CREATE TABLE Notification(id INTEGER PRIMARY KEY AUTOINCREMENT, subject TEXT NOT NULL, title TEXT NOT NULL, message TEXT NOT NULL, imageUrl TEXT,  type TEXT, data TEXT)");
      await db.execute("""CREATE TABLE Amount(
            amounts_list_id INTEGER NOT NULL,
            name TEXT NOT NULL, 
            value TEXT NOT NULL, 
            FOREIGN KEY (amounts_list_id) REFERENCES Notification(id))
          """);
    });

    _database = r;

    return r;
  }

  var idIndex = 0;

  insertNotification(NotificationModel noti) async {
    final db = await database;
    var query = await db.query(NotificationModel.TABLENAME,
        where: "id = ?", whereArgs: [noti.id]);

    do {
      idIndex++;
    } while (query.length < 0);
    noti.id = idIndex;
    await db.insert(
      NotificationModel.TABLENAME,
      noti.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<NotificationModel>> retrieveNotifications() async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query(NotificationModel.TABLENAME, orderBy: "$columnId DESC");

    var list = List.generate(maps.length, (i) {
      return NotificationModel(
          id: maps[i]['id'],
          subject: maps[i]['subject'],
          title: maps[i]['title'],
          type: maps[i]['type'],
          imageUrl: maps[i]['imageUrl'],
          message: maps[i]['message'],
          data: maps[i]['data'].toString());
    });

    print(list);

    list.sort((b, a) => b.id!.compareTo(a.id!));

    return list;
  }

  // this method is not necessary
  updateNotification(NotificationModel todo) async {
    final db = await database;

    await db.update(NotificationModel.TABLENAME, todo.toMap(),
        where: 'id = ?',
        whereArgs: [todo.id],
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  deleteNotification(int id) async {
    var db = await database;
    db.delete(NotificationModel.TABLENAME, where: 'id = ?', whereArgs: [id]);
  }

  Future<NotificationModel> getNotificationByIdv2(int id) async {
    var db = await database;
    var result = await db
        .query(NotificationModel.TABLENAME, where: 'id = ?', whereArgs: [id]);
    // print("result[0] $result");

    print("getNotificationById" + result.toString());

    return NotificationModel.fromJSON(result.first);
  }

  Future<NotificationModel> getNotificationById(int id) async {
    var db = await database;
    var result = await db
        .query(NotificationModel.TABLENAME, where: 'id = ?', whereArgs: [id]);
    print("result[0] $result");

    var r = List<Map<String, dynamic>>.generate(
        result.length, (index) => Map<String, dynamic>.from(result[index]),
        growable: true);

    return NotificationModel.fromJsonNotificationV2(r[0] as dynamic);
  }
}
