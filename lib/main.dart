import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:material_color_utilities/material_color_utilities.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:todo_aeo/pages/todo_page.dart';
import 'package:todo_aeo/tests/database_initializer.dart';
import 'package:todo_aeo/pages/calendar_page.dart';
import 'package:todo_aeo/pages/settings_page.dart';
import 'package:todo_aeo/providers/todo_provider.dart';
import 'package:todo_aeo/providers/scaffold_elements_notifier.dart';
import 'package:todo_aeo/providers/theme_provider.dart';
import 'package:todo_aeo/providers/settings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final CorePalette? palette = await DynamicColorPlugin.getCorePalette();

  // await DatabaseInitializer.initializeWithSampleData();

  runApp(ToDo(palette: palette));
}

class ToDo extends StatelessWidget {
  const ToDo({super.key, this.palette});

  final CorePalette? palette;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => TodoProvider()),
        ChangeNotifierProvider(create: (context) => ScaffoldElementsNotifier()),
        ChangeNotifierProvider(create: (context) => SettingsProvider()),
        ChangeNotifierProvider(
          create: (context) {
            final themeProvider = ThemeProvider();
            themeProvider.initialize(); // 初始化主题设置
            return themeProvider;
          },
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          // 如果主题提供者还没有初始化完成，显示加载界面
          if (!themeProvider.isInitialized) {
            return MaterialApp(
              home: Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
              debugShowCheckedModeBanner: false,
            );
          }
          
          return ResponsiveSizer(
            builder: (context, orientation, screenType) {
              return MaterialApp(
                home: ToDoHomeFrame(title: "ToDo Aeo"),
                title: "ToDo",
                theme: themeProvider.useDynamicColor && palette != null
                    ? ThemeData(
                        useMaterial3: true,
                        colorScheme: ColorScheme.fromSeed(
                          seedColor: Color(palette!.primary.get(40)),
                          brightness: themeProvider.isDarkMode 
                            ? Brightness.dark 
                            : Brightness.light,
                        ),
                      )
                    : themeProvider.getThemeData(),
                debugShowCheckedModeBanner: false,
              );
            },
          );
        },
      ),
    );
  }
}

class ToDoHomeFrame extends StatefulWidget {
  final String title;

  const ToDoHomeFrame({super.key, required this.title});

  @override
  State<StatefulWidget> createState() => _ToDoHomeFrameState();
}

class _ToDoHomeFrameState extends State<ToDoHomeFrame> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [TodoPage(), CalendarPage(), SettingsPage()];

  @override
  void initState() {
    super.initState();
    // 延迟初始化Provider数据，避免阻塞UI
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TodoProvider>().init();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ScaffoldElementsNotifier>(
      builder: (context, scaffoldElements, child) {
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          appBar: scaffoldElements.appBar,
          floatingActionButton: scaffoldElements.floatingActionButton,
          floatingActionButtonLocation:
              scaffoldElements.floatingActionButtonLocation,
          floatingActionButtonAnimator:
              scaffoldElements.floatingActionButtonAnimator,
          drawer: scaffoldElements.drawer,
          endDrawer: scaffoldElements.endDrawer,
          body: _pages[_selectedIndex],
          bottomNavigationBar: NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            indicatorShape: RoundedRectangleBorder(
              borderRadius: BorderRadiusGeometry.circular(12),
            ),
            destinations: const <Widget>[
              NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
              NavigationDestination(
                icon: Icon(Icons.calendar_month),
                label: 'Calendar',
              ),
              NavigationDestination(
                icon: Icon(Icons.settings),
                label: 'Settings',
              ),
            ],
          ),
        );
      },
    );
  }
}
