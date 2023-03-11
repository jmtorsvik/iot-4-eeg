import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:connection_app/main.dart';

void main() {
  testWidgets('ConnectionApp has button', (WidgetTester tester) async {
    await tester.pumpWidget(const ConnectionApp());

    expect(find.widgetWithText(ElevatedButton, 'Connect!'), findsOneWidget);
  });
}
