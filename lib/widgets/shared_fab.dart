import 'package:flutter/material.dart';
import 'package:todo_aeo/providers/todo_provider.dart';
import 'package:todo_aeo/utils/app_routes.dart';

class SharedFAB {
  // 移除单例模式，每次都创建新的实例，但确保它们在逻辑上是相同的
  static Widget build(BuildContext context, TodoProvider provider) {
    return FloatingActionButton(
      heroTag: "todo_add_fab_to_todo_save_fab", // 使用heroTag而不是Hero wrapper
      key: const ValueKey('shared_todo_add_fab'), // 使用固定的 key 来标识这是同一个逻辑组件
      onPressed: () {
        AppRoutes.pushTodoPage(context, provider);
      },
      tooltip: "添加一个Todo",
      child: const Icon(Icons.add),
    );
  }
}
