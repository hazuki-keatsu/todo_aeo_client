import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _currentLocale = const Locale('zh', 'CN'); // 默认中文
  bool _isInitialized = false;
  String _savedLanguageCode = 'system'; // 保存的语言设置

  Locale get currentLocale => _currentLocale;
  bool get isInitialized => _isInitialized;

  // 支持的语言列表
  static const List<Locale> supportedLocales = [
    Locale('zh', 'CN'), // 中文
    Locale('en', 'US'), // 英文
  ];

  // 语言代码到显示名称的映射
  static const Map<String, String> languageNames = {
    'zh_CN': '中文',
    'en_US': 'English',
    'system': '跟随系统',
  };

  /// 初始化语言设置
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _savedLanguageCode = prefs.getString('language_code') ?? 'system';

    if (_savedLanguageCode == 'system') {
      // 使用系统语言
      _currentLocale = _getSystemLocale();
    } else {
      // 解析保存的语言代码
      final parts = _savedLanguageCode.split('_');
      if (parts.length == 2) {
        _currentLocale = Locale(parts[0], parts[1]);
      } else {
        _currentLocale = _getSystemLocale();
      }
    }

    _isInitialized = true;
    notifyListeners();
  }

  /// 获取系统语言
  Locale _getSystemLocale() {
    final systemLocale = WidgetsBinding.instance.platformDispatcher.locale;

    // 检查系统语言是否在支持列表中
    for (final supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == systemLocale.languageCode) {
        return supportedLocale;
      }
    }

    // 如果系统语言不支持，返回默认语言（中文）
    return const Locale('zh', 'CN');
  }

  /// 切换语言
  Future<void> changeLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();

    _savedLanguageCode = languageCode;
    await prefs.setString('language_code', languageCode);

    if (languageCode == 'system') {
      _currentLocale = _getSystemLocale();
    } else {
      final parts = languageCode.split('_');
      if (parts.length == 2) {
        _currentLocale = Locale(parts[0], parts[1]);
      }
    }

    notifyListeners();
  }

  /// 获取当前语言的代码（用于UI显示选中状态）
  String get currentLanguageCode {
    if (_savedLanguageCode == 'system') {
      return 'system';
    }
    return '${_currentLocale.languageCode}_${_currentLocale.countryCode}';
  }

  /// 获取当前语言的显示名称
  String get currentLanguageName {
    if (_savedLanguageCode == 'system') {
      return languageNames['system']!;
    }
    return languageNames[currentLanguageCode] ?? '中文';
  }
}