import 'package:flutter/material.dart';

/// Scaffold 组件传递数据结构
class PageComponents {
  PageComponents({
    required this.appBar,
    required this.body,
    this.fab,
    this.faba,
    this.fabl,
    this.endDrawer,
  });

  final AppBar appBar;
  final Widget body;
  final FloatingActionButton? fab;
  final FloatingActionButtonAnimator? faba;
  final FloatingActionButtonLocation? fabl;
  final Drawer? endDrawer;
}
