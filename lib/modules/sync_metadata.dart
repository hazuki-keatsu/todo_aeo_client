/// 同步元数据
class SyncMetadata {
  final String hash;
  final int timestamp;
  final int version;
  final int itemCount;

  SyncMetadata({
    required this.hash,
    required this.timestamp,
    required this.version,
    required this.itemCount,
  });

  Map<String, dynamic> toMap() {
    return {
      'hash': hash,
      'timestamp': timestamp,
      'version': version,
      'itemCount': itemCount,
    };
  }

  static SyncMetadata fromMap(Map<String, dynamic> map) {
    return SyncMetadata(
      hash: map['hash'] as String,
      timestamp: map['timestamp'] as int,
      version: map['version'] as int? ?? 1,
      itemCount: map['itemCount'] as int? ?? 0,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SyncMetadata &&
        other.hash == hash &&
        other.timestamp == timestamp &&
        other.version == version &&
        other.itemCount == itemCount;
  }

  @override
  int get hashCode {
    return hash.hashCode ^
        timestamp.hashCode ^
        version.hashCode ^
        itemCount.hashCode;
  }
}
