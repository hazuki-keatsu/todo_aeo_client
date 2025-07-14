import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_aeo/functions/show_dialog.dart';
import 'package:todo_aeo/providers/todo_provider.dart';
import 'package:todo_aeo/widgets/month_calendar.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Consumer<TodoProvider>(
      builder: (context, todoProvider, child) {
        if (todoProvider.isLoading) {
          return Scaffold(
            appBar: AppBar(
              title: Text('日历'),
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text('日历'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
          ),
          body: Container(
            alignment: Alignment(0, -1),
            padding: EdgeInsets.all(8),
            child: MonthCalendar(),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              ShowDialog.showAddTodoDialog(context, todoProvider);
            },
            tooltip: "添加一个Todo",
            child: Icon(Icons.add),
          ),
          floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        );
      },
    );
  }
}
