import 'package:flutter/material.dart';
import 'package:todo_aeo/functions/database_query.dart';

class TodoProvider extends ChangeNotifier {
  final DatabaseQuery dq = DatabaseQuery.instance;
  late List<Map<String, dynamic>> todos;
  late List<Map<String, dynamic>> categories;

  Future<void> init() async {
    todos = await dq.getAllTodos();
    categories = await dq.getAllCategories();
  }
} 