import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_aeo/providers/theme_provider.dart';

class ThemePage extends StatelessWidget {
  const ThemePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back),
            ),
            title: Text("主题设置"),
          ),
          body: ListView(
            padding: EdgeInsets.all(8),
            children: [
              // 深色模式开关
              Card(
                child: SwitchListTile(
                  title: Text('深色模式'),
                  subtitle: Text('开启深色主题'),
                  value: themeProvider.isDarkMode,
                  onChanged: (value) async {
                    await themeProvider.setDarkMode(value);
                  },
                  secondary: Icon(
                    themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                  ),
                ),
              ),
              
              SizedBox(height: 16),
              
              // 动态取色开关
              Card(
                child: SwitchListTile(
                  title: Text('动态取色'),
                  subtitle: Text('根据壁纸自动选择主题色 (Android 12 以上)'),
                  value: themeProvider.useDynamicColor,
                  onChanged: (value) async {
                    await themeProvider.setUseDynamicColor(value);
                  },
                  secondary: Icon(Icons.auto_awesome),
                ),
              ),
              
              SizedBox(height: 16),
              
              // 颜色选择
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '主题颜色',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        themeProvider.useDynamicColor 
                          ? '当前使用动态取色' 
                          : '当前: ${themeProvider.getColorName(themeProvider.seedColor)}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      SizedBox(height: 16),
                      
                      // 颜色网格
                      GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 5,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1,
                        ),
                        itemCount: ThemeProvider.predefinedColors.length,
                        itemBuilder: (context, index) {
                          final color = ThemeProvider.predefinedColors[index];
                          final isSelected = !themeProvider.useDynamicColor && 
                                           themeProvider.seedColor == color;
                          
                          return GestureDetector(
                            onTap: () async {
                              await themeProvider.setSeedColor(color);
                              if (themeProvider.useDynamicColor) {
                                await themeProvider.setUseDynamicColor(false);
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(16),
                                border: isSelected 
                                  ? Border.all(
                                      color: Theme.of(context).colorScheme.outline,
                                      width: 3,
                                    )
                                  : null,
                                boxShadow: [
                                  BoxShadow(
                                    color: color.withValues(alpha: 0.3),
                                    offset: Offset(0, 2),
                                    blurRadius: 4,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: isSelected
                                ? Icon(
                                    Icons.check,
                                    color: _getContrastColor(color),
                                    size: 24,
                                  )
                                : null,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: 16),
              
              // 预览卡片
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '主题预览',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      
                      // 预览内容
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primary,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Icon(
                                    Icons.palette,
                                    color: Theme.of(context).colorScheme.onPrimary,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '主题预览',
                                        style: Theme.of(context).textTheme.titleSmall,
                                      ),
                                      Text(
                                        '这是应用的主题色效果',
                                        style: Theme.of(context).textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: FilledButton(
                                    onPressed: () {},
                                    child: Text('主要按钮'),
                                  ),
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () {},
                                    child: Text('次要按钮'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  // 获取对比色（用于选中图标）
  Color _getContrastColor(Color color) {
    // 简单的对比度计算
    final luminance = (0.299 * color.r + 0.587 * color.g + 0.114 * color.b) / 255;
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}
