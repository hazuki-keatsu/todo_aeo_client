import 'package:flutter/material.dart';
import 'package:todo_aeo/functions/data_refresh.dart';
import 'package:todo_aeo/functions/todos_sort.dart';
import 'package:provider/provider.dart';
import 'package:todo_aeo/utils/parse_color.dart';
import 'package:todo_aeo/widgets/shared_end_drawer.dart';
import 'package:todo_aeo/widgets/todo_tile.dart';
import 'package:todo_aeo/widgets/shared_fab.dart';
import 'package:todo_aeo/modules/todo.dart';
import 'package:todo_aeo/providers/todo_provider.dart';
import 'package:todo_aeo/providers/scaffold_elements_notifier.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

// TODO: 添加多选功能，优化操作逻辑
// 短按查看详情 -> 编辑和删除功能
// 长按进入多选

class _HomePageState extends State<HomePage> {
  int? selectedCategoryId; // null表示显示所有todos
  String selectedCategoryName = "全部";
  bool _hasInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasInitialized) {
        _updateScaffoldElements();
        _hasInitialized = true;
      }
    });
  }

  void _updateScaffoldElements() {
    final todoProvider = Provider.of<TodoProvider>(context, listen: false);
    final scaffoldElements = Provider.of<ScaffoldElementsNotifier>(
      context,
      listen: false,
    );

    // 分别更新不同的元素
    scaffoldElements.updateAppBar(_buildAppBar(context, todoProvider));
    
    // 使用共享的 FAB，只更新 FAB 而不触发全局重构
    scaffoldElements.updateFloatingActionButton(SharedFAB.build(context, todoProvider));
    scaffoldElements.updateFloatingActionButtonLocation(FloatingActionButtonLocation.endFloat);
    scaffoldElements.updateFloatingActionButtonAnimator(FloatingActionButtonAnimator.scaling);
    
    scaffoldElements.updateEndDrawer(SharedEndDrawer.build(
      context, 
      todoProvider,
      selectedCategoryId: selectedCategoryId,
      onCategorySelected: _selectCategory,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TodoProvider>(
      builder: (context, todoProvider, child) {
        // 当数据变化时更新 Scaffold 元素
        if (_hasInitialized && (todoProvider.categories?.isNotEmpty == true)) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _updateScaffoldElements();
          });
        }

        if (todoProvider.isLoading) {
          return Center(child: CircularProgressIndicator());
        }

        if (todoProvider.error != null) {
          return Center(
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
          );
        }

        // 修改这部分逻辑来正确处理未分类的情况
        final todos = selectedCategoryId == null
            ? todoProvider.todos ?? []
            : selectedCategoryId == -1
            ? (todoProvider.todos ?? [])
                  .where((todo) => todo.categoryId == null)
                  .toList()
            : todoProvider.getTodosByCategory(selectedCategoryId);

        return _buildTodoBody(context, todos, todoProvider);
      },
    );
  }

  // 选择分类
  void _selectCategory(int? categoryId, String categoryName) {
    setState(() {
      selectedCategoryId = categoryId;
      selectedCategoryName = categoryName;
    });
    // 立即更新 AppBar 标题
    _updateScaffoldElements();
    Navigator.pop(context); // 关闭侧边栏
  }

  // 完成数据的本地同步
  void _updateCompleted(bool value, int? id) {
    if (id == null) return;

    final provider = context.read<TodoProvider>();
    provider.toggleTodoCompletion(id);
  }

  // 构建 AppBar
  AppBar _buildAppBar(BuildContext context, TodoProvider provider) {
    return AppBar(
      title: Text(
        selectedCategoryName,
        style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
      ),
      automaticallyImplyLeading: false,
      actions: <Widget>[
        Tooltip(
          message: "刷新",
          child: IconButton(
            onPressed: () {
              dataRefresh(provider, context);
            },
            icon: Icon(
              Icons.refresh,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
        ),
        Tooltip(
          message: "Todo 分组",
          child: IconButton(
            onPressed: () {
              Scaffold.of(context).openEndDrawer();
            },
            icon: Icon(
              Icons.menu,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
        ),
      ],
      backgroundColor: Theme.of(context).colorScheme.primary,
    );
  }

  // 构建主体内容
  Widget _buildTodoBody(
    BuildContext context,
    List<Todo> todos,
    TodoProvider provider,
  ) {
    // 使用TodosSort进行分组
    final completionGroups = TodosSort.todosCompletion(todos);
    final completedTodos = TodosSort.todosSortByFinishingTime(
      completionGroups[0],
    );
    final uncompletedTodos = TodosSort.todosSortByFinishingTime(
      completionGroups[1],
    );

    // 计算Body高度
    final availableHeight =
        MediaQuery.of(context).size.height -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom -
        kBottomNavigationBarHeight -
        kToolbarHeight;

    return SizedBox(
      height: availableHeight, // 使用您已经计算好的高度
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 未完成的todos
            if (uncompletedTodos.isNotEmpty) ...[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Text(
                  '未完成 (${uncompletedTodos.length})',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
                      finishingAt: todo.finishingAt,
                      updateCompetedFunction: _updateCompleted,
                      categoryName: _getCategoryName(todo.categoryId),
                      categoryColor: _getCategoryColor(todo.categoryId),
                      todoProvider: provider,
                    ),
                  );
                },
              ),
            ],
            // 已完成的todos
            if (completedTodos.isNotEmpty) ...[
              if (uncompletedTodos.isNotEmpty) SizedBox(height: 16),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Text(
                  '已完成 (${completedTodos.length})',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
                      finishingAt: todo.finishingAt,
                      updateCompetedFunction: _updateCompleted,
                      categoryName: _getCategoryName(todo.categoryId),
                      categoryColor: _getCategoryColor(todo.categoryId),
                      todoProvider: provider,
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
                              color: Theme.of(context).colorScheme.outline,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String? _getCategoryName(int? categoryId) {
    if (categoryId == null) return null;
    final categories = context.read<TodoProvider>().categories ?? [];
    final category = categories.firstWhere((cat) => cat.id == categoryId);
    return category.name;
  }

  Color? _getCategoryColor(int? categoryId) {
    if (categoryId == null) return null;
    final categories = context.read<TodoProvider>().categories ?? [];
    final category = categories.firstWhere((cat) => cat.id == categoryId);
    // 使用了ShowDialog中的辅助函数
    return category.color != null
        ? parseColor(category.color!, context)
        : null;
  }
}
