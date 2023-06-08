import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'notification_model.dart';

class DatabaseHelper {
  //Create a private constructor
  DatabaseHelper._();

  static const databaseName = 'notifications_push_v1.db';

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
          "CREATE TABLE Notification(id INTEGER PRIMARY KEY AUTOINCREMENT, subject TEXT NOT NULL, title TEXT NOT NULL, message TEXT NOT NULL, imageUrl TEXT,  type TEXT)");
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

  insertNotification(NotificationModel noti) async {
    final db = await database;
    if (noti.data == null) {
      var res = await db.insert(NotificationModel.TABLENAME, noti.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
      return;
    }

    noti.data?.forEach((element) async {
      var amountInfo = {
        "value": element['value'].toString(),
        "name": element['name'].toString(),
        "amounts_list_id": element['value'].hashCode
      };
      await db.insert(
        NotificationModel.SUB_TABLENAME,
        amountInfo,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });

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
          data: maps[i]['data']);
    });

    list.sort((a, b) => b.id!.compareTo(a.id!));

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

  Future<NotificationModel> getNotificationById(int id) async {
    var db = await database;
    var result = await db
        .query(NotificationModel.TABLENAME, where: 'id = ?', whereArgs: [id]);

    print("getNotificationById" + result.toString());

    return NotificationModel.fromJSON(result.first);
  }

    Future<List<TypeNotification>> getDataNotificationById(int id) async {
    var db = await database;
    var result = await db
        .query(NotificationModel.SUB_TABLENAME, where: 'amounts_list_id = ?', whereArgs: [id]);

     var result2 = await db
        .query(NotificationModel.SUB_TABLENAME);

    print("getDataNotificationById" + result.toString());
    print("getDataNotificationById2" + result2.toString());

    return List.generate(result2.length, (index)=> TypeNotification.fromJSON(result2[index]));
  }
  
}


