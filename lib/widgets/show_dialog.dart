import 'package:flutter/material.dart';
import 'package:todo_aeo/l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;

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
              title: Text(isEditMode ? l10n.editCategory : l10n.addNewCategory),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 分类名称输入框
                  TextField(
                    decoration: InputDecoration(
                      labelText: l10n.categoryName,
                      border: OutlineInputBorder(),
                      hintText: l10n.categoryNameRequired,
                    ),
                    controller: TextEditingController(text: categoryName),
                    onChanged: (value) {
                      categoryName = value;
                    },
                  ),
                  SizedBox(height: 16),
                  // 颜色选择
                  Text(l10n.selectColor, style: Theme.of(context).textTheme.titleSmall),
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
                  child: Text(l10n.cancel),
                  onPressed: () {
                    Navigator.pop(dialogContext, false);
                  },
                ),
                TextButton(
                  child: Text(l10n.confirm),
                  onPressed: () async {
                    if (categoryName.trim().isEmpty) {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        SnackBar(
                          content: Text(l10n.categoryNameRequired),
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
                            content: Text(isEditMode ? l10n.categoryUpdateSuccess : l10n.categoryAddSuccess),
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
                              isEditMode ? '${l10n.updateCategoryFailed}: $e' : '${l10n.addCategoryFailed}: $e',
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
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.confirmDelete),
          content: mode == OperationMode.todo
              ? Text(l10n.confirmDeleteTodo)
              : Text(l10n.confirmDeleteCategory),
          actions: [
            TextButton(
              child: Text(l10n.cancel),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: Text(l10n.delete, style: TextStyle(color: Colors.red)),
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
    final l10n = AppLocalizations.of(context)!;
    // 根据模式查找对应的数据
    if (mode == OperationMode.todo) {
      final todos = provider.todos;
      final todo = todos?.firstWhere((todo) => todo.id == id);

      if (todo == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.todoNotFound), duration: Duration(seconds: 3)),
        );
        return;
      }

      _showTodoOptionsBottomSheet(context, todo, id, provider, mode);
    } else if (mode == OperationMode.category) {
      final categories = provider.categories;
      final category = categories?.firstWhere((category) => category.id == id);

      if (category == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.categoryNotFound), duration: Duration(seconds: 3)),
        );
        return;
      }

      _showCategoryOptionsBottomSheet(context, category, id, provider, mode);
    }
  }

  static void _showTodoOptionsBottomSheet(
    BuildContext context,
    dynamic todo,
    int id,
    TodoProvider provider,
    OperationMode mode,
  ) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
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
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // 待办事项详情卡片
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).colorScheme.outline.withValues(alpha: 0.2),
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
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            SizedBox(width: 8),
                            Text(
                              l10n.todoTitle,
                              style: Theme.of(context).textTheme.labelMedium
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
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
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            todo.title,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w500),
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
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              SizedBox(width: 8),
                              Text(
                                l10n.description,
                                style: Theme.of(context).textTheme.labelMedium
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
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
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              todo.description!,
                              style: Theme.of(context).textTheme.bodyMedium,
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
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.secondary,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        l10n.createTime,
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall
                                            ?.copyWith(
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.secondary,
                                            ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    _formatDateTime(todo.createdAt, l10n),
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
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
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.tertiary,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          l10n.finishTime,
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelSmall
                                              ?.copyWith(
                                                color: Theme.of(
                                                  context,
                                                ).colorScheme.tertiary,
                                              ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      _formatDateTime(todo.finishingAt!, l10n),
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall,
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
                              AppRoutes.pushTodoEditPage(context, id, provider);
                            },
                            icon: Icon(Icons.edit),
                            label: Text(l10n.edit),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.primary,
                              foregroundColor: Theme.of(
                                context,
                              ).colorScheme.onPrimary,
                              elevation: 2,
                              shadowColor: Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.3),
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
                            label: Text(l10n.delete),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Theme.of(
                                context,
                              ).colorScheme.error,
                              side: BorderSide(
                                color: Theme.of(context).colorScheme.error,
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

  static void _showCategoryOptionsBottomSheet(
    BuildContext context,
    dynamic category,
    int id,
    TodoProvider provider,
    OperationMode mode,
  ) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
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
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // 分类详情卡片
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).colorScheme.outline.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 分类名称
                        Row(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: category.color != null
                                    ? parseColor(category.color, context)
                                    : Theme.of(context).colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              l10n.categoryNameLabel,
                              style: Theme.of(context).textTheme.labelMedium
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
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
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            category.name,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(fontWeight: FontWeight.w500),
                          ),
                        ),

                        SizedBox(height: 16),

                        // 统计信息
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 16,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                            SizedBox(width: 4),
                            Text(
                              '${l10n.todoCountInCategory}: ${provider.todos?.where((todo) => todo.categoryId == id).length ?? 0}',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.secondary,
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
                              ShowDialog.showCategoryDialog(
                                context,
                                provider,
                                categoryId: id,
                              );
                            },
                            icon: Icon(Icons.edit),
                            label: Text(l10n.edit),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.primary,
                              foregroundColor: Theme.of(
                                context,
                              ).colorScheme.onPrimary,
                              elevation: 2,
                              shadowColor: Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.3),
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
                            label: Text(l10n.delete),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Theme.of(
                                context,
                              ).colorScheme.error,
                              side: BorderSide(
                                color: Theme.of(context).colorScheme.error,
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
  static String _formatDateTime(DateTime dateTime, AppLocalizations l10n) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(Duration(days: 1));
    final targetDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (targetDate == today) {
      return '${l10n.today} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (targetDate == yesterday) {
      return '${l10n.yesterday} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else {
      return '${dateTime.month}/${dateTime.day} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }

  static void showAboutApplicationDialog(
    BuildContext context,
    SettingsProvider settingsProvider,
  ) {
    return showAboutDialog(
      context: context,
      applicationName: 'Todo AEO',
      applicationVersion: settingsProvider.packageInfo?.version,
      applicationIcon: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/icon.png'),
            fit: BoxFit.contain,
          ),
          shape: BoxShape.rectangle,
          borderRadius: const BorderRadius.all(Radius.circular(12)),
        ),
      ),
      children: [
        Text(AppLocalizations.of(context)!.introduction1),
        SizedBox(height: 8),
        Text(AppLocalizations.of(context)!.introduction2),
      ],
    );
  }
}
