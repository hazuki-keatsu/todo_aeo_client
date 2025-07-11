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
  
  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  Future<void> _loadTodos() async {
    try {
      final loadedTodos = await DatabaseQuery.instance.getAllTodos();
      setState(() {
        todos = List.generate(loadedTodos.length, (i) => Todo.fromMap(loadedTodos[i]));
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    return ListView.builder(
      itemCount: todos?.length ?? 0,
      itemBuilder: (context, index) {
        return TodoTile(
          title: todos![index].title, 
          description: todos![index].description ?? "", 
          isCompleted: todos![index].isCompleted == true ? 1 : 0, 
          createdAt: todos![index].createdAt, 
          updatedAt: todos![index].updatedAt
        );
      },
    );
  }
}
