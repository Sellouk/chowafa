// Basic Flutter widget test for Chowafa Oracle App

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:chowafa/main.dart';

void main() {
  testWidgets('App loads home screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ChowafaApp());

    // Verify the home screen loads with Arabic text
    expect(find.text('CHOWAFA'), findsOneWidget);
    expect(find.text('اقرأ مستقبلي'), findsOneWidget);
  });
}
