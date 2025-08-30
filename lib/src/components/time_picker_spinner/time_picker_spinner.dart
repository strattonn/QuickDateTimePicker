import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/quick_datetime_picker_bloc.dart';
import 'bloc/time_picker_spinner_bloc.dart';

class TimePickerSpinner extends StatelessWidget {
  final String amText;
  final String pmText;
  final bool isShowSeconds;
  final bool is24HourMode;
  final int minutesInterval;
  final int secondsInterval;
  final bool isForce2Digits;
  final int minuteIncrement; // New parameter for minute increment

  final double height;
  final double diameterRatio;
  final double itemExtent;
  final double squeeze;
  final double magnification;
  final bool looping;
  final Widget selectionOverlay;

  const TimePickerSpinner({
    super.key,
    this.height = 200,
    this.diameterRatio = 2,
    this.itemExtent = 40,
    this.squeeze = 1,
    this.magnification = 1.1,
    this.looping = false,
    this.selectionOverlay = const CupertinoPickerDefaultSelectionOverlay(),
    required this.amText,
    required this.pmText,
    required this.isShowSeconds,
    required this.is24HourMode,
    required this.minutesInterval,
    required this.secondsInterval,
    required this.isForce2Digits,
    this.minuteIncrement = 1, // Default to 1 minute increment
  });

