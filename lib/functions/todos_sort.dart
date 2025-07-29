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

  // 优先级排序
  static List<Todo> todosSortByPriority(List<Todo> todos) {
    List<Todo> sortedTodos = List.from(todos); // 创建新的List避免原地修改
    sortedTodos.sort((Todo todo1, Todo todo2) {
      // 按优先级排序（数值越大优先级越高）
      int priorityComparison = todo2.priority.compareTo(todo1.priority);
      if (priorityComparison != 0) {
        return priorityComparison;
      }
      // 如果优先级相同，按创建时间排序（最新的在前）
      return todo2.createdAt.compareTo(todo1.createdAt);
    });
    return sortedTodos;
  }

  // 时间顺序排序 - 保持向后兼容
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
