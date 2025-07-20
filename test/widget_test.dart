// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:todo_aeo/main.dart';
import 'package:todo_aeo/providers/todo_provider.dart';

void main() {
  // 在所有测试开始前初始化数据库
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    
  });

  Widget createTestApp() {
    return ChangeNotifierProvider(
      create: (context) => TodoProvider()..init(),
      child: MaterialApp(
        home: ToDoHomeFrame(title: "ToDo Aeo"),
      ),
    );
  }

  testWidgets('Todo app loads and shows navigation', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(createTestApp());
    
    // Wait for async operations to complete
    await tester.pumpAndSettle();

    // Verify that the app loads correctly
    expect(find.text('全部'), findsOneWidget);
    
    // Verify navigation exists
    expect(find.byType(NavigationBar), findsOneWidget);
    
    // Verify FAB exists
    expect(find.byIcon(Icons.add), findsOneWidget);
  });

  testWidgets('Can navigate between pages', (WidgetTester tester) async {
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();

    // Test navigation to Calendar page
    await tester.tap(find.text('Calendar'));
    await tester.pumpAndSettle();
    expect(find.text('日历'), findsOneWidget);

    // Test navigation to Settings page
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('设置'), findsOneWidget);

    // Test navigation back to Home
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(find.text('全部'), findsOneWidget);
  });

  testWidgets('Can open add todo dialog', (WidgetTester tester) async {
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();

    // Tap the FAB button
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    // Verify the dialog appears
    expect(find.text('添加新的待办事项'), findsOneWidget);
    expect(find.text('取消'), findsOneWidget);
    expect(find.text('确定'), findsOneWidget);
  });
}
