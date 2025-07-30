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

class _HomePageState extends State<HomePage> {
  int? selectedCategoryId; // null表示显示所有todos
  String selectedCategoryName = "全部";
  bool _hasInitialized = false;
  List<Todo>? _localSortedTodos; // 本地排序状态
  bool _showCompleted = false; // 是否显示已完成的todo

  // 多选相关状态
  bool _isMultiSelectMode = false; // 是否处于多选模式
  Set<int> _selectedTodoIds = {}; // 已选中的待办事项ID集合

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
      _localSortedTodos = null; // 清空本地状态以强制重新排序
    });

    // 立即更新 AppBar 标题
    _updateScaffoldElements();

    // 强制触发Provider重新构建，确保UI更新
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 触发一次轻量级的状态通知，确保Consumer重新构建
      if (mounted) {
        setState(() {});
      }
    });

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
    // 多选模式下的AppBar
    if (_isMultiSelectMode) {
      return AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.close,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
          onPressed: () {
            setState(() {
              _isMultiSelectMode = false;
              _selectedTodoIds.clear();
            });
            _updateScaffoldElements();
          },
          tooltip: '退出多选',
        ),
        title: Text(
          '已选择 ${_selectedTodoIds.length} 项',
          style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
        ),
        centerTitle: false,
        actions: <Widget>[
          // 全选/取消全选按钮
          IconButton(
            icon: Icon(
              _areAllTodosSelected() ? Icons.deselect : Icons.select_all,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
            onPressed: _toggleSelectAll,
            tooltip: _areAllTodosSelected() ? '取消全选' : '全选',
          ),
          // 删除按钮
          IconButton(
            icon: Icon(
              Icons.delete,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
            onPressed: _selectedTodoIds.isEmpty ? null : _deleteSelectedTodos,
            tooltip: '删除所选项',
          ),
        ],
        backgroundColor: Theme.of(context).colorScheme.primary,
      );
    }

    // 正常模式的AppBar
    return AppBar(
      title: Text(
        selectedCategoryName,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onPrimary,
        ),
      ),
      centerTitle: false,
      automaticallyImplyLeading: false,
      actions: <Widget>[
        _buildAnimatedToggleButtons(),
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
      height: 36,
      width: 160,
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
              dragIndex: _isMultiSelectMode ? null : index,
              // 在多选模式下禁用拖动
              enableDrag: !_isMultiSelectMode,
              // 在多选模式下禁用拖动功能
              // 多选相关属性
              isMultiSelectMode: _isMultiSelectMode,
              isSelected: _selectedTodoIds.contains(todo.id),
              onLongPress: () => _enableMultiSelectMode(todo.id),
              onSelected: (selected) => _toggleTodoSelection(todo.id, selected),
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

  // 启用多选模式
  void _enableMultiSelectMode(int initialId) {
    setState(() {
      _isMultiSelectMode = true;
      _selectedTodoIds = {initialId}; // 添加长按的待办事项作为初始选中项
    });
    _updateScaffoldElements(); // 更新AppBar以显示多选操作
  }

  // 切换待办事项的选中状态
  void _toggleTodoSelection(int id, bool selected) {
    setState(() {
      if (selected) {
        _selectedTodoIds.add(id);
      } else {
        _selectedTodoIds.remove(id);
      }
    });
  }

  // 切换全选/取消全选
  void _toggleSelectAll() {
    setState(() {
      if (_areAllTodosSelected()) {
        // 如果当前是全选状态，则取消全选
        _selectedTodoIds.clear();
      } else {
        // 否则执行全选
        _selectedTodoIds = _localSortedTodos!.map((todo) => todo.id).toSet();
      }
    });
  }

  // 检查是否所有待办事项都被选中
  bool _areAllTodosSelected() {
    if (_localSortedTodos == null) return false;
    return _localSortedTodos!.every((todo) =>
        _selectedTodoIds.contains(todo.id));
  }

  // 删除选中的待办事项
  void _deleteSelectedTodos() {
    final provider = context.read<TodoProvider>();
    // 过滤出选中的待办事项
    final selectedTodos = provider.todos?.where((todo) =>
        _selectedTodoIds.contains(todo.id)).toList() ?? [];

    // 显示确认对话框
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('确认删除'),
          content: Text(
              '您确定要删除选中的 ${selectedTodos.length} 项待办事项吗？'),
          actions: <Widget>[
            TextButton(
              child: Text('取消'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('删除', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
                // 执行删除操作
                provider.deleteTodos(
                    selectedTodos.map((todo) => todo.id).toList());
                // 退出多选模式
                setState(() {
                  _isMultiSelectMode = false;
                  _selectedTodoIds.clear();
                });
              },
            ),
          ],
        );
      },
    );
  }
}
