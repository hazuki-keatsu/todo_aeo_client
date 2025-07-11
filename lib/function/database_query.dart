import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

// Sqflite操作封装

class DatabaseQuery {
  static final DatabaseQuery _instance = DatabaseQuery._internal();
  static DatabaseQuery get instance => _instance;

  static Database? _database;
  DatabaseQuery._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('todoContent.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    // 创建todos表
    await db.execute('''
      CREATE TABLE todos(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        isCompleted INTEGER NOT NULL DEFAULT 0,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');
    
    // 创建settings表
    await db.execute('''
      CREATE TABLE settings(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        key TEXT UNIQUE NOT NULL,
        value TEXT NOT NULL
      )
    ''');
  }

  // Todo操作
  Future<List<Map<String, dynamic>>> getAllTodos() async {
    final db = await instance.database;
    return await db.query('todos', orderBy: 'createdAt DESC');
  }

  Future<int> insertTodo(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('todos', row);
  }

  Future<int> updateTodo(Map<String, dynamic> row) async {
    final db = await instance.database;
    final id = row['id'];
    return await db.update('todos', row, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteTodo(int id) async {
    final db = await instance.database;
    return await db.delete('todos', where: 'id = ?', whereArgs: [id]);
  }

  // Settings操作
  Future<String?> getSetting(String key) async {
    final db = await instance.database;
    final result = await db.query('settings', where: 'key = ?', whereArgs: [key]);
    return result.isNotEmpty ? result.first['value'] as String : null;
  }

  Future<int> setSetting(String key, String value) async {
    final db = await instance.database;
    return await db.insert(
      'settings',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}