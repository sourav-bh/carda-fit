import 'dart:io';
import 'package:app/model/allergy.dart';
import 'package:app/model/exercise.dart';
import 'package:app/model/user_exercise.dart';
import 'package:app/model/user_info.dart';
import 'package:path/path.dart';
import 'package:app/model/user_allergy.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:app/model/learning.dart';
import 'package:app/model/user_learning_contents.dart';

const TABLE_USER = 'user';
const TABLE_TASKS = 'tasks';
const TABLE_EXERCISES = 'exercises';
const TABLE_USER_EXERCISES = 'user_exercises';
const TABLE_USER_ALLERGY = 'user_allergies';
const TABLE_ALLERGY = 'allergies';
const TABLE_LEARNING = 'learning';
const TABLE_USER_LEARNING_CONTENTS = 'user_learning_contents';

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
      CREATE TABLE ${TABLE_USER}(
        id INTEGER PRIMARY KEY,
        fullName TEXT,
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
      CREATE TABLE ${TABLE_TASKS}(
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
      CREATE TABLE ${TABLE_EXERCISES}(
        id INTEGER PRIMARY KEY,
        name VARCHAR,
        difficulty_level INTEGER,
        description VARCHAR,
        created_at TIMESTAMP,
        done INTEGER
      )
    ''');
    await db.execute('''
      CREATE TABLE ${TABLE_ALLERGY}(
        code INTEGER PRIMARY KEY,
        name VARCHAR,
        description VARCHAR,
        cause VARCHAR,
        done INTEGER
      )
    ''');
    await db.execute('''
      CREATE TABLE ${TABLE_USER_ALLERGY}(
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
      CREATE TABLE ${TABLE_USER_EXERCISES}(
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
      CREATE TABLE ${TABLE_LEARNING}(
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
      CREATE TABLE ${TABLE_USER_LEARNING_CONTENTS}(
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

  /// public_users

  Future<List<UserInfo>> getUserInfo() async {
    Database db = await instance.database;
    var userInfo = await db.query(TABLE_USER, orderBy: 'full_name');
    List<UserInfo> userInfoList = userInfo.isNotEmpty
        ? userInfo.map((e) => UserInfo.fromMap(e)).toList()
        : [];
    return userInfoList;
  }

  Future<int> addUser(UserInfo item) async {
    Database db = await instance.database;
    return await db.insert(TABLE_USER, item.toMap());
  }

  Future<int> removeUser(int id) async {
    Database db = await instance.database;
    return await db.delete(TABLE_USER, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateUser(UserInfo item) async {
    Database db = await instance.database;
    return await db.update(TABLE_USER, item.toMap(),
        where: 'id = ?', whereArgs: [item.userId]);
  }

  /// user_allergies

  Future<List<UserAllergy>> getUserAllergies() async {
    Database db = await instance.database;
    var userAllergy = await db.query(TABLE_USER_ALLERGY, orderBy: 'user_id');
    List<UserAllergy> userAllergyList = userAllergy.isNotEmpty
        ? userAllergy.map((e) => UserAllergy.fromMap(e)).toList()
        : [];
    return userAllergyList;
  }

  Future<int> addUserAllergy(UserAllergy item) async {
    Database db = await instance.database;
    return await db.insert(TABLE_USER_ALLERGY, item.toMap());
  }

  Future<int> removeUserAllergy(int id) async {
    Database db = await instance.database;
    return await db
        .delete(TABLE_USER_ALLERGY, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateUserAllergy(UserAllergy item) async {
    Database db = await instance.database;
    return await db.update(TABLE_USER_ALLERGY, item.toMap(),
        where: 'id = ?', whereArgs: [item.userId]);
  }

  /// allerrgies

  Future<List<Allergy>> getAllergies() async {
    Database db = await instance.database;
    var allergies = await db.query(TABLE_ALLERGY, orderBy: 'code');
    List<Allergy> allergyList = allergies.isNotEmpty
        ? allergies.map((e) => Allergy.fromMap(e)).toList()
        : [];
    return allergyList;
  }

  Future<int> addAllergy(Allergy item) async {
    Database db = await instance.database;
    return await db.insert(TABLE_ALLERGY, item.toMap());
  }

  Future<int> removeAllergy(int id) async {
    Database db = await instance.database;
    return await db.delete(TABLE_ALLERGY, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateAllergy(Allergy item) async {
    Database db = await instance.database;
    return await db.update(TABLE_ALLERGY, item.toMap(),
        where: 'id = ?', whereArgs: [item.code]);
  }

  /// learning

  Future<List<Learning>> getAllLearnings() async {
    Database db = await instance.database;
    var learnings = await db.query(TABLE_LEARNING, orderBy: 'title');
    List<Learning> learningList = learnings.isNotEmpty
        ? learnings.map((e) => Learning.fromMap(e)).toList()
        : [];
    return learningList;
  }

  Future<int> addLearning(Learning item) async {
    Database db = await instance.database;
    return await db.insert(TABLE_LEARNING, item.toMap());
  }

  Future<int> removeLearning(int id) async {
    Database db = await instance.database;
    return await db.delete(TABLE_LEARNING, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateLearning(Learning item) async {
    Database db = await instance.database;
    return await db.update(TABLE_LEARNING, item.toMap(),
        where: 'id = ?', whereArgs: [item.title]);
  }

  /// user_learning_contents

  Future<List<UserLearningContent>> getUserLearningContents() async {
    Database db = await instance.database;
    var userLearningContents =
        await db.query(TABLE_USER_LEARNING_CONTENTS, orderBy: 'view_count');
    List<UserLearningContent> userLearningContentList =
        userLearningContents.isNotEmpty
            ? userLearningContents
                .map((e) => UserLearningContent.fromMap(e))
                .toList()
            : [];
    return userLearningContentList;
  }

  Future<int> addUserLearningContent(UserLearningContent item) async {
    Database db = await instance.database;
    return await db.insert(TABLE_USER_LEARNING_CONTENTS, item.toMap());
  }

  Future<int> removeUserLearningContent(int id) async {
    Database db = await instance.database;
    return await db
        .delete(TABLE_USER_LEARNING_CONTENTS, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateUserLearningContent(UserLearningContent item) async {
    Database db = await instance.database;
    return await db.update(TABLE_USER_LEARNING_CONTENTS, item.toMap(),
        where: 'id = ?', whereArgs: [item.viewCount]);
  }

  /// exercise

  Future<List<Exercise>> getExercises() async {
    Database db = await instance.database;
    var exercises = await db.query(TABLE_EXERCISES, orderBy: 'name');
    List<Exercise> exerciseList = exercises.isNotEmpty
        ? exercises.map((e) => Exercise.fromMap(e)).toList()
        : [];
    return exerciseList;
  }

  Future<int> addExercise(Exercise item) async {
    Database db = await instance.database;
    return await db.insert(TABLE_EXERCISES, item.toMap());
  }

  Future<int> removeExercise(int id) async {
    Database db = await instance.database;
    return await db.delete(TABLE_EXERCISES, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateExercise(Exercise item) async {
    Database db = await instance.database;
    return await db.update(TABLE_EXERCISES, item.toMap(),
        where: 'id = ?', whereArgs: [item.name]);
  }

  /// user_exercise

  Future<List<UserExercise>> getUserExercises() async {
    Database db = await instance.database;
    var userExercises =
        await db.query(TABLE_USER_EXERCISES, orderBy: 'user_id');
    List<UserExercise> userExerciseList = userExercises.isNotEmpty
        ? userExercises.map((e) => UserExercise.fromMap(e)).toList()
        : [];
    return userExerciseList;
  }

  Future<int> addUserExercise(UserExercise item) async {
    Database db = await instance.database;
    return await db.insert(TABLE_USER_EXERCISES, item.toMap());
  }

  Future<int> removeUserExercise(int id) async {
    Database db = await instance.database;
    return await db
        .delete(TABLE_USER_EXERCISES, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateUserExercise(UserExercise item) async {
    Database db = await instance.database;
    return await db.update(TABLE_USER_EXERCISES, item.toMap(),
        where: 'id = ?', whereArgs: [item.userId]);
  }
}
