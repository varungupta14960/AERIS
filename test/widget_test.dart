// Basic smoke test: the app launches and shows the Dashboard.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:airsync/main.dart';

void main() {
  testWidgets('AERIS launches and shows the Dashboard', (WidgetTester tester) async {
    await tester.pumpWidget(const AerisApp());
    await tester.pump();

    expect(find.text('AERIS'), findsWidgets);
    expect(find.text('Personal Air Intelligence'), findsOneWidget);
  });
}
