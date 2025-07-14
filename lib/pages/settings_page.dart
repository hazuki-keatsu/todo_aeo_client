import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_aeo/providers/todo_provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<TodoProvider>(
      builder: (context, todoProvider, child) {
        final totalTodos = todoProvider.todos?.length ?? 0;
        final completedTodos = todoProvider.todos?.where((todo) => todo.isCompleted).length ?? 0;
        final totalCategories = todoProvider.categories?.length ?? 0;

        return Scaffold(
          appBar: AppBar(
            title: Text('设置'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
          ),
          body: ListView(
            padding: EdgeInsets.all(16),
            children: [
              // 统计信息卡片
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '统计信息',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem(
                            context,
                            '总待办',
                            totalTodos.toString(),
                            Icons.list,
                          ),
                          _buildStatItem(
                            context,
                            '已完成',
                            completedTodos.toString(),
                            Icons.check_circle,
                          ),
                          _buildStatItem(
                            context,
                            '分类数',
                            totalCategories.toString(),
                            Icons.label,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              // 数据管理
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.refresh),
                      title: Text('刷新数据'),
                      subtitle: Text('重新加载所有数据'),
                      onTap: () async {
                        try {
                          await todoProvider.refresh();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('数据刷新成功'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('刷新失败: $e'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                    ),
                    Divider(height: 1),
                    ListTile(
                      leading: Icon(Icons.info_outline),
                      title: Text('关于应用'),
                      subtitle: Text('Todo AEO v1.0'),
                      onTap: () {
                        showAboutDialog(
                          context: context,
                          applicationName: 'Todo AEO',
                          applicationVersion: '1.0.0',
                          applicationIcon: Icon(Icons.check_circle),
                          children: [
                            Text('一个简洁美观的待办事项管理应用'),
                            SizedBox(height: 8),
                            Text('使用 Flutter 和 Material You 设计'),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              // 应用信息
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '应用信息',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      SizedBox(height: 16),
                      _buildInfoRow('版本', '1.0.0'),
                      _buildInfoRow('框架', 'Flutter'),
                      _buildInfoRow('设计', 'Material You'),
                      if (todoProvider.error != null)
                        _buildInfoRow('状态', '错误: ${todoProvider.error}'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          size: 32,
          color: Theme.of(context).colorScheme.primary,
        ),
        SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
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
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}