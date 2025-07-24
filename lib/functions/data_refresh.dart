import 'package:flutter/material.dart';
import 'package:todo_aeo/providers/todo_provider.dart';

// TODO: 后续加入远程同步模块

Future<void> dataRefresh(TodoProvider provider, BuildContext context) async {
  try {
    await provider.refresh();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('数据刷新成功'), duration: Duration(seconds: 2)),
    );
  } catch (e) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('刷新失败: $e'), duration: Duration(seconds: 2)));
  }
}
