import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/producto_model.dart';
import '../../data/models/venta_model.dart';
import '../../data/models/detalle_venta_model.dart';
import '../../blocs/venta/venta_bloc.dart';
import '../../blocs/venta/venta_event.dart';
import '../../blocs/venta/venta_state.dart';
import '../../blocs/producto/producto_bloc.dart';
import '../../blocs/producto/producto_event.dart';
import '../../blocs/producto/producto_state.dart';

class NuevaVentaScreen extends StatefulWidget {
  const NuevaVentaScreen({super.key});

  @override
  State<NuevaVentaScreen> createState() => _NuevaVentaScreenState();
}

class _NuevaVentaScreenState extends State<NuevaVentaScreen> {
  final _clienteController = TextEditingController();
  final _observacionController = TextEditingController();

  final List<String> _formasPago = [
    'Efectivo',
    'Transferencia',
    'Depósito',
    'En factura',
    'Cortesía',
  ];
  String _formaPagoSeleccionada = 'Efectivo';

  final List<DetalleVentaModel> _carrito = [];
  double _totalVenta = 0.0;

  @override
  void initState() {
    super.initState();
    context.read<ProductoBloc>().add(CargarProductosEvent());
  }

  void _agregarAlCarrito(ProductoModel producto) {
    if (producto.cantidad <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El producto no tiene stock disponible'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      int index =
          _carrito.indexWhere((item) => item.productoId == producto.id);
      if (index >= 0) {
        if (_carrito[index].cantidad < producto.cantidad) {
          _carrito[index] = DetalleVentaModel(
            productoId: producto.id!,
            nombreProducto: producto.nombre,
            cantidad: _carrito[index].cantidad + 1,
            precioUnitario: producto.precio,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No hay más stock disponible para este producto'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      } else {
        _carrito.add(
          DetalleVentaModel(
            productoId: producto.id!,
            nombreProducto: producto.nombre,
            cantidad: 1,
            precioUnitario: producto.precio,
          ),
        );
      }
      _calcularTotal();
    });
  }

  void _eliminarDelCarrito(int productoId) {
    setState(() {
      _carrito.removeWhere((item) => item.productoId == productoId);
      _calcularTotal();
    });
  }

  void _calcularTotal() {
    _totalVenta = _carrito.fold(
      0,
      (sum, item) => sum + (item.cantidad * item.precioUnitario),
    );
  }

  void _limpiarFormulario() {
    setState(() {
      _clienteController.clear();
      _observacionController.clear();
      _carrito.clear();
      _totalVenta = 0.0;
      _formaPagoSeleccionada = 'Efectivo';
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<VentaBloc, VentaState>(
      listener: (context, state) {
        if (state is VentaSuccessState) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('¡Venta registrada con éxito y stock actualizado!'),
              backgroundColor: Colors.green,
            ),
          );
          _limpiarFormulario();
          context.read<ProductoBloc>().add(CargarProductosEvent());
        } else if (state is VentaErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error), backgroundColor: Colors.red),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // PANEL IZQUIERDO: Catálogo de Productos
            Expanded(
              flex: 4,
              child: Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Productos Disponibles',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: BlocBuilder<ProductoBloc, ProductoState>(
                          builder: (context, state) {
                            if (state is ProductoLoadingState) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            } else if (state is ProductosCargadosState) {
                              if (state.productos.isEmpty) {
                                return const Center(
                                  child: Text('No hay productos disponibles'),
                                );
                              }
                              return ListView.builder(
                                itemCount: state.productos.length,
                                itemBuilder: (context, index) {
                                  final prod = state.productos[index];
                                  return ListTile(
                                    title: Text(prod.nombre),
                                    subtitle: Text(
                                      'Stock: ${prod.cantidad} unidades | \$${prod.precio.toStringAsFixed(2)}',
                                    ),
                                    trailing: IconButton(
                                      icon: const Icon(
                                        Icons.add_circle,
                                        color: Colors.blue,
                                      ),
                                      onPressed: prod.cantidad > 0
                                          ? () => _agregarAlCarrito(prod)
                                          : null,
                                    ),
                                  );
                                },
                              );
                            } else if (state is ProductoErrorState) {
                              return Center(
                                child: Text('Error: ${state.error}'),
                              );
                            }
                            return const Center(
                              child: Text('Cargando productos...'),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // PANEL DERECHO: Formulario de Checkout y Carrito
            Expanded(
              flex: 5,
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Detalle de la Venta',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      // Campos del Cliente y Transacción
                      TextField(
                        controller: _clienteController,
                        decoration: const InputDecoration(
                          labelText: 'Nombre del Cliente *',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: _formaPagoSeleccionada,
                        decoration: const InputDecoration(
                          labelText: 'Forma de Pago',
                          border: OutlineInputBorder(),
                        ),
                        items: _formasPago
                            .map(
                              (forma) => DropdownMenuItem(
                                value: forma,
                                child: Text(forma),
                              ),
                            )
                            .toList(),
                        onChanged: (val) =>
                            setState(() => _formaPagoSeleccionada = val!),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _observacionController,
                        decoration: const InputDecoration(
                          labelText: 'Observación (Opcional)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Items Seleccionados:',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const Divider(),
                      // Tabla o Lista del Carrito Actual
                      Expanded(
                        child: _carrito.isEmpty
                            ? const Center(
                              child: Text(
                                'El carrito está vacío',
                                style: TextStyle(color: Colors.grey),
                              ),
                            )
                            : ListView.builder(
                              itemCount: _carrito.length,
                              itemBuilder: (context, index) {
                                final item = _carrito[index];
                                return ListTile(
                                  dense: true,
                                  title: Text(
                                    item.nombreProducto ?? 'Producto',
                                  ),
                                  subtitle: Text(
                                    '${item.cantidad}x \$${item.precioUnitario.toStringAsFixed(2)}',
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '\$${(item.cantidad * item.precioUnitario).toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.remove_circle,
                                          color: Colors.red,
                                        ),
                                        onPressed: () =>
                                            _eliminarDelCarrito(item.productoId),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                      ),
                      const Divider(),
                      // Resumen Final y Botón de Envío
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'TOTAL:',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '\$${_totalVenta.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.point_of_sale),
                          label: const Text(
                            'Procesar y Guardar Venta',
                            style: TextStyle(fontSize: 16),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            if (_clienteController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'El nombre del cliente es obligatorio.',
                                  ),
                                ),
                              );
                              return;
                            }
                            if (_carrito.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Debe agregar al menos un producto al carrito.',
                                  ),
                                ),
                              );
                              return;
                            }

                            final nuevaVenta = VentaModel(
                              fecha: DateTime.now(),
                              total: _totalVenta,
                              nombreCliente:
                                  _clienteController.text.trim(),
                              formaPago: _formaPagoSeleccionada,
                              observacion:
                                  _observacionController.text.trim().isEmpty
                                      ? null
                                      : _observacionController.text.trim(),
                              productos: _carrito,
                            );

                            context.read<VentaBloc>().add(
                              RealizarVentaEvent(nuevaVenta),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _clienteController.dispose();
    _observacionController.dispose();
    super.dispose();
  }
}
