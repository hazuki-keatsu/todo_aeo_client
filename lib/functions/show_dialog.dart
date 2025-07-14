import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_aeo/providers/todo_provider.dart';

class ShowDialog {
  static Future<void> showAddTodoDialog(
    BuildContext context,
    TodoProvider provider,
  ) async {
    String todoName = '';
    String todoDescription = '';
    int? selectedCategoryId;
    DateTime? selectedFinishingDate;

    // 保存主页面的context
    final scaffoldContext = context;
    final categories = provider.categories ?? [];

    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('添加新的待办事项'),
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
                        border: Border.all(color: Theme.of(context).hintColor),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: DropdownButton<int?>(
                        value: selectedCategoryId,
                        hint: Text('  选择分类（可选）'),
                        isExpanded: true,
                        underline: SizedBox(),
                        items: [
                          DropdownMenuItem<int?>(
                            value: null,
                            child: Text('  无分类'),
                          ),
                          if (categories.isNotEmpty)
                            ...categories.map((category) {
                              return DropdownMenuItem<int?>(
                                value: category.id,
                                child: Row(
                                  children: [
                                    SizedBox(width: 8),
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
                            }),
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedCategoryId = value;
                          });
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
                  child: Text('确定'),
                  onPressed: () async {
                    if (todoName.trim().isEmpty) {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        SnackBar(
                          content: Text('请输入待办事项名称'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      return;
                    }

                    try {
                      // 准备插入数据
                      final todoData = {
                        'title': todoName.trim(),
                        'description': todoDescription.trim().isEmpty
                            ? null
                            : todoDescription.trim(),
                        'isCompleted': 0,
                        'categoryId': selectedCategoryId,
                        'createdAt': DateTime.now().toIso8601String(),
                        'finishingAt': selectedFinishingDate?.toIso8601String(),
                      };

                      // 添加到数据库
                      await provider.addTodo(todoData);

                      if (dialogContext.mounted) {
                        Navigator.pop(dialogContext);
                      }

                      // 显示成功消息
                      if (scaffoldContext.mounted) {
                        ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                          SnackBar(
                            content: Text('待办事项添加成功'),
                            behavior: SnackBarBehavior.floating,
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
                            content: Text('添加待办事项失败: $e'),
                            behavior: SnackBarBehavior.floating,
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

  static Future<void> showAddCategoryDialog(BuildContext context) async {
    String categoryName = '';
    String selectedColor = '#3B82F6';

    // 保存主页面的context
    final scaffoldContext = context;
    final provider = context.read<TodoProvider>(); // 默认蓝色

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

    final dialogContext = context;

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('添加新的分类'),
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
                    Navigator.pop(context);
                  },
                ),
                TextButton(
                  child: Text('确定'),
                  onPressed: () async {
                    if (categoryName.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('请输入分类名称'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      return;
                    }

                    try {
                      // 添加分类到数据库
                      await provider.addCategory({
                        'name': categoryName.trim(),
                        'color': selectedColor,
                        'createdAt': DateTime.now().toIso8601String(),
                      });

                      if (dialogContext.mounted) {
                        Navigator.pop(dialogContext);
                      }

                      if (scaffoldContext.mounted) {
                        ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                          SnackBar(
                            content: Text('分类添加成功'),
                            behavior: SnackBarBehavior.floating,
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
                            content: Text('添加分类失败: $e'),
                            behavior: SnackBarBehavior.floating,
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

  static void showDeleteConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('确认删除'),
          content: Text('确定要删除这个待办事项吗？'),
          actions: [
            TextButton(
              child: Text('取消'),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: Text('删除', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.pop(context);
                // TODO: 实现删除逻辑
              },
            ),
          ],
        );
      },
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
