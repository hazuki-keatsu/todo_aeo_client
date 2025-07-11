import 'package:todo_aeo/functions/database_query.dart';

class DatabaseInitializer {
  static Future<void> initializeWithSampleData() async {
    final db = DatabaseQuery.instance;
    
    // 检查是否已有数据
    final existingTodos = await db.getAllTodos();
    if (existingTodos.isNotEmpty) {
      print('数据库已有数据，跳过初始化');
      return;
    }
    
    // 添加示例数据
    final sampleTodos = [
      {
        'title': '学习 Flutter',
        'description': '完成 Todo 应用开发',
        'isCompleted': 0,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
      {
        'title': '买菜',
        'description': '购买今晚晚餐的食材',
        'isCompleted': 0,
        'createdAt': DateTime.now().subtract(Duration(hours: 1)).toIso8601String(),
        'updatedAt': DateTime.now().subtract(Duration(hours: 1)).toIso8601String(),
      },
      {
        'title': '锻炼身体',
        'description': '跑步 30 分钟',
        'isCompleted': 1,
        'createdAt': DateTime.now().subtract(Duration(days: 1)).toIso8601String(),
        'updatedAt': DateTime.now().subtract(Duration(hours: 2)).toIso8601String(),
      },
    ];
    
    for (final todoData in sampleTodos) {
      await db.insertTodo(todoData);
    }
    
    print('已添加 ${sampleTodos.length} 条示例数据');
  }
}