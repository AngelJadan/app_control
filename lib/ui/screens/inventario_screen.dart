import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/producto/producto_bloc.dart';
import '../../blocs/producto/producto_event.dart';
import '../../blocs/producto/producto_state.dart';
import '../../data/models/producto_model.dart';

class InventarioScreen extends StatefulWidget {
  const InventarioScreen({super.key});

  @override
  State<InventarioScreen> createState() => _InventarioScreenState();
}

class _InventarioScreenState extends State<InventarioScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ProductoBloc>().add(CargarProductosEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Gestión de Inventario',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              ElevatedButton.icon(
                onPressed: () => _mostrarDialogoCrearProducto(context),
                icon: const Icon(Icons.add),
                label: const Text('Nuevo Producto'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: BlocListener<ProductoBloc, ProductoState>(
              listener: (context, state) {
                if (state is ProductoOperacionExitoState) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.mensaje),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else if (state is ProductoErrorState) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.error),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: BlocBuilder<ProductoBloc, ProductoState>(
                builder: (context, state) {
                  if (state is ProductoLoadingState) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is ProductosCargadosState) {
                    if (state.productos.isEmpty) {
                      return const Center(
                        child: Text('No hay productos en el inventario'),
                      );
                    }
                    return _buildProductosTable(context, state.productos);
                  } else if (state is ProductoErrorState) {
                    return Center(child: Text('Error: ${state.error}'));
                  } else {
                    return const Center(child: Text('Cargando productos...'));
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductosTable(
    BuildContext context,
    List<ProductoModel> productos,
  ) {
    return SingleChildScrollView(
      child: Card(
        elevation: 2,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('ID')),
            DataColumn(label: Text('Nombre')),
            DataColumn(label: Text('Precio')),
            DataColumn(label: Text('Stock')),
            DataColumn(label: Text('Descripción')),
            DataColumn(label: Text('Acciones')),
          ],
          rows: productos
              .map((producto) => DataRow(cells: [
                    DataCell(Text(producto.id.toString())),
                    DataCell(Text(producto.nombre)),
                    DataCell(Text('\$${producto.precio.toStringAsFixed(2)}')),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: producto.cantidad < 10
                              ? Colors.red.shade100
                              : Colors.green.shade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          producto.cantidad.toString(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: producto.cantidad < 10
                                ? Colors.red
                                : Colors.green,
                          ),
                        ),
                      ),
                    ),
                    DataCell(Text(producto.descripcion ?? '-')),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.add_box, color: Colors.blue),
                            tooltip: 'Aumentar Stock',
                            onPressed: () =>
                                _mostrarDialogoAumentarStock(context, producto),
                          ),
                          IconButton(
                            icon:
                                const Icon(Icons.edit, color: Colors.orange),
                            tooltip: 'Editar',
                            onPressed: () =>
                                _mostrarDialogoEditarProducto(context, producto),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            tooltip: 'Eliminar',
                            onPressed: () =>
                                _confirmarEliminar(context, producto),
                          ),
                        ],
                      ),
                    ),
                  ]))
              .toList(),
        ),
      ),
    );
  }

  void _mostrarDialogoCrearProducto(BuildContext context) {
    final nombreController = TextEditingController();
    final precioController = TextEditingController();
    final cantidadController = TextEditingController();
    final descripcionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Crear Nuevo Producto'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del Producto *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: precioController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Precio *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: cantidadController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Cantidad Inicial *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descripcionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción (Opcional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () {
              if (nombreController.text.isEmpty ||
                  precioController.text.isEmpty ||
                  cantidadController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Por favor completa los campos requeridos'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              final producto = ProductoModel(
                nombre: nombreController.text.trim(),
                precio: double.parse(precioController.text),
                cantidad: int.parse(cantidadController.text),
                descripcion: descripcionController.text.trim().isEmpty
                    ? null
                    : descripcionController.text.trim(),
              );

              context.read<ProductoBloc>().add(CrearProductoEvent(producto));
              Navigator.pop(context);
            },
            child: const Text('Crear'),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoAumentarStock(
    BuildContext context,
    ProductoModel producto,
  ) {
    final cantidadController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Aumentar Stock'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Producto: ${producto.nombre}'),
            Text('Stock Actual: ${producto.cantidad}'),
            const SizedBox(height: 12),
            TextField(
              controller: cantidadController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Cantidad a Agregar *',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            onPressed: () {
              if (cantidadController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Ingresa la cantidad'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              context.read<ProductoBloc>().add(
                    AumentarStockEvent(
                      productoId: producto.id!,
                      cantidadASumar: int.parse(cantidadController.text),
                    ),
                  );
              Navigator.pop(context);
            },
            child: const Text('Aumentar'),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoEditarProducto(
    BuildContext context,
    ProductoModel producto,
  ) {
    final nombreController = TextEditingController(text: producto.nombre);
    final precioController =
        TextEditingController(text: producto.precio.toString());
    final descripcionController =
        TextEditingController(text: producto.descripcion);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Producto'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del Producto *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: precioController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Precio *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descripcionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción (Opcional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: () {
              if (nombreController.text.isEmpty ||
                  precioController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Por favor completa los campos requeridos'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              final productoActualizado = ProductoModel(
                id: producto.id,
                nombre: nombreController.text.trim(),
                precio: double.parse(precioController.text),
                cantidad: producto.cantidad,
                descripcion: descripcionController.text.trim().isEmpty
                    ? null
                    : descripcionController.text.trim(),
              );

              context
                  .read<ProductoBloc>()
                  .add(EditarProductoEvent(productoActualizado));
              Navigator.pop(context);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _confirmarEliminar(BuildContext context, ProductoModel producto) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Eliminación'),
        content: Text(
          '¿Estás seguro de que deseas eliminar el producto "${producto.nombre}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              context
                  .read<ProductoBloc>()
                  .add(EliminarProductoEvent(producto.id!));
              Navigator.pop(context);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
