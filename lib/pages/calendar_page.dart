import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_aeo/functions/data_refresh.dart';
import 'package:todo_aeo/functions/show_dialog.dart';
import 'package:todo_aeo/functions/todos_sort.dart';
import 'package:todo_aeo/modules/todo.dart';
import 'package:todo_aeo/providers/todo_provider.dart';
import 'package:todo_aeo/providers/scaffold_elements_notifier.dart';
import 'package:todo_aeo/widgets/month_calendar.dart';
import 'package:todo_aeo/widgets/shared_end_drawer.dart';
import 'package:todo_aeo/widgets/week_calendar.dart';
import 'package:todo_aeo/widgets/shared_fab.dart';
import 'package:todo_aeo/widgets/todo_tile.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage>
    with SingleTickerProviderStateMixin {
  DateTime selectedDate = DateTime.now();
  ScrollController? _scrollController;
  bool _showWeekCalendar = false;
  final GlobalKey _monthCalendarKey = GlobalKey();
  bool _isAnimating = false; // 添加动画状态标记

  // 动画控制器
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController!.addListener(_onScroll);

    // 初始化动画控制器
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    // 渐显动画
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // 向下滑入动画
    _slideAnimation = Tween<Offset>(begin: Offset(0, -1.0), end: Offset(0, 0))
        .animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateScaffoldElements();
    });
    
  }

  @override
  void dispose() {
    _scrollController?.removeListener(_onScroll);
    _scrollController?.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // 如果正在动画中，不处理滚动事件，避免干扰用户滑动
    if (_isAnimating) return;

    final RenderBox? renderBox =
        _monthCalendarKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final position = renderBox.localToGlobal(Offset.zero);
      final monthCalendarBottom = position.dy + renderBox.size.height;

      // 如果月历底部滚出屏幕顶部，显示周历
      final shouldShowWeekCalendar = monthCalendarBottom < kToolbarHeight;

      if (shouldShowWeekCalendar != _showWeekCalendar) {
        setState(() {
          _showWeekCalendar = shouldShowWeekCalendar;
          _isAnimating = true; // 标记动画开始
        });

        // 控制动画
        if (shouldShowWeekCalendar) {
          _animationController.forward().then((_) {
            _isAnimating = false; // 动画完成
          });
        } else {
          _animationController.reverse().then((_) {
            _isAnimating = false; // 动画完成
          });
        }
      }
    }
  }

  void _updateScaffoldElements() {
    final provider = Provider.of<TodoProvider>(context, listen: false);
    final scaffoldElements = Provider.of<ScaffoldElementsNotifier>(
      context,
      listen: false,
    );

    // 分别更新不同的元素
    scaffoldElements.updateAppBar(
      AppBar(
        title: Text(
          "日历",
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
      ),
    );

    // 使用共享的 FAB，只更新 FAB 而不触发全局重构
    scaffoldElements.updateFloatingActionButton(
      SharedFAB.build(context, provider),
    );

    scaffoldElements.updateEndDrawer(SharedEndDrawer.build(
      context, 
      provider,
      selectedCategoryId: null,
      onCategorySelected: (_, _) {},
    ));
  }

  // 统一的日期选择处理函数，确保两个日历组件同步
  void _onDateSelected(DateTime selectedDateTimeInCalendar) {
    setState(() {
      selectedDate = selectedDateTimeInCalendar;
    });

    // 日期切换后，检查是否需要收起周历
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkScrollabilityAndHideWeekCalendar();
    });
  }

  // 检查滚动能力并在需要时隐藏周历
  void _checkScrollabilityAndHideWeekCalendar() {
    final ScrollController? controller = _scrollController;
    if (controller != null && controller.hasClients) {
      final ScrollPosition position = controller.position;

      // 如果内容高度小于等于视口高度，说明无法滚动
      if (position.maxScrollExtent <= 0) {
        // 如果当前显示了周历，则收起它
        if (_showWeekCalendar && !_isAnimating) {
          setState(() {
            _showWeekCalendar = false;
            _isAnimating = true;
          });
          _animationController.reverse().then((_) {
            _isAnimating = false;
          });
        }
      }
    }
  }

  // 完成数据的本地同步
  void _updateCompleted(bool value, int? id) {
    if (id == null) return;

    final provider = context.read<TodoProvider>();
    provider.toggleTodoCompletion(id);
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
        ? ShowDialog.parseColor(category.color!, context)
        : null;
  }

  // 构建分成完成和未完成两部分的待办事项列表
  List<Widget> _buildTodoSections(List<Todo> todayTodo, TodoProvider todoProvider) {
    if (todayTodo.isEmpty) {
      return [
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
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),
        ),
      ];
    }

    // 使用TodosSort进行分组
    final completionGroups = TodosSort.todosCompletion(todayTodo);
    final completedTodos = TodosSort.todosSortByFinishingTime(completionGroups[0]);
    final uncompletedTodos = TodosSort.todosSortByFinishingTime(completionGroups[1]);

    List<Widget> sections = [];

    // 未完成的todos
    if (uncompletedTodos.isNotEmpty) {
      sections.add(
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            '${selectedDate.day}日未完成 (${uncompletedTodos.length})',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
      sections.add(
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
                categoryName: _getCategoryName(todo.categoryId),
                categoryColor: _getCategoryColor(todo.categoryId),
                todoProvider: todoProvider,
              ),
            );
          },
        ),
      );
    }

    // 已完成的todos
    if (completedTodos.isNotEmpty) {
      if (uncompletedTodos.isNotEmpty) sections.add(SizedBox(height: 16));
      sections.add(
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            '${selectedDate.day}日已完成 (${completedTodos.length})',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
      sections.add(
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
                categoryName: _getCategoryName(todo.categoryId),
                categoryColor: _getCategoryColor(todo.categoryId),
                todoProvider: todoProvider,
              ),
            );
          },
        ),
      );
    }

    return sections;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TodoProvider>(
      builder: (context, todoProvider, child) {
        // 当数据变化时更新 Scaffold 元素
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _updateScaffoldElements();
          // 检查内容是否足够滚动，如果不够则收起周历
          _checkScrollabilityAndHideWeekCalendar();
        });

        List<DateTime> todoDeadLine = [];
        List<Todo> todayTodo = todoProvider.getTodosByDay(selectedDate);

        if (todoProvider.todos != null) {
          for (var i in todoProvider.todos!) {
            todoDeadLine.add(i.finishingAt!);
          }
        }

        if (todoProvider.isLoading) {
          return Center(child: CircularProgressIndicator());
        }

        return Stack(
          children: [
            // 主要内容区域
            SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 月历
                  Container(
                    key: _monthCalendarKey,
                    child: MonthCalendar(
                      markedDates: todoDeadLine,
                      initialDate: selectedDate,
                      onDateSelected: _onDateSelected,
                    ),
                  ),
                  Divider(),
                  ..._buildTodoSections(todayTodo, todoProvider),
                ],
              ),
            ),

            // 固定在顶部的周历（带动画）
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return _showWeekCalendar || _animationController.value > 0.0
                    ? Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).scaffoldBackgroundColor,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    offset: Offset(0, 2),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: WeekCalendar(
                                markedDates: todoDeadLine,
                                initialDate: selectedDate,
                                onDateSelected: _onDateSelected,
                              ),
                            ),
                          ),
                        ),
                      )
                    : SizedBox.shrink();
              },
            ),
          ],
        );
      },
    );
  }
}
