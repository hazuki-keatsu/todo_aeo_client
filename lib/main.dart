import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:material_color_utilities/material_color_utilities.dart';
import 'package:todo_aeo/pages/todo_page.dart';
import 'package:todo_aeo/tests/database_initializer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final CorePalette? palette = await DynamicColorPlugin.getCorePalette();

  await DatabaseInitializer.initializeWithSampleData();

  runApp(ToDo(palette: palette,));
}

class ToDo extends StatelessWidget {
  const ToDo({super.key, this.palette});

  final CorePalette? palette;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ToDoHomeFrame(title: "ToDo"),
      title: "ToDo",
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: palette != null 
          ? ColorScheme.fromSeed(seedColor: Color(palette!.primary.get(40)))
          : null,
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ToDoHomeFrame extends StatefulWidget {
  final String title;

  const ToDoHomeFrame({super.key,required this.title});

  @override
  State<StatefulWidget> createState() => _ToDoHomeFrameState();
}

class _ToDoHomeFrameState extends State<ToDoHomeFrame> {
  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(widget.title, style: TextStyle(color: colorScheme.onPrimary)),
        actions: [IconButton(onPressed: () {}, icon: Icon(Icons.menu, color: colorScheme.onPrimary,))],
        backgroundColor: colorScheme.primary,
      ),
      body: TodoPage(),
    );
  }
}
