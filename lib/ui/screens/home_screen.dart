import 'package:app_control/ui/screens/ventas_screen.dart';
import 'package:app_control/ui/screens/inventario_screen.dart';
import 'package:app_control/ui/screens/reportes_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Lista de pantallas principales
  final List<Widget> _screens = [
    const NuevaVentaScreen(),
    const InventarioScreen(),
    const ReportesScreen(),
  ];

  @override
  // ignore: non_constant_identifier_names
  Widget build(BuildContext Size) {
    return Scaffold(
      body: Row(
        children: [
          // Barra de navegación lateral ideal para Desktop
          NavigationRail(
            selectedIndex: _selectedIndex,
            labelType: NavigationRailLabelType.all,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.add_shopping_cart),
                label: Text('Nueva Venta'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.inventory),
                label: Text('Inventario'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.bar_chart),
                label: Text('Reportes'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          // Contenido principal de la aplicación
          Expanded(
            child: Container(
              color: Colors.grey[50],
              child: _screens[_selectedIndex],
            ),
          ),
        ],
      ),
    );
  }
}
