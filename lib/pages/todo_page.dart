import 'package:flutter/material.dart';
import 'package:todo_aeo/functions/todos_sort.dart';
import 'package:provider/provider.dart';
import 'package:todo_aeo/functions/show_dialog.dart';
import 'package:todo_aeo/widgets/todo_tile.dart';
import 'package:todo_aeo/modules/todo.dart';
import 'package:todo_aeo/modules/category.dart';
import 'package:todo_aeo/providers/todo_provider.dart';

// TODO: 每次修改ToDo的完成情况时对List进行重建，重新进行排序，使用Hero动画
// TODO: 添加ToDo删除时的动画

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  int? selectedCategoryId; // null表示显示所有todos
  String selectedCategoryName = "全部";
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Consumer<TodoProvider>(
      builder: (context, todoProvider, child) {
        if (todoProvider.isLoading) {
          return Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(title: Text(selectedCategoryName)),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (todoProvider.error != null) {
          return Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(title: Text(selectedCategoryName)),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('加载失败: ${todoProvider.error}'),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      todoProvider.clearError();
                      todoProvider.refresh();
                    },
                    child: Text('重试'),
                  ),
                ],
              ),
            ),
          );
        }

        final todos = selectedCategoryId == null
            ? todoProvider.todos ?? []
            : todoProvider.getTodosByCategory(selectedCategoryId);

        final categories = todoProvider.categories ?? [];

        return _buildTodoPage(context, todos, categories, todoProvider);
      },
    );
  }

  // 选择分类
  void _selectCategory(int? categoryId, String categoryName) {
    setState(() {
      selectedCategoryId = categoryId;
      selectedCategoryName = categoryName;
    });
    Navigator.pop(context); // 关闭侧边栏
  }

  // 完成数据的本地同步
  void _updateCompleted(bool value, int? id) {
    if (id == null) return;

    final provider = context.read<TodoProvider>();
    provider.toggleTodoCompletion(id);
  }

  Widget _buildTodoPage(
    BuildContext context,
    List<Todo> todos,
    List<Category> categories,
    TodoProvider provider,
  ) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          selectedCategoryName,
          style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
        ),
        automaticallyImplyLeading: false,
        actions: <Widget>[
          Tooltip(
            message: "Todo 分组",
            child: IconButton(
              onPressed: () {
                _scaffoldKey.currentState?.openEndDrawer();
              },
              icon: Icon(
                Icons.menu,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ),
        ],
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ShowDialog.showAddTodoDialog(context, provider);
        },
        tooltip: "添加一个Todo",
        child: Icon(Icons.add),
      ),
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Padding(
        padding: EdgeInsetsGeometry.fromLTRB(8, 4, 8, 8),
        child: Builder(
          builder: (context) {
            // 使用TodosSort进行分组
            final completionGroups = TodosSort.todosCompletion(todos);
            final completedTodos = TodosSort.todosSortByFinishingTime(
              completionGroups[0],
            );
            final uncompletedTodos = TodosSort.todosSortByFinishingTime(
              completionGroups[1],
            );

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 未完成的todos
                  if (uncompletedTodos.isNotEmpty) ...[
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      child: Text(
                        '未完成 (${uncompletedTodos.length})',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: uncompletedTodos.length,
                      itemBuilder: (context, index) {
                        final todo = uncompletedTodos[index];
                        return Material(
                          type: MaterialType.transparency,
                          child: TodoTile(
                            key: ValueKey('uncompleted_${todo.id}'),
                            id: todo.id,
                            title: todo.title,
                            description: todo.description ?? "",
                            isCompleted: todo.isCompleted == true ? 1 : 0,
                            createdAt: todo.createdAt,
                            finishingAt: todo.finishingAt ?? DateTime.now(),
                            updateCompetedFunction: _updateCompleted,
                          ),
                        );
                      },
                    ),
                  ],
                  // 已完成的todos
                  if (completedTodos.isNotEmpty) ...[
                    if (uncompletedTodos.isNotEmpty) SizedBox(height: 16),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      child: Text(
                        '已完成 (${completedTodos.length})',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: Theme.of(context).colorScheme.outline,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: completedTodos.length,
                      itemBuilder: (context, index) {
                        final todo = completedTodos[index];
                        return Material(
                          type: MaterialType.transparency,
                          child: TodoTile(
                            key: ValueKey('completed_${todo.id}'),
                            id: todo.id,
                            title: todo.title,
                            description: todo.description ?? "",
                            isCompleted: todo.isCompleted == true ? 1 : 0,
                            createdAt: todo.createdAt,
                            finishingAt: todo.finishingAt ?? DateTime.now(),
                            updateCompetedFunction: _updateCompleted,
                          ),
                        );
                      },
                    ),
                  ],
                  // 空状态提示
                  if (todos.isEmpty)
                    Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Column(
                          children: [
                            Icon(
                              Icons.task_alt,
                              size: 64,
                              color: Theme.of(context).colorScheme.outline,
                            ),
                            SizedBox(height: 16),
                            Text(
                              '暂无待办事项',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.outline,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
      endDrawer: _buildDrawer(context, categories),
    );
  }

  Widget _buildDrawer(BuildContext context, List<Category> categories) {
    return Drawer(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondaryContainer,
            ),
            child: Column(
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "Todo ",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSecondaryContainer,
                        ),
                      ),
                      TextSpan(
                        text: "A",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3B82F6),
                        ),
                      ),
                      TextSpan(
                        text: "E",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF10B981),
                        ),
                      ),
                      TextSpan(
                        text: "O",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFF59E0B),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  "A nice day meets you!",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                    fontWeight: FontWeight.w400,
                    fontSize: 18,
                    fontFamily: "cursive",
                  ),
                ),
                TextButton.icon(
                  onPressed: () {},
                  label: Text("关于"),
                  icon: Icon(Icons.info_outline),
                ),
              ],
            ),
          ),
          // 分类列表
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 全部todos
                  ListTile(
                    leading: Icon(Icons.list),
                    title: Text("全部"),
                    selected: selectedCategoryId == null,
                    onTap: () => _selectCategory(null, "全部"),
                    selectedColor: Theme.of(context).colorScheme.primary,
                    selectedTileColor: Theme.of(
                      context,
                    ).colorScheme.surfaceContainer,
                  ),
                  // 未分类todos
                  ListTile(
                    leading: Icon(Icons.label_off),
                    title: Text("未分类"),
                    selected: selectedCategoryId == -1,
                    onTap: () => _selectCategory(-1, "未分类"),
                    selectedColor: Theme.of(context).colorScheme.primary,
                    selectedTileColor: Theme.of(
                      context,
                    ).colorScheme.surfaceContainer,
                  ),
                  if (categories.isNotEmpty) ...[
                    Divider(),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Text(
                        "分类",
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    ...categories.map((category) {
                      final isSelected = selectedCategoryId == category.id;
                      return ListTile(
                        leading: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: category.color != null
                                ? ShowDialog.parseColor(category.color, context)
                                : Theme.of(context).colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        title: Text(category.name),
                        selected: isSelected,
                        selectedColor: Theme.of(context).colorScheme.primary,
                        selectedTileColor: Theme.of(
                          context,
                        ).colorScheme.surfaceContainer,
                        onTap: () =>
                            _selectCategory(category.id, category.name),
                      );
                    }),
                  ],
                  Divider(),
                  ListTile(
                    leading: Icon(Icons.add),
                    title: Text("添加分类"),
                    onTap: () {
                      Navigator.pop(context);
                      ShowDialog.showAddCategoryDialog(context);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
