// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:bavo/main.dart';

void main() {
  testWidgets('Bavo app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const BavoApp());

    // Verify that our app displays the welcome message.
    expect(find.text('欢迎使用 Bavo'), findsOneWidget);
    expect(find.text('您的全新应用体验'), findsOneWidget);
  });
}
