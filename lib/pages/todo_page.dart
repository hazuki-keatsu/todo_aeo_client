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
                    autofocus: true,
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

                      Navigator.pop(context);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('分类添加成功'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('添加分类失败: $e'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
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
        onPressed: () {},
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
