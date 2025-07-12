import 'package:flutter/material.dart';
import 'package:todo_aeo/functions/database_query.dart';
import 'package:todo_aeo/widgets/todo_tile.dart';
import 'package:todo_aeo/modules/todo.dart';
import 'package:todo_aeo/modules/category.dart';

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
                      selectedTileColor: Theme.of(context).colorScheme.surfaceContainer,
                    ),
                    // 未分类todos
                    ListTile(
                      leading: Icon(Icons.label_off),
                      title: Text("未分类"),
                      selected: selectedCategoryId == -1,
                      onTap: () => _selectCategory(-1, "未分类"),
                      selectedColor: Theme.of(context).colorScheme.primary,
                      selectedTileColor: Theme.of(context).colorScheme.surfaceContainer,
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
                          selectedTileColor: Theme.of(context).colorScheme.surfaceContainer,
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
                        // TODO: 添加分类功能
                        Navigator.pop(context);
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
