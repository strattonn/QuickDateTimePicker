import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quick_datetime_picker/quick_datetime_picker.dart';

void main() {
  group('Dialog Functions Basic Tests', () {
  testWidgets('showQuickDateTimePicker can be called',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showQuickDateTimePicker(context: context);
                },
                child: const Text('Show Picker'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Picker'));
      await tester.pump();

      // Verify dialog appeared
      expect(find.byType(Dialog), findsOneWidget);

      // Close dialog to clean up
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();
    });

  testWidgets('showQuickDateTimeRangePicker can be called',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showQuickDateTimeRangePicker(context: context);
                },
                child: const Text('Show Range Picker'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Range Picker'));
      await tester.pump();

      // Verify dialog appeared
      expect(find.byType(Dialog), findsOneWidget);

      // Close dialog to clean up
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();
    });

    testWidgets('dialog functions accept configuration parameters',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showQuickDateTimePicker(
                    context: context,
                    type: QuickDateTimePickerType.date,
                    initialDateTime: DateTime(2024, 6, 15),
                    firstDateTime: DateTime(2024, 1, 1),
                    lastDateTime: DateTime(2024, 12, 31),
                    is24HourMode: true,
                  );
                },
                child: const Text('Show Date Picker'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Date Picker'));
      await tester.pump();

      expect(find.byType(Dialog), findsOneWidget);

      // Close dialog
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();
    });
  });
}
