import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sistema_portoes_app/features/usuarios/ui/lista_moradores_screen.dart';
import 'features/portoes/ui/portoes_screen.dart';
import 'features/logs/ui/logs_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _isAdmin = false;
  
  static final List<Widget> _telas = <Widget>[
    const PortoesScreen(), // Index 0
    const LogsScreen(),    // Index 1
  ];

  @override
  void initState() {
    super.initState();
    _verificarPermissao();
  }

  Future<void> _verificarPermissao() async {
    final prefs = await SharedPreferences.getInstance();
    final tipo = prefs.getString('user_type');
    setState(() {
      _isAdmin = tipo == 'admin' || tipo == 'super_admin';
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _telas.elementAt(_selectedIndex),
      
      // Só mostra se for Admin
      floatingActionButton: _isAdmin && _selectedIndex == 1
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ListaMoradoresScreen()),
                );
              },
              label: const Text("Gerir Morador"),
              icon: const Icon(Icons.people_alt),
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            )
          : null,
      // -----------------------------------

      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: const <NavigationDestination>[
          NavigationDestination(
            icon: Icon(Icons.garage_outlined),
            selectedIcon: Icon(Icons.garage),
            label: 'Portões',
          ),
          NavigationDestination(
            icon: Icon(Icons.list_alt_outlined),
            selectedIcon: Icon(Icons.list_alt),
            label: 'Histórico',
          ),
        ],
      ),
    );
  }
}