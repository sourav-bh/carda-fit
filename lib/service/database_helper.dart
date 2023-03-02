import 'dart:io';
import 'package:app/model/allergy.dart';
import 'package:app/model/condition.dart';
import 'package:app/model/exercise.dart';
import 'package:app/model/scorer.dart';
import 'package:app/model/user_condition.dart';
import 'package:app/model/user_exercise.dart';
import 'package:app/model/user_info.dart';
import 'package:app/model/user_task.dart';
import 'package:path/path.dart';
import 'package:app/model/user_allergy.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:app/model/learning.dart';
import 'package:app/model/user_learning_contents.dart';
import 'package:app/model/task_alert.dart';

import '../model/task.dart';
import '../model/task_alert.dart';
import '../model/task_alert.dart';

const TABLE_USER = 'user';
const TABLE_TASK = 'task';
const TABLE_EXERCISES = 'exercises';
const TABLE_EXERCISE_STEPS = 'exercise_steps';
const TABLE_USER_EXERCISES = 'user_exercises';
const TABLE_USER_ALLERGY = 'user_allergies';
const TABLE_ALLERGY = 'allergies';
const TABLE_LEARNING = 'learning';
const TABLE_USER_LEARNING_CONTENTS = 'user_learning_contents';
const TABLE_CONDITION = 'condition';
const TABLE_USER_CONDITION = 'user_condition';
const TABLE_USER_TASK = 'user_tasks';
const TABLE_SCORER = 'public_scorer';
const TABLE_TASK_ALERT = 'task_alert';

class DatabaseHelper {
  // Singleton Pattern
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async => _database ??= await _initDatabase();

  Future<Database> _initDatabase() async {
    Directory? documentsDirectory = await getExternalStorageDirectory();
    String path = join(documentsDirectory?.path ?? "", 'carda_fit.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute("CREATE TABLE ${TABLE_USER}("
        "id INTEGER PRIMARY KEY,"
        "fullName TEXT,"
        "avatar VARCHAR,"
        "gender VARCHAR,"
        "age INTEGER,"
        "weight INTEGER,"
        "height INTEGER,"
        "designation VARCHAR,"
        "job_type VARCHAR,"
        "condition VARCHAR,"
        "created_at TIMESTAMP)");
    await db.execute("CREATE TABLE ${TABLE_TASK}("
        "id INTEGER PRIMARY KEY,"
        "name VARCHAR,"
        "difficulty_level INTEGER,"
        "description VARCHAR,"
        "frequency INTEGER,"
        "duration INTEGER,"
        "score DOUBLE,"
        "created_at TIMESTAMP)");
    await db.execute("CREATE TABLE ${TABLE_EXERCISES}("
        "id INTEGER PRIMARY KEY,"
        "condition VARCHAR,"
        "name VARCHAR,"
        "description VARCHAR,"
        "url VARCHAR,"
        "duration INTEGER,"
        "difficulty_level INTEGER,"
        "created_at TIMESTAMP)");
    await db.execute("CREATE TABLE ${TABLE_EXERCISE_STEPS}("
        "id INTEGER PRIMARY KEY,"
        "serial_no VARCHAR,"
        "name VARCHAR,"
        "details VARCHAR,"
        "media VARCHAR,"
        "duration INTEGER,"
        "created_at TIMESTAMP)");
    await db.execute("CREATE TABLE ${TABLE_USER_TASK}("
        "user_id INTEGER PRIMARY KEY,"
        "task_id INTEGER,"
        "total_due_count INTEGER,"
        "completed_count INTEGER,"
        "created_at TIMESTAMP,"
        "last_updated_at TIMESTAMP)");
    await db.execute("CREATE TABLE ${TABLE_USER_EXERCISES}("
        "user_id INTEGER PRIMARY KEY,"
        "exercise_id INTEGER,"
        "done INTEGER)");
    await db.execute("CREATE TABLE ${TABLE_LEARNING}("
        "id INTEGER PRIMARY KEY,"
        "condition VARCHAR,"
        "title VARCHAR,"
        "description VARCHAR,"
        "content_uri VARCHAR,"
        "target_user_level VARCHAR,"
        "content_type VARCHAR,"
        "created_at TIMESTAMP,"
        "condition VARCHAR,"
        "done INTEGER)");
    await db.execute("CREATE TABLE ${TABLE_USER_LEARNING_CONTENTS}("
        "user_id INTEGER PRIMARY KEY,"
        "content_id INTEGER,"
        "favourite INTEGER,"
        "view_count INTEGER,"
        "last_viewed_at TIMESTAMP,"
        "done INTEGER)");
  }

