import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_aeo/l10n/app_localizations.dart';
import 'package:todo_aeo/providers/language_provider.dart';

class LanguageSettingsPage extends StatefulWidget {
  const LanguageSettingsPage({super.key});

  @override
  State<LanguageSettingsPage> createState() => _LanguageSettingsPageState();
}

class _LanguageSettingsPageState extends State<LanguageSettingsPage> {
  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.languageSwitch,
          style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back),
          color: Theme.of(context).colorScheme.onPrimary,
        ),
      ),
      body: Column(
        children: [
          _buildLanguageOption(
            context,
            languageProvider,
            'system',
            l10n.followSystem,
          ),
          _buildLanguageOption(
            context,
            languageProvider,
            'zh_CN',
            l10n.chinese,
          ),
          _buildLanguageOption(
            context,
            languageProvider,
            'en_US',
            l10n.english,
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    LanguageProvider languageProvider,
    String languageCode,
    String languageName,
  ) {
    final isSelected = languageCode == languageProvider.currentLanguageCode;

    return ListTile(
      title: Text(languageName),
      trailing: isSelected ? Icon(Icons.check, color: Theme.of(context).primaryColor) : null,
      onTap: () async {
        // 在异步操作前获取本地化对象
        final l10n = AppLocalizations.of(context)!;
        
        await languageProvider.changeLanguage(languageCode);
        
        if (mounted) {
          // 显示切换成功的提示
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${l10n.languageChanged}: $languageName'),
              duration: Duration(seconds: 1),
            ),
          );
        }
      },
    );
  }
}