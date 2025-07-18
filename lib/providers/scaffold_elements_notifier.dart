import 'package:flutter/material.dart';

class ScaffoldElementsNotifier extends ChangeNotifier {
  AppBar? _appBar;
  Widget? _floatingActionButton;
  FloatingActionButtonLocation? _floatingActionButtonLocation;
  FloatingActionButtonAnimator? _floatingActionButtonAnimator;
  Widget? _drawer;
  Widget? _endDrawer;
  
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
    _appBar = appBar;
    _floatingActionButton = floatingActionButton;
    _floatingActionButtonLocation = floatingActionButtonLocation;
    _floatingActionButtonAnimator = floatingActionButtonAnimator;
    _drawer = drawer;
    _endDrawer = endDrawer;
    notifyListeners();
  }
  
  void clearElements() {
    _appBar = null;
    _floatingActionButton = null;
    _floatingActionButtonLocation = null;
    _floatingActionButtonAnimator = null;
    _drawer = null;
    _endDrawer = null;
    notifyListeners();
  }
}