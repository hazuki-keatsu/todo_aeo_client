import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_aeo/l10n/app_localizations.dart';
import 'package:todo_aeo/pages/language_settings_page.dart';
import 'package:todo_aeo/services/sync/data_refresh.dart';
import 'package:todo_aeo/widgets/show_dialog.dart';
import 'package:todo_aeo/providers/todo_provider.dart';
import 'package:todo_aeo/providers/scaffold_elements_notifier.dart';
import 'package:todo_aeo/providers/settings_provider.dart';
import 'package:todo_aeo/utils/app_routes.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateScaffoldElements();
    });
  }

  void _updateScaffoldElements() {
    final scaffoldElements = Provider.of<ScaffoldElementsNotifier>(
      context,
      listen: false,
    );
    final l10n = AppLocalizations.of(context)!;

    scaffoldElements.updateAppBar(
      AppBar(
        title: Text(l10n.settings),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
    );

    scaffoldElements.updateFloatingActionButton(null);
    scaffoldElements.updateEndDrawer(null);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Consumer2<TodoProvider, SettingsProvider>(
      builder: (context, todoProvider, settingsProvider, child) {
        // 当数据变化时更新 Scaffold 元素
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _updateScaffoldElements();
        });

        final totalTodos = todoProvider.todos?.length ?? 0;
        final completedTodos =
            todoProvider.todos?.where((todo) => todo.isCompleted).length ?? 0;
        final totalCategories = todoProvider.categories?.length ?? 0;

        const sizedBoxHeight = 8.0;

        return ListView(
          padding: EdgeInsets.all(3),
          children: [
            // 统计信息卡片
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.statistics, style: Theme.of(context).textTheme.titleLarge),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          context,
                          l10n.total,
                          totalTodos.toString(),
                          Icons.list,
                        ),
                        _buildStatItem(
                          context,
                          l10n.completed,
                          completedTodos.toString(),
                          Icons.check_circle_outline,
                        ),
                        _buildStatItem(
                          context,
                          l10n.categoryCount,
                          totalCategories.toString(),
                          Icons.label_outlined,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: sizedBoxHeight),
            // 服务器配置
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.cloud_outlined),
                    title: Text(l10n.serverConfiguration),
                    subtitle: Text(l10n.configureSyncSettings),
                    onTap: () {
                      Navigator.push(
                        context,
                        AppRoutes.generateRoute(const RouteSettings(
                            name: "/sync_settings"))!,
                      );
                    },
                  ),
                  Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.sync),
                    title: Text(l10n.syncNow),
                    subtitle: Text(l10n.syncImmediately),
                    onTap: () {
                      dataRefresh(todoProvider, context, () => mounted);
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: sizedBoxHeight),
            // 数据管理
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.color_lens_outlined),
                    title: Text(l10n.themeSwitch),
                    subtitle: Text(l10n.chooseTheme),
                    onTap: () {
                      Navigator.push(
                        context,
                        AppRoutes.generateRoute(const RouteSettings(name: "/theme_settings"))!,
                      );
                    },
                  ),
                  Divider(),
                  ListTile(
                    leading: Icon(Icons.language_outlined),
                    title: Text(l10n.languageSwitch),
                    subtitle: Text(l10n.chooseLanguage),
                    onTap: () {
                      AppRoutes.pushPage(context, LanguageSettingsPage());
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: sizedBoxHeight),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.info_outline),
                    title: Text(l10n.aboutApp),
                    subtitle: settingsProvider.isLoading
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 12,
                                height: 12,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(l10n.loading),
                            ],
                          )
                        : Text(
                      'Todo AEO ${settingsProvider.getFormattedVersion(
                          showBuildNumber: false)}',
                          ),
                    onTap: () {
                      ShowDialog.showAboutApplicationDialog(
                        context,
                        settingsProvider,
                      );
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: sizedBoxHeight),
            // 应用信息
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.appInfo, style: Theme.of(context).textTheme.titleLarge),
                    SizedBox(height: 16),
                    // 使用SettingsProvider的便捷方法来构建信息行
                    ...settingsProvider
                        .getAppInfoMap()
                        .entries
                        .map((entry) => _buildInfoRow(entry.key, entry.value)),
                    _buildInfoRow('框架', 'Flutter'),
                    _buildInfoRow('设计', 'Material You'),
                    if (settingsProvider.error != null)
                      _buildInfoRow(
                        'Provider状态',
                        '错误: ${settingsProvider.error}',
                      ),
                    if (todoProvider.error != null)
                      _buildInfoRow('Todo状态', '错误: ${todoProvider.error}'),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
        SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
