import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;
import 'package:todo_aeo/l10n/app_localizations.dart';

class SettingsProvider extends ChangeNotifier {
  PackageInfo? _packageInfo;
  bool _isLoading = true;
  String? _error;

  // Getters
  PackageInfo? get packageInfo => _packageInfo;
  bool get isLoading => _isLoading;
  String? get error => _error;

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
      if (kDebugMode) {
        debugPrint('Failed to load package info: $e');
      }

    }
  }

  // 手动刷新包信息
  Future<void> refresh() async {
    await _loadPackageInfo();
  }

  // 获取格式化的版本信息用于显示
  String getFormattedVersion({bool showBuildNumber = true, required AppLocalizations l10nPrama}) {
    final l10n = l10nPrama;
    if (_packageInfo == null) return l10n.loading;
    
    if (showBuildNumber) {
      return 'v${_packageInfo!.version}+${_packageInfo!.buildNumber}';
    } else {
      return 'v${_packageInfo!.version}';
    }
  }

  // 获取应用的基本信息Map，方便在UI中遍历显示
  Map<String, String> getAppInfoMap({required AppLocalizations l10nPrama}) {
    final l10n = l10nPrama;
    if (_packageInfo == null) {
      return {
        l10n.version: l10n.loading,
        l10n.packageName: l10n.loading,
      };
    }

    return {
      l10n.version: _packageInfo!.version,
      l10n.packageName: _packageInfo!.packageName,
    };
  }

  // 检查是否有可用的包信息
  bool get hasPackageInfo => _packageInfo != null;
}