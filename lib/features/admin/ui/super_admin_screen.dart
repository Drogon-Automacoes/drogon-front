import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/network/api_client.dart';
import '../../auth/ui/login_screen.dart';

class SuperAdminScreen extends StatefulWidget {
  const SuperAdminScreen({super.key});

  @override
  State<SuperAdminScreen> createState() => _SuperAdminScreenState();
}

class _SuperAdminScreenState extends State<SuperAdminScreen> {
  int _selectedIndex = 0;
  final _client = GetIt.I<ApiClient>();
  
  // Dados locais
  List<dynamic> _condominios = [];
  List<dynamic> _logs = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    setState(() => _isLoading = true);
    try {
      if (_selectedIndex == 0) {
        final response = await _client.dio.get('/condominios/');
        setState(() => _condominios = response.data);
      } else {
        final response = await _client.dio.get('/logs/');
        setState(() => _logs = response.data);
      }
    } catch (e) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Erro ao carregar dados")));
    } finally {
      if(mounted) setState(() => _isLoading = false);
    }
  }

  // --- AÇÕES ---

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    if (mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

  void _criarCondominio() {
    final nomeCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Novo Condomínio"),
        content: TextField(controller: nomeCtrl, decoration: const InputDecoration(labelText: "Nome")),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () async {
              try {
                await _client.dio.post('/condominios/', data: {
                  "nome": nomeCtrl.text,
                  "endereco": "Rua Exemplo",
                  "cnpj": "000"
                });
                Navigator.pop(ctx);
                _carregarDados(); // Atualiza lista
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Erro ao criar")));
              }
            },
            child: const Text("Criar"),
          )
        ],
      ),
    );
  }

  void _criarSindico(String condominioId) {
    final nomeCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final senhaCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Novo Síndico"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nomeCtrl, decoration: const InputDecoration(labelText: "Nome")),
            TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: "Email")),
            TextField(controller: senhaCtrl, decoration: const InputDecoration(labelText: "Senha")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () async {
              try {
                await _client.dio.post('/usuarios/', data: {
                  "nome": nomeCtrl.text,
                  "email": emailCtrl.text,
                  "senha": senhaCtrl.text,
                  "tipo": "admin",
                  "condominio_id": condominioId
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Síndico criado com sucesso!"), backgroundColor: Colors.green,));
              } catch (e) {
                print(e);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Erro ao criar síndico (Email já existe?)"), backgroundColor: Colors.red,));
              }
            },
            child: const Text("Cadastrar"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedIndex == 0 ? "Gerenciar Clientes" : "Logs do Sistema"),
        backgroundColor: Colors.purple[800],
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _carregarDados),
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator()) 
          : _selectedIndex == 0 ? _buildListaCondominios() : _buildListaLogs(),
      
      floatingActionButton: _selectedIndex == 0 
          ? FloatingActionButton(onPressed: _criarCondominio, backgroundColor: Colors.purple, child: const Icon(Icons.add, color: Colors.white)) 
          : null,
      
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (idx) {
          setState(() => _selectedIndex = idx);
          _carregarDados();
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.business), label: "Condomínios"),
          NavigationDestination(icon: Icon(Icons.list), label: "Logs Globais"),
        ],
      ),
    );
  }

  Widget _buildListaCondominios() {
    if (_condominios.isEmpty) return const Center(child: Text("Nenhum condomínio."));
    return ListView.builder(
      itemCount: _condominios.length,
      itemBuilder: (ctx, i) {
        final condo = _condominios[i];
        return Card(
          margin: const EdgeInsets.all(8),
          child: ListTile(
            leading: const Icon(Icons.apartment, color: Colors.purple),
            title: Text(condo['nome']),
            subtitle: Text(condo['id']),
            trailing: IconButton(
              icon: const Icon(Icons.person_add),
              tooltip: "Criar Síndico para este condomínio",
              onPressed: () => _criarSindico(condo['id']),
            ),
          ),
        );
      },
    );
  }

  Widget _buildListaLogs() {
    if (_logs.isEmpty) return const Center(child: Text("Sem logs."));
    return ListView.builder(
      itemCount: _logs.length,
      itemBuilder: (ctx, i) {
        final log = _logs[i];
        return ListTile(
          title: Text(log['acao']),
          subtitle: Text("${log['data_hora']} - Condomínio/Portão: ${log['portao_id']}"),
          leading: Icon(Icons.history, size: 16),
        );
      },
    );
  }
}