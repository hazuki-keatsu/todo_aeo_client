import 'package:todo_aeo/services/sync/data_diff_service.dart';

class Category with Versionable {
  final int? id;
  final String name;
  final String? color;
  final DateTime createdAt;
  @override
  final int version; // 版本号字段
  @override
  final DateTime? updatedAt; // 更新时间字段

  Category({
    this.id,
    required this.name,
    this.color,
    required this.createdAt,
    this.version = 1, // 默认版本号为1
    this.updatedAt,
  });

  // 从数据库 Map 创建 Category 对象
  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as int?,
      name: map['name'] as String,
      color: map['color'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
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
      'name': name,
      'color': color,
      'createdAt': createdAt.toIso8601String(),
      'version': version, // 添加版本号字段
      'updatedAt': updatedAt?.toIso8601String(), // 添加更新时间字段
    };
  }

  // 创建新版本的Category（版本号自动递增）
  Category copyWithNewVersion({
    String? name,
    String? color,
  }) {
    return Category(
      id: id,
      name: name ?? this.name,
      color: color ?? this.color,
      createdAt: createdAt,
      version: version + 1,
      // 版本号递增
      updatedAt: DateTime.now(), // 更新时间为当前时间
    );
  }

  // 实现Versionable接口
  @override
  String get versionableId => id?.toString() ?? '0';
}