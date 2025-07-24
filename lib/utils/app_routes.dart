import 'package:flutter/material.dart';
import 'package:todo_aeo/pages/todo_page.dart';
import 'package:todo_aeo/providers/todo_provider.dart';

class AppRoutes {
  // 路由名称常量
  static const String todoPage = '/todo';
  static const String todoEditPage = '/todo/edit';

  // 自定义页面切换动画 - 非线性复合动画（滑动+缩放+淡入）
  static Route<T> slideFromRightRoute<T extends Object?>(
    Widget page, {
    RouteSettings? settings,
    Duration duration = const Duration(milliseconds: 400),
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // 使用不同的缓动曲线，创建复合动画效果
        const slideCurve = Curves.easeOutCubic;
        const fadeCurve = Curves.easeInOut;

        // 滑动动画：从右边滑入
        const slideBegin = Offset(1.0, 0.0);
        const slideEnd = Offset.zero;
        var slideTween = Tween(
          begin: slideBegin,
          end: slideEnd,
        ).chain(CurveTween(curve: slideCurve));
        var slideAnimation = animation.drive(slideTween);


        // 淡入动画：透明度从0到1
        var fadeTween = Tween(
          begin: 0.0,
          end: 1.0,
        ).chain(CurveTween(curve: fadeCurve));
        var fadeAnimation = animation.drive(fadeTween);

        // 组合动画：滑动 + 缩放 + 淡入
        return SlideTransition(
          position: slideAnimation,
          child: FadeTransition(opacity: fadeAnimation, child: child),
        );
      },
    );
  }

  // 通用的页面导航方法，自动应用非线性复合动画
  static Future<T?> pushPage<T extends Object?>(
    BuildContext context,
    Widget page, {
    String? routeName,
    Duration duration = const Duration(milliseconds: 400),
  }) {
    return Navigator.push<T>(
      context,
      slideFromRightRoute<T>(
        page,
        settings: routeName != null ? RouteSettings(name: routeName) : null,
        duration: duration,
      ),
    );
  }

  // 路由生成器
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case todoPage:
        final args = settings.arguments as Map<String, dynamic>?;
        return slideFromRightRoute(
          TodoPage(
            provider: args?['provider'] as TodoProvider,
            lastPageContext: args?['lastPageContext'] as BuildContext,
          ),
          settings: settings,
        );

      case todoEditPage:
        final args = settings.arguments as Map<String, dynamic>?;
        return slideFromRightRoute(
          TodoPage(
            todoId: args?['todoId'] as int?,
            provider: args?['provider'] as TodoProvider,
            lastPageContext: args?['lastPageContext'] as BuildContext,
          ),
          settings: settings,
        );

      default:
        return null;
    }
  }

  // 便捷的导航方法
  static Future<T?> pushTodoPage<T extends Object?>(
    BuildContext context,
    TodoProvider provider,
  ) {
    return Navigator.pushNamed(
      context,
      todoPage,
      arguments: {'provider': provider, 'lastPageContext': context},
    );
  }

  static Future<T?> pushTodoEditPage<T extends Object?>(
    BuildContext context,
    int todoId,
    TodoProvider provider,
  ) {
    return Navigator.pushNamed(
      context,
      todoEditPage,
      arguments: {
        'todoId': todoId,
        'provider': provider,
        'lastPageContext': context,
      },
    );
  }
}
