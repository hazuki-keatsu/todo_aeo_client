import 'package:flutter/material.dart';
import 'package:todo_aeo/modules/sync_settings.dart';
import 'package:todo_aeo/services/database_query.dart';
import 'package:todo_aeo/services/weddav_sync.dart';

class SyncSettingsProvider extends ChangeNotifier {
  SyncSettings _settings = SyncSettings();
  bool _isLoading = false;
  String? _error;
  bool _isTestingConnection = false;

  // Getters
  SyncSettings get settings => _settings;

  bool get isLoading => _isLoading;

  String? get error => _error;

  bool get isTestingConnection => _isTestingConnection;

  // 从数据库加载设置
  Future<void> loadSettings() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final db = DatabaseQuery.instance;
      final settingsMap = <String, String?>{};

      // 加载所有同步相关的设置
      for (String key in [
        'sync_host',
        'sync_username',
        'sync_password',
        'sync_enabled',
      ]) {
        settingsMap[key] = await db.getSetting(key);
      }

      _settings = SyncSettings.fromMap(settingsMap);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = '加载同步设置失败: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // 保存设置到数据库
  Future<void> saveSettings(SyncSettings settings) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final db = DatabaseQuery.instance;
      final settingsMap = settings.toMap();

      // 保存所有设置到数据库
      for (String key in settingsMap.keys) {
        await db.setSetting(key, settingsMap[key]!);
      }

      _settings = settings;

      // 如果启用了同步且设置有效，初始化WebDAV客户端
      if (settings.isEnabled && settings.isValid) {
        WebdavSyncService.instance.init(
          host: settings.host!,
          user: settings.username!,
          password: settings.password!,
        );
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = '保存同步设置失败: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // 测试连接
  Future<bool> testConnection() async {
    if (!_settings.isValid) {
      _error = '请填写完整的连接信息';
      notifyListeners();
      return false;
    }

    try {
      _isTestingConnection = true;
      _error = null;
      notifyListeners();

      // 创建临时客户端进行测试
      WebdavSyncService.instance.init(
        host: _settings.host!,
        user: _settings.username!,
        password: _settings.password!,
      );

      // 尝试同步空数据来测试连接
      await WebdavSyncService.instance.sync(
        localTodos: [],
        localCategories: [],
      );

      _isTestingConnection = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = '连接测试失败: $e';
      _isTestingConnection = false;
      notifyListeners();
      return false;
    }
  }

  // 更新单个字段
  void updateHost(String host) {
    _settings = _settings.copyWith(host: host);
    notifyListeners();
  }

  void updateUsername(String username) {
    _settings = _settings.copyWith(username: username);
    notifyListeners();
  }

  void updatePassword(String password) {
    _settings = _settings.copyWith(password: password);
    notifyListeners();
  }

  void updateEnabled(bool enabled) {
    _settings = _settings.copyWith(isEnabled: enabled);
    notifyListeners();
  }

  // 清除错误
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // 刷新设置
  Future<void> refresh() async {
    await loadSettings();
  }
}
