import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/log_model.dart';
import '../data/logs_service.dart';

abstract class LogsState {}
class LogsInitial extends LogsState {}
class LogsLoading extends LogsState {}
class LogsLoaded extends LogsState {
  final List<LogModel> logs;
  LogsLoaded(this.logs);
}
class LogsError extends LogsState {
  final String message;
  LogsError(this.message);
}

class LogsCubit extends Cubit<LogsState> {
  final LogsService service;

  LogsCubit(this.service) : super(LogsInitial());

  Future<void> carregarLogs() async {
    emit(LogsLoading());
    try {
      final logs = await service.getLogs();
      emit(LogsLoaded(logs));
    } catch (e) {
      emit(LogsError("Acesso Negado ou Falha na conexão."));
    }
  }
}