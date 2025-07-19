import 'package:flutter/material.dart';
import 'package:todo_aeo/functions/show_dialog.dart';
import 'package:todo_aeo/providers/todo_provider.dart';

class SharedFAB {
  // 移除单例模式，每次都创建新的实例，但确保它们在逻辑上是相同的
  static Widget build(BuildContext context, TodoProvider provider) {
    return FloatingActionButton(
      key: const ValueKey('shared_todo_fab'), // 使用固定的 key 来标识这是同一个逻辑组件
      onPressed: () {
        ShowDialog.showTodoDialog(context, provider);
      },
      tooltip: "添加一个Todo",
      child: const Icon(Icons.add),
    );
  }
}
