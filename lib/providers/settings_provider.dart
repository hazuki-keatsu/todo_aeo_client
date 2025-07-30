import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsProvider extends ChangeNotifier {
  PackageInfo? _packageInfo;
  bool _isLoading = true;
  String? _error;

  // Getters
  PackageInfo? get packageInfo => _packageInfo;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // 便捷的getter方法
  String get appName => _packageInfo?.appName ?? '未知应用';
  String get packageName => _packageInfo?.packageName ?? '未知包名';
  String get version => _packageInfo?.version ?? '未知版本';
  String get buildNumber => _packageInfo?.buildNumber ?? '未知构建号';
  String get fullVersion => _packageInfo != null 
      ? '${_packageInfo!.version}+${_packageInfo!.buildNumber}'
      : '未知版本';

  SettingsProvider() {
    _loadPackageInfo();
  }

  // 加载包信息
  Future<void> _loadPackageInfo() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final packageInfo = await PackageInfo.fromPlatform();
      
      _packageInfo = packageInfo;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = '加载应用信息失败: $e';
      _isLoading = false;
      notifyListeners();
      print('Failed to load package info: $e');
    }
  }

  // 手动刷新包信息
  Future<void> refresh() async {
    await _loadPackageInfo();
  }

  // 获取格式化的版本信息用于显示
  String getFormattedVersion({bool showBuildNumber = true}) {
    if (_packageInfo == null) return '加载中...';
    
    if (showBuildNumber) {
      return 'v${_packageInfo!.version}+${_packageInfo!.buildNumber}';
    } else {
      return 'v${_packageInfo!.version}';
    }
  }

  // 获取应用的基本信息Map，方便在UI中遍历显示
  Map<String, String> getAppInfoMap() {
    if (_packageInfo == null) {
      return {
        '版本': '加载中...',
        '包名': '加载中...',
      };
    }

    return {
      '版本': _packageInfo!.version,
      '包名': _packageInfo!.packageName,
    };
  }

  // 检查是否有可用的包信息
  bool get hasPackageInfo => _packageInfo != null;
}