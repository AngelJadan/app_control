import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

// Importa tus blocs y repositorios
import 'repositories/venta_repository.dart';
import 'repositories/producto_repository.dart';
import 'blocs/venta/venta_bloc.dart';
import 'blocs/producto/producto_bloc.dart';
import 'ui/screens/home_screen.dart';

void main() {
  // Inicialización requerida para SQLite en Windows/Linux Desktop
  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Proveemos el BLoC globalmente a toda la aplicación
    return MultiBlocProvider(
      providers: [
        BlocProvider<VentaBloc>(
          create: (context) => VentaBloc(VentaRepository()),
        ),
        BlocProvider<ProductoBloc>(
          create: (context) => ProductoBloc(ProductoRepository()),
        ),
      ],
      // CRUCIAL: MaterialApp introduce el widget 'Directionality' automáticamente
      child: MaterialApp(
        title: 'Control de Inventario y Ventas',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed:
              Colors.blue, // Define el color base de tu app desktop
        ),
        home: const HomeScreen(), // Tu pantalla principal con el NavigationRail
      ),
    );
  }
}
