import 'package:flutter/material.dart';
import '../../../injection_container.dart';
import '../data/usuarios_service.dart';

class CadastroMoradorScreen extends StatefulWidget {
  const CadastroMoradorScreen({super.key});

  @override
  State<CadastroMoradorScreen> createState() => _CadastroMoradorScreenState();
}

class _CadastroMoradorScreenState extends State<CadastroMoradorScreen> {
  final _nomeCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _senhaCtrl = TextEditingController();
  bool _loading = false;

  void _salvar() async {
    if (_nomeCtrl.text.isEmpty || _emailCtrl.text.isEmpty || _senhaCtrl.text.isEmpty) return;
    
    setState(() => _loading = true);
    try {
      await sl<UsuariosService>().cadastrarMorador(
        _nomeCtrl.text, _emailCtrl.text, _senhaCtrl.text
      );
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Morador criado!"), backgroundColor: Colors.green));
        Navigator.pop(context); // Volta
      }
    } catch (e) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
      }
    } finally {
      if(mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Novo Morador")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: _nomeCtrl, decoration: const InputDecoration(labelText: "Nome Completo", border: OutlineInputBorder())),
            const SizedBox(height: 15),
            TextField(controller: _emailCtrl, decoration: const InputDecoration(labelText: "Email", border: OutlineInputBorder())),
            const SizedBox(height: 15),
            TextField(controller: _senhaCtrl, decoration: const InputDecoration(labelText: "Senha Provisória", border: OutlineInputBorder())),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _loading ? null : _salvar,
                child: _loading ? const CircularProgressIndicator() : const Text("CADASTRAR"),
              ),
            )
          ],
        ),
      ),
    );
  }
}