import 'package:flutter/material.dart';
import 'package:todo_aeo/functions/database_query.dart';
import 'package:todo_aeo/widgets/todo_tile.dart';
import 'package:todo_aeo/modules/todo.dart';
import 'package:todo_aeo/modules/category.dart';

// TODO: 每次修改ToDo的完成情况时对List进行重建，重新进行排序，使用Hero动画
// TODO: 添加ToDo删除时的动画

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  List<Todo>? todos;
  List<Category>? categories;
  bool isLoading = true;
  int? selectedCategoryId; // null表示显示所有todos
  String selectedCategoryName = "全部";
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // 加载所有数据
  Future<void> _loadData() async {
    try {
      await Future.wait([_loadTodos(), _loadCategories()]);
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  // 加载todos
  Future<void> _loadTodos() async {
    List<Map<String, dynamic>> loadedTodos;

    if (selectedCategoryId == null) {
      loadedTodos = await DatabaseQuery.instance.getAllTodos();
    } else if (selectedCategoryId == -1) {
      // -1 表示未分类
      loadedTodos = await DatabaseQuery.instance.getUncategorizedTodos();
    } else {
      loadedTodos = await DatabaseQuery.instance.getTodosByCategory(
        selectedCategoryId!,
      );
    }

    setState(() {
      todos = List.generate(
        loadedTodos.length,
        (i) => Todo.fromMap(loadedTodos[i]),
      );
    });
  }

  // 加载分类
  Future<void> _loadCategories() async {
    final loadedCategories = await DatabaseQuery.instance.getAllCategories();
    setState(() {
      categories = List.generate(
        loadedCategories.length,
        (i) => Category.fromMap(loadedCategories[i]),
      );
    });
  }

  // 选择分类
  void _selectCategory(int? categoryId, String categoryName) {
    setState(() {
      selectedCategoryId = categoryId;
      selectedCategoryName = categoryName;
    });
    _loadTodos();
    Navigator.pop(context); // 关闭侧边栏
  }

  // 完成数据的本地同步
  void _updateCompleted(bool value, int? id) {
    try {
      if (id == null) {
        throw "empty id error";
      }
      final todoDatabaseInstance = DatabaseQuery.instance;

      setState(() {
        todoDatabaseInstance.updateTodo({
          'id': id,
          'isCompleted': value == true ? 1 : 0,
        });
      });
    } catch (e) {
      print(e);
    }
  }

  // 颜色解析
  Color _parseColor(String? colorString) {
    if (colorString == null || colorString.isEmpty) {
      return Theme.of(context).colorScheme.primary;
    }

    // 检查是否是有效的十六进制颜色格式
    if (colorString.startsWith('#') && colorString.length == 7) {
      try {
        return Color(
          int.parse(colorString.substring(1), radix: 16) + 0xFF000000,
        );
      } catch (e) {
        return Theme.of(context).colorScheme.primary;
      }
    }

    // 如果不是十六进制格式，返回默认颜色
    return Theme.of(context).colorScheme.primary;
  }

  Future<void> _showAddTodoDialog(BuildContext context) async {
    String todoName = '';
    String todoDescription = '';
    int? selectedCategoryId;
    DateTime? selectedFinishingDate;

    // 保存主页面的context
    final scaffoldContext = context;

    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('添加新的待办事项'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 待办事项名称
                    TextField(
                      decoration: InputDecoration(
                        labelText: '待办事项名称',
                        border: OutlineInputBorder(),
                        hintText: '请输入待办事项名称',
                      ),
                      onChanged: (value) {
                        todoName = value;
                      },
                    ),
                    SizedBox(height: 16),
                    // 待办事项描述
                    TextField(
                      decoration: InputDecoration(
                        labelText: '待办事项描述(可选)',
                        border: OutlineInputBorder(),
                        hintText: '请输入待办事项描述',
                        alignLabelWithHint: true
                      ),
                      maxLines: 3,
                      onChanged: (value) {
                        todoDescription = value;
                      },
                    ),
                    SizedBox(height: 16),
                    // 分类选择
                    Text('选择分类', style: Theme.of(context).textTheme.titleSmall),
                    SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Theme.of(context).hintColor),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: DropdownButton<int?>(
                        value: selectedCategoryId,
                        hint: Text('  选择分类（可选）'),
                        isExpanded: true,
                        underline: SizedBox(),
                        items: [
                          DropdownMenuItem<int?>(
                            value: null,
                            child: Text('  无分类'),
                          ),
                          if (categories != null)
                            ...categories!.map((category) {
                              return DropdownMenuItem<int?>(
                                value: category.id,
                                child: Row(
                                  children: [
                                    SizedBox(width: 8),
                                    Container(
                                      width: 16,
                                      height: 16,
                                      decoration: BoxDecoration(
                                        color: _parseColor(category.color),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Text(category.name),
                                  ],
                                ),
                              );
                            }),
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedCategoryId = value;
                          });
                        },
                      ),
                    ),
                    SizedBox(height: 16),
                    // 完成日期选择
                    Text('完成日期', style: Theme.of(context).textTheme.titleSmall),
                    SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        final date = await showDatePicker(
                          helpText: "选择日期",
                          cancelText: "取消",
                          confirmText: "确定",
                          fieldLabelText: "请输入日期",
                          fieldHintText: "mm/dd/yyyy",
                          context: context,
                          initialDate: selectedFinishingDate ?? DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(Duration(days: 365 * 2)),
                        );
                        if (date != null) {
                          setState(() {
                            selectedFinishingDate = date;
                          });
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Theme.of(context).hintColor),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today, size: 20),
                            SizedBox(width: 8),
                            Text(
                              selectedFinishingDate != null
                                  ? '${selectedFinishingDate!.year}-${selectedFinishingDate!.month.toString().padLeft(2, '0')}-${selectedFinishingDate!.day.toString().padLeft(2, '0')}'
                                  : '选择完成日期（可选）',
                              style: TextStyle(
                                color: selectedFinishingDate != null
                                    ? Theme.of(
                                        context,
                                      ).textTheme.bodyMedium?.color
                                    : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('取消'),
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                ),
                TextButton(
                  child: Text('确定'),
                  onPressed: () async {
                    if (todoName.trim().isEmpty) {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        SnackBar(
                          content: Text('请输入待办事项名称'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      return;
                    }

                    try {
                      // 准备插入数据
                      final todoData = {
                        'title': todoName.trim(),
                        'description': todoDescription.trim().isEmpty
                            ? null
                            : todoDescription.trim(),
                        'isCompleted': 0,
                        'categoryId': selectedCategoryId,
                        'createdAt': DateTime.now().toIso8601String(),
                        'finishingAt': selectedFinishingDate?.toIso8601String(),
                      };

                      // 添加到数据库
                      await DatabaseQuery.instance.insertTodo(todoData);

                      // 重新加载todos
                      await _loadTodos();

                      if (dialogContext.mounted) {
                        Navigator.pop(dialogContext);
                      }

                      // 显示成功消息
                      if (scaffoldContext.mounted) {
                        ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                          SnackBar(
                            content: Text('待办事项添加成功'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    } catch (e) {
                      if (dialogContext.mounted) {
                        Navigator.pop(dialogContext);
                      }
                      if (scaffoldContext.mounted) {
                        ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                          SnackBar(
                            content: Text('添加待办事项失败: $e'),
                            behavior: SnackBarBehavior.floating,
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
  }

  Future<void> _showAddCategoryDialog(BuildContext context) async {
    String categoryName = '';
    String selectedColor = '#3B82F6'; // 默认蓝色

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

    final dialogContext = context;

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('添加新的分类'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 分类名称输入框
                  TextField(
                    decoration: InputDecoration(
                      labelText: '分类名称',
                      border: OutlineInputBorder(),
                      hintText: '请输入分类名称',
                    ),
                    onChanged: (value) {
                      categoryName = value;
                    },
                  ),
                  SizedBox(height: 16),
                  // 颜色选择
                  Text('选择颜色', style: Theme.of(context).textTheme.titleSmall),
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
                            color: _parseColor(color),
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
                  child: Text('取消'),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                TextButton(
                  child: Text('确定'),
                  onPressed: () async {
                    if (categoryName.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('请输入分类名称'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      return;
                    }

                    try {
                      // 添加分类到数据库
                      await DatabaseQuery.instance.insertCategory({
                        'name': categoryName.trim(),
                        'color': selectedColor,
                        'createdAt': DateTime.now().toIso8601String(),
                      });

                      // 重新加载分类数据
                      await _loadCategories();

                      if (dialogContext.mounted) {
                        Navigator.pop(dialogContext);
                        ScaffoldMessenger.of(dialogContext).showSnackBar(
                          SnackBar(
                            content: Text('分类添加成功'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    } catch (e) {
                      if (dialogContext.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('添加分类失败: $e'),
                            behavior: SnackBarBehavior.floating,
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
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          selectedCategoryName,
          style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
        ),
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
          _showAddTodoDialog(context);
        },
        tooltip: "添加一个Todo",
        child: Icon(Icons.add),
      ),
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: ListView.builder(
        itemCount: todos?.length ?? 0,
        itemBuilder: (context, index) {
          return TodoTile(
            id: todos![index].id,
            title: todos![index].title,
            description: todos![index].description ?? "",
            isCompleted: todos![index].isCompleted == true ? 1 : 0,
            createdAt: todos![index].createdAt,
            finishingAt: todos![index].finishingAt,
            updateCompetedFunction: _updateCompleted,
          );
        },
      ),
      endDrawer: Drawer(
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
                    if (categories != null && categories!.isNotEmpty) ...[
                      Divider(),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Text(
                          "分类",
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                      ),
                      ...categories!.map((category) {
                        final isSelected = selectedCategoryId == category.id;
                        return ListTile(
                          leading: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: category.color != null
                                  ? _parseColor(category.color)
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
                        _showAddCategoryDialog(context);
                      },
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
}
