import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_aeo/l10n/app_localizations.dart';
import 'package:todo_aeo/widgets/show_dialog.dart';
import 'package:todo_aeo/providers/settings_provider.dart';
import 'package:todo_aeo/providers/todo_provider.dart';
import 'package:todo_aeo/utils/parse_color.dart';

class SharedEndDrawer {
  static Widget build(
    BuildContext context, 
    TodoProvider provider, {
    int? selectedCategoryId,
    required Function(int?, String) onCategorySelected,
  }) {
    final l10n = AppLocalizations.of(context)!;
    return Drawer(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondaryContainer,
            ),
            child: Column(
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: l10n.todoAppName,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSecondaryContainer,
                        ),
                      ),
                      TextSpan(
                        text: "A",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3B82F6),
                        ),
                      ),
                      TextSpan(
                        text: "E",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF10B981),
                        ),
                      ),
                      TextSpan(
                        text: "O",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFF59E0B),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  l10n.niceDay,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                    fontWeight: FontWeight.w400,
                    fontSize: 18,
                    fontFamily: "cursive",
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
                    ShowDialog.showAboutApplicationDialog(context, settingsProvider);
                  },
                  label: Text(AppLocalizations.of(context)!.aboutApp),
                  icon: Icon(Icons.info_outline),
                ),
              ],
            ),
          ),
          // 分类列表 - 使用 Consumer 来监听 provider 变化
          Expanded(
            child: Consumer<TodoProvider>(
              builder: (context, todoProvider, child) {
                final categories = todoProvider.categories ?? [];
                
                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 全部todos
                      ListTile(
                        leading: Icon(Icons.list),
                        title: Text(AppLocalizations.of(context)!.all),
                        selected: selectedCategoryId == null,
                        onTap: () => onCategorySelected(null, AppLocalizations.of(context)!.all),
                        selectedColor: Theme.of(context).colorScheme.primary,
                        selectedTileColor: Theme.of(
                          context,
                        ).colorScheme.surfaceContainer,
                      ),
                      // 未分类todos
                      ListTile(
                        leading: Icon(Icons.label_off),
                        title: Text(AppLocalizations.of(context)!.uncategorize),
                        selected: selectedCategoryId == -1,
                        onTap: () => onCategorySelected(-1, AppLocalizations.of(context)!.uncategorize),
                        selectedColor: Theme.of(context).colorScheme.primary,
                        selectedTileColor: Theme.of(
                          context,
                        ).colorScheme.surfaceContainer,
                      ),
                      if (categories.isNotEmpty) ...[
                        Divider(),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.categories,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                        ...categories.map((category) {
                          final isSelected = selectedCategoryId == category.id;
                          return ListTile(
                            leading: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: category.color != null
                                    ? parseColor(category.color, context)
                                    : Theme.of(context).colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            title: Text(category.name),
                            selected: isSelected,
                            selectedColor: Theme.of(context).colorScheme.primary,
                            selectedTileColor: Theme.of(
                              context,
                            ).colorScheme.surfaceContainer,
                            onTap: () =>
                                onCategorySelected(category.id, category.name),
                            onLongPress: () => ShowDialog.showOptionsBottomSheet(
                              category.id!,
                              todoProvider,
                              context,
                              OperationMode.category,
                            ),
                          );
                        }),
                      ],
                      Divider(),
                      ListTile(
                        leading: Icon(Icons.add),
                        title: Text(AppLocalizations.of(context)!.addCategory),
                        onTap: () async {
                          Navigator.pop(context);
                          await ShowDialog.showCategoryDialog(context, provider);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}