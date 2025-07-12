class Category {
  final int? id;
  final String name;
  final String? color;
  final DateTime createdAt;

  Category({
    this.id,
    required this.name,
    this.color,
    required this.createdAt,
  });

  // 从数据库 Map 创建 Todo 对象
  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as int?,
      name: map['name'] as String,
      color: map['color'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  // 转换为数据库 Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'color': color,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}