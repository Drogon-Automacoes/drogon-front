import 'package:flutter/material.dart';
import '../../../injection_container.dart';
import '../../auth/data/user_model.dart';
import '../../auth/data/auth_service.dart';
import '../data/usuarios_service.dart';
import 'cadastro_morador_screen.dart';

class ListaMoradoresScreen extends StatefulWidget {
  const ListaMoradoresScreen({super.key});

  @override
  State<ListaMoradoresScreen> createState() => _ListaMoradoresScreenState();
}

class _ListaMoradoresScreenState extends State<ListaMoradoresScreen> {
  List<UserModel> _moradores = [];
  bool _isLoading = true;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _carregarTudo();
  }

  void _carregarTudo() async {
    setState(() => _isLoading = true);
    try {
      final me = await sl<AuthService>().getUserMe();
      _currentUserId = me.id;

      final lista = await sl<UsuariosService>().getMoradores();
      
      setState(() {
        _moradores = lista;
      });
    } catch (e) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Erro ao carregar lista")));
    } finally {
      if(mounted) setState(() => _isLoading = false);
    }
  }

  void _toggleBloqueio(UserModel user) async {
    final vaiBloquear = user.ativo; 
    final textoAcao = vaiBloquear ? "BLOQUEADO" : "DESBLOQUEADO";
    final corAcao = vaiBloquear ? Colors.red : Colors.green;

    try {
      await sl<UsuariosService>().toggleBloqueio(user.id);
      
      // Feedback Visual
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Usuário ${user.nome} foi $textoAcao com sucesso."), 
            backgroundColor: corAcao,
            duration: const Duration(seconds: 2),
          )
        );
      }
      
      _carregarTudo();
      
    } catch (e) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Erro ao alterar status")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Gestão de Moradores")),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => const CadastroMoradorScreen()));
          _carregarTudo();
        },
        child: const Icon(Icons.add),
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator()) 
          : _moradores.isEmpty 
              ? const Center(child: Text("Nenhum usuário encontrado."))
              : ListView.separated(
                  itemCount: _moradores.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (ctx, i) {
                    final morador = _moradores[i];
                    final souEu = morador.id == _currentUserId;
                    final ehAdmin = morador.tipo == 'admin' || morador.tipo == 'super_admin';
                    
                    final podeBloquear = !souEu && !ehAdmin;

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: morador.ativo ? Colors.blue : Colors.grey,
                        child: Icon(morador.ativo ? Icons.person : Icons.person_off, color: Colors.white),
                      ),
                      title: Text(
                        morador.nome, 
                        style: TextStyle(
                          decoration: morador.ativo ? null : TextDecoration.lineThrough,
                          color: morador.ativo ? Colors.black : Colors.grey,
                          fontWeight: FontWeight.w500
                        )
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(morador.email),
                          if (ehAdmin) 
                            const Text("ADMINISTRADOR", style: TextStyle(fontSize: 10, color: Colors.orange, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      trailing: Switch(
                        value: morador.ativo,
                        activeColor: Colors.green,
                        inactiveThumbColor: Colors.red,
                        onChanged: podeBloquear 
                            ? (val) => _toggleBloqueio(morador)
                            : null, 
                      ),
                    );
                  },
                ),
    );
  }
}