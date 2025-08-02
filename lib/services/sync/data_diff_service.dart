import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:todo_aeo/modules/todo.dart';
import 'package:todo_aeo/modules/category.dart';

/// 数据差异合并服务
/// 实现逐项合并算法，支持版本号和智能冲突解决
class DataDiffService {
  /// 合并两个数据列表，返回合并结果和冲突信息
  static MergeResult<T> mergeLists<T extends Versionable>(
    List<T> localList,
    List<T> remoteList,
  ) {
    final Map<String, T> localMap = {
      for (var item in localList) item.versionableId: item,
    };
    final Map<String, T> remoteMap = {
      for (var item in remoteList) item.versionableId: item,
    };

    final List<T> mergedList = [];
    final List<ConflictItem<T>> conflicts = [];

    // 处理本地项目
    for (var localItem in localList) {
      final remoteItem = remoteMap[localItem.versionableId];

      if (remoteItem == null) {
        // 本地新增项目，直接添加
        mergedList.add(localItem);
      } else {
        // 存在于两边，需要比较版本
        final mergeResult = _mergeItem(localItem, remoteItem);
        if (mergeResult.hasConflict) {
          conflicts.add(
            ConflictItem(
              id: localItem.versionableId,
              localItem: localItem,
              remoteItem: remoteItem,
              conflictType: ConflictType.versionConflict,
            ),
          );
          // 冲突时使用版本号更高的项目
          mergedList.add(mergeResult.item);
        } else {
          mergedList.add(mergeResult.item);
        }
      }
    }

    // 处理远程独有的项目
    for (var remoteItem in remoteList) {
      if (!localMap.containsKey(remoteItem.versionableId)) {
        mergedList.add(remoteItem);
      }
    }

    return MergeResult(
      mergedData: mergedList,
      conflicts: conflicts,
      hasConflicts: conflicts.isNotEmpty,
    );
  }

  /// 合并单个项目
  static ItemMergeResult<T> _mergeItem<T extends Versionable>(
    T local,
    T remote,
  ) {
    if (local.version > remote.version) {
      return ItemMergeResult(item: local, hasConflict: false);
    } else if (local.version < remote.version) {
      return ItemMergeResult(item: remote, hasConflict: false);
    } else {
      // 版本号相同，比较内容哈希
      if (_calculateItemHash(local) == _calculateItemHash(remote)) {
        return ItemMergeResult(item: local, hasConflict: false);
      } else {
        // 相同版本但内容不同，这是真正的冲突
        // 使用更新时间较晚的项目
        final useLocal =
            (local.updatedAt?.isAfter(remote.updatedAt ?? DateTime(0)) ??
            false);
        return ItemMergeResult(
          item: useLocal ? local : remote,
          hasConflict: true,
        );
      }
    }
  }

  /// 计算单个项目的哈希值
  static String _calculateItemHash<T>(T item) {
    String content;
    if (item is Todo) {
      content = jsonEncode(item.toMap());
    } else if (item is Category) {
      content = jsonEncode(item.toMap());
    } else {
      content = item.toString();
    }
    return sha256.convert(utf8.encode(content)).toString();
  }

  /// 计算数据列表的哈希值
  static String calculateDataHash<T>(List<T> data) {
    final jsonString = jsonEncode(
      data.map((item) {
        if (item is Todo) return item.toMap();
        if (item is Category) return item.toMap();
        return item.toString();
      }).toList(),
    );
    return sha256.convert(utf8.encode(jsonString)).toString();
  }
}

/// 支持版本控制的数据接口
mixin Versionable {
  String get versionableId;

  int get version;

  DateTime? get updatedAt;
}

/// 合并结果
class MergeResult<T> {
  final List<T> mergedData;
  final List<ConflictItem<T>> conflicts;
  final bool hasConflicts;

  MergeResult({
    required this.mergedData,
    required this.conflicts,
    required this.hasConflicts,
  });
}

/// 单个项目合并结果
class ItemMergeResult<T> {
  final T item;
  final bool hasConflict;

  ItemMergeResult({required this.item, required this.hasConflict});
}

/// 冲突项目
class ConflictItem<T> {
  final String id;
  final T localItem;
  final T remoteItem;
  final ConflictType conflictType;

  ConflictItem({
    required this.id,
    required this.localItem,
    required this.remoteItem,
    required this.conflictType,
  });
}

/// 冲突类型
enum ConflictType { versionConflict, contentConflict, deleteConflict }
