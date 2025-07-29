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
  List<Todo>? _localSortedTodos; // 本地排序状态
  bool _showCompleted = false; // 是否显示已完成的todo

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
    scaffoldElements.updateFloatingActionButton(
      SharedFAB.build(context, todoProvider),
    );
    scaffoldElements.updateFloatingActionButtonLocation(
      FloatingActionButtonLocation.endFloat,
    );
    scaffoldElements.updateFloatingActionButtonAnimator(
      FloatingActionButtonAnimator.scaling,
    );

    scaffoldElements.updateEndDrawer(
      SharedEndDrawer.build(
        context,
        todoProvider,
        selectedCategoryId: selectedCategoryId,
        onCategorySelected: _selectCategory,
      ),
    );
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
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // 标题
          Text(
            selectedCategoryName,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(width: 16), // 标题和切换按钮之间的间距
          // 切换按钮组
          _buildAnimatedToggleButtons(),
        ],
      ),
      centerTitle: false,
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

  // 构建带滑动动画的切换按钮
  Widget _buildAnimatedToggleButtons() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          // 滑动的背景
          AnimatedPositioned(
            duration: Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            left: _showCompleted ? 80.0 : 0.0, // 根据选中状态调整位置
            top: 0,
            bottom: 0,
            width: 80.0, // 单个按钮的宽度
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onPrimary,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          // 按钮文字
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildToggleButton(
                context,
                "进行中",
                !_showCompleted,
                () => setState(() {
                  _showCompleted = false;
                  _localSortedTodos = null; // 清空本地状态以强制重新排序
                }),
              ),
              _buildToggleButton(
                context,
                "已完成",
                _showCompleted,
                () => setState(() {
                  _showCompleted = true;
                  _localSortedTodos = null; // 清空本地状态以强制重新排序
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 构建切换按钮
  Widget _buildToggleButton(
    BuildContext context,
    String text,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: () {
        if (isSelected) return; // 如果已经选中则不执行
        onTap();
      },
      child: Container(
        width: 80.0, // 固定宽度确保对齐
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            style: TextStyle(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onPrimary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              fontSize: 14,
            ),
            child: Text(text),
          ),
        ),
      ),
    );
  }

  // 构建主体内容
  Widget _buildTodoBody(
    BuildContext context,
    List<Todo> todos,
    TodoProvider provider,
  ) {
    // 根据当前显示状态过滤todos
    final filteredTodos = todos.where((todo) {
      return _showCompleted ? todo.isCompleted : !todo.isCompleted;
    }).toList();

    // 如果本地排序状态为空或数据发生变化，重新排序
    if (_localSortedTodos == null ||
        _localSortedTodos!.length != filteredTodos.length) {
      _localSortedTodos = TodosSort.todosSortByPriority(filteredTodos);
    }

    // 确保 _localSortedTodos 不为空且长度正确
    if (_localSortedTodos == null || _localSortedTodos!.isEmpty) {
      _localSortedTodos = filteredTodos.isNotEmpty
          ? TodosSort.todosSortByPriority(filteredTodos)
          : <Todo>[];
    }

    // 计算Body高度 - 由于移除了AppBar的bottom部分，不再需要减去48像素
    final availableHeight =
        MediaQuery.of(context).size.height -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom -
        kBottomNavigationBarHeight -
        kToolbarHeight;

    if (filteredTodos.isEmpty) {
      return AnimatedSwitcher(
        duration: Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
              ),
              child: child,
            ),
          );
        },
        child: SizedBox(
          key: ValueKey(
            'empty_state_$_showCompleted',
          ), // 确保AnimatedSwitcher识别变化
          height: availableHeight,
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _showCompleted ? Icons.task_alt : Icons.pending_actions,
                    size: 64,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  SizedBox(height: 16),
                  Text(
                    _showCompleted ? '暂无已完成事项' : '暂无待办事项',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return AnimatedSwitcher(
      duration: Duration(milliseconds: 300),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return SlideTransition(
          position: Tween<Offset>(begin: Offset(0.0, 0.1), end: Offset.zero)
              .animate(
                CurvedAnimation(parent: animation, curve: Curves.easeInOut),
              ),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      child: SizedBox(
        key: ValueKey('todo_list_$_showCompleted'), // 确保AnimatedSwitcher识别变化
        height: availableHeight,
        child: ReorderableListView.builder(
          padding: EdgeInsets.zero, // 完全移除内边距
          itemCount: _localSortedTodos!.length,
          buildDefaultDragHandles: false, // 禁用默认拖拽手柄，我们自己添加
          proxyDecorator: (child, index, animation) {
            // 自定义拖拽时的外观，减少阴影和背景效果
            return Material(
              elevation: 2, // 减少阴影高度
              color: Colors.transparent, // 透明背景
              shadowColor: Colors.black12, // 更淡的阴影颜色
              child: Transform.scale(
                scale: 1.02, // 轻微放大
                child: child,
              ),
            );
          },
          onReorder: (int oldIndex, int newIndex) {
            // 安全检查：确保索引在有效范围内
            if (_localSortedTodos == null ||
                oldIndex >= _localSortedTodos!.length ||
                oldIndex < 0) {
              return;
            }

            // 立即更新本地UI状态
            setState(() {
              // 调整newIndex，如果向后移动需要减1
              if (oldIndex < newIndex) {
                newIndex -= 1;
              }

              // 再次确保newIndex在有效范围内
              newIndex = newIndex.clamp(0, _localSortedTodos!.length - 1);

              // 移动本地列表中的元素
              final Todo movedTodo = _localSortedTodos!.removeAt(oldIndex);
              _localSortedTodos!.insert(newIndex, movedTodo);
            });

            // 异步更新数据库，不触发状态更新
            _updateDatabaseSilently(provider, _localSortedTodos!);
          },
          itemBuilder: (context, index) {
            // 安全检查索引范围
            if (index >= _localSortedTodos!.length) {
              return Container(key: ValueKey('empty_$index'));
            }

            final todo = _localSortedTodos![index];
            return TodoTile(
              key: ValueKey('todo_${todo.id}'),
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
              priority: todo.priority,
              dragIndex: index, // 传递拖动索引
              enableDrag: true, // 启用拖动功能
            );
          },
        ),
      ),
    );
  }

  // 静默更新数据库，不触发状态更新
  Future<void> _updateDatabaseSilently(
    TodoProvider provider,
    List<Todo> reorderedTodos,
  ) async {
    try {
      // 安全检查
      if (reorderedTodos.isEmpty) {
        return;
      }

      // 重新分配优先级
      int maxPriority = 0;
      if (provider.todos != null && provider.todos!.isNotEmpty) {
        maxPriority = provider.todos!
            .map((todo) => todo.priority)
            .reduce((a, b) => a > b ? a : b);
      }
      int startPriority = maxPriority + reorderedTodos.length;

      // 批量更新数据库中的优先级，不触发UI更新
      List<int> todoIds = reorderedTodos.map((todo) => todo.id).toList();
      await provider.reorderTodosSilently(todoIds, startPriority);
    } catch (e) {
      print('静默更新数据库失败: $e');
      // 如果更新失败，可以选择重新加载数据
      // provider.refresh();
    }
  }

  String? _getCategoryName(int? categoryId) {
    if (categoryId == null) return null;
    final categories = context.read<TodoProvider>().categories ?? [];
    try {
      final category = categories.firstWhere(
        (cat) => cat.id == categoryId,
        orElse: () => throw StateError('Category not found'),
      );
      return category.name;
    } catch (e) {
      // 如果找不到分类，返回null或默认值
      return null;
    }
  }

  Color? _getCategoryColor(int? categoryId) {
    if (categoryId == null) return null;
    final categories = context.read<TodoProvider>().categories ?? [];
    try {
      final category = categories.firstWhere(
        (cat) => cat.id == categoryId,
        orElse: () => throw StateError('Category not found'),
      );
      // 使用了ShowDialog中的辅助函数
      return category.color != null
          ? parseColor(category.color!, context)
          : null;
    } catch (e) {
      // 如果找不到分类，返回null
      return null;
    }
  }
}
