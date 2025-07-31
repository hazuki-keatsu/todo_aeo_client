import 'package:flutter/material.dart';
import 'package:todo_aeo/services/database_query.dart';

class ThemeProvider extends ChangeNotifier {
  // 预定义颜色
  static const List<Color> predefinedColors = [
    Color(0xFF6200EE), // 紫色
    Color(0xFF2196F3), // 蓝色
    Color(0xFF4CAF50), // 绿色
    Color(0xFFFF9800), // 橙色
    Color(0xFFF44336), // 红色
    Color(0xFF9C27B0), // 紫红色
    Color(0xFF00BCD4), // 青色
    Color(0xFFFFEB3B), // 黄色
    Color(0xFF795548), // 棕色
    Color(0xFF607D8B), // 蓝灰色
  ];

  static const List<String> colorNames = [
    '紫色',
    '蓝色', 
    '绿色',
    '橙色',
    '红色',
    '紫红色',
    '青色',
    '黄色',
    '棕色',
    '蓝灰色',
  ];

  Color _seedColor = predefinedColors[0];
  bool _useDynamicColor = false; // 默认不使用动态取色，因为可能需要额外权限
  bool _isDarkMode = false;
  bool _isInitialized = false;

  Color get seedColor => _seedColor;
  bool get useDynamicColor => _useDynamicColor;
  bool get isDarkMode => _isDarkMode;
  bool get isInitialized => _isInitialized;

  // 初始化，从数据库加载设置
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      final db = DatabaseQuery.instance;
      
      // 加载种子颜色
      final seedColorValue = await db.getSetting('theme_seed_color');
      if (seedColorValue != null) {
        _seedColor = Color(int.parse(seedColorValue));
      }
      
      // 加载动态取色设置
      final useDynamicColorValue = await db.getSetting('theme_use_dynamic_color');
      if (useDynamicColorValue != null) {
        _useDynamicColor = useDynamicColorValue == 'true';
      }
      
      // 加载深色模式设置
      final isDarkModeValue = await db.getSetting('theme_is_dark_mode');
      if (isDarkModeValue != null) {
        _isDarkMode = isDarkModeValue == 'true';
      }
      
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      print('Failed to load theme settings: $e');
      _isInitialized = true;
    }
  }

  // 设置种子颜色
  Future<void> setSeedColor(Color color) async {
    _seedColor = color;
    notifyListeners();
    
    try {
      final db = DatabaseQuery.instance;
      await db.setSetting('theme_seed_color', color.toString());
    } catch (e) {
      print('Failed to save seed color: $e');
    }
  }

  // 切换动态取色
  Future<void> setUseDynamicColor(bool value) async {
    _useDynamicColor = value;
    notifyListeners();
    
    try {
      final db = DatabaseQuery.instance;
      await db.setSetting('theme_use_dynamic_color', value.toString());
    } catch (e) {
      print('Failed to save dynamic color setting: $e');
    }
  }

  // 切换深色模式
  Future<void> setDarkMode(bool value) async {
    _isDarkMode = value;
    notifyListeners();
    
    try {
      final db = DatabaseQuery.instance;
      await db.setSetting('theme_is_dark_mode', value.toString());
    } catch (e) {
      print('Failed to save dark mode setting: $e');
    }
  }

  // 获取当前主题数据
  ThemeData getThemeData() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _seedColor,
        brightness: _isDarkMode ? Brightness.dark : Brightness.light,
      ),
    );
  }

  // 获取颜色名称
  String getColorName(Color color) {
    final index = predefinedColors.indexOf(color);
    return index >= 0 ? colorNames[index] : '自定义';
  }
}
