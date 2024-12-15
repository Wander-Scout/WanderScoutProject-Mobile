import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wanderscout/main.dart';
import 'package:wanderscout/davin/screens/login.dart';

void main() {
  group('MyApp Widget Tests', () {
    testWidgets('MyApp builds successfully and shows LoginPage', (WidgetTester tester) async {
      // Build the widget tree
      await tester.pumpWidget(const MyApp());

      // Verify that the MaterialApp is built
      expect(find.byType(MaterialApp), findsOneWidget);

      // Verify that LoginPage is displayed
      expect(find.byType(LoginPage), findsOneWidget);
    });
  });
}
