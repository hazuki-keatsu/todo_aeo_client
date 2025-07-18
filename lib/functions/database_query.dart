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
    // 创建categories表
    await db.execute('''
      CREATE TABLE categories(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        color TEXT,
        createdAt TEXT NOT NULL
      )
    ''');
    
    // 创建todos表
    await db.execute('''
      CREATE TABLE todos(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        isCompleted INTEGER NOT NULL DEFAULT 0,
        categoryId INTEGER,
        createdAt TEXT NOT NULL,
        finishingAt TEXT,
        FOREIGN KEY (categoryId) REFERENCES categories (id) ON DELETE SET NULL
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

  // Category操作
  Future<List<Map<String, dynamic>>> getAllCategories() async {
    final db = await instance.database;
    return await db.query('categories', orderBy: 'createdAt DESC');
  }

  Future<int> insertCategory(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('categories', row);
  }

  Future<int> updateCategory(Map<String, dynamic> row) async {
    final db = await instance.database;
    final id = row['id'];
    return await db.update('categories', row, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteCategory(int id) async {
    final db = await instance.database;
    // 删除分类时，将该分类下的todos的categoryId设为null
    await db.update('todos', {'categoryId': null}, where: 'categoryId = ?', whereArgs: [id]);
    return await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  Future<Map<String, dynamic>?> getCategoryById(int id) async {
    final db = await instance.database;
    final result = await db.query('categories', where: 'id = ?', whereArgs: [id]);
    return result.isNotEmpty ? result.first : null;
  }

  // 获取指定分类下的todos
  Future<List<Map<String, dynamic>>> getTodosByCategory(int categoryId) async {
    final db = await instance.database;
    return await db.query('todos', where: 'categoryId = ?', whereArgs: [categoryId], orderBy: 'createdAt DESC');
  }

  // 获取未分类的todos
  Future<List<Map<String, dynamic>>> getUncategorizedTodos() async {
    final db = await instance.database;
    return await db.query('todos', where: 'categoryId IS NULL', orderBy: 'createdAt DESC');
  }

  // 获取todos及其分类信息
  Future<List<Map<String, dynamic>>> getTodosWithCategory() async {
    final db = await instance.database;
    return await db.rawQuery('''
      SELECT 
        t.*,
        c.name as categoryName,
        c.color as categoryColor
      FROM todos t
      LEFT JOIN categories c ON t.categoryId = c.id
      ORDER BY t.createdAt DESC
    ''');
  }

  // 清空所有数据但保留表结构
  Future<void> clearAllData() async {
    final db = await instance.database;
    
    // 开始事务，确保所有操作要么全部成功，要么全部失败
    await db.transaction((txn) async {
      // 清空todos表
      await txn.delete('todos');
      
      // 清空categories表
      await txn.delete('categories');
      
      // 清空settings表
      await txn.delete('settings');
      
      // 重置自增ID（可选）
      await txn.delete('sqlite_sequence', where: 'name IN (?, ?, ?)', 
          whereArgs: ['todos', 'categories', 'settings']);
    });
  }

  // 单独清空todos表
  Future<void> clearTodos() async {
    final db = await instance.database;
    await db.delete('todos');
    // 重置自增ID（可选）
    await db.delete('sqlite_sequence', where: 'name = ?', whereArgs: ['todos']);
  }

  // 单独清空categories表
  Future<void> clearCategories() async {
    final db = await instance.database;
    await db.delete('categories');
    // 重置自增ID（可选）
    await db.delete('sqlite_sequence', where: 'name = ?', whereArgs: ['categories']);
  }

  // 单独清空settings表
  Future<void> clearSettings() async {
    final db = await instance.database;
    await db.delete('settings');
    // 重置自增ID（可选）
    await db.delete('sqlite_sequence', where: 'name = ?', whereArgs: ['settings']);
  }
}