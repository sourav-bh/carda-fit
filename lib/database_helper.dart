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
    String path = join(documentsDirectory.path, 'carda_fit.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE public_users(
        id INTEGER PRIMARY KEY,
        full_name TEXT,
        age DOUBLE,
        weight DOUBLE,
        height DOUBLE,  
        bmi DOUBLE,
        job_time DOUBLE,
        job_type user.job_type,
        created_at TIMESTAMP,
        done INETEGER
      )
    ''');
    await db.execute('''
      CREATE TABLE trainer_tasks(
        id INTEGER PRIMARY KEY,
        name VARCHAR,
        difficulty_level INTEGER,
        description VARCHAR,
        frequency INTEGER,
        duration INTEGER,
        score DOUBLE,
        created_at TIMESTAMP,
        done INTEGER
      )
    ''');
    await db.execute('''
      CREATE TABLE trainer_exercises(
        id INTEGER PRIMARY KEY,
        name VARCHAR,
        difficulty_level INTEGER,
        description VARCHAR,
        created_at TIMESTAMP,
        done INTEGER
      )
    ''');
    await db.execute('''
      CREATE TABLE user.allergies(
        code INTEGER PRIMARY KEY,
        name VARCHAR,
        description VARCHAR,
        cause VARCHAR,
        done INTEGER
      )
    ''');
    await db.execute('''
      CREATE TABLE user.user_allergies(
        user_id INTEGER PRIMARY KEY,
        allergy_code INTEGER
        done INTEGER
      )
    ''');
    await db.execute('''
      CREATE TABLE user.user_tasks(
        user_id INTEGER PRIMARY KEY,
        task_id INTEGER,
        total_due_count INTEGER,
        completed_count INTEGER,
        created_at TIMESTAMP,
        last_updated_at TIMESTAMP,
        done INTEGER
      )
    ''');
    await db.execute('''
      CREATE TABLE user.user_alert(
        id INTEGER PRIMARY KEY,
        user_id INTEGER,
        task_id INTEGER,
        title VARCHAR,
        description INTEGER,
        content_uri VARCHAR,
        status public.task_status
        created_at TIMESTAMP,
        updated_at TIMESTAMP,
        done INTEGER
      )
    ''');
    await db.execute('''
      CREATE TABLE user.user_exercises(
        user_id INTEGER PRIMARY KEY,
        exercise_id INTEGER,
        done INTEGER
      )
    ''');
    await db.execute('''
      CREATE TABLE user.condition(
        code INTEGER PRIMARY KEY,
        name VARCHAR,
        description VARCHAR,
        frequency INTEGER,
        done INTEGER
      )
    ''');
    await db.execute('''
      CREATE TABLE user.user_condition(
        user_id INTEGER PRIMARY KEY,
        condition_code INTEGER
        done INTEGER
      )
    ''');
    await db.execute('''
      CREATE TABLE trainer.learning(
        id INTEGER PRIMARY KEY,
        title VARCHAR,
        description VARCHAR,
        content_uri VARCHAR,
        target_user_level USERS.LEVEL,
        content_type LEARNING.CONTENT_TYPE,
        created_at TIMESTAMP,
        done INTEGER
      )
    ''');
    await db.execute('''
      CREATE TABLE user.learning_contents(
        user_id INTEGER PRIMARY KEY,
        content_id INTEGER,
        view_count INTEGER,
        last_viewed_at TIMESTAMP,
        done INTEGER
      )
    ''');
    await db.execute('''
      CREATE TABLE public.scorer(
        id INTEGER PRIMARY KEY,
        user_id INTEGER,
        current_score DOUBLE,
        current_level USER.LEVEL,
        current_rank INTEGER,
        current_streak INTEGER,
        longest_streak INTEGER,
        done INTEGER
      )
    ''');
  }

  Future<List<UserInfo>> getUserInfos() async {
    Database db = await instance.database;
    var userInfo = await db.query('public_users', orderBy: 'full_name');
    List<UserInfo> userInfoList = userInfo.isNotEmpty
        ? userInfo.map((e) => UserInfo.fromMap(e)).toList()
        : [];
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
    return await db.update('public_users', item.toMap(),
        where: 'id = ?', whereArgs: [item.userId]);
  }
}
