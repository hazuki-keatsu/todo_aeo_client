import 'package:flutter/material.dart';

Color parseColor(String? colorString, BuildContext context) {
    if (colorString == null || colorString.isEmpty) {
      return Theme.of(context).colorScheme.primary;
    }

    // 检查是否是有效的十六进制颜色格式
    if (colorString.startsWith('#') && colorString.length == 7) {
      try {
        return Color(
          int.parse(colorString.substring(1), radix: 16) + 0xFF000000,
        );
      } catch (e) {
        return Theme.of(context).colorScheme.primary;
      }
    }

    // 如果不是十六进制格式，返回默认颜色
    return Theme.of(context).colorScheme.primary;
  }