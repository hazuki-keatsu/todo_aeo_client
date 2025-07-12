class Todo {
  final int? id;
  final String title;
  final String? description;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime finishingAt;

  Todo({
    this.id,
    required this.title,
    this.description,
    this.isCompleted = false,
    required this.createdAt,
    required this.finishingAt,
  });

  // 从数据库 Map 创建 Todo 对象
  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map['id'] as int?,
      title: map['title'] as String,
      description: map['description'] as String?,
      isCompleted: (map['isCompleted'] as int) == 1,
      createdAt: DateTime.parse(map['createdAt'] as String),
      finishingAt: DateTime.parse(map['finishingAt'] as String),
    );
  }

  // 转换为数据库 Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'finishingAt': finishingAt.toIso8601String(),
    };
  }
}