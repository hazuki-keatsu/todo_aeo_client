import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_aeo/providers/sync_settings_provider.dart';
import 'package:todo_aeo/modules/sync_settings.dart';

class SyncSettingsPage extends StatefulWidget {
  const SyncSettingsPage({super.key});

  @override
  State<SyncSettingsPage> createState() => _SyncSettingsPageState();
}

class _SyncSettingsPageState extends State<SyncSettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final _hostController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isEnabled = false;

  // 防抖定时器
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCurrentSettings();
    });

    // 为文本控制器添加监听器，实现自动保存
    _hostController.addListener(_onTextFieldChanged);
    _usernameController.addListener(_onTextFieldChanged);
    _passwordController.addListener(_onTextFieldChanged);
  }

  void _loadCurrentSettings() {
    final provider = Provider.of<SyncSettingsProvider>(context, listen: false);
    final settings = provider.settings;

    _hostController.text = settings.host ?? '';
    _usernameController.text = settings.username ?? '';
    _passwordController.text = settings.password ?? '';
    _isEnabled = settings.isEnabled;
    setState(() {});
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _hostController.removeListener(_onTextFieldChanged);
    _usernameController.removeListener(_onTextFieldChanged);
    _passwordController.removeListener(_onTextFieldChanged);
    _hostController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // 文本字段改变时的回调，使用防抖来避免频繁保存
  void _onTextFieldChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 800), () {
      _autoSaveSettings();
    });
  }

  // 自动保存设置
  Future<void> _autoSaveSettings() async {
    if (!mounted) return;

    // 只有在表单有效时才保存
    if (_formKey.currentState?.validate() == true) {
      final provider = Provider.of<SyncSettingsProvider>(
        context,
        listen: false,
      );

      final settings = SyncSettings(
        host: _hostController.text.trim(),
        username: _usernameController.text.trim(),
        password: _passwordController.text,
        isEnabled: _isEnabled,
      );

      await provider.saveSettings(settings);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SyncSettingsProvider>(
      builder: (context, syncProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('同步设置'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
          ),
          body: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(4),
              children: [
                // WebDAV 服务器配置卡片
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  _isEnabled
                                      ? Icons.cloud_done
                                      : Icons.cloud_off,
                                  color: _isEnabled
                                      ? Colors.green
                                      : Colors.grey,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'WebDAV 同步配置',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            SwitchListTile(
                              title: const Text('启用同步'),
                              subtitle: Text(
                                _isEnabled ? '已启用 WebDAV 同步' : '同步已禁用',
                              ),
                              value: _isEnabled,
                              onChanged: (value) {
                                setState(() {
                                  _isEnabled = value;
                                });
                                // 开关状态改变时立即保存
                                _autoSaveSettings();
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.storage),
                            const SizedBox(width: 8),
                            Text(
                              '服务器配置',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // 服务器地址
                        TextFormField(
                          controller: _hostController,
                          decoration: const InputDecoration(
                            labelText: '服务器地址',
                            hintText: 'https://example.com/dav',
                            prefixIcon: Icon(Icons.link),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '请输入服务器地址';
                            }
                            if (!value.startsWith('http://') &&
                                !value.startsWith('https://')) {
                              return '请输入有效的URL (http:// 或 https://)';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // 用户名
                        TextFormField(
                          controller: _usernameController,
                          decoration: const InputDecoration(
                            labelText: '用户名',
                            hintText: '输入您的用户名',
                            prefixIcon: Icon(Icons.person),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '请输入用户名';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // 密码
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: '密码',
                            hintText: '输入您的密码',
                            prefixIcon: const Icon(Icons.lock),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            border: const OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '请输入密码';
                            }
                            return null;
                          },
                        ),

                        // 操作面板
                        SizedBox(height: 16),

                        // 测试连接按钮
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ElevatedButton.icon(
                              onPressed: syncProvider.isTestingConnection
                                  ? null
                                  : _testConnection,
                              icon: syncProvider.isTestingConnection
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.wifi_tethering),
                              label: Text(
                                syncProvider.isTestingConnection
                                    ? '测试中...'
                                    : '测试连接',
                              ),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // 错误信息显示
                if (syncProvider.error != null) ...[
                  const SizedBox(height: 16),
                  Card(
                    color: Theme.of(context).colorScheme.errorContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Theme.of(
                              context,
                            ).colorScheme.onErrorContainer,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              syncProvider.error!,
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onErrorContainer,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => syncProvider.clearError(),
                            color: Theme.of(
                              context,
                            ).colorScheme.onErrorContainer,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                // 帮助信息卡片
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.help_outline),
                            const SizedBox(width: 8),
                            Text(
                              '帮助信息',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '• WebDAV 是一种基于 HTTP 的协议，用于远程文件管理\n'
                          '• 支持 坚果云 等服务\n'
                          '• 服务器地址示例：http://dav.jianguoyun.com/dav/\n'
                          '• 请确保您的服务器支持 WebDAV 协议',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _testConnection() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final provider = Provider.of<SyncSettingsProvider>(context, listen: false);

    // 临时更新设置用于测试
    provider.updateHost(_hostController.text.trim());
    provider.updateUsername(_usernameController.text.trim());
    provider.updatePassword(_passwordController.text);

    final success = await provider.testConnection();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? '连接测试成功！' : '连接测试失败，请检查设置'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }
}
