import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:webdav_client/webdav_client.dart';
import 'package:todo_aeo/modules/todo.dart';
import 'package:todo_aeo/modules/category.dart';
import 'package:todo_aeo/services/sync/sync_exceptions.dart';
import 'package:todo_aeo/services/sync/data_diff_service.dart';
import 'package:todo_aeo/services/sync/local_metadata_service.dart';
import 'package:todo_aeo/modules/sync_metadata.dart';

class WebdavSyncService {
  // 单例模式
  WebdavSyncService._privateConstructor();

  static final WebdavSyncService instance =
      WebdavSyncService._privateConstructor();

  static const String _basePath = '/TodoAeoSync';

  late Client _client;
  bool _isInitialized = false;

  /// 初始化WebDAV Client
  /// 在任意其他的方法之前执行
  Future<void> init({
    required String host,
    required String user,
    required String password,
  }) async {
    try {
      _client = newClient(host, user: user, password: password);
      _client.setHeaders({'content-type': 'application/json'});

      try {
        await _client.readProps(_basePath);
      } catch (e) {
        // 如果捕获到的是DioException且状态码为404，说明目录不存在
        if (e is DioException && e.response?.statusCode == 404) {
          // 目录不存在，创建它
          await _client.mkdir(_basePath);
        } else {
          // 如果是其他错误（如认证失败、网络问题），则重新抛出
          rethrow;
        }
      }

      _isInitialized = true;
    } catch (e) {
      throw InitializationException(
        'Failed to initialize WebDAV client or create directory',
        details: e.toString(),
      );
    }
  }

  void _checkInitialized() {
    if (!_isInitialized) {
      throw InitializationException(
        "WebdavSyncService not initialized. Call init() first.",
      );
    }
  }

  /// 使用WebDAV服务器同步本地数据
  /// 实现智能合并和冲突检测
  Future<SyncResult> sync({
    required List<Todo> localTodos,
    required List<Category> localCategories,
  }) async {
    _checkInitialized();

    try {
      // 处理todos数据同步
      final todosResult = await _syncDataWithSmartMerge(
        'todos.json',
        localTodos,
        (map) => Todo.fromMap(map),
      );

      // 处理categories数据同步
      final categoriesResult = await _syncDataWithSmartMerge(
        'categories.json',
        localCategories,
        (map) => Category.fromMap(map),
      );

      // 保存同步成功的时间戳
      await LocalMetadataService.saveLastSyncTime('todos.json', DateTime.now());
      await LocalMetadataService.saveLastSyncTime(
        'categories.json',
        DateTime.now(),
      );

      return SyncResult(
        todos: todosResult.mergedData.cast<Todo>(),
        categories: categoriesResult.mergedData.cast<Category>(),
        todoConflicts: todosResult.conflicts,
        categoryConflicts: categoriesResult.conflicts,
        hasConflicts: todosResult.hasConflicts || categoriesResult.hasConflicts,
      );
    } catch (e) {
      if (e is SyncException) {
        rethrow;
      }
      throw SyncFailedException('Sync operation failed', details: e.toString());
    }
  }

  /// 智能合并同步数据
  Future<MergeResult<T>> _syncDataWithSmartMerge<T extends Versionable>(
    String fileName,
    List<T> localData,
    T Function(Map<String, dynamic>) fromMap,
  ) async {
    try {
      // 检查本地数据是否有变化
      final hasLocalChanges = await LocalMetadataService.hasLocalDataChanged(
        fileName,
        localData,
      );

      if (!hasLocalChanges) {
        // 本地无变化，检查远程是否有更新
        final remoteData = await _downloadData<T>(fileName, fromMap);
        if (remoteData.isNotEmpty) {
          // 远程有数据，直接返回远程数据
          return MergeResult(
            mergedData: remoteData,
            conflicts: [],
            hasConflicts: false,
          );
        }
      }

      // 获取本地和远程数据
      final localMetadata = LocalMetadataService.generateMetadata(localData);
      final remoteMetadata = await _getRemoteMetadata(fileName);
      final remoteData = await _downloadData<T>(fileName, fromMap);

      if (remoteData.isEmpty) {
        // 远程没有数据，直接上传本地数据
        await _uploadDataWithMetadata(fileName, localData, localMetadata);
        await LocalMetadataService.saveDataMetadata(fileName, localMetadata);
        return MergeResult(
          mergedData: localData,
          conflicts: [],
          hasConflicts: false,
        );
      }

      // 使用版本向量进行智能合并
      final mergeResult = DataDiffService.mergeLists(localData, remoteData);

      if (mergeResult.hasConflicts) {
        // 有冲突时，保存冲突副本
        await _handleConflicts(fileName, localData, remoteData);
      }

      // 上传合并后的数据
      final mergedMetadata = LocalMetadataService.generateMetadata(
        mergeResult.mergedData,
        version: (localMetadata.version > (remoteMetadata?.version ?? 0))
            ? localMetadata.version + 1
            : (remoteMetadata?.version ?? 0) + 1,
      );

      await _uploadDataWithMetadata(
        fileName,
        mergeResult.mergedData,
        mergedMetadata,
      );
      await LocalMetadataService.saveDataMetadata(fileName, mergedMetadata);

      return mergeResult;
    } catch (e) {
      if (e is SyncException) {
        rethrow;
      }
      throw SyncFailedException(
        'Failed to sync data for $fileName',
        details: e.toString(),
      );
    }
  }

