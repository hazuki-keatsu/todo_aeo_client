import 'package:flutter/material.dart';
import 'package:todo_aeo/functions/database_query.dart';
import 'package:todo_aeo/widgets/todo_tile.dart';
import 'package:todo_aeo/modules/todo.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  List<Todo>? todos;
  bool isLoading = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  // 加载动画
  Future<void> _loadTodos() async {
    try {
      final loadedTodos = await DatabaseQuery.instance.getAllTodos();
      setState(() {
        todos = List.generate(
          loadedTodos.length,
          (i) => Todo.fromMap(loadedTodos[i]),
        );
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
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

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          'Todo',
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
            updatedAt: todos![index].updatedAt,
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
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer),
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
                            ).colorScheme.onPrimaryContainer,
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
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
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
            // 在此处建立分类列表
          ],
        ),
      ),
    );
  }
}
