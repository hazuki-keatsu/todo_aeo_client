import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_aeo/services/sync/data_diff_service.dart';
import 'package:todo_aeo/modules/sync_metadata.dart';

/// 本地元数据管理服务
/// 负责持久化存储同步相关的元数据
class LocalMetadataService {
  static const String _keyPrefix = 'sync_metadata_';
  static const String _lastSyncPrefix = 'last_sync_';

  /// 保存数据的元数据
  static Future<void> saveDataMetadata(
    String fileName,
    SyncMetadata metadata,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_keyPrefix$fileName';
    await prefs.setString(key, jsonEncode(metadata.toMap()));
  }

  /// 获取数据的元数据
  static Future<SyncMetadata?> getDataMetadata(String fileName) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_keyPrefix$fileName';
    final jsonString = prefs.getString(key);

    if (jsonString == null) return null;

    try {
      final map = jsonDecode(jsonString) as Map<String, dynamic>;
      return SyncMetadata.fromMap(map);
    } catch (e) {
      return null;
    }
  }

  /// 保存最后成功同步的时间
  static Future<void> saveLastSyncTime(
    String fileName,
    DateTime syncTime,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_lastSyncPrefix$fileName';
    await prefs.setInt(key, syncTime.millisecondsSinceEpoch);
  }

  /// 获取最后成功同步的时间
  static Future<DateTime?> getLastSyncTime(String fileName) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_lastSyncPrefix$fileName';
    final timestamp = prefs.getInt(key);

    if (timestamp == null) return null;

    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  /// 检查本地数据是否有变化
  static Future<bool> hasLocalDataChanged<T>(
    String fileName,
    List<T> currentData,
  ) async {
    final storedMetadata = await getDataMetadata(fileName);
    if (storedMetadata == null) return true;

    final currentHash = DataDiffService.calculateDataHash(currentData);
    return currentHash != storedMetadata.hash;
  }

  /// 生成数据的元数据
  static SyncMetadata generateMetadata<T>(List<T> data, {int? version}) {
    final hash = DataDiffService.calculateDataHash(data);
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    return SyncMetadata(
      hash: hash,
      timestamp: timestamp,
      version: version ?? 1,
      itemCount: data.length,
    );
  }

  /// 清除指定文件的元数据
  static Future<void> clearMetadata(String fileName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_keyPrefix$fileName');
    await prefs.remove('$_lastSyncPrefix$fileName');
  }

  /// 清除所有同步元数据
  static Future<void> clearAllMetadata() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();

    for (var key in keys) {
      if (key.startsWith(_keyPrefix) || key.startsWith(_lastSyncPrefix)) {
        await prefs.remove(key);
      }
    }
  }
}
