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
                            // Compute minute columns once per build for performance
                            final minuteColumns = _minuteColumns(minutesInterval);
                            return LayoutBuilder(
                              builder: (context, constraints) {
                                // Columns for hours grid (responsive)
                                final bool isMobile = MediaQuery.of(context).size.shortestSide < 600;
                                final int hourColumns = _hourColumns(constraints.maxWidth, isMobile);

                                // Treat small devices as mobile (already computed above)

                                // Spacing/padding constants reused for both sections
                                // Tune mobile paddings so grids sit closer to the top, while keeping numbers visually smaller.
                                final double hoursPadLR = isMobile ? 16.0 : 4.0;
                                final double hoursPadTop = isMobile ? 0.0 : 4.0;
                                final double hoursPadBottom = isMobile ? 16.0 : 4.0;
                                final double minutesPadLR = isMobile ? 16.0 : 4.0;
                                final double minutesPadTop = isMobile ? 0.0 : 4.0;
                                final double minutesPadBottom = isMobile ? 16.0 : 4.0;

                                // Totals used in layout math below (for wide layout only)
                                final double hoursPaddingH = hoursPadLR * 2;
                                final double minutesPaddingH = minutesPadLR * 2;
                                const double hoursSpacing = 3.0; // Grid mainAxisSpacing for hours
                                const double minutesSpacing = 4.0; // Grid mainAxisSpacing for minutes

                                const double secondsWidth = 80;
                                const double ampmWidth = 70;
                                // final double secondsHeight = height; // Not needed since we're not pre-calculating heights

                                // Compute available width for tile columns by removing fixed columns
                                final double otherFixedWidth =
                                    (isShowSeconds ? secondsWidth : 0) +
                                        (!is24HourMode ? ampmWidth : 0) +
                                        16; // small allowance for extra padding

                                // Total gaps and paddings consumed by both grids
                                final double totalGapsAndPadding =
                                    // hours gaps + hours padding
                                    ((hourColumns > 1 ? (hourColumns - 1) * hoursSpacing : 0) + hoursPaddingH) +
                                        // minutes gaps + minutes padding
                                        ((minuteColumns > 1 ? (minuteColumns - 1) * minutesSpacing : 0) + minutesPaddingH);

                                // Shared tile size (wide layout) — divide remaining width across all columns
                                final double usableForTiles =
                                    (constraints.maxWidth - otherFixedWidth) - totalGapsAndPadding;
                                final double tileSizeForWide =
                                    usableForTiles > 0
                                        ? usableForTiles / (hourColumns + minuteColumns)
                                        : 45.0; // fallback reasonable size

                                // Section widths computed from the shared tile size (include gaps + padding)
                                final double hoursWidth =
                                    hourColumns * tileSizeForWide +
                                        (hourColumns > 1 ? (hourColumns - 1) * hoursSpacing : 0) +
                                        hoursPaddingH;

                                final double minutesWidth =
                                    minuteColumns * tileSizeForWide +
                                        (minuteColumns > 1 ? (minuteColumns - 1) * minutesSpacing : 0) +
                                        minutesPaddingH;

                                final double requiredHorizontalWidth =
                                    hoursWidth + minutesWidth + otherFixedWidth;

                                final bool isNarrow = isMobile || constraints.maxWidth < requiredHorizontalWidth;

                                // Helpers to build each section; expanded=true uses full width
                                Widget buildHours({required bool expanded}) {
                                  return SizedBox(
                                    width: expanded ? constraints.maxWidth : hoursWidth,
                                    height: expanded ? null : height,
                                    child: Container(
                                      padding: EdgeInsets.fromLTRB(
                                        hoursPadLR,
                                        expanded && isMobile ? hoursPadTop : 4.0,
                                        hoursPadLR,
                                        expanded && isMobile ? hoursPadBottom : 4.0,
                                      ),
                                      alignment: Alignment.topCenter,
                                      child: GridView.builder(
                                        gridDelegate:
                                            SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: hourColumns,
                                          mainAxisSpacing: 3.0,
                                          crossAxisSpacing: 3.0,
                                          childAspectRatio: 1.0,
                                        ),
                                        physics: expanded ? const NeverScrollableScrollPhysics() : null,
                                        shrinkWrap: expanded,
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
                                                      final hourOffset =
                                                          (datetimeBloc.state.dateTime.hour >= 12)
                                                              ? 12
                                                              : 0;
                                                      final selectedHourValue = index + hourOffset;
                                                      datetimeBloc
                                                          .add(QuickUpdateHour(hour: selectedHourValue));
                                                    } else {
                                                      final selectedHourValue =
                                                          int.parse(state.hours[index]);
                                                      datetimeBloc
                                                          .add(QuickUpdateHour(hour: selectedHourValue));
                                                    }
                                                  },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: isSelected
                                                  ? Theme.of(context).colorScheme.primary
                                                  : Theme.of(context).colorScheme.surface,
                                              foregroundColor: isSelected
                                                  ? Theme.of(context).colorScheme.onPrimary
                                                  : (isDisabled
                                                      ? Colors.grey.withOpacity(0.5)
                                                      : Theme.of(context).colorScheme.onSurface),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8.0),
                                              ),
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 4.0,
                                                vertical: 4.0,
                                              ),
                                              minimumSize: const Size(40, 40),
                                            ),
                                            child: FittedBox(
                                              fit: BoxFit.scaleDown,
                                              child: Text(
                                                hour,
                                                style: timePickerTheme.hourMinuteTextStyle,
                                                textAlign: TextAlign.center,
                                                maxLines: 1,
                                                overflow: TextOverflow.visible,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  );
                                }

                                Widget buildMinutes({required bool expanded}) {
                                  return SizedBox(
                                    width: expanded ? constraints.maxWidth : minutesWidth,
                                    height: expanded ? null : height,
                                    child: Container(
                                      // Match hours' container padding so tops align
                                      padding: EdgeInsets.fromLTRB(
                                        minutesPadLR,
                                        expanded && isMobile ? minutesPadTop : 4.0,
                                        minutesPadLR,
                                        expanded && isMobile ? minutesPadBottom : 4.0,
                                      ),
                                      child: GridView.builder(
                                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: minuteColumns,
                                          mainAxisSpacing: 4.0,
                                          crossAxisSpacing: 4.0,
                                          childAspectRatio: 1.0,
                                        ),
                                        // In stacked layout, disable internal scrolling and size to content
                                        physics: expanded ? const NeverScrollableScrollPhysics() : null,
                                        shrinkWrap: expanded,
                                        itemCount: state.minutes.length,
                                        itemBuilder: (context, index) {
                                          String minute = state.minutes[index];
                                          final int minuteValue = int.parse(minute);
                                          final bool isDisabled =
                                              _isMinuteDisabled(minuteValue, datetimeBloc.state);
                                          final bool isSelected =
                                              datetimeBloc.state.dateTime.minute == minuteValue;

                                          if (isForce2Digits) {
                                            minute = minute.padLeft(2, '0');
                                          }

                                          return ElevatedButton(
                                            onPressed: isDisabled
                                                ? null
                                                : () {
                                                    final selectedMinuteValue = int.parse(state.minutes[index]);
                                                    datetimeBloc.add(QuickUpdateMinute(minute: selectedMinuteValue));
                                                  },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: isSelected
                                                  ? Theme.of(context).colorScheme.primary
                                                  : Theme.of(context).colorScheme.surface,
                                              foregroundColor: isSelected
                                                  ? Theme.of(context).colorScheme.onPrimary
                                                  : (isDisabled
                                                      ? Colors.grey.withOpacity(0.5)
                                                      : Theme.of(context).colorScheme.onSurface),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8.0),
                                              ),
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 4.0,
                                                vertical: 4.0,
                                              ),
                                              minimumSize: const Size(40, 40),
                                            ),
                                            child: FittedBox(
                                              fit: BoxFit.scaleDown,
                                              child: Text(
                                                minute,
                                                style: timePickerTheme.hourMinuteTextStyle,
                                                textAlign: TextAlign.center,
                                                maxLines: 1,
                                                overflow: TextOverflow.visible,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  );
                                }

                                Widget buildSeconds({required bool expanded}) {
                                  return SizedBox(
                                    width: expanded ? constraints.maxWidth : secondsWidth,
                                    height: height,
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
                                        datetimeBloc.add(QuickUpdateSecond(second: secondValue));
                                      },
                                      children: List.generate(
                                        state.seconds.length,
                                        (index) {
                                          String second = state.seconds[index];
                                          final int secondValue = int.parse(second);
                                          final bool isDisabled = _isSecondDisabled(secondValue, datetimeBloc.state);

                                          if (isForce2Digits) {
                                            second = second.padLeft(2, '0');
                                          }

                                          return Center(
                                            child: FittedBox(
                                              fit: BoxFit.scaleDown,
                                              child: Text(
                                                second,
                                                style: timePickerTheme.hourMinuteTextStyle?.copyWith(
                                                      color: isDisabled ? Colors.grey.withOpacity(0.5) : null,
                                                    ) ??
                                                    TextStyle(
                                                      color: isDisabled ? Colors.grey.withOpacity(0.5) : null,
                                                    ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  );
                                }

                                Widget buildAmPm({required bool expanded}) {
                                  final bool isPm = datetimeBloc.state.dateTime.hour >= 12;
                                  if (expanded) {
                                    // Stacked/narrow: render a single-row of two buttons with mobile padding
                                    return SizedBox(
                                      width: constraints.maxWidth,
                                      height: 52,
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: isMobile ? 12.0 : 0.0,
                                          vertical: isMobile ? 8.0 : 0.0,
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  datetimeBloc.add(const QuickUpdateAbbreviation(isPm: false));
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: !isPm ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surface,
                                                  foregroundColor: !isPm ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurface,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(8.0),
                                                  ),
                                                  padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 6.0),
                                                  minimumSize: const Size(34, 34),
                                                ),
                                                child: FittedBox(
                                                  fit: BoxFit.scaleDown,
                                                  child: Text(
                                                    state.abbreviations[0],
                                                    style: timePickerTheme.hourMinuteTextStyle,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  datetimeBloc.add(const QuickUpdateAbbreviation(isPm: true));
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: isPm ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surface,
                                                  foregroundColor: isPm ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurface,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(8.0),
                                                  ),
                                                  padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 6.0),
                                                  minimumSize: const Size(34, 34),
                                                ),
                                                child: FittedBox(
                                                  fit: BoxFit.scaleDown,
                                                  child: Text(
                                                    state.abbreviations[1],
                                                    style: timePickerTheme.hourMinuteTextStyle,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }

                                  // Wide: render two buttons stacked to fit the time column
                                  return SizedBox(
                                    width: ampmWidth,
                                    height: height,
                                    child: Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          SizedBox(
                                            height: 34,
                                            child: ElevatedButton(
                                              onPressed: () {
                                                datetimeBloc.add(const QuickUpdateAbbreviation(isPm: false));
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: !isPm ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surface,
                                                foregroundColor: !isPm ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurface,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(8.0),
                                                ),
                                                padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 6.0),
                                                minimumSize: const Size(34, 34),
                                              ),
                                              child: FittedBox(
                                                fit: BoxFit.scaleDown,
                                                child: Text(
                                                  state.abbreviations[0],
                                                  style: timePickerTheme.hourMinuteTextStyle,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          SizedBox(
                                            height: 34,
                                            child: ElevatedButton(
                                              onPressed: () {
                                                datetimeBloc.add(const QuickUpdateAbbreviation(isPm: true));
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: isPm ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surface,
                                                foregroundColor: isPm ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurface,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(8.0),
                                                ),
                                                padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 6.0),
                                                minimumSize: const Size(34, 34),
                                              ),
                                              child: FittedBox(
                                                fit: BoxFit.scaleDown,
                                                child: Text(
                                                  state.abbreviations[1],
                                                  style: timePickerTheme.hourMinuteTextStyle,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }

                                if (!isNarrow) {
                                  return SizedBox(
                                    height: height,
                                    child: Row(
                                      textDirection: TextDirection.ltr,
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        buildHours(expanded: false),
                                        buildMinutes(expanded: false),
                                        if (isShowSeconds) buildSeconds(expanded: false),
                                        if (!is24HourMode) buildAmPm(expanded: false),
                                      ],
                                    ),
                                  );
                                }

                                // Narrow/mobile: stack vertically. On mobile prefer hours->minutes->AMPM for ergonomics.
                                // Let the Column size itself naturally since grids are shrink-wrapping
                                // double totalHeight = hoursStackedHeight + minutesStackedHeight;
                                // if (!is24HourMode) totalHeight += 52; // compact AM/PM row height
                                // if (isShowSeconds) totalHeight += secondsHeight;

                                // Build child list with mobile-optimized order when on small devices
                                final List<Widget> stackedChildren = [];
                                stackedChildren.add(buildHours(expanded: true));
                                if (isMobile) {
                                  stackedChildren.add(buildMinutes(expanded: true));
                                  if (!is24HourMode) stackedChildren.add(buildAmPm(expanded: true));
                                } else {
                                  if (!is24HourMode) stackedChildren.add(buildAmPm(expanded: true));
                                  stackedChildren.add(buildMinutes(expanded: true));
                                }
                                if (isShowSeconds) stackedChildren.add(buildSeconds(expanded: true));

                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: stackedChildren,
                                );
                              },
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

                  int _minuteColumns(int minutesInterval) {
                    switch (minutesInterval) {
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
                        return 4; // 0, 30
                      case 12:
                        return 4; // 0, 30
                      case 15:
                        return 4; // 0, 30
                      case 20:
                        return 3; // 0, 30
                      case 30:
                        return 2;
                      default:
                        if (minutesInterval > 6 && minutesInterval < 15) {
                          return 4; // 0, 15, 30, 45
                        } else if (minutesInterval > 15 && minutesInterval < 30) {
                          return 2; // 0, 30
                        } else if (minutesInterval > 30 && minutesInterval < 60) {
                          return 1; // Only one column needed for full hour increments
                        }
                        return 1; // Only one column needed for full hour increments
                    }
                  }

                  // Decide hour grid columns based on layout width and device type.
                  // On mobile, prefer 6 columns (12 hours -> 2 rows). Otherwise default to 4.
                  int _hourColumns(double maxWidth, bool isMobile) {
                    if (isMobile) {
                      return 6;
                    }
                    return 4;
                  }
                }
