import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../injection_container.dart';
import '../logic/logs_cubit.dart';

class LogsScreen extends StatelessWidget {
  const LogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Histórico de Acessos"),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<LogsCubit>().carregarLogs(),
          )
        ],
      ),
      body: BlocProvider(
        create: (_) => sl<LogsCubit>()..carregarLogs(),
        child: BlocBuilder<LogsCubit, LogsState>(
          builder: (context, state) {
            if (state is LogsLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is LogsError) {
              return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
            } else if (state is LogsLoaded) {
              if (state.logs.isEmpty) return const Center(child: Text("Sem histórico."));
              
              return ListView.separated(
                itemCount: state.logs.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (ctx, index) {
                  final log = state.logs[index];
                  final dataFormatada = log.dataHora.split('.')[0].replaceAll('T', ' ');

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: log.sucesso ? Colors.green[100] : Colors.red[100],
                      child: Icon(
                        log.sucesso ? Icons.check : Icons.block,
                        color: log.sucesso ? Colors.green : Colors.red,
                      ),
                    ),
                    title: Text(
                      log.usuarioNome, 
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("${log.acao.toUpperCase()} - $dataFormatada"),
                        if (log.observacao != null)
                          Text("Obs: ${log.observacao}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  );
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}