  /// 处理冲突：保存冲突副本并抛出冲突异常
  Future<void> _handleConflicts<T>(
    String fileName,
    List<T> localData,
    List<T> remoteData,
  ) async {
    try {
      // 生成冲突文件名
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final conflictFileName =
          '${fileName.replaceAll('.json', '')}.conflict.$timestamp.json';

      // 保存本地版本为冲突副本
      final localMetadata = LocalMetadataService.generateMetadata(localData);
      await _uploadDataWithMetadata(conflictFileName, localData, localMetadata);

      throw ConflictDetectedException(
        'Data conflict detected during sync',
        conflictFileName,
        details: 'Local version saved as $conflictFileName',
      );
    } catch (e) {
      if (e is ConflictDetectedException) {
        rethrow;
      }
      throw SyncFailedException(
        'Failed to handle conflicts for $fileName',
        details: e.toString(),
      );
    }
  }

  /// 获取远程文件的元信息
  Future<SyncMetadata?> _getRemoteMetadata(String fileName) async {
    try {
      final remotePath = '$_basePath/$fileName.meta';
      final bytes = await _client.read(remotePath);
      final jsonString = utf8.decode(bytes);
      final map = jsonDecode(jsonString) as Map<String, dynamic>;
      return SyncMetadata.fromMap(map);
    } catch (e) {
      // 元信息文件不存在或读取失败
      return null;
    }
  }

  /// 上传数据和元信息
  Future<void> _uploadDataWithMetadata<T>(
    String fileName,
    List<T> data,
    SyncMetadata metadata,
  ) async {
    try {
      // 上传数据文件
      await _uploadData(fileName, data);

      // 上传元信息文件
      final metadataFileName = '$fileName.meta';
      final metadataJsonString = jsonEncode(metadata.toMap());
      final metadataBytes = Uint8List.fromList(utf8.encode(metadataJsonString));
      await _client.write('$_basePath/$metadataFileName', metadataBytes);
    } catch (e) {
      throw SyncFailedException(
        'Failed to upload data with metadata for $fileName',
        details: e.toString(),
      );
    }
  }

  /// 上传一个数据列表到WebDAV服务器上的文件
  Future<void> _uploadData<T>(String fileName, List<T> data) async {
    _checkInitialized();
    try {
      final jsonData = data.map((item) {
        if (item is Todo) return item.toMap();
        if (item is Category) return item.toMap();
        return item.toString();
      }).toList();

      final jsonString = jsonEncode(jsonData);
      final bytes = Uint8List.fromList(utf8.encode(jsonString));
      await _client.write('$_basePath/$fileName', bytes);
    } catch (e) {
      throw SyncFailedException(
        'Failed to upload data for $fileName',
        details: e.toString(),
      );
    }
  }

  /// 从WebDAV服务器的文件下载和解析数据列表
  Future<List<T>> _downloadData<T>(
    String fileName,
    T Function(Map<String, dynamic>) fromMap,
  ) async {
    _checkInitialized();
    try {
      final bytes = await _client.read('$_basePath/$fileName');
      final jsonString = utf8.decode(bytes);
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList
          .map((jsonItem) => fromMap(jsonItem as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // 文件不存在或为空时返回空列表
      return [];
    }
  }

  /// 列出所有冲突文件
  Future<List<String>> listConflictFiles() async {
    _checkInitialized();
    try {
      final files = await _client.readDir(_basePath);
      return files
          .where((file) => file.name?.contains('.conflict.') == true)
          .map((file) => file.name!)
          .toList();
    } catch (e) {
      throw SyncFailedException(
        'Failed to list conflict files',
        details: e.toString(),
      );
    }
  }

  /// 删除冲突文件
  Future<void> deleteConflictFile(String fileName) async {
    _checkInitialized();
    try {
      await _client.remove('$_basePath/$fileName');
      await _client.remove('$_basePath/$fileName.meta');
    } catch (e) {
      throw SyncFailedException(
        'Failed to delete conflict file $fileName',
        details: e.toString(),
      );
    }
  }
}

/// 同步结果
class SyncResult {
  final List<Todo> todos;
  final List<Category> categories;
  final List<ConflictItem<Todo>> todoConflicts;
  final List<ConflictItem<Category>> categoryConflicts;
  final bool hasConflicts;

  SyncResult({
    required this.todos,
    required this.categories,
    required this.todoConflicts,
    required this.categoryConflicts,
    required this.hasConflicts,
  });
}
