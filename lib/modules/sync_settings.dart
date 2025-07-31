class SyncSettings {
  final String? host;
  final String? username;
  final String? password;
  final bool isEnabled;

  SyncSettings({
    this.host,
    this.username,
    this.password,
    this.isEnabled = false,
  });

  // 从Map创建SyncSettings对象
  factory SyncSettings.fromMap(Map<String, String?> map) {
    return SyncSettings(
      host: map['sync_host'],
      username: map['sync_username'],
      password: map['sync_password'],
      isEnabled: map['sync_enabled'] == 'true',
    );
  }

  // 转换为Map用于存储到数据库
  Map<String, String> toMap() {
    return {
      'sync_host': host ?? '',
      'sync_username': username ?? '',
      'sync_password': password ?? '',
      'sync_enabled': isEnabled.toString(),
    };
  }

  // 检查设置是否完整
  bool get isValid {
    return host != null &&
        host!.isNotEmpty &&
        username != null &&
        username!.isNotEmpty &&
        password != null &&
        password!.isNotEmpty;
  }

  SyncSettings copyWith({
    String? host,
    String? username,
    String? password,
    bool? isEnabled,
  }) {
    return SyncSettings(
      host: host ?? this.host,
      username: username ?? this.username,
      password: password ?? this.password,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }
}
