import 'package:todo_aeo/modules/todo.dart';

class TodosSort {
  // 完成情况分类
  static List<List<Todo>> todosCompletion(List<Todo> todos) {
    List<Todo> completed = [];
    List<Todo> unCompleted = [];

    for (var todo in todos) {
      if (todo.isCompleted == true) {
        completed.add(todo);
      } else if (todo.isCompleted == false) {
        unCompleted.add(todo);
      }
    }

    return [completed, unCompleted];
  }

  // 时间顺序排序
  static List<Todo> todosSortByFinishingTime(List<Todo> todos) {
    List<Todo> sortedTodos = List.from(todos); // 创建新的List避免原地修改
    sortedTodos.sort((Todo todo1, Todo todo2) {
      if (todo1.finishingAt != null && todo2.finishingAt != null) {
        if (todo1.finishingAt!.isAfter(todo2.finishingAt!)) {
          return 1;
        } else if (todo1.finishingAt!.isBefore(todo2.finishingAt!)) {
          return -1;
        }
        return 0;
      }
      if (todo1.finishingAt == null) return 1;
      if (todo2.finishingAt == null) return -1;
      return 0;
    });
    return sortedTodos;
  }
}
