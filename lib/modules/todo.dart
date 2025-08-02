import 'package:todo_aeo/services/sync/data_diff_service.dart';

class Todo with Versionable {
  final int id;
  final String title;
  final String? description;
  final bool isCompleted;
  final int? categoryId;
  final DateTime createdAt;
  final DateTime? finishingAt;
  final int priority; // 新增优先级字段，数值越小优先级越高
  @override
  final int version; // 版本号字段
  @override
  final DateTime? updatedAt; // 更新时间字段

  Todo({
    required this.id,
    required this.title,
    this.description,
    this.isCompleted = false,
    this.categoryId,
    required this.createdAt,
    this.finishingAt,
    this.priority = 0, // 默认优先级为0
    this.version = 1, // 默认版本号为1
    this.updatedAt,
  });

  // 从数据库 Map 创建 Todo 对象
  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map['id'] as int,
      title: map['title'] as String,
      description: map['description'] as String?,
      isCompleted: (map['isCompleted'] as int) == 1,
      categoryId: map['categoryId'] as int?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      finishingAt: map['finishingAt'] != null 
          ? DateTime.parse(map['finishingAt'] as String)
          : null,
      priority: map['priority'] as int? ?? 0, // 添加优先级字段，默认为0
      version: map['version'] as int? ?? 1,
      // 添加版本号字段，默认为1
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'] as String)
          : null,
    );
  }

  // 转换为数据库 Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted ? 1 : 0,
      'categoryId': categoryId,
      'createdAt': createdAt.toIso8601String(),
      'finishingAt': finishingAt?.toIso8601String(),
      'priority': priority, // 添加优先级字段
      'version': version, // 添加版本号字段
      'updatedAt': updatedAt?.toIso8601String(), // 添加更新时间字段
    };
  }

  // 创建新版本的Todo（版本号自动递增）
  Todo copyWithNewVersion({
    String? title,
    String? description,
    bool? isCompleted,
    int? categoryId,
    DateTime? finishingAt,
    int? priority,
  }) {
    return Todo(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      categoryId: categoryId ?? this.categoryId,
      createdAt: createdAt,
      finishingAt: finishingAt ?? this.finishingAt,
      priority: priority ?? this.priority,
      version: version + 1,
      // 版本号递增
      updatedAt: DateTime.now(), // 更新时间为当前时间
    );
  }

  // 实现Versionable接口
  @override
  String get versionableId => id.toString();
}