  @override
  Widget build(BuildContext context) {
    final datetimeBloc = context.read<QuickDatetimePickerBloc>();
    final timePickerTheme = Theme.of(context).timePickerTheme;

    return BlocProvider(
      create: (context) => TimePickerSpinnerBloc(
        amText: amText,
        pmText: pmText,
        isShowSeconds: isShowSeconds,
        is24HourMode: is24HourMode,
        minutesInterval: minutesInterval,
        secondsInterval: secondsInterval,
        isForce2Digits: isForce2Digits,
        minuteIncrement: minuteIncrement, // Pass the new parameter
        firstDateTime: datetimeBloc.state.firstDate,
        lastDateTime: datetimeBloc.state.lastDate,
        initialDateTime: datetimeBloc.state.dateTime,
      ),
      child: BlocConsumer<TimePickerSpinnerBloc, TimePickerSpinnerState>(
        listenWhen: (previous, current) {
          if (previous is TimePickerSpinnerInitial &&
              current is TimePickerSpinnerLoaded) {
            return true;
          }

          return false;
        },
        listener: (context, state) {
          if (state is TimePickerSpinnerLoaded) {
            datetimeBloc.add(QuickUpdateMinute(
                minute: int.parse(state.minutes[state.initialMinuteIndex])));

            if (isShowSeconds) {
              datetimeBloc.add(QuickUpdateSecond(
                  second: int.parse(state.seconds[state.initialSecondIndex])));
            }
          }
        },
        builder: (context, state) {
          if (state is TimePickerSpinnerLoaded) {
            return SizedBox(
              height: height,
              child: Row(
                textDirection: TextDirection.ltr,
                children: [
                  /// Hours
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          mainAxisSpacing: 8.0,
                          crossAxisSpacing: 8.0,
                        ),
                        itemCount: state.hours.length,
                        itemBuilder: (context, index) {
                          String hour = state.hours[index];
                          final int hourValue = is24HourMode
                              ? int.parse(hour)
                              : (hour == '12' ? 0 : int.parse(hour)) +
                                  (datetimeBloc.state.dateTime.hour >= 12
                                      ? 12
                                      : 0);

                          final bool isDisabled =
                              _isHourDisabled(hourValue, datetimeBloc.state);
                          final bool isSelected =
                              datetimeBloc.state.dateTime.hour == hourValue;

                          if (isForce2Digits) {
                            hour = hour.padLeft(2, '0');
                          }

                          return ElevatedButton(
                            onPressed: isDisabled
                                ? null
                                : () {
                                    if (!is24HourMode) {
                                      final hourOffset = state
                                                  .abbreviationController
                                                  .hasClients &&
                                              state.abbreviationController
                                                      .selectedItem ==
                                                  1
                                          ? 12
                                          : 0;
                                      final selectedHourValue =
                                          index + hourOffset;
                                      datetimeBloc.add(QuickUpdateHour(
                                          hour: selectedHourValue));
                                    } else {
                                      final selectedHourValue =
                                          int.parse(state.hours[index]);
                                      datetimeBloc.add(QuickUpdateHour(
                                          hour: selectedHourValue));
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.surface,
                              foregroundColor: isSelected
                                  ? Theme.of(context).colorScheme.onPrimary
                                  : (isDisabled
                                      ? Colors.grey.withValues(alpha: 0.5)
                                      : Theme.of(context)
                                          .colorScheme
                                          .onSurface),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            child: Text(
                              hour,
                              style: timePickerTheme.hourMinuteTextStyle
                                      ?.copyWith(
                                    color: isSelected
                                        ? Theme.of(context)
                                            .colorScheme
                                            .onPrimary
                                        : (isDisabled
                                            ? Colors.grey.withValues(alpha: 0.5)
                                            : null),
                                  ) ??
                                  TextStyle(
                                    color: isSelected
                                        ? Theme.of(context)
                                            .colorScheme
                                            .onPrimary
                                        : (isDisabled
                                            ? Colors.grey.withValues(alpha: 0.5)
                                            : null),
                                  ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  /// Minutes
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      child: GridView.builder(
                        gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: _minuteColumns(minuteIncrement),
                          mainAxisSpacing: 8.0,
                          crossAxisSpacing: 8.0,
                        ),
                        itemCount: state.minutes.length,
                        itemBuilder: (context, index) {
                          String minute = state.minutes[index];
                          final int minuteValue = int.parse(minute);
                          final bool isDisabled = _isMinuteDisabled(
                              minuteValue, datetimeBloc.state);
                          final bool isSelected =
                              datetimeBloc.state.dateTime.minute == minuteValue;

                          if (isForce2Digits) {
                            minute = minute.padLeft(2, '0');
                          }

                          return ElevatedButton(
                            onPressed: isDisabled
                                ? null
                                : () {
                                    final selectedMinuteValue =
                                        int.parse(state.minutes[index]);
                                    datetimeBloc.add(QuickUpdateMinute(
                                        minute: selectedMinuteValue));
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.surface,
                              foregroundColor: isSelected
                                  ? Theme.of(context).colorScheme.onPrimary
                                  : (isDisabled
                                      ? Colors.grey.withValues(alpha: 0.5)
                                      : Theme.of(context)
                                          .colorScheme
                                          .onSurface),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4.0,
                                vertical: 4.0,
                              ),
                              minimumSize: const Size(40, 40),
                            ),
                            child: Text(
                              minute,
                              style: timePickerTheme.hourMinuteTextStyle
                                      ?.copyWith(
                                    color: isSelected
                                        ? Theme.of(context)
                                            .colorScheme
                                            .onPrimary
                                        : (isDisabled
                                            ? Colors.grey.withValues(alpha: 0.5)
                                            : null),
                                  ) ??
                                  TextStyle(
                                    color: isSelected
                                        ? Theme.of(context)
                                            .colorScheme
                                            .onPrimary
                                        : (isDisabled
                                            ? Colors.grey.withValues(alpha: 0.5)
                                            : null),
                                  ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.visible,
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  /// Seconds
                  if (isShowSeconds)
                    Expanded(
                      child: CupertinoPicker(
                        scrollController: FixedExtentScrollController(
                          initialItem: state.initialSecondIndex,
                        ),
                        diameterRatio: diameterRatio,
                        itemExtent: itemExtent,
                        squeeze: squeeze,
                        magnification: magnification,
                        looping: looping,
                        selectionOverlay: selectionOverlay,
                        onSelectedItemChanged: (index) {
                          final secondValue = int.parse(state.seconds[index]);
                          datetimeBloc
                              .add(QuickUpdateSecond(second: secondValue));
                        },
                        children: List.generate(
                          state.seconds.length,
                          (index) {
                            String second = state.seconds[index];
                            final int secondValue = int.parse(second);
                            final bool isDisabled = _isSecondDisabled(
                                secondValue, datetimeBloc.state);

                            if (isForce2Digits) {
                              second = second.padLeft(2, '0');
                            }

                            return Center(
                                child: Text(second,
                                    style: timePickerTheme.hourMinuteTextStyle
                                            ?.copyWith(
                                          color: isDisabled
                                              ? Colors.grey
                                                  .withValues(alpha: 0.5)
                                              : null,
                                        ) ??
                                        TextStyle(
                                          color: isDisabled
                                              ? Colors.grey
                                                  .withValues(alpha: 0.5)
                                              : null,
                                        )));
                          },
                        ),
                      ),
                    ),

                  /// AM/PM
                  if (!is24HourMode)
                    Expanded(
                      child: CupertinoPicker.builder(
                        scrollController: state.abbreviationController,
                        diameterRatio: diameterRatio,
                        itemExtent: itemExtent,
                        squeeze: squeeze,
                        magnification: magnification,
                        selectionOverlay: selectionOverlay,
                        onSelectedItemChanged: (index) {
                          if (index == 0) {
                            datetimeBloc.add(
                                const QuickUpdateAbbreviation(isPm: false));
                          } else {
                            datetimeBloc
                                .add(const QuickUpdateAbbreviation(isPm: true));
                          }
                        },
                        childCount: state.abbreviations.length,
                        itemBuilder: (context, index) {
                          return Center(
                              child: Text(state.abbreviations[index],
                                  style: timePickerTheme.hourMinuteTextStyle));
                        },
                      ),
                    ),
                ],
              ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  bool _isHourDisabled(int hour, QuickDatetimePickerState state) {
    // For hour validation, only compare at the hour level
    if (_isSameDate(state.dateTime, state.firstDate)) {
      if (hour < state.firstDate.hour) {
        return true;
      }
    }

    if (_isSameDate(state.dateTime, state.lastDate)) {
      if (hour > state.lastDate.hour) {
        return true;
      }
    }

    return false;
  }

  bool _isMinuteDisabled(int minute, QuickDatetimePickerState state) {
    // For minute validation, compare at the minute level when on the exact hour
    if (_isSameDate(state.dateTime, state.firstDate) &&
        state.dateTime.hour == state.firstDate.hour) {
      if (minute < state.firstDate.minute) {
        return true;
      }
    }

    if (_isSameDate(state.dateTime, state.lastDate) &&
        state.dateTime.hour == state.lastDate.hour) {
      if (minute > state.lastDate.minute) {
        return true;
      }
    }

    return false;
  }

  bool _isSecondDisabled(int second, QuickDatetimePickerState state) {
    // For second validation, compare at the second level when on the exact hour and minute
    if (_isSameDate(state.dateTime, state.firstDate) &&
        state.dateTime.hour == state.firstDate.hour &&
        state.dateTime.minute == state.firstDate.minute) {
      if (second < state.firstDate.second) {
        return true;
      }
    }

    if (_isSameDate(state.dateTime, state.lastDate) &&
        state.dateTime.hour == state.lastDate.hour &&
        state.dateTime.minute == state.lastDate.minute) {
      if (second > state.lastDate.second) {
        return true;
      }
    }

    return false;
  }

  bool _isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  int _minuteColumns(int minuteIncrement) {
    switch (minuteIncrement) {
      case 1:
        return 6; // 0, 10, 20, 30, 40, 50
      case 2:
        return 6; // 0, 20, 40
      case 3:
        return 5; // 0, 15, 30, 45
      case 4:
        return 5; // 0, 20, 40
      case 5:
        return 4; // 0, 15, 30, 45
      case 6:
        return 4; // 0, 30
      case 10:
        return 3; // 0, 30
      case 12:
        return 3; // 0, 30
      case 15:
        return 2; // 0, 30
      case 20:
        return 2; // 0, 30
      case 30:
      default:
        return 1; // Only one column needed for full hour increments
    }

  }
}
