import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';

part 'quick_datetime_picker_event.dart';
part 'quick_datetime_picker_state.dart';

class QuickDatetimePickerBloc
    extends Bloc<QuickDatetimePickerEvent, QuickDatetimePickerState> {
  QuickDatetimePickerBloc({
    required DateTime initialDateTime,
    required DateTime firstDate,
    required DateTime lastDate,
  }) : super(QuickDateTimeInitial(
          dateTime: initialDateTime,
          firstDate: firstDate,
          lastDate: lastDate,
        )) {
    on<QuickUpdateDate>(
      (event, emit) => _updateDate(event, emit),
      transformer: debounce(
        const Duration(milliseconds: 50),
      ),
    );
    on<QuickUpdateHour>(
      (event, emit) => _updateHour(event, emit),
      transformer: debounce(
        const Duration(milliseconds: 150),
      ),
    );
    on<QuickUpdateMinute>(
      (event, emit) => _updateMinute(event, emit),
      transformer: debounce(
        const Duration(milliseconds: 150),
      ),
    );
    on<QuickUpdateSecond>(
      (event, emit) => _updateSecond(event, emit),
      transformer: debounce(
        const Duration(milliseconds: 150),
      ),
    );

    on<QuickUpdateAbbreviation>(
      (event, emit) => _updateAbbreviation(event, emit),
      transformer: debounce(
        const Duration(milliseconds: 150),
      ),
    );
  }

  void _updateDate(QuickUpdateDate event, Emitter<QuickDatetimePickerState> emit) {
    emit(
      QuickDateTimeChanged(
        dateTime: state.dateTime.copyWith(
          year: event.dateTime.year,
          month: event.dateTime.month,
          day: event.dateTime.day,
        ),
        firstDate: state.firstDate,
        lastDate: state.lastDate,
      ),
    );
  }

  void _updateHour(QuickUpdateHour event, Emitter<QuickDatetimePickerState> emit) {
    emit(
      QuickDateTimeChanged(
        dateTime: state.dateTime.copyWith(
          hour: event.hour ?? state.dateTime.hour,
        ),
        firstDate: state.firstDate,
        lastDate: state.lastDate,
      ),
    );
  }

  void _updateMinute(
      QuickUpdateMinute event, Emitter<QuickDatetimePickerState> emit) {
    emit(
      QuickDateTimeChanged(
        dateTime: state.dateTime.copyWith(
          minute: event.minute ?? state.dateTime.minute,
        ),
        firstDate: state.firstDate,
        lastDate: state.lastDate,
      ),
    );
  }

  void _updateSecond(
      QuickUpdateSecond event, Emitter<QuickDatetimePickerState> emit) {
    emit(
      QuickDateTimeChanged(
        dateTime: state.dateTime.copyWith(
          second: event.second ?? state.dateTime.second,
        ),
        firstDate: state.firstDate,
        lastDate: state.lastDate,
      ),
    );
  }

  void _updateAbbreviation(
      QuickUpdateAbbreviation event, Emitter<QuickDatetimePickerState> emit) {
    final updatedHour =
        event.isPm ? state.dateTime.hour + 12 : state.dateTime.hour - 12;

    final dateTime = DateTime(
      state.dateTime.year,
      state.dateTime.month,
      state.dateTime.day,
      updatedHour,
      state.dateTime.minute,
      state.dateTime.second,
    );

    emit(
      QuickDateTimeChanged(
        dateTime: dateTime,
        firstDate: state.firstDate,
        lastDate: state.lastDate,
      ),
    );
  }

  EventTransformer<Event> debounce<Event>(Duration duration) {
    return (events, mapper) =>
        events.debounceTime(duration).asyncExpand(mapper);
  }
}
