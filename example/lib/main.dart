import 'package:flutter/material.dart';
import 'package:quick_datetime_picker/quick_datetime_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Quick DateTime Picker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.cyan,
          brightness: Brightness.light,
        ),
      ),
      home: const QuickExample(),
    );
  }
}

class QuickExample extends StatelessWidget {
  const QuickExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () async {
                final DateTime? dateTime =
                    await showQuickDateTimePicker(context: context);

                // Use dateTime here
                debugPrint('dateTime: $dateTime');
              },
              child: const Text('Show Quick DateTime Picker'),
            ),
            ElevatedButton(
              onPressed: () async {
                final DateTime? result = await showQuickDateTimePicker(
                  context: context,
                  is24HourMode: false,
                  minutesInterval: 15
                );

                if (result != null) {
                  // This should show the second and millisecond fields set to zero after the fix
                  debugPrint(
                      'Selected DateTime: ${result.toUtc().toIso8601String()}');
                  debugPrint(
                      'Seconds: ${result.second}, Milliseconds: ${result.millisecond}');
                }
              },
              child: const Text('Test 24-Hour Mode (check seconds)'),
            ),
            ElevatedButton(
              onPressed: () async {
                final DateTime? result = await showQuickDateTimePicker(
                  context: context,
                  minutesInterval: 15,
                  is24HourMode: true,
                  isShowSeconds: true,
                );

                if (result != null) {
                  // This should show microseconds as 0 even when seconds are enabled
                  debugPrint(
                      'Selected DateTime with seconds: ${result.toUtc().toIso8601String()}');
                  debugPrint(
                      'Seconds: ${result.second}, Microseconds: ${result.microsecond}');
                }
              },
              child: const Text('Test with Seconds (check microseconds)'),
            ),
            ElevatedButton(
              onPressed: () async {
                final List<DateTime>? dateTime =
                    await showQuickDateTimeRangePicker(context: context);

                // Use dateTime here
                debugPrint('dateTime: $dateTime');
              },
              child: const Text('Show DateTime Picker'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                final DateTime? dateOnly =
                    await showQuickDateOnlyPicker(context: context);

                if (dateOnly != null) {
                  debugPrint('Selected date-only: ${dateOnly.toIso8601String()}');
                } else {
                  debugPrint('Date-only picker dismissed');
                }
              },
              child: const Text('Show Date-Only Picker'),
            ),
          ],
        ),
      ),
    );
  }
}
