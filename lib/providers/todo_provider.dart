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
      // 获取当前最大的优先级值，新Todo的优先级 = 最大值 + 1
      int maxPriority = 0;
      if (_todos != null && _todos!.isNotEmpty) {
        maxPriority = _todos!.map((todo) => todo.priority).reduce((a, b) => a > b ? a : b);
      }
      todoData['priority'] = maxPriority + 1;
      
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

  // Update todos priority order
  Future<void> updateTodosPriority(List<int> todoIds) async {
    try {
      await _dq.updateTodosPriority(todoIds);
      await _loadTodos();
      notifyListeners();
    } catch (e) {
      _error = '更新优先级失败: $e';
      notifyListeners();
      rethrow;
    }
  }

  // Update single todo priority
  Future<void> updateTodoPriority(int todoId, int newPriority) async {
    try {
      await _dq.updateTodoPriority(todoId, newPriority);
      await _loadTodos();
      notifyListeners();
    } catch (e) {
      _error = '更新优先级失败: $e';
      notifyListeners();
      rethrow;
    }
  }

  // Reorder todos by dragging - 处理拖动排序
  Future<void> reorderTodos(List<Todo> todos, int oldIndex, int newIndex) async {
    try {
      // 创建一个新的列表避免修改原列表
      List<Todo> reorderedTodos = List.from(todos);
      
      // 调整newIndex，如果向后移动需要减1
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      
      // 移动元素
      final Todo movedTodo = reorderedTodos.removeAt(oldIndex);
      reorderedTodos.insert(newIndex, movedTodo);
      
      // 重新分配优先级，使用大优先级在上的逻辑
      // 获取当前最大优先级作为起始值
      int maxPriority = _todos?.map((todo) => todo.priority).reduce((a, b) => a > b ? a : b) ?? 0;
      int startPriority = maxPriority + reorderedTodos.length;
      
      // 批量更新数据库中的优先级
      List<int> todoIds = reorderedTodos.map((todo) => todo.id).toList();
      await _dq.updateTodosPriorityBatch(todoIds, startPriority);
      
      // 重新加载数据
      await _loadTodos();
      notifyListeners();
    } catch (e) {
      _error = '重新排序失败: $e';
      notifyListeners();
      rethrow;
    }
  }

  // 静默重新排序todos，不触发UI更新
  Future<void> reorderTodosSilently(List<int> todoIds, int startPriority) async {
    try {
      // 批量更新数据库中的优先级
      await _dq.updateTodosPriorityBatch(todoIds, startPriority);
      
      // 静默重新加载数据，不触发notifyListeners
      await _loadTodos();
    } catch (e) {
      print('静默排序失败: $e');
      // 静默失败，不设置错误状态
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