import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:webdav_client/webdav_client.dart';
import 'package:todo_aeo/modules/todo.dart';
import 'package:todo_aeo/modules/category.dart';

class WebdavSyncService {
  // 单例模式
  WebdavSyncService._privateConstructor();

  static final WebdavSyncService instance =
      WebdavSyncService._privateConstructor();

  late Client _client;
  bool _isInitialized = false;

  /// 初始话WebDAV Client
  /// 在任意其他的方法之前执行
  void init({
    required String host,
    required String user,
    required String password,
  }) {
    _client = newClient(host, user: user, password: password);
    _client.setHeaders({'content-type': 'application/json'});
    _isInitialized = true;
  }

  void _checkInitialized() {
    if (!_isInitialized) {
      throw Exception("WebdavSyncService not initialized. Call init() first.");
    }
  }

  /// 使用WebDAV服务器同步本地数据
  /// 上传本地列表和下载远程列表
  Future<Map<String, dynamic>> sync({
    required List<Todo> localTodos,
    required List<Category> localCategories,
  }) async {
    _checkInitialized();

    // 处理todos数据同步
    final todosResult = await _syncDataWithMerge(
      'todos.json',
      localTodos.map((e) => e.toMap()).toList(),
      (map) => Todo.fromMap(map),
    );

    // 处理categories数据同步
    final categoriesResult = await _syncDataWithMerge(
      'categories.json',
      localCategories.map((e) => e.toMap()).toList(),
      (map) => Category.fromMap(map),
    );

    return {
      'todos': todosResult.cast<Todo>(),
      'categories': categoriesResult.cast<Category>(),
    };
  }

  /// 通过时间戳和哈希值比较来同步数据
  Future<List<T>> _syncDataWithMerge<T>(
    String fileName,
    List<Map<String, dynamic>> localData,
    T Function(Map<String, dynamic>) fromMap,
  ) async {
    try {
      // 获取本地数据的元信息
      final localMetadata = await _getDataMetadata(localData);

      // 尝试获取远程元信息
      final remoteMetadata = await _getRemoteMetadata(fileName);

      if (remoteMetadata == null) {
        // 远程没有文件，直接上传本地数据
        await _uploadDataWithMetadata(fileName, localData, localMetadata);
        return localData.map((map) => fromMap(map)).toList();
      }

      // 比较时间戳
      if (localMetadata['timestamp'] > remoteMetadata['timestamp']) {
        // 本地数据更新，上传到云端
        await _uploadDataWithMetadata(fileName, localData, localMetadata);
        return localData.map((map) => fromMap(map)).toList();
      } else if (localMetadata['timestamp'] < remoteMetadata['timestamp']) {
        // 远程数据更新，下载到本地
        final remoteData = await _downloadData<T>(fileName, fromMap);
        return remoteData;
      } else {
        // 时间戳相同，比较哈希值
        if (localMetadata['hash'] != remoteMetadata['hash']) {
          // 哈希值不同，说明数据有差异，使用更新的数据（这里选择上传本地数据）
          await _uploadDataWithMetadata(fileName, localData, localMetadata);
          return localData.map((map) => fromMap(map)).toList();
        } else {
          // 数据完全相同，返回本地数据
          return localData.map((map) => fromMap(map)).toList();
        }
      }
    } catch (e) {
      print("Error during sync merge for $fileName: $e");
      // 出错时返回本地数据
      return localData.map((map) => fromMap(map)).toList();
    }
  }

  /// 获取数据的元信息（时间戳和哈希值）
  Future<Map<String, dynamic>> _getDataMetadata(
    List<Map<String, dynamic>> data,
  ) async {
    final jsonString = jsonEncode(data);
    final bytes = utf8.encode(jsonString);
    final hash = sha256.convert(bytes).toString();
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    return {'timestamp': timestamp, 'hash': hash};
  }

  /// 获取远程文件的元信息
  Future<Map<String, dynamic>?> _getRemoteMetadata(String fileName) async {
    try {
      final metadataFileName = '$fileName.meta';
      final bytes = await _client.read(metadataFileName);
      final jsonString = utf8.decode(bytes);
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      // 元信息文件不存在
      return null;
    }
  }

  /// 上传数据和元信息
  Future<void> _uploadDataWithMetadata(
    String fileName,
    List<Map<String, dynamic>> data,
    Map<String, dynamic> metadata,
  ) async {
    // 上传数据文件
    await _uploadData(fileName, data);

    // 上传元信息文件
    final metadataFileName = '$fileName.meta';
    final metadataJsonString = jsonEncode(metadata);
    final metadataBytes = Uint8List.fromList(utf8.encode(metadataJsonString));
    await _client.write(metadataFileName, metadataBytes);
  }

  /// 上传一个数据列表到在WebDAV服务器上的文件
  Future<void> _uploadData(
    String fileName,
    List<Map<String, dynamic>> data,
  ) async {
    _checkInitialized();
    final jsonString = jsonEncode(data);
    final bytes = Uint8List.fromList(utf8.encode(jsonString));
    await _client.write(fileName, bytes);
  }

  /// 从WebDAV服务器的文件上下载和解析一个数据列表的数据
  Future<List<T>> _downloadData<T>(
    String fileName,
    T Function(Map<String, dynamic>) fromMap,
  ) async {
    _checkInitialized();
    try {
      final bytes = await _client.read(fileName);
      final jsonString = utf8.decode(bytes);
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList
          .map((jsonItem) => fromMap(jsonItem as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // 解决文件不存在或为空的问题
      print("Error downloading $fileName: $e");
      return [];
    }
  }
}
