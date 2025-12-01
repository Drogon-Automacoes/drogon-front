import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sistema_portoes_app/features/auth/ui/login_screen.dart';
import '../../../injection_container.dart';
import '../logic/portoes_cubit.dart';
import '../data/portao_model.dart';

class PortoesScreen extends StatefulWidget {
  const PortoesScreen({super.key});

  @override
  State<PortoesScreen> createState() => _PortoesScreenState();
}

class _PortoesScreenState extends State<PortoesScreen> {
  String _tituloCondominio = "Controle de Acesso";

  @override
  void initState() {
    super.initState();
    _carregarNomeCondominio();
  }

  void _carregarNomeCondominio() async {
    final prefs = await SharedPreferences.getInstance();
    final nome = prefs.getString('condominio_nome');
    if (nome != null) {
      setState(() {
        _tituloCondominio = nome;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<PortoesCubit>()..carregarPortoes(),
      child: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              title: Column(
                children: [
                  const Text("Meus Portões", style: TextStyle(fontSize: 16)),
                  Text(
                    _tituloCondominio,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () =>
                      context.read<PortoesCubit>().carregarPortoes(),
                ),
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.remove('access_token');

                    if (context.mounted) {
                      Navigator.of(
                        context,
                        rootNavigator: true,
                      ).pushReplacement(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    }
                  },
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () => _mostrarDialogCadastro(context),
              label: const Text("Novo Portão"),
              icon: const Icon(Icons.add),
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
            ),
            body: BlocConsumer<PortoesCubit, PortoesState>(
              listener: (context, state) {
                if (state is PortoesError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is PortoesLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is PortoesLoaded) {
                  if (state.portoes.isEmpty) {
                    return _buildEmptyState();
                  }
                  return RefreshIndicator(
                    onRefresh: () =>
                        context.read<PortoesCubit>().carregarPortoes(),
                    child: ListView.separated(
                      padding: const EdgeInsets.all(20),
                      itemCount: state.portoes.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (ctx, index) =>
                          _PortaoCard(portao: state.portoes[index]),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.sensor_door_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            "Nenhum portão cadastrado",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogCadastro(BuildContext context) {
    final cubit = context.read<PortoesCubit>();
    final nomeController = TextEditingController();
    final topicoController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Cadastrar Portão"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nomeController,
              decoration: const InputDecoration(
                labelText: "Nome (ex: Garagem B)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: topicoController,
              decoration: const InputDecoration(
                labelText: "Tópico MQTT (ex: blocoB/portao)",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () {
              if (nomeController.text.isNotEmpty &&
                  topicoController.text.isNotEmpty) {
                cubit.adicionarPortao(
                  nomeController.text,
                  topicoController.text,
                );
                Navigator.pop(ctx);
              }
            },
            child: const Text("Salvar"),
          ),
        ],
      ),
    );
  }
}

class _PortaoCard extends StatelessWidget {
  final PortaoModel portao;

  const _PortaoCard({required this.portao});

  @override
  Widget build(BuildContext context) {
    final corStatus = portao.isAberto ? Colors.green : Colors.redAccent;
    final textoStatus = portao.isAberto ? "ABERTO" : "FECHADO";
    final iconeStatus = portao.isAberto ? Icons.lock_open : Icons.lock;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      portao.nome,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "ID: ${portao.topicoMqtt}",
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: corStatus.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: corStatus.withOpacity(0.5)),
                  ),
                  child: Row(
                    children: [
                      Icon(iconeStatus, size: 16, color: corStatus),
                      const SizedBox(width: 4),
                      Text(
                        textoStatus,
                        style: TextStyle(
                          color: corStatus,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: portao.emManutencao
                    ? null
                    : () => context.read<PortoesCubit>().alternarPortao(portao),
                style: ElevatedButton.styleFrom(
                  backgroundColor: portao.isAberto
                      ? Colors.grey[800]
                      : Colors.blueAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: portao.emManutencao
                    ? const Text("EM MANUTENÇÃO")
                    : Text(portao.isAberto ? "FECHAR PORTÃO" : "ABRIR PORTÃO"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
