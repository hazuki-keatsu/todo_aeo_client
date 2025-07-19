import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_aeo/providers/todo_provider.dart';
import 'package:todo_aeo/providers/scaffold_elements_notifier.dart';
import 'package:todo_aeo/widgets/month_calendar.dart';
import 'package:todo_aeo/widgets/shared_fab.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateScaffoldElements();
    });
  }

  void _updateScaffoldElements() {
    final provider = Provider.of<TodoProvider>(context, listen: false);
    final scaffoldElements = Provider.of<ScaffoldElementsNotifier>(
      context,
      listen: false,
    );

    // 分别更新不同的元素
    scaffoldElements.updateAppBar(AppBar(
      title: Text('日历'),
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Theme.of(context).colorScheme.onPrimary,
    ));
    
    // 使用共享的 FAB，只更新 FAB 而不触发全局重构
    scaffoldElements.updateFloatingActionButton(SharedFAB.build(context, provider));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TodoProvider>(
      builder: (context, todoProvider, child) {
        // 当数据变化时更新 Scaffold 元素
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _updateScaffoldElements();
        });
        // TODO: 这是一段有问题的代码
        List<DateTime> todoDeadLine = [];

        if (todoProvider.todos != null) {
          for (var i in todoProvider.todos!) {
            todoDeadLine.add(i.finishingAt!);
          }
        }

        if (todoProvider.isLoading) {
          return Center(child: CircularProgressIndicator());
        }

        return Container(
          alignment: Alignment(0, -1),
          padding: EdgeInsets.all(16),
          child: MonthCalendar(markedDates: todoDeadLine),
        );
      },
    );
  }
}
