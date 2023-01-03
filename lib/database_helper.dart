import 'dart:io';
import 'package:app/model/user_info.dart';
import 'package:path/path.dart';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  // Singleton Pattern
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async => _database ??= await _initDatabase();

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'public_users.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE public_users(
        id INEGER PRIMARY KEY,
        full_name TEXT,
        age DOUBLE,
        weight DOUBLE,
        height DOUBLE,  
        bmi DOUBLE,
        job_time Double
        job_type user.job_type
        created_at timestamp
        done INETEGER, 
      )
    ''');
  }

  Future<List<UserInfo>> getUserInfos() async {
    Database db = await instance.database;
    var userInfo = await db.query('public_users', orderBy: 'full_name');
    List<UserInfo> userInfoList =
      userInfo.isNotEmpty ? userInfo.map((e) => UserInfo.fromMap(e)).toList()
    return userInfoList;
  }

  Future<int> add(UserInfo item) async {
    Database db = await instance.database; 
    return await db.insert('public_users', item.toMap());
  }

  Future<int> remove(int id) async {
    Database db = await instance.database; 
    return await db.delete('public_users', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> update(UserInfo item) async {
    Database db = await instance.database; 
    return await db.update('public_users', item.toMap(), where: 'id = ?', whereArgs: [item.id]);
  }
}