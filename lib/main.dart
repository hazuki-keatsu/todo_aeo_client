import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:material_color_utilities/material_color_utilities.dart';
import 'package:provider/provider.dart';
import 'package:todo_aeo/pages/home_page.dart';
import 'package:todo_aeo/pages/calendar_page.dart';
import 'package:todo_aeo/pages/settings_page.dart';
import 'package:todo_aeo/providers/sync_settings_provider.dart';
import 'package:todo_aeo/providers/todo_provider.dart';
import 'package:todo_aeo/providers/scaffold_elements_notifier.dart';
import 'package:todo_aeo/providers/theme_provider.dart';
import 'package:todo_aeo/providers/settings_provider.dart';
import 'package:todo_aeo/providers/language_provider.dart';
import 'package:todo_aeo/services/sync/weddav_sync.dart';
import 'package:todo_aeo/utils/app_routes.dart';
import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;

// 国际化
import 'package:todo_aeo/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// 测试
// import 'package:todo_aeo/tests/database_initializer.dart';

// TODO: 自定义背景和自定义提示音
// TODO: 添加主页面切换动画
// TODO: 修复AppBar动画问题

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
        ChangeNotifierProvider(create: (context) => SyncSettingsProvider()),
        ChangeNotifierProvider(
          create: (context) {
            final themeProvider = ThemeProvider();
            themeProvider.initialize(); // 初始化主题设置
            return themeProvider;
          },
        ),
        ChangeNotifierProvider(
          create: (context) {
            final languageProvider = LanguageProvider();
            languageProvider.initialize(); // 初始化语言设置
            return languageProvider;
          },
        ),
      ],
      child: Consumer3<ThemeProvider, SyncSettingsProvider, LanguageProvider>(
        builder: (context, themeProvider, syncSettingsProvider, languageProvider, child) {
          // 如果主题或语言还没有初始化完成，显示加载界面
          if (!themeProvider.isInitialized || !languageProvider.isInitialized) {
            return MaterialApp(
              home: Scaffold(body: Center(child: CircularProgressIndicator())),
              debugShowCheckedModeBanner: false,
            );
          }

          return MaterialApp(
            home: ToDoHomeFrame(title: "ToDo Aeo"),
            title: "ToDo Aeo",
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            onGenerateRoute: AppRoutes.generateRoute,
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
            supportedLocales: LanguageProvider.supportedLocales,
            locale: languageProvider.currentLocale,
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

  final List<Widget> _pages = [HomePage(), CalendarPage(), SettingsPage()];

  @override
  void initState() {
    super.initState();
    // 延迟初始化Provider数据，避免阻塞UI
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TodoProvider>().init();
      _initializeWebdav(); // 初始化WebDAV
    });
  }

  /// 检查并初始化WebDAV服务
  Future<void> _initializeWebdav() async {
    // 使用 context.read 获取 Provider，因为我们不需要监听变化
    final syncSettings = context.read<SyncSettingsProvider>();

    await syncSettings.loadSettings();

    // 检查WebDAV同步是否已启用
    if (syncSettings.settings.isEnabled && !syncSettings.isLoading) {
      try {
        // 从Provider获取凭据并初始化WebDAV服务
        WebdavSyncService.instance.init(
          host: syncSettings.settings.host!,
          user: syncSettings.settings.username!,
          password: syncSettings.settings.password!,
        );
        if (kDebugMode) {
          debugPrint(syncSettings.settings.host ?? 'host为空');
          debugPrint(syncSettings.settings.username ?? 'username为空');
          debugPrint(syncSettings.settings.password ?? 'password为空');
        }

        if (kDebugMode) {
          debugPrint("WebDAV 服务启动成功");
        }
      } catch (e) {
        // 如果初始化失败，显示错误提示
        if (mounted) {
          // 检查widget是否仍在树中
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('WebDAV 初始化失败: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

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
            destinations: <Widget>[
              NavigationDestination(icon: Icon(Icons.home), label: l10n.homePage),
              NavigationDestination(
                icon: Icon(Icons.calendar_month),
                label: l10n.calendarPage,
              ),
              NavigationDestination(icon: Icon(Icons.settings), label: l10n.settingsPage),
            ],
          ),
        );
      },
    );
  }
}
