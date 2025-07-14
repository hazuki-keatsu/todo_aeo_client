import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Expanded(
                  child: MonthCalendar(
                    onDateSelected: (date) {
                      print('选中日期: ${date.toString()}');
                    },
                    markedDates: [
                      DateTime.now().add(const Duration(days: 2)),
                      DateTime.now().add(const Duration(days: 6)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
