import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quick_datetime_picker/src/bloc/quick_datetime_picker_bloc.dart';

void main() {
  group('QuickDatetimePickerBloc Tests', () {
    late QuickDatetimePickerBloc bloc;
    final initialDateTime = DateTime(2024, 6, 15, 10, 30, 45);
    final firstDate = DateTime(2024, 1, 1);
    final lastDate = DateTime(2024, 12, 31);

    setUp(() {
      bloc = QuickDatetimePickerBloc(
        initialDateTime: initialDateTime,
        firstDate: firstDate,
        lastDate: lastDate,
      );
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state is QuickDateTimeInitial with correct values', () {
      expect(bloc.state, isA<QuickDateTimeInitial>());
      expect(bloc.state.dateTime, equals(initialDateTime));
      expect(bloc.state.firstDate, equals(firstDate));
      expect(bloc.state.lastDate, equals(lastDate));
    });

    group('QuickUpdateDate Event', () {
      blocTest<QuickDatetimePickerBloc, QuickDatetimePickerState>(
        'emits QuickDateTimeChanged when QuickUpdateDate is added',
        build: () => bloc,
        act: (bloc) => bloc.add(QuickUpdateDate(dateTime: DateTime(2024, 7, 20))),
        wait: const Duration(milliseconds: 100),
        expect: () => [
          isA<QuickDateTimeChanged>().having(
            (state) => state.dateTime,
            'dateTime',
            DateTime(2024, 7, 20, 10, 30, 45),
          ),
        ],
      );

      blocTest<QuickDatetimePickerBloc, QuickDatetimePickerState>(
        'preserves time when updating date',
        build: () => bloc,
        act: (bloc) => bloc.add(QuickUpdateDate(dateTime: DateTime(2024, 12, 25))),
        wait: const Duration(milliseconds: 100),
        expect: () => [
          isA<QuickDateTimeChanged>().having(
            (state) => state.dateTime,
            'dateTime',
            DateTime(2024, 12, 25, 10, 30, 45),
          ),
        ],
      );
    });

    group('QuickUpdateHour Event', () {
      blocTest<QuickDatetimePickerBloc, QuickDatetimePickerState>(
        'emits QuickDateTimeChanged when QuickUpdateHour is added',
        build: () => bloc,
        act: (bloc) => bloc.add(const QuickUpdateHour(hour: 14)),
        wait: const Duration(milliseconds: 200),
        expect: () => [
          isA<QuickDateTimeChanged>().having(
            (state) => state.dateTime.hour,
            'hour',
            14,
          ),
        ],
      );

      blocTest<QuickDatetimePickerBloc, QuickDatetimePickerState>(
        'preserves existing hour when null is passed',
        build: () => bloc,
        act: (bloc) => bloc.add(const QuickUpdateHour(hour: null)),
        wait: const Duration(milliseconds: 200),
        expect: () => [
          isA<QuickDateTimeChanged>().having(
            (state) => state.dateTime.hour,
            'hour',
            10,
          ),
        ],
      );
    });

    group('QuickUpdateMinute Event', () {
      blocTest<QuickDatetimePickerBloc, QuickDatetimePickerState>(
        'emits QuickDateTimeChanged when QuickUpdateMinute is added',
        build: () => bloc,
        act: (bloc) => bloc.add(const QuickUpdateMinute(minute: 45)),
        wait: const Duration(milliseconds: 200),
        expect: () => [
          isA<QuickDateTimeChanged>().having(
            (state) => state.dateTime.minute,
            'minute',
            45,
          ),
        ],
      );

      blocTest<QuickDatetimePickerBloc, QuickDatetimePickerState>(
        'preserves existing minute when null is passed',
        build: () => bloc,
        act: (bloc) => bloc.add(const QuickUpdateMinute(minute: null)),
        wait: const Duration(milliseconds: 200),
        expect: () => [
          isA<QuickDateTimeChanged>().having(
            (state) => state.dateTime.minute,
            'minute',
            30,
          ),
        ],
      );
    });

    group('QuickUpdateSecond Event', () {
      blocTest<QuickDatetimePickerBloc, QuickDatetimePickerState>(
        'emits QuickDateTimeChanged when QuickUpdateSecond is added',
        build: () => bloc,
        act: (bloc) => bloc.add(const QuickUpdateSecond(second: 15)),
        wait: const Duration(milliseconds: 200),
        expect: () => [
          isA<QuickDateTimeChanged>().having(
            (state) => state.dateTime.second,
            'second',
            15,
          ),
        ],
      );

      blocTest<QuickDatetimePickerBloc, QuickDatetimePickerState>(
        'preserves existing second when null is passed',
        build: () => bloc,
        act: (bloc) => bloc.add(const QuickUpdateSecond(second: null)),
        wait: const Duration(milliseconds: 200),
        expect: () => [
          isA<QuickDateTimeChanged>().having(
            (state) => state.dateTime.second,
            'second',
            45,
          ),
        ],
      );
    });

    group('QuickUpdateAbbreviation Event', () {
      blocTest<QuickDatetimePickerBloc, QuickDatetimePickerState>(
        'adds 12 hours when switching to PM',
        build: () => bloc,
        act: (bloc) => bloc.add(const QuickUpdateAbbreviation(isPm: true)),
        wait: const Duration(milliseconds: 200),
        expect: () => [
          isA<QuickDateTimeChanged>().having(
            (state) => state.dateTime.hour,
            'hour',
            22, // 10 + 12
          ),
        ],
      );

      blocTest<QuickDatetimePickerBloc, QuickDatetimePickerState>(
        'subtracts 12 hours when switching to AM',
        build: () => QuickDatetimePickerBloc(
          initialDateTime: DateTime(2024, 6, 15, 14, 30, 45), // 2:30 PM
          firstDate: firstDate,
          lastDate: lastDate,
        ),
        act: (bloc) => bloc.add(const QuickUpdateAbbreviation(isPm: false)),
        wait: const Duration(milliseconds: 200),
        expect: () => [
          isA<QuickDateTimeChanged>().having(
            (state) => state.dateTime.hour,
            'hour',
            2, // 14 - 12
          ),
        ],
      );
    });

    group('State Properties', () {
      test('isFirstDate returns true when date matches firstDate', () {
        final testBloc = QuickDatetimePickerBloc(
          initialDateTime: DateTime(2024, 1, 1, 10, 30),
          firstDate: DateTime(2024, 1, 1, 0, 0),
          lastDate: DateTime(2024, 12, 31),
        );

        expect(testBloc.state.isFirstDate, isTrue);
        testBloc.close();
      });

      test('isLastDate returns true when date matches lastDate', () {
        final testBloc = QuickDatetimePickerBloc(
          initialDateTime: DateTime(2024, 12, 31, 10, 30),
          firstDate: DateTime(2024, 1, 1),
          lastDate: DateTime(2024, 12, 31, 23, 59),
        );

        expect(testBloc.state.isLastDate, isTrue);
        testBloc.close();
      });

      test('isValidTime returns true for valid time within bounds', () {
        final testBloc = QuickDatetimePickerBloc(
          initialDateTime: DateTime(2024, 6, 15, 10, 30),
          firstDate: DateTime(2024, 1, 1, 8, 0),
          lastDate: DateTime(2024, 12, 31, 18, 0),
        );

        expect(testBloc.state.isValidTime, isTrue);
        testBloc.close();
      });

      test(
          'isValidTime returns false when time is before firstDate time on same day',
          () {
        final testBloc = QuickDatetimePickerBloc(
          initialDateTime: DateTime(2024, 1, 1, 7, 30), // Before 8:00 AM
          firstDate: DateTime(2024, 1, 1, 8, 0),
          lastDate: DateTime(2024, 12, 31, 18, 0),
        );

        expect(testBloc.state.isValidTime, isFalse);
        testBloc.close();
      });

      test(
          'isValidTime returns false when time is after lastDate time on same day',
          () {
        final testBloc = QuickDatetimePickerBloc(
          initialDateTime: DateTime(2024, 12, 31, 19, 30), // After 6:00 PM
          firstDate: DateTime(2024, 1, 1, 8, 0),
          lastDate: DateTime(2024, 12, 31, 18, 0),
        );

        expect(testBloc.state.isValidTime, isFalse);
        testBloc.close();
      });
    });

    group('Debouncing', () {
      blocTest<QuickDatetimePickerBloc, QuickDatetimePickerState>(
        'debounces multiple rapid events',
        build: () => bloc,
        act: (bloc) {
          bloc.add(const QuickUpdateHour(hour: 11));
          bloc.add(const QuickUpdateHour(hour: 12));
          bloc.add(const QuickUpdateHour(hour: 13));
        },
        wait: const Duration(milliseconds: 300),
        expect: () => [
          isA<QuickDateTimeChanged>().having(
            (state) => state.dateTime.hour,
            'hour',
            13, // Only the last event should be processed
          ),
        ],
      );
    });
  });
}
