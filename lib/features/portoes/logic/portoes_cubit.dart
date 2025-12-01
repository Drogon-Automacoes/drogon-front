import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/portao_model.dart';
import '../data/portoes_service.dart';

abstract class PortoesState {}
class PortoesInitial extends PortoesState {}
class PortoesLoading extends PortoesState {}
class PortoesLoaded extends PortoesState {
  final List<PortaoModel> portoes;
  PortoesLoaded(this.portoes);
}
class PortoesError extends PortoesState {
  final String message;
  PortoesError(this.message);
}

class PortoesCubit extends Cubit<PortoesState> {
  final PortoesService service;

  PortoesCubit(this.service) : super(PortoesInitial());

  Future<void> carregarPortoes() async {
    emit(PortoesLoading());
    try {
      final lista = await service.getPortoes();
      emit(PortoesLoaded(lista));
    } catch (e) {
      emit(PortoesError("Não foi possível carregar os portões."));
    }
  }

  Future<void> alternarPortao(PortaoModel portao) async {
    try {
      final novaAcao = portao.isAberto ? "fechar" : "abrir";
      await service.acionarPortao(portao.id, novaAcao);
      
      carregarPortoes();
    } catch (e) {
      emit(PortoesError("Falha ao comunicar com o portão."));
      carregarPortoes();
    }
  }

  Future<void> adicionarPortao(String nome, String topico) async {
    emit(PortoesLoading());
    try {
      await service.cadastrarPortao(nome, topico);
      carregarPortoes();
    } catch (e) {
      emit(PortoesError(e.toString().replaceAll("Exception: ", "")));
      carregarPortoes();
    }
  }
}