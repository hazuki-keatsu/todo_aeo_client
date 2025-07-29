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
                            duration: Duration(seconds: 3)
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
                            duration: Duration(seconds: 3)
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
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.all(8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  leading: Icon(Icons.edit),
                  title: Text('编辑'),
                  onTap: () {
                    Navigator.pop(context);
                    if (mode == OperationMode.todo) {
                      AppRoutes.pushTodoEditPage(context, id, provider);
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
                ),
                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  leading: Icon(Icons.delete, color: Colors.red),
                  title: Text('删除', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.pop(context);
                    ShowDialog.showDeleteConfirmDialog(
                      context,
                      id,
                      provider,
                      mode,
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static void showAboutApplicationDialog(
    BuildContext context,
    SettingsProvider settingsProvider,
  ) {
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
