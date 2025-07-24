import 'package:flutter/material.dart';
import 'package:todo_aeo/functions/database_query.dart';
import 'package:todo_aeo/modules/todo.dart';
import 'package:todo_aeo/modules/category.dart';

class TodoProvider extends ChangeNotifier {
  final DatabaseQuery _dq = DatabaseQuery.instance;
  
  List<Todo>? _todos;
  List<Category>? _categories;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Todo>? get todos => _todos;
  List<Category>? get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Initialize data
  Future<void> init() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.wait([
        _loadTodos(),
        _loadCategories(),
      ]);
    } catch (e) {
      _error = '初始化数据失败: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Private methods for loading data
  Future<void> _loadTodos() async {
    final todosData = await _dq.getAllTodos();
    _todos = todosData.map((data) => Todo.fromMap(data)).toList();
  }

  Future<void> _loadCategories() async {
    final categoriesData = await _dq.getAllCategories();
    _categories = categoriesData.map((data) => Category.fromMap(data)).toList();
  }

  // Get todos by category
  List<Todo> getTodosByCategory(int? categoryId) {
    if (_todos == null) return [];
    if (categoryId == null) {
      return _todos!.where((todo) => todo.categoryId == null).toList();
    }
    return _todos!.where((todo) => todo.categoryId == categoryId).toList();
  }

  // Get todos for today
  List<Todo> getTodosByDay(DateTime time) {
    if (_todos == null) return [];
    return _todos!.where((todo) {
      if (todo.finishingAt == null) return false;
      final finishDate = todo.finishingAt!;
      return finishDate.year == time.year && 
             finishDate.month == time.month && 
             finishDate.day == time.day;
    }).toList();
  }

  // Add new todo
  Future<void> addTodo(Map<String, dynamic> todoData) async {
    try {
      await _dq.insertTodo(todoData);
      await _loadTodos();
      notifyListeners();
    } catch (e) {
      _error = '添加待办事项失败: $e';
      notifyListeners();
      rethrow;
    }
  }

  // Update todo
  Future<void> updateTodo(Map<String, dynamic> todoData) async {
    try {
      await _dq.updateTodo(todoData);
      await _loadTodos();
      notifyListeners();
    } catch (e) {
      _error = '更新待办事项失败: $e';
      notifyListeners();
      rethrow;
    }
  }

  // Delete todo
  Future<void> deleteTodo(int id) async {
    try {
      await _dq.deleteTodo(id);
      await _loadTodos();
      notifyListeners();
    } catch (e) {
      _error = '删除待办事项失败: $e';
      notifyListeners();
      rethrow;
    }
  }

  // Toggle todo completion
  Future<void> toggleTodoCompletion(int id) async {
    if (_todos == null) return;
    
    final todo = _todos!.firstWhere((t) => t.id == id);
    final updatedData = {
      'id': id,
      'isCompleted': todo.isCompleted ? 0 : 1,
    };
    
    await updateTodo(updatedData);
  }

  // Add new category
  Future<void> addCategory(Map<String, dynamic> categoryData) async {
    try {
      await _dq.insertCategory(categoryData);
      await _loadCategories();
      notifyListeners();
    } catch (e) {
      _error = '添加分类失败: $e';
      notifyListeners();
      rethrow;
    }
  }

  // Update category
  Future<void> updateCategory(Map<String, dynamic> categoryData) async {
    try {
      await _dq.updateCategory(categoryData);
      await _loadCategories();
      notifyListeners();
    } catch (e) {
      _error = '更新分类失败: $e';
      notifyListeners();
      rethrow;
    }
  }

  // Delete category
  Future<void> deleteCategory(int id) async {
    try {
      await _dq.deleteCategory(id);
      await _loadCategories();
      await _loadTodos(); // Reload todos as they might be affected
      notifyListeners();
    } catch (e) {
      _error = '删除分类失败: $e';
      notifyListeners();
      rethrow;
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Refresh all data
  Future<void> refresh() async {
    await init();
  }
} 