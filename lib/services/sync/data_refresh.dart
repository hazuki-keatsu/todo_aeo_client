import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:todo_aeo/providers/todo_provider.dart';
import 'package:todo_aeo/providers/sync_settings_provider.dart';
import 'package:todo_aeo/services/sync/weddav_sync.dart';
import 'package:todo_aeo/services/sync/sync_exceptions.dart';
import 'package:todo_aeo/services/database_query.dart';
import 'package:provider/provider.dart';

Future<void> dataRefresh(
  TodoProvider provider,
  BuildContext context,
  bool Function() isMounted,
) async {
  // 在异步操作前获取 ScaffoldMessenger
  final scaffoldMessenger = ScaffoldMessenger.of(context);
  // 在异步操作前获取 Navigator
  final navigator = Navigator.of(context);

  try {
    final syncSettingsProvider = Provider.of<SyncSettingsProvider>(
      context,
      listen: false,
    );

    if (!syncSettingsProvider.settings.isEnabled) {
      await provider.refresh();
      if (!isMounted()) return;
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('本地数据刷新成功'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final settings = syncSettingsProvider.settings;
    if (!settings.isValid) {
      await provider.refresh();
      if (!isMounted()) return;
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('同步配置不正确，仅使用本地数据刷新'),
          duration: Duration(seconds: 3),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    scaffoldMessenger.showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 12),
            Text('正在同步数据...'),
          ],
        ),
        duration: Duration(seconds: 30),
      ),
    );

    final webdavSync = WebdavSyncService.instance;
    await webdavSync.init(
      host: settings.host!,
      user: settings.username!,
      password: settings.password!,
    );

    final todos = provider.todos ?? [];
    final categories = provider.categories ?? [];

    final syncResult = await webdavSync.sync(
      localTodos: todos,
      localCategories: categories,
    );

    await _updateLocalDatabase(syncResult);
    await provider.refresh();

    if (!isMounted()) return;
    scaffoldMessenger.hideCurrentSnackBar();

    if (syncResult.hasConflicts) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('同步完成，但发现数据冲突'),
              if (syncResult.todoConflicts.isNotEmpty)
                Text('待办事项冲突: ${syncResult.todoConflicts.length} 个'),
              if (syncResult.categoryConflicts.isNotEmpty)
                Text('分类冲突: ${syncResult.categoryConflicts.length} 个'),
              const Text('已自动选择最新版本，请检查数据'),
            ],
          ),
          duration: const Duration(seconds: 5),
          backgroundColor: Colors.orange,
          action: SnackBarAction(
            label: '查看详情',
            onPressed: () {
              if (isMounted()) {
                _showConflictDetails(context, syncResult, navigator);
              }
            },
          ),
        ),
      );
    } else {
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('数据同步成功'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.green,
        ),
      );
    }
  } catch (e) {
    if (!isMounted()) return;
    scaffoldMessenger.hideCurrentSnackBar();

    String errorMessage = '同步失败';
    Color backgroundColor = Colors.red;

    if (e is InitializationException) {
      errorMessage = 'WebDAV 连接失败: ${e.message}';
    } else if (e is SyncFailedException) {
      errorMessage = '数据同步失败: ${e.message}';
    } else {
      errorMessage = '同步失败: $e';
    }

    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text(errorMessage),
        duration: const Duration(seconds: 5),
        backgroundColor: backgroundColor,
        action: SnackBarAction(
          label: '重试',
          textColor: Colors.white,
          onPressed: () => dataRefresh(provider, context, isMounted),
        ),
      ),
    );

    try {
      await provider.refresh();
    } catch (localError) {
      if (!isMounted()) return;
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('本地数据刷新也失败: $localError'),
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.red.shade800,
        ),
      );
    }
  }
}

/// 将同步结果更新到本地数据库
Future<void> _updateLocalDatabase(SyncResult syncResult) async {
  final db = DatabaseQuery.instance;

  for (final todo in syncResult.todos) {
    try {
      await db.updateTodo(todo.toMap());
    } catch (e) {
      try {
        await db.insertTodo(todo.toMap());
      } catch (insertError) {
        if (kDebugMode) {
          print('Failed to save todo ${todo.id}: $insertError');
        }
      }
    }
  }

  for (final category in syncResult.categories) {
    try {
      await db.updateCategory(category.toMap());
    } catch (e) {
      try {
        await db.insertCategory(category.toMap());
      } catch (insertError) {
        if (kDebugMode) {
          print('Failed to save category ${category.id}: $insertError');
        }
      }
    }
  }
}

/// 显示冲突详情对话框
void _showConflictDetails(
  BuildContext context,
  SyncResult syncResult,
  NavigatorState navigator,
) {
  showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: const Text('数据冲突详情'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (syncResult.todoConflicts.isNotEmpty) ...[
                const Text(
                  '待办事项冲突:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...syncResult.todoConflicts.map(
                  (conflict) => Padding(
                    padding: const EdgeInsets.only(left: 16, bottom: 4),
                    child: Text('• ${conflict.localItem.title} (已选择最新版本)'),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              if (syncResult.categoryConflicts.isNotEmpty) ...[
                const Text(
                  '分类冲突:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...syncResult.categoryConflicts.map(
                  (conflict) => Padding(
                    padding: const EdgeInsets.only(left: 16, bottom: 4),
                    child: Text('• ${conflict.localItem.name} (已选择最新版本)'),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Text(
                '冲突解决策略：自动选择最后修改时间较新的版本。如果数据不正确，请手动调整。',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: const Text('确定'),
            onPressed: () => Navigator.of(dialogContext).pop(),
          ),
        ],
      );
    },
  );
}
