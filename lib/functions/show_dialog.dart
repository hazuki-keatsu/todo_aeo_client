import 'package:flutter/material.dart';
import 'package:todo_aeo/providers/settings_provider.dart';
import 'package:todo_aeo/providers/todo_provider.dart';

enum OperationMode { todo, category }

class ShowDialog {
  static Future<void> showTodoDialog(
    BuildContext context,
    TodoProvider provider, {
    int? todoId, // 如果提供了todoId，则为编辑模式；否则为添加模式
  }) async {
    final isEditMode = todoId != null;

    // 初始化变量
    String todoName = '';
    String todoDescription = '';
    int? selectedCategoryId;
    DateTime? selectedFinishingDate;

    // 如果是编辑模式，获取现有数据
    if (isEditMode) {
      final existingTodo = provider.todos?.firstWhere(
        (todo) => todo.id == todoId,
      );
      if (existingTodo != null) {
        todoName = existingTodo.title;
        todoDescription = existingTodo.description ?? '';
        selectedCategoryId = existingTodo.categoryId;
        selectedFinishingDate = existingTodo.finishingAt;
      }
    }

    // 保存主页面的context
    final scaffoldContext = context;

    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(isEditMode ? '编辑待办事项' : '添加新的待办事项'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 待办事项名称
                    TextField(
                      decoration: InputDecoration(
                        labelText: '待办事项名称',
                        border: OutlineInputBorder(),
                        hintText: '请输入待办事项名称',
                      ),
                      controller: TextEditingController(text: todoName),
                      onChanged: (value) {
                        todoName = value;
                      },
                    ),
                    SizedBox(height: 16),
                    // 待办事项描述
                    TextField(
                      decoration: InputDecoration(
                        labelText: '待办事项描述(可选)',
                        border: OutlineInputBorder(),
                        hintText: '请输入待办事项描述',
                        alignLabelWithHint: true,
                      ),
                      maxLines: 3,
                      controller: TextEditingController(text: todoDescription),
                      onChanged: (value) {
                        todoDescription = value;
                      },
                    ),
                    SizedBox(height: 16),
                    // 分类选择
                    Text('选择分类', style: Theme.of(context).textTheme.titleSmall),
                    SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context).dividerColor,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      // TODO: 修复DropdownMenuItem对不齐的问题
                      child: DropdownButtonFormField<int?>(
                        value: selectedCategoryId,
                        decoration: InputDecoration(
                          hintText: '选择分类（可选）',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        isExpanded: true,
                        icon: Icon(Icons.arrow_drop_down),
                        items: [
                          DropdownMenuItem<int?>(
                            value: null,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.category_outlined,
                                  color: Colors.grey,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text('无分类'),
                              ],
                            ),
                          ),
                          // 添加现有分类
                          ...provider.categories?.map((category) {
                                return DropdownMenuItem<int?>(
                                  value: category.id,
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 16,
                                        height: 16,
                                        decoration: BoxDecoration(
                                          color: parseColor(
                                            category.color,
                                            context,
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Text(category.name),
                                    ],
                                  ),
                                );
                              }) ??
                              [],
                          // 添加新分类选项
                          DropdownMenuItem<int?>(
                            value: -1,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.add_circle_outline,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  '新增分类',
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        onChanged: (value) async {
                          if (value == -1) {
                            // 用户选择了新增分类，显示新增分类对话框
                            final result = await showCategoryDialog(context, provider);
                            // 如果成功创建了新分类，获取最新创建的分类ID并选中它
                            if (result == true) {
                              // 等待下一帧再更新状态，确保 provider 的分类列表已更新
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (provider.categories != null &&
                                    provider.categories!.isNotEmpty) {
                                  final latestCategory =
                                      provider.categories!.last;
                                  setState(() {
                                    selectedCategoryId = latestCategory.id;
                                  });
                                }
                              });
                            }
                          } else {
                            setState(() {
                              selectedCategoryId = value;
                            });
                          }
                        },
                      ),
                    ),
                    SizedBox(height: 16),
                    // 完成日期选择
                    Text('完成日期', style: Theme.of(context).textTheme.titleSmall),
                    SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        final date = await showDatePicker(
                          helpText: "选择日期",
                          cancelText: "取消",
                          confirmText: "确定",
                          fieldLabelText: "请输入日期",
                          fieldHintText: "mm/dd/yyyy",
                          context: context,
                          initialDate: selectedFinishingDate ?? DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(Duration(days: 365 * 2)),
                        );
                        if (date != null) {
                          setState(() {
                            selectedFinishingDate = date;
                          });
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(context).hintColor,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today, size: 20),
                            SizedBox(width: 8),
                            Text(
                              selectedFinishingDate != null
                                  ? '${selectedFinishingDate!.year}-${selectedFinishingDate!.month.toString().padLeft(2, '0')}-${selectedFinishingDate!.day.toString().padLeft(2, '0')}'
                                  : '选择完成日期（可选）',
                              style: TextStyle(
                                color: selectedFinishingDate != null
                                    ? Theme.of(
                                        context,
                                      ).textTheme.bodyMedium?.color
                                    : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('取消'),
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                ),
                TextButton(
                  child: Text(isEditMode ? '保存' : '确定'),
                  onPressed: () async {
                    if (todoName.trim().isEmpty) {
                      ScaffoldMessenger.of(
                        dialogContext,
                      ).showSnackBar(SnackBar(content: Text('请输入待办事项名称')));
                      return;
                    }

                    try {
                      // 准备数据
                      final todoData = {
                        'id': todoId,
                        'title': todoName.trim(),
                        'description': todoDescription.trim().isEmpty
                            ? null
                            : todoDescription.trim(),
                        'categoryId': selectedCategoryId,
                        'finishingAt': selectedFinishingDate?.toIso8601String(),
                      };

                      if (isEditMode) {
                        // 编辑模式：更新现有待办事项
                        await provider.updateTodo(todoData);
                      } else {
                        // 添加模式：创建新的待办事项
                        todoData['isCompleted'] = 0;
                        todoData['createdAt'] = DateTime.now()
                            .toIso8601String();
                        await provider.addTodo(todoData);
                      }

                      if (dialogContext.mounted) {
                        Navigator.pop(dialogContext);
                      }

                      // 显示成功消息
                      if (scaffoldContext.mounted) {
                        ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                          SnackBar(
                            content: Text(isEditMode ? '待办事项更新成功' : '待办事项添加成功'),
                          ),
                        );
                      }
                    } catch (e) {
                      if (dialogContext.mounted) {
                        Navigator.pop(dialogContext);
                      }
                      if (scaffoldContext.mounted) {
                        ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                          SnackBar(
                            content: Text(
                              isEditMode ? '更新待办事项失败: $e' : '添加待办事项失败: $e',
                            ),
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
  }

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
                      ScaffoldMessenger.of(
                        dialogContext,
                      ).showSnackBar(SnackBar(content: Text('请输入分类名称')));
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
                        ScaffoldMessenger.of(
                          scaffoldContext,
                        ).showSnackBar(SnackBar(content: Text(isEditMode ? '分类更新成功' : '分类添加成功')));
                      }
                    } catch (e) {
                      if (dialogContext.mounted) {
                        Navigator.pop(dialogContext, false);
                      }
                      if (scaffoldContext.mounted) {
                        ScaffoldMessenger.of(
                          scaffoldContext,
                        ).showSnackBar(SnackBar(content: Text(isEditMode ? '更新分类失败: $e' : '添加分类失败: $e')));
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

  // 编辑分类变成了新增分类
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
                      ShowDialog.showTodoDialog(context, provider, todoId: id);
                    }
                    else if (mode == OperationMode.category) {
                      ShowDialog.showCategoryDialog(context, provider, categoryId: id);
                    }
                    else {
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

  // 颜色解析
  static Color parseColor(String? colorString, BuildContext context) {
    if (colorString == null || colorString.isEmpty) {
      return Theme.of(context).colorScheme.primary;
    }

    // 检查是否是有效的十六进制颜色格式
    if (colorString.startsWith('#') && colorString.length == 7) {
      try {
        return Color(
          int.parse(colorString.substring(1), radix: 16) + 0xFF000000,
        );
      } catch (e) {
        return Theme.of(context).colorScheme.primary;
      }
    }

    // 如果不是十六进制格式，返回默认颜色
    return Theme.of(context).colorScheme.primary;
  }
}
