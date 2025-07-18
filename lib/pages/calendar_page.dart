import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_aeo/providers/todo_provider.dart';
import 'package:todo_aeo/providers/scaffold_elements_notifier.dart';
import 'package:todo_aeo/widgets/month_calendar.dart';

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
    final scaffoldElements = Provider.of<ScaffoldElementsNotifier>(context, listen: false);
    
    scaffoldElements.updateElements(
      appBar: AppBar(
        title: Text('日历'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TodoProvider>(
      builder: (context, todoProvider, child) {
        // 当数据变化时更新 Scaffold 元素
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _updateScaffoldElements();
        });

        if (todoProvider.isLoading) {
          return Center(child: CircularProgressIndicator());
        }

        return Container(
          alignment: Alignment(0, -1),
          padding: EdgeInsets.all(8),
          child: MonthCalendar(),
        );
      },
    );
  }
}
