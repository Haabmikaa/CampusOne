import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:campus_one/main.dart';

void main() {
  testWidgets('CampusOne app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const CampusOneApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
