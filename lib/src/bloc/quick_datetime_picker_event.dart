part of 'quick_datetime_picker_bloc.dart';

sealed class QuickDatetimePickerEvent extends Equatable {
  const QuickDatetimePickerEvent();

  @override
  List<Object> get props => [];
}

final class QuickUpdateDate extends QuickDatetimePickerEvent {
  final DateTime dateTime;

  const QuickUpdateDate({required this.dateTime});

  @override
  List<Object> get props => [dateTime];
}

final class QuickUpdateHour extends QuickDatetimePickerEvent {
  final int? hour;

  const QuickUpdateHour({required this.hour});
}

final class QuickUpdateMinute extends QuickDatetimePickerEvent {
  final int? minute;

  const QuickUpdateMinute({required this.minute});
}

final class QuickUpdateSecond extends QuickDatetimePickerEvent {
  final int? second;

  const QuickUpdateSecond({required this.second});
}

final class QuickUpdateAbbreviation extends QuickDatetimePickerEvent {
  final bool isPm;

  const QuickUpdateAbbreviation({required this.isPm});
}
