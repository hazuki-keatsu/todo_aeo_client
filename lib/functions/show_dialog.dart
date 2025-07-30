import 'package:flutter/material.dart';
import 'package:todo_aeo/providers/settings_provider.dart';
import 'package:todo_aeo/providers/todo_provider.dart';
import 'package:todo_aeo/utils/app_routes.dart';
import 'package:todo_aeo/utils/parse_color.dart';

enum OperationMode { todo, category }

class ShowDialog {
  static Future<bool> showCategoryDialog(
    BuildContext context,
    TodoProvider provider, {
    int? categoryId,
  }) async {
    String categoryName = '';
    String selectedColor = '#3B82F6';

    // 保存主页面的context
    final scaffoldContext = context;

    final isEditMode = categoryId != null;

    if (isEditMode) {
      final existingCategory = provider.categories?.firstWhere(
        (category) => category.id == categoryId,
      );
      if (existingCategory != null) {
        categoryName = existingCategory.name;
        selectedColor = existingCategory.color ?? '#3B82F6';
      } else {
        throw "CategoryId Crushed.";
      }
    }

    final List<String> predefinedColors = [
      '#3B82F6', // 蓝色
      '#10B981', // 绿色
      '#F59E0B', // 橙色
      '#EF4444', // 红色
      '#8B5CF6', // 紫色
      '#06B6D4', // 青色
      '#84CC16', // 青绿色
      '#F97316', // 橙红色
    ];

    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(isEditMode ? '编辑分类' : '添加新的分类'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 分类名称输入框
                  TextField(
                    decoration: InputDecoration(
                      labelText: '分类名称',
                      border: OutlineInputBorder(),
                      hintText: '请输入分类名称',
                    ),
                    controller: TextEditingController(text: categoryName),
                    onChanged: (value) {
                      categoryName = value;
                    },
                  ),
                  SizedBox(height: 16),
                  // 颜色选择
                  Text('选择颜色', style: Theme.of(context).textTheme.titleSmall),
                  SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: predefinedColors.map((color) {
                      final isSelected = selectedColor == color;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedColor = color;
                          });
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: parseColor(color, context),
                            shape: BoxShape.circle,
                            border: isSelected
                                ? Border.all(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    width: 3,
                                  )
                                : null,
                          ),
                          child: isSelected
                              ? Icon(Icons.check, color: Colors.white, size: 20)
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('取消'),
                  onPressed: () {
                    Navigator.pop(dialogContext, false);
                  },
                ),
                TextButton(
                  child: Text('确定'),
                  onPressed: () async {
                    if (categoryName.trim().isEmpty) {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        SnackBar(
                          content: Text('请输入分类名称'),
                          duration: Duration(seconds: 3),
                        ),
                      );
                      return;
                    }

                    try {
                      if (isEditMode) {
                        // 编辑模式：更新现有分类
                        await provider.updateCategory({
                          'id': categoryId,
                          'name': categoryName.trim(),
                          'color': selectedColor,
                        });
                      } else {
                        // 添加模式：创建新的分类
                        await provider.addCategory({
                          'name': categoryName.trim(),
                          'color': selectedColor,
                          'createdAt': DateTime.now().toIso8601String(),
                        });
                      }

                      if (dialogContext.mounted) {
                        Navigator.pop(dialogContext, true);
                      }

                      if (scaffoldContext.mounted) {
                        ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                          SnackBar(
                            content: Text(isEditMode ? '分类更新成功' : '分类添加成功'),
                            duration: Duration(seconds: 3),
                          ),
                        );
                      }
                    } catch (e) {
                      if (dialogContext.mounted) {
                        Navigator.pop(dialogContext, false);
                      }
                      if (scaffoldContext.mounted) {
                        ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                          SnackBar(
                            content: Text(
                              isEditMode ? '更新分类失败: $e' : '添加分类失败: $e',
                            ),
                            duration: Duration(seconds: 3),
                          ),
                        );
                      }
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );

    return result ?? false;
  }

  static void showDeleteConfirmDialog(
    BuildContext context,
    int id,
    TodoProvider provider,
    OperationMode mode,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('确认删除'),
          content: mode == OperationMode.todo
              ? Text('确定要删除这个待办事项吗？')
              : Text('确定要删除这个分类吗？'),
          actions: [
            TextButton(
              child: Text('取消'),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: Text('删除', style: TextStyle(color: Colors.red)),
              onPressed: () {
                if (mode == OperationMode.todo) {
                  Navigator.pop(context);
                  provider.deleteTodo(id);
                } else if (mode == OperationMode.category) {
                  Navigator.pop(context);
                  provider.deleteCategory(id);
                  for (var i in provider.getTodosByCategory(id)) {
                    provider.deleteTodo(i.id);
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  static void showOptionsBottomSheet(
    int id,
    TodoProvider provider,
    BuildContext context,
    OperationMode mode,
  ) {
    final todos = provider.todos;
    // 根据ID查找对应的待办事项，而不是使用索引访问
    final todo = todos?.firstWhere((todo) => todo.id == id);

    if (todo == null) {
      // 如果找不到对应的待办事项，显示错误信息
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('未找到对应的待办事项'),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: Theme
                .of(context)
                .colorScheme
                .surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 拖拽指示器
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Theme
                            .of(context)
                            .colorScheme
                            .onSurfaceVariant
                            .withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // 待办事项详情卡片
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme
                          .of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Theme
                            .of(context)
                            .colorScheme
                            .outline
                            .withValues(alpha: 0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 标题
                        Row(
                          children: [
                            Icon(
                              Icons.title,
                              size: 18,
                              color: Theme
                                  .of(context)
                                  .colorScheme
                                  .primary,
                            ),
                            SizedBox(width: 8),
                            Text(
                              '标题',
                              style: Theme
                                  .of(context)
                                  .textTheme
                                  .labelMedium
                                  ?.copyWith(
                                color: Theme
                                    .of(context)
                                    .colorScheme
                                    .primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme
                                .of(context)
                                .colorScheme
                                .surface,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            todo.title,
                            style: Theme
                                .of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),

                        // 描述（如果存在）
                        if (todo.description != null &&
                            todo.description != '') ...[
                          SizedBox(height: 16),
                          Row(
                            children: [
                              Icon(
                                Icons.description,
                                size: 18,
                                color: Theme
                                    .of(context)
                                    .colorScheme
                                    .primary,
                              ),
                              SizedBox(width: 8),
                              Text(
                                '描述',
                                style: Theme
                                    .of(context)
                                    .textTheme
                                    .labelMedium
                                    ?.copyWith(
                                  color: Theme
                                      .of(context)
                                      .colorScheme
                                      .primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme
                                  .of(context)
                                  .colorScheme
                                  .surface,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              todo.description!,
                              style: Theme
                                  .of(context)
                                  .textTheme
                                  .bodyMedium,
                            ),
                          ),
                        ],

                        SizedBox(height: 16),

                        // 时间信息
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.access_time,
                                        size: 16,
                                        color: Theme
                                            .of(context)
                                            .colorScheme
                                            .secondary,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        '创建时间',
                                        style: Theme
                                            .of(context)
                                            .textTheme
                                            .labelSmall
                                            ?.copyWith(
                                          color: Theme
                                              .of(context)
                                              .colorScheme
                                              .secondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    _formatDateTime(todo.createdAt),
                                    style: Theme
                                        .of(context)
                                        .textTheme
                                        .bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            if (todo.finishingAt != null)
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.event_available,
                                          size: 16,
                                          color: Theme
                                              .of(context)
                                              .colorScheme
                                              .tertiary,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          '完成时间',
                                          style: Theme
                                              .of(context)
                                              .textTheme
                                              .labelSmall
                                              ?.copyWith(
                                            color: Theme
                                                .of(context)
                                                .colorScheme
                                                .tertiary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      _formatDateTime(todo.finishingAt!),
                                      style: Theme
                                          .of(context)
                                          .textTheme
                                          .bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20),

                  // 操作按钮
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 56,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              if (mode == OperationMode.todo) {
                                AppRoutes.pushTodoEditPage(
                                    context, id, provider);
                              } else if (mode == OperationMode.category) {
                                ShowDialog.showCategoryDialog(
                                  context,
                                  provider,
                                  categoryId: id,
                                );
                              } else {
                                throw "showOptionBottomSheet Crushed.";
                              }
                            },
                            icon: Icon(Icons.edit),
                            label: Text('编辑'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme
                                  .of(context)
                                  .colorScheme
                                  .primary,
                              foregroundColor: Theme
                                  .of(context)
                                  .colorScheme
                                  .onPrimary,
                              elevation: 2,
                              shadowColor: Theme
                                  .of(context)
                                  .colorScheme
                                  .primary
                                  .withValues(alpha: 0.3),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 56,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              ShowDialog.showDeleteConfirmDialog(
                                context,
                                id,
                                provider,
                                mode,
                              );
                            },
                            icon: Icon(Icons.delete_outline),
                            label: Text('删除'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Theme
                                  .of(context)
                                  .colorScheme
                                  .error,
                              side: BorderSide(
                                color: Theme
                                    .of(context)
                                    .colorScheme
                                    .error,
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 8),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // 格式化日期时间的辅助方法
  static String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(Duration(days: 1));
    final targetDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (targetDate == today) {
      return '今天 ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute
          .toString().padLeft(2, '0')}';
    } else if (targetDate == yesterday) {
      return '昨天 ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute
          .toString().padLeft(2, '0')}';
    } else {
      return '${dateTime.month}/${dateTime.day} ${dateTime.hour
          .toString()
          .padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }

  static void showAboutApplicationDialog(BuildContext context,
      SettingsProvider settingsProvider,) {
    return showAboutDialog(
      context: context,
      applicationName: 'Todo AEO',
      applicationVersion: settingsProvider.fullVersion,
      applicationIcon: Icon(Icons.check_circle, size: 48),
      children: [
        Text('一个主打简洁和安全的待办事项管理应用'),
        SizedBox(height: 8),
        Text('使用 Flutter 和 Material You 设计'),
      ],
    );
  }
}