  /// public_users

  Future<List<UserInfo>> getAllUserInfo() async {
    Database db = await instance.database;
    var userInfo = await db.query(TABLE_USER, orderBy: 'full_name');
    List<UserInfo> userInfoList = userInfo.isNotEmpty
        ? userInfo.map((e) => UserInfo.fromMap(e)).toList()
        : [];
    return userInfoList;
  }

  Future<UserInfo?> getUserInfo(int id) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> users =
        await db.query(TABLE_USER, where: 'id = ?', whereArgs: [id]);
    if (users.isNotEmpty) {
      return UserInfo.fromMap(users.first);
    } else {
      return null;
    }
  }

  Future<int> addUser(UserInfo item) async {
    Database db = await instance.database;
    return await db.insert(TABLE_USER, item.toMap());
  }

  Future<int> removeUser(int id) async {
    Database db = await instance.database;
    return await db.delete(TABLE_USER, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateUser(UserInfo item, int id) async {
    Database db = await instance.database;
    return await db
        .update(TABLE_USER, item.toMap(), where: 'id = ?', whereArgs: [id]);
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

  /// learning contents
  Future<List<LearningContent>> getLearningContents() async {
    Database db = await instance.database;
    var learnings = await db.query(TABLE_LEARNING, orderBy: 'title');
    List<LearningContent> learningList = learnings.isNotEmpty
        ? learnings.map((e) => LearningContent.fromMap(e)).toList()
        : [];
    return learningList;
  }

  Future<int> addLearningContent(LearningContent item) async {
    Database db = await instance.database;
    return await db.insert(TABLE_LEARNING, item.toMap());
  }

  Future<int> removeLearningContent(int id) async {
    Database db = await instance.database;
    return await db.delete(TABLE_LEARNING, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateLearningContent(LearningContent item) async {
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

  /// condition

  Future<List<Condition>> getCondition() async {
    Database db = await instance.database;
    var conditions = await db.query(TABLE_CONDITION, orderBy: 'code');
    List<Condition> conditionList = conditions.isNotEmpty
        ? conditions.map((e) => Condition.fromMap(e)).toList()
        : [];
    return conditionList;
  }

  Future<int> addCondition(Condition item) async {
    Database db = await instance.database;
    return await db.insert(TABLE_CONDITION, item.toMap());
  }

  Future<int> removeCondition(int id) async {
    Database db = await instance.database;
    return await db.delete(TABLE_CONDITION, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateCondition(Condition item) async {
    Database db = await instance.database;
    return await db.update(TABLE_LEARNING, item.toMap(),
        where: 'id = ?', whereArgs: [item.code]);
  }

  /// user_condition

  Future<List<UserCondition>> getUserCondition() async {
    Database db = await instance.database;
    var userConditions =
        await db.query(TABLE_USER_CONDITION, orderBy: 'user_id');
    List<UserCondition> userConditionList = userConditions.isNotEmpty
        ? userConditions.map((e) => UserCondition.fromMap(e)).toList()
        : [];
    return userConditionList;
  }

  Future<int> addUserCondition(UserCondition item) async {
    Database db = await instance.database;
    return await db.insert(TABLE_USER_CONDITION, item.toMap());
  }

  Future<int> removeUserCondition(int id) async {
    Database db = await instance.database;
    return await db
        .delete(TABLE_USER_CONDITION, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateUserCondition(UserCondition item) async {
    Database db = await instance.database;
    return await db.update(TABLE_USER_CONDITION, item.toMap(),
        where: 'id = ?', whereArgs: [item.userId]);
  }

  /// task

  Future<List<Task>> getTasks() async {
    Database db = await instance.database;
    var tasks = await db.query(TABLE_TASK, orderBy: 'user_id');
    List<Task> taskList =
        tasks.isNotEmpty ? tasks.map((e) => Task.fromMap(e)).toList() : [];
    return taskList;
  }

  Future<int> addTask(Task item) async {
    Database db = await instance.database;
    return await db.insert(TABLE_TASK, item.toMap());
  }

  Future<int> removeTask(int id) async {
    Database db = await instance.database;
    return await db.delete(TABLE_TASK, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateTask(Task item) async {
    Database db = await instance.database;
    return await db.update(TABLE_TASK, item.toMap(),
        where: 'id = ?', whereArgs: [item.userId]);
  }

  /// user_task

  Future<List<UserTask>> getUserTasks() async {
    Database db = await instance.database;
    var userTasks = await db.query(TABLE_USER_TASK, orderBy: 'user_id');
    List<UserTask> userTaskList = userTasks.isNotEmpty
        ? userTasks.map((e) => UserTask.fromMap(e)).toList()
        : [];
    return userTaskList;
  }

  Future<int> addUserTask(UserTask item) async {
    Database db = await instance.database;
    return await db.insert(TABLE_USER_TASK, item.toMap());
  }

  Future<int> removeUserTask(int id) async {
    Database db = await instance.database;
    return await db.delete(TABLE_USER_TASK, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateUserTask(UserTask item) async {
    Database db = await instance.database;
    return await db.update(TABLE_USER_TASK, item.toMap(),
        where: 'id = ?', whereArgs: [item.userId]);
  }

  /// scorer

  Future<List<Scorer>> getScores() async {
    Database db = await instance.database;
    var scores = await db.query(TABLE_SCORER, orderBy: 'scorer_id');
    List<Scorer> scorerList =
        scores.isNotEmpty ? scores.map((e) => Scorer.fromMap(e)).toList() : [];
    return scorerList;
  }

  Future<int> addScorer(Scorer item) async {
    Database db = await instance.database;
    return await db.insert(TABLE_SCORER, item.toMap());
  }

  Future<int> removeScorer(int id) async {
    Database db = await instance.database;
    return await db.delete(TABLE_SCORER, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateScorer(Scorer item) async {
    Database db = await instance.database;
    return await db.update(TABLE_SCORER, item.toMap(),
        where: 'id = ?', whereArgs: [item.scorerId]);
  }

  /// user_alert

  Future<List<TaskAlert>> TaskAlerts() async {
    Database db = await instance.database;
    var taskAlerts = await db.query(TABLE_TASK_ALERT, orderBy: 'alert_id');
    List<TaskAlert> taskAlertList = taskAlerts.isNotEmpty
        ? taskAlerts.map((e) => TaskAlert.fromMap(e)).toList()
        : [];
    return taskAlertList;
  }

  Future<int> addTaskAlert(TaskAlert item) async {
    Database db = await instance.database;
    return await db.insert(TABLE_TASK_ALERT, item.toMap());
  }

  Future<int> removeTaskAlert(int id) async {
    Database db = await instance.database;
    return await db.delete(TABLE_TASK_ALERT, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateTaskAlert(TaskAlert item) async {
    Database db = await instance.database;
    return await db.update(TABLE_TASK_ALERT, item.toMap(),
        where: 'id = ?', whereArgs: [item.alertId]);
  }
}
