import 'package:flutter/material.dart';

class ScaffoldElementsNotifier extends ChangeNotifier {
  AppBar? _appBar;
  Widget? _floatingActionButton;
  FloatingActionButtonLocation? _floatingActionButtonLocation;
  FloatingActionButtonAnimator? _floatingActionButtonAnimator;
  Widget? _drawer;
  Widget? _endDrawer;
  
  // 为每个元素创建独立的通知器
  final ValueNotifier<AppBar?> _appBarNotifier = ValueNotifier<AppBar?>(null);
  final ValueNotifier<Widget?> _floatingActionButtonNotifier = ValueNotifier<Widget?>(null);
  final ValueNotifier<FloatingActionButtonLocation?> _floatingActionButtonLocationNotifier = ValueNotifier<FloatingActionButtonLocation?>(null);
  final ValueNotifier<FloatingActionButtonAnimator?> _floatingActionButtonAnimatorNotifier = ValueNotifier<FloatingActionButtonAnimator?>(null);
  final ValueNotifier<Widget?> _drawerNotifier = ValueNotifier<Widget?>(null);
  final ValueNotifier<Widget?> _endDrawerNotifier = ValueNotifier<Widget?>(null);
  
  // 公开访问独立通知器
  ValueNotifier<AppBar?> get appBarNotifier => _appBarNotifier;
  ValueNotifier<Widget?> get floatingActionButtonNotifier => _floatingActionButtonNotifier;
  ValueNotifier<FloatingActionButtonLocation?> get floatingActionButtonLocationNotifier => _floatingActionButtonLocationNotifier;
  ValueNotifier<FloatingActionButtonAnimator?> get floatingActionButtonAnimatorNotifier => _floatingActionButtonAnimatorNotifier;
  ValueNotifier<Widget?> get drawerNotifier => _drawerNotifier;
  ValueNotifier<Widget?> get endDrawerNotifier => _endDrawerNotifier;
  
  AppBar? get appBar => _appBar;
  Widget? get floatingActionButton => _floatingActionButton;
  FloatingActionButtonLocation? get floatingActionButtonLocation => _floatingActionButtonLocation;
  FloatingActionButtonAnimator? get floatingActionButtonAnimator => _floatingActionButtonAnimator;
  Widget? get drawer => _drawer;
  Widget? get endDrawer => _endDrawer;
  
  void updateElements({
    AppBar? appBar,
    Widget? floatingActionButton,
    FloatingActionButtonLocation? floatingActionButtonLocation,
    FloatingActionButtonAnimator? floatingActionButtonAnimator,
    Widget? drawer,
    Widget? endDrawer,
  }) {
    bool hasGlobalChange = false;
    
    if (_appBar != appBar) {
      _appBar = appBar;
      _appBarNotifier.value = appBar;
      hasGlobalChange = true;
    }
    
    if (_floatingActionButton != floatingActionButton) {
      _floatingActionButton = floatingActionButton;
      _floatingActionButtonNotifier.value = floatingActionButton;
      hasGlobalChange = true;
    }
    
    if (_floatingActionButtonLocation != floatingActionButtonLocation) {
      _floatingActionButtonLocation = floatingActionButtonLocation;
      _floatingActionButtonLocationNotifier.value = floatingActionButtonLocation;
      hasGlobalChange = true;
    }
    
    if (_floatingActionButtonAnimator != floatingActionButtonAnimator) {
      _floatingActionButtonAnimator = floatingActionButtonAnimator;
      _floatingActionButtonAnimatorNotifier.value = floatingActionButtonAnimator;
      hasGlobalChange = true;
    }
    
    if (_drawer != drawer) {
      _drawer = drawer;
      _drawerNotifier.value = drawer;
      hasGlobalChange = true;
    }
    
    if (_endDrawer != endDrawer) {
      _endDrawer = endDrawer;
      _endDrawerNotifier.value = endDrawer;
      hasGlobalChange = true;
    }
    
    // 只有当有全局性变化时才触发全局通知
    if (hasGlobalChange) {
      notifyListeners();
    }
  }
  
  // 单独更新特定元素的方法
  void updateAppBar(AppBar? appBar) {
    if (_appBar != appBar) {
      _appBar = appBar;
      _appBarNotifier.value = appBar;
      notifyListeners();
    }
  }
  
  void updateFloatingActionButton(Widget? floatingActionButton) {
    if (_floatingActionButton != floatingActionButton) {
      _floatingActionButton = floatingActionButton;
      _floatingActionButtonNotifier.value = floatingActionButton;
      // 对于 FAB，只触发特定通知，不触发全局重构
    }
  }
  
  void updateFloatingActionButtonLocation(FloatingActionButtonLocation? location) {
    if (_floatingActionButtonLocation != location) {
      _floatingActionButtonLocation = location;
      _floatingActionButtonLocationNotifier.value = location;
      // FAB 位置变化通常不需要全局重构，只更新相关组件
    }
  }
  
  void updateFloatingActionButtonAnimator(FloatingActionButtonAnimator? animator) {
    if (_floatingActionButtonAnimator != animator) {
      _floatingActionButtonAnimator = animator;
      _floatingActionButtonAnimatorNotifier.value = animator;
      // FAB 动画器变化通常不需要全局重构，只更新相关组件
    }
  }
  
  void updateDrawer(Widget? drawer) {
    if (_drawer != drawer) {
      _drawer = drawer;
      _drawerNotifier.value = drawer;
      notifyListeners();
    }
  }
  
  void updateEndDrawer(Widget? endDrawer) {
    if (_endDrawer != endDrawer) {
      _endDrawer = endDrawer;
      _endDrawerNotifier.value = endDrawer;
      notifyListeners();
    }
  }
  
  void clearElements() {
    _appBar = null;
    _floatingActionButton = null;
    _floatingActionButtonLocation = null;
    _floatingActionButtonAnimator = null;
    _drawer = null;
    _endDrawer = null;
    
    // 清除所有独立通知器
    _appBarNotifier.value = null;
    _floatingActionButtonNotifier.value = null;
    _floatingActionButtonLocationNotifier.value = null;
    _floatingActionButtonAnimatorNotifier.value = null;
    _drawerNotifier.value = null;
    _endDrawerNotifier.value = null;
    
    notifyListeners();
  }
  
  @override
  void dispose() {
    _appBarNotifier.dispose();
    _floatingActionButtonNotifier.dispose();
    _floatingActionButtonLocationNotifier.dispose();
    _floatingActionButtonAnimatorNotifier.dispose();
    _drawerNotifier.dispose();
    _endDrawerNotifier.dispose();
    super.dispose();
  }
}