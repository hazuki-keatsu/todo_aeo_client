import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:todo_aeo/providers/todo_provider.dart';
import 'package:todo_aeo/providers/sync_settings_provider.dart';
import 'package:todo_aeo/services/sync/weddav_sync.dart';
import 'package:todo_aeo/services/sync/sync_exceptions.dart';
import 'package:todo_aeo/services/database_query.dart';
import 'package:provider/provider.dart';
import 'package:todo_aeo/l10n/app_localizations.dart';

Future<void> dataRefresh(
  TodoProvider provider,
  BuildContext context,
  bool Function() isMounted,
) async {
  // 在异步操作前获取 ScaffoldMessenger
  final scaffoldMessenger = ScaffoldMessenger.of(context);
  // 在异步操作前获取 Navigator
  final navigator = Navigator.of(context);
  // 获取国际化对象
  final l10n = AppLocalizations.of(context)!;

  try {
    final syncSettingsProvider = Provider.of<SyncSettingsProvider>(
      context,
      listen: false,
    );

    if (!syncSettingsProvider.settings.isEnabled) {
      await provider.refresh();
      if (!isMounted()) return;
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(l10n.localDataRefreshSuccess),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    final settings = syncSettingsProvider.settings;
    if (!settings.isValid) {
      await provider.refresh();
      if (!isMounted()) return;
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(l10n.syncConfigIncorrectLocalOnly),
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Text(l10n.syncingData),
          ],
        ),
        duration: const Duration(seconds: 30),
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
              Text(l10n.syncCompletedWithConflicts),
              if (syncResult.todoConflicts.isNotEmpty)
                Text(l10n.todoConflictsCount(syncResult.todoConflicts.length)),
              if (syncResult.categoryConflicts.isNotEmpty)
                Text(l10n.categoryConflictsCount(syncResult.categoryConflicts.length)),
              Text(l10n.autoSelectedLatestVersion),
            ],
          ),
          duration: const Duration(seconds: 5),
          backgroundColor: Colors.orange,
          action: SnackBarAction(
            label: l10n.viewDetails,
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
        SnackBar(
          content: Text(l10n.dataSyncSuccess),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.green,
        ),
      );
    }
  } catch (e) {
    if (!isMounted()) return;
    scaffoldMessenger.hideCurrentSnackBar();

    String errorMessage = l10n.syncFailed;
    Color backgroundColor = Colors.red;

    if (e is InitializationException) {
      errorMessage = l10n.webdavConnectionFailed(e.message);
    } else if (e is SyncFailedException) {
      errorMessage = l10n.dataSyncFailedWithMessage(e.message);
    } else {
      errorMessage = l10n.syncFailedWithError(e.toString());
    }

    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text(errorMessage),
        duration: const Duration(seconds: 5),
        backgroundColor: backgroundColor,
        action: SnackBarAction(
          label: l10n.retry,
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
          content: Text(l10n.localDataRefreshFailed(localError.toString())),
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
  final l10n = AppLocalizations.of(context)!;

  showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: Text(l10n.dataConflictDetails),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (syncResult.todoConflicts.isNotEmpty) ...[
                Text(
                  l10n.todoConflictsLabel,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...syncResult.todoConflicts.map(
                  (conflict) => Padding(
                    padding: const EdgeInsets.only(left: 16, bottom: 4),
                    child: Text('• ${conflict.localItem.title}${l10n.selectedLatestVersionSuffix}'),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              if (syncResult.categoryConflicts.isNotEmpty) ...[
                Text(
                  l10n.categoryConflictsLabel,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...syncResult.categoryConflicts.map(
                  (conflict) => Padding(
                    padding: const EdgeInsets.only(left: 16, bottom: 4),
                    child: Text('• ${conflict.localItem.name}${l10n.selectedLatestVersionSuffix}'),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Text(
                l10n.conflictResolutionStrategy,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: Text(l10n.confirm),
            onPressed: () => Navigator.of(dialogContext).pop(),
          ),
        ],
      );
    },
  );
